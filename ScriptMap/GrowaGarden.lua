-- รอให้เกมโหลดสมบูรณ์
repeat task.wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LOCAL_PLAYER = Players.LocalPlayer
local PLACE_ID = game.PlaceId
local CURRENT_VERSION = game.PlaceVersion
local MAX_VERSION = 1233
local ENABLE_RAM_LOG = false -- ตัวแปรควบคุมการเปิด/ปิด Log ของ RAM (true = เปิด, false = ปิด)

print("📌 Current Game Version:", CURRENT_VERSION)

-- ✅ ถ้าเวอร์ชันนี้ไม่เกิน MAX → ไม่ต้องทำอะไร
if CURRENT_VERSION <= MAX_VERSION then
    print("✅ You're already in an acceptable version (" .. CURRENT_VERSION .. ").")
else
    -- 🌀 ถ้าเวอร์ชันนี้สูงเกิน → เริ่มหาเซิร์ฟใหม่
    print("🔍 Version is", CURRENT_VERSION, "which is > " .. MAX_VERSION .. ". Hopping to better server...")
end

-- สร้าง Folder ใน Executor Storage
local function createExecutorFolder(folderName)
    if isfolder then
        if not isfolder(folderName) then
            makefolder(folderName)
            print("📁 Created folder in Executor storage: " .. folderName)
        else
            print("📁 Folder already exists in Executor storage: " .. folderName)
        end
    else
        warn("⚠️ Executor does not support folder creation. Using default behavior.")
    end
end

-- อ่าน Job IDs จากไฟล์
local function readJobIds(fileName)
    if isfile and readfile then
        if isfile(fileName) then
            local content = readfile(fileName)
            local jobIds = {}
            for jobId in content:gmatch("[^\n]+") do
                table.insert(jobIds, jobId)
            end
            return jobIds
        end
    end
    return {}
end

-- เขียน Job ID ลงไฟล์
local function writeJobId(fileName, jobId)
    if writefile and isfile then
        local jobIds = readJobIds(fileName)
        for _, id in ipairs(jobIds) do
            if id == jobId then
                return -- Job ID มีอยู่แล้ว
            end
        end
        table.insert(jobIds, jobId)
        writefile(fileName, table.concat(jobIds, "\n"))
        print("📝 Added to " .. fileName .. ": " .. jobId)
    else
        warn("⚠️ Executor does not support file writing. Cannot save " .. fileName .. ".")
    end
end

-- สร้าง Folder และกำหนดไฟล์สำหรับ ServerBlacklist และ AcceptedServers
createExecutorFolder("ServerHopData")
local BLACKLIST_FILE = "ServerHopData/ServerBlacklist.txt"
local ACCEPTED_FILE = "ServerHopData/AcceptedServers.txt"

-- โหลด RAMAccount
local RAMAccount
local success, err = pcall(function()
    RAMAccount = loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua'))()
end)
if not success then
    warn("[ERROR] Failed to load RAMAccount: " .. tostring(err))
    RAMAccount = { new = function() return { SetAlias = function() end, SetDescription = function() end } end }
end

-- สร้าง MyAccount
local MyAccount
success, err = pcall(function()
    MyAccount = RAMAccount.new(game:GetService("Players").LocalPlayer.Name)
end)
if not success or not MyAccount then
    warn("[ERROR] Failed to initialize MyAccount: " .. tostring(err))
    MyAccount = RAMAccount.new("DefaultUser")
end

-- บันทึก JobId ปัจจุบันลง ServerBlacklist
local function saveCurrentServer()
    local currentJobId = game.JobId
    if currentJobId and currentJobId ~= "" then
        writeJobId(BLACKLIST_FILE, currentJobId)
    end
end

-- บันทึก JobId ของเซิร์ฟเวอร์ที่เวอร์ชัน <= 1233
local function saveAcceptedServer(serverId, version)
    if serverId and serverId ~= "" then
        writeJobId(ACCEPTED_FILE, serverId .. " (Version: " .. version .. ")")
    end
end

-- ตรวจสอบว่า JobId นี้อยู่ใน blacklist หรือไม่
local function isServerBlacklisted(jobId)
    local blacklisted = readJobIds(BLACKLIST_FILE)
    for _, id in ipairs(blacklisted) do
        if id == jobId then
            return true
        end
    end
    return false
end

-- ตรวจสอบว่า JobId นี้อยู่ใน AcceptedServers หรือไม่
local function isServerAccepted(jobId)
    local accepted = readJobIds(ACCEPTED_FILE)
    for _, id in ipairs(accepted) do
        if id:match(jobId) then
            return true
        end
    end
    return false
end

-- ⭐ random delay ป้องกัน rate limit
local function smartWait(minTime, maxTime)
    local delayTime = math.random(minTime * 100, maxTime * 100) / 100
    wait(delayTime)
end

-- ⭐ ขอ server list จาก Roblox API
local function getPublicServers(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PLACE_ID)
    if cursor then
        url = url .. "&cursor=" .. cursor
    end

    smartWait(2, 4) -- wait ป้องกัน rate limit

    local success, result = pcall(function()
        local raw = game:HttpGet(url)
        return HttpService:JSONDecode(raw)
    end)

    if success then
        if result and result.data then
            return result
        elseif result.errors then
            for _, err in ipairs(result.errors) do
                if err.message == "Too many requests" then
                    warn("⚠️ Rate limit hit. Waiting 15s before retry...")
                    wait(15)
                    return nil
                end
            end
        end
    else
        warn("❌ Error fetching servers:", result)
    end

    wait(3)
    return nil
end

-- ⭐ teleport ไปเซิร์ฟใหม่
local function teleportToServer(serverId)
    print("🚀 Teleporting to:", serverId)
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, serverId, LOCAL_PLAYER)
    end)
    if not success then
        warn("❌ Failed to teleport to " .. serverId .. ": " .. tostring(err))
        return false
    end
    return true
end

-- ลองเข้าร่วมเซิร์ฟเวอร์จาก AcceptedServers
local function tryJoinAcceptedServers()
    local acceptedList = readJobIds(ACCEPTED_FILE)
    if #acceptedList == 0 then
        print("📂 No servers in AcceptedServers to try. Proceeding to find new servers...")
        return false
    end

    print("🔎 Attempting to join servers from AcceptedServers...")
    for _, jobIdEntry in ipairs(acceptedList) do
        local serverId = jobIdEntry:match("^(.-)%s%(") -- ดึง Job ID จากรูปแบบ "jobId (Version: 1233)"
        if serverId then
            print("🔍 Trying to join accepted server: " .. serverId)
            local success = teleportToServer(serverId)
            if success then
                print("✅ Successfully joined accepted server: " .. serverId)
                wait(10)
                return true
            else
                print("⛔ Could not join accepted server: " .. serverId .. ". Trying next...")
                wait(5)
            end
        end
    end

    print("❌ All servers in AcceptedServers are unavailable. Finding new servers...")
    return false
end

-- 🔁 วนหา server ที่ version ต่ำกว่าและไม่ซ้ำ
local function findAndHop()
    -- บันทึกเซิร์ฟเวอร์ปัจจุบันก่อนเริ่ม hop
    saveCurrentServer()
    local cursor = nil

    while true do
        local data = getPublicServers(cursor)
        if data and data.data then
            for _, server in ipairs(data.data) do
                if server.id and not isServerBlacklisted(server.id) then
                    local ver = server.version or 0
                    local playing = server.playing or 0
                    local maxPlayers = server.maxPlayers or 1

                    print(string.format("🧩 Server: %s | Version: %d | Players: %d", server.id, ver, playing))

                    if ver <= MAX_VERSION and playing < maxPlayers then
                        -- บันทึก JobId ลง AcceptedServers
                        saveAcceptedServer(server.id, ver)
                        -- เพิ่ม JobId ลง blacklist เฉพาะเมื่อไม่ได้อยู่ใน AcceptedServers
                        if not isServerAccepted(server.id) then
                            writeJobId(BLACKLIST_FILE, server.id)
                        end
                        teleportToServer(server.id)
                        wait(10)
                    end
                else
                    if server.id then
                        print("⛔ Skipped server (already visited):", server.id)
                    end
                end
            end

            cursor = data.nextPageCursor
            if not cursor then
                print("🔁 End of list. Restarting search...")
                smartWait(4, 6)
                cursor = nil
            end
        else
            print("⚠️ No server list received. Waiting...")
            smartWait(10, 15)
        end
    end
end

-- ฟังก์ชัน log กระชับ
local function log(type, message, isRAMLog)
    if isRAMLog and not ENABLE_RAM_LOG then return end -- ข้าม Log ของ RAM ถ้าปิดอยู่
    local timeStr = os.date("%H:%M:%S")
    if type == "info" then
        print("["..timeStr.."] ℹ️ " .. message)
    elseif type == "error" then
        warn("["..timeStr.."] ❌ " .. message)
    elseif type == "debug" then
        print("["..timeStr.."] 🔍 " .. message)
    end
end

-- ฟังก์ชันแปลงเลขเงินให้เป็นตัวย่อ
local function FormatMoney(value)
    value = tonumber(value) or 0
    if value >= 1e12 then
        return string.format("%.2fT", value / 1e12)
    elseif value >= 1e9 then
        return string.format("%.2fB", value / 1e9)
    elseif value >= 1e6 then
        return string.format("%.2fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.2fk", value / 1e3)
    else
        return tostring(value)
    end
end

-- ฟังก์ชันทำความสะอาดชื่อไอเทม
local function CleanItemName(itemName)
    -- ตัดส่วนที่มี [ ] ออก เช่น "Shovel [Destroy Plants]" -> "Shovel"
    local cleanedName = itemName:match("^[^%[]+"):gsub("%s+$", "")
    -- แปลงเป็น lowercase และตัดช่องว่างหรือขีดเส้นใต้
    return cleanedName:lower():gsub("[_%s]+", "")
end

-- ฟังก์ชันดึงข้อมูลไอเทมที่ต้องการ
local function GetTargetItemsSummary()
    local summary = {}
    local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
    if not backpack then
        log("error", "No Backpack found", true)
        return "No Items"
    end

    -- ดีบัก: แสดงไอเทมทั้งหมดใน Backpack (ชื่อดิบ)
    log("debug", "Raw items in Backpack:", true)
    for _, item in ipairs(backpack:GetChildren()) do
        log("debug", "- " .. item.Name, true)
    end

    -- รายการไอเทมที่ต้องการ
    local targetItems = {"Candy Blossom Seed", "Night Seed Pack", "Night Egg", "Bug Egg"}
    local targetSet = {}
    for _, target in ipairs(targetItems) do
        targetSet[CleanItemName(target)] = true
    end

    -- ดีบัก: แสดงรายการเป้าหมายหลังทำความสะอาด
    log("debug", "Target items (cleaned):", true)
    for target, _ in pairs(targetSet) do
        log("debug", "- " .. target, true)
    end

    -- ตรวจสอบไอเทมใน Backpack ด้วยการค้นหาคำย่อย
    for _, item in ipairs(backpack:GetChildren()) do
        local cleanedName = CleanItemName(item.Name)
        log("debug", "Checking item: " .. item.Name .. " (cleaned: " .. cleanedName .. ")", true)
        for targetCleaned in pairs(targetSet) do
            if cleanedName:find(targetCleaned) or targetCleaned:find(cleanedName) then
                local amount = ""
                if item:FindFirstChild("Amount") and tonumber(item.Amount.Value) then
                    amount = " x" .. tostring(item.Amount.Value)
                elseif item:FindFirstChild("Value") and tonumber(item.Value.Value) then
                    amount = " x" .. tostring(item.Value.Value)
                end
                table.insert(summary, item.Name .. amount)
                log("debug", "Found item: " .. item.Name .. amount, true)
                break -- หยุดการตรวจสอบเมื่อพบการจับคู่
            end
        end
    end

    if #summary == 0 then
        return "No Candy Blossom Seed, Night Seed Pack, Night Egg, or Bug Egg"
    end
    return table.concat(summary, ", ")
end

-- วนลูปหลักเพื่ออัปเดต RAMAccount
local function startRAMUpdateLoop()
    log("info", "Starting RAM update loop", true)
    while true do
        -- ดึงข้อมูลเงิน
        local sheckles = 0
        local leaderstats = game:GetService("Players").LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:FindFirstChild("Sheckles") then
            sheckles = leaderstats.Sheckles.Value
        else
            log("error", "Sheckles not found in leaderstats", true)
        end
        local formatted_money = FormatMoney(sheckles)

        -- ดึงข้อมูลไอเทมที่ต้องการ
        local items_summary = GetTargetItemsSummary()

        -- อัปเดต RAMAccount
        local update_success, update_err = pcall(function()
            MyAccount:SetAlias("Money: " .. formatted_money)
            MyAccount:SetDescription(items_summary)
        end)

        if update_success then
            log("info", "RAMAccount updated - Money: " .. formatted_money .. ", Items: " .. items_summary, true)
        else
            log("error", "Failed to update RAMAccount: " .. tostring(update_err), true)
        end

        task.wait(60) -- อัปเดตทุก 1 นาที
    end
end

-- Main Execution
if CURRENT_VERSION > MAX_VERSION then
    -- ลองเข้าร่วมเซิร์ฟเวอร์จาก AcceptedServers ก่อน
    local joined = tryJoinAcceptedServers()
    if not joined then
        task.spawn(findAndHop)
    end
else
    -- บันทึก JobId ปัจจุบันลง AcceptedServers หากเวอร์ชัน <= 1233
    saveAcceptedServer(game.JobId, CURRENT_VERSION)
end
task.spawn(startRAMUpdateLoop) -- เริ่มลูป RAM เสมอ