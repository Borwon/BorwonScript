-- Configuration
local CONFIG = {
    MAX_VERSION = 1233,              -- Maximum acceptable game version
    ENABLE_RAM_LOG = false,          -- Enable/disable RAM logging (true = on, false = off)
    ENABLE_ACCEPTED_SERVER_JOIN = false, -- Enable/disable joining servers from AcceptedServers (true = on, false = off)
    ENABLE_SERVER_HOP = false         -- Enable/disable server hopping entirely (true = on, false = off)
}

-- Service Initialization
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LOCAL_PLAYER = Players.LocalPlayer
local PLACE_ID = game.PlaceId
local CURRENT_VERSION = game.PlaceVersion

print("📌 Current Game Version:", CURRENT_VERSION)

if CURRENT_VERSION <= CONFIG.MAX_VERSION then
    print("✅ You're already in an acceptable version (" .. CURRENT_VERSION .. ").")
else
    print("🔍 Version is " .. CURRENT_VERSION .. " which is > " .. CONFIG.MAX_VERSION .. ". Hopping to better server...")
end

-- Utility Functions
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

local function readJobIds(fileName)
    if isfile and readfile then
        if isfile(fileName) then
            local content = readfile(fileName)
            local jobIds = {}
            for jobId in content:gmatch("[^\n]+") do
                -- Only extract the base jobId (before any space or parenthesis)
                local baseId = jobId:match("^(.-)%s*%(") or jobId
                table.insert(jobIds, baseId)
            end
            return jobIds
        end
    end
    return {}
end

local function writeJobId(fileName, jobId)
    if writefile and isfile then
        local jobIds = readJobIds(fileName)
        local baseJobId = jobId:match("^(.-)%s*%(") or jobId
        local isDuplicate = false
        for _, id in ipairs(jobIds) do
            if id == baseJobId then
                isDuplicate = true
                break
            end
        end
        if not isDuplicate then
            -- Only store the base jobId for blacklist, but keep full info for accepted servers
            if fileName:find("Blacklist") then
                table.insert(jobIds, baseJobId)
                writefile(fileName, table.concat(jobIds, "\n"))
                print("📝 Added to " .. fileName .. ": " .. baseJobId)
            else
                table.insert(jobIds, jobId)
                writefile(fileName, table.concat(jobIds, "\n"))
                print("📝 Added to " .. fileName .. ": " .. jobId)
            end
        else
            print("ℹ️ Skipped duplicate in " .. fileName .. ": " .. baseJobId)
        end
    else
        warn("⚠️ Executor does not support file writing. Cannot save " .. fileName .. ".")
    end
end

local function smartWait(minTime, maxTime)
    local delayTime = math.random(minTime * 100, maxTime * 100) / 100
    wait(delayTime)
end

local function log(type, message, isRAMLog)
    if isRAMLog and not CONFIG.ENABLE_RAM_LOG then return end
    local timeStr = os.date("%H:%M:%S")
    if type == "info" then
        print("[" .. timeStr .. "] ℹ️ " .. message)
    elseif type == "error" then
        warn("[" .. timeStr .. "] ❌ " .. message)
    elseif type == "debug" then
        print("[" .. timeStr .. "] 🔍 " .. message)
    end
end

local function formatMoney(value)
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

local function cleanItemName(itemName)
    local cleanedName = itemName:match("^[^%[]+"):gsub("%s+$", "")
    return cleanedName:lower():gsub("[_%s]+", "")
end

-- Core Functions
local function saveCurrentServer()
    local currentJobId = game.JobId
    if currentJobId and currentJobId ~= "" then
        writeJobId("ServerHopData/ServerBlacklist.txt", currentJobId)
        print("📝 Saved current server to Blacklist: " .. currentJobId)
    else
        warn("❌ Failed to get current JobId for Blacklist.")
    end
end

local function saveAcceptedServer(serverId, version)
    if serverId and serverId ~= "" then
        writeJobId("ServerHopData/AcceptedServers.txt", serverId .. " (Version: " .. version .. ")")
        print("📝 Saved accepted server: " .. serverId .. " (Version: " .. version .. ")")
    end
end

local function isServerBlacklisted(jobId)
    local blacklisted = readJobIds("ServerHopData/ServerBlacklist.txt")
    for _, id in ipairs(blacklisted) do
        if id == jobId then
            print("🔍 Server " .. jobId .. " is blacklisted.")
            return true
        end
    end
    print("🔍 Server " .. jobId .. " is not blacklisted.")
    return false
end

local function isServerAccepted(jobId)
    local accepted = readJobIds("ServerHopData/AcceptedServers.txt")
    for _, id in ipairs(accepted) do
        if id == jobId then
            return true
        end
    end
    return false
end

local function getPublicServers(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PLACE_ID)
    if cursor then url = url .. "&cursor=" .. cursor end

    smartWait(2, 4)

    local success, result = pcall(function()
        local raw = game:HttpGet(url)
        return HttpService:JSONDecode(raw)
    end)

    if success then
        if result and result.data then return result
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

local function teleportToServer(serverId)
    print("🚀 Teleporting to:", serverId)
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, serverId, LOCAL_PLAYER)
    end)
    if not success then
        warn("❌ Failed to teleport to " .. serverId .. ": " .. tostring(err))
        return false
    end

    task.wait(5)
    if game.JobId and game.JobId == serverId then
        print("✅ Teleport confirmed. Now in server:", serverId)
        return true
    else
        print("⛔ Teleport failed or disconnected after teleport to:", serverId)
        return false
    end
end

local function tryJoinAcceptedServers()
    if not CONFIG.ENABLE_ACCEPTED_SERVER_JOIN then
        print("🔧 Accepted server join disabled. Proceeding to find new servers...")
        return false
    end

    local acceptedList = readJobIds("ServerHopData/AcceptedServers.txt")
    if #acceptedList == 0 then
        print("📂 No servers in AcceptedServers to try. Proceeding to find new servers...")
        return false
    end

    print("🔎 Attempting to join a random server from AcceptedServers (one attempt)...")
    local randomIndex = math.random(1, #acceptedList)
    local serverId = acceptedList[randomIndex]:match("^(.-)%s%(")
    if serverId and not isServerBlacklisted(serverId) then
        print("🔍 Trying to join random accepted server: " .. serverId)
        local success = teleportToServer(serverId)
        if success then
            print("✅ Successfully joined and confirmed in accepted server: " .. serverId)
            return true
        else
            print("⛔ Could not join accepted server: " .. serverId .. ". Switching to normal hop...")
            wait(3)
            return false
        end
    end

    print("❌ No valid or non-blacklisted server ID in AcceptedServers. Switching to normal hop...")
    wait(3)
    return false
end

local function findAndHop()
    print("🔍 Starting normal server hop...")
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

                    if ver <= CONFIG.MAX_VERSION and playing < maxPlayers then
                        saveAcceptedServer(server.id, ver)
                        -- Only blacklist if not accepted
                        if not isServerAccepted(server.id) then
                            writeJobId("ServerHopData/ServerBlacklist.txt", server.id)
                        end
                        local success = teleportToServer(server.id)
                        if success then
                            task.wait(10)
                            return
                        else
                            task.wait(3)
                        end
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

local function getTargetItemsSummary()
    local summary = {}
    local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
    if not backpack then
        log("error", "No Backpack found", true)
        return "No Items"
    end

    log("debug", "Raw items in Backpack:", true)
    for _, item in ipairs(backpack:GetChildren()) do
        log("debug", "- " .. item.Name, true)
    end

    local targetItems = {"Candy Blossom Seed", "Night Seed Pack", "Night Egg", "Bug Egg", "Moon Blossom Seed"}
    local targetSet = {}
    for _, target in ipairs(targetItems) do
        targetSet[cleanItemName(target)] = true
    end

    log("debug", "Target items (cleaned):", true)
    for target, _ in pairs(targetSet) do
        log("debug", "- " .. target, true)
    end

    for _, item in ipairs(backpack:GetChildren()) do
        local cleanedName = cleanItemName(item.Name)
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
                break
            end
        end
    end

    if #summary == 0 then
        return "No Candy Blossom Seed, Night Seed Pack, Night Egg, Bug Egg, or Moon Blossom Seed"
    end
    return table.concat(summary, ", ")
end

local function startRAMUpdateLoop()
    log("info", "Starting RAM update loop", true)
    while true do
        local sheckles = 0
        local leaderstats = game:GetService("Players").LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:FindFirstChild("Sheckles") then
            sheckles = leaderstats.Sheckles.Value
        else
            log("error", "Sheckles not found in leaderstats", true)
        end
        local formatted_money = formatMoney(sheckles)

        local items_summary = getTargetItemsSummary()

        local update_success, update_err = pcall(function()
            if typeof(MyAccount) == "table" or typeof(MyAccount) == "Instance" then
                MyAccount:SetAlias("Money: " .. formatted_money)
                MyAccount:SetDescription(items_summary)
            else
                log("error", "MyAccount is not defined or not valid", true)
            end
        end)

        if update_success then
            log("info", "RAMAccount updated - Money: " .. formatted_money .. ", Items: " .. items_summary, true)
        else
            log("error", "Failed to update RAMAccount: " .. tostring(update_err), true)
        end

        task.wait(60)
    end
end

-- Main Execution
print("🔧 Starting main execution...")

-- Ensure ServerHopData folder exists before any file operations
createExecutorFolder("ServerHopData")

-- Start RAM update immediately
print("🔄 Starting RAM update loop immediately...")
task.spawn(startRAMUpdateLoop)

-- Check if server hopping is enabled
if not CONFIG.ENABLE_SERVER_HOP then
    print("🔧 Server hopping disabled. Staying in current server...")
    if CURRENT_VERSION <= CONFIG.MAX_VERSION then
        print("✅ Current version <= MAX_VERSION. Saving current server to AcceptedServers...")
        saveAcceptedServer(game.JobId, CURRENT_VERSION)
    else
        print("⚠️ Current version > MAX_VERSION, but server hopping is disabled. Staying in current server...")
    end
else
    -- Delay Server Hop by 30 seconds to wait for loading
    print("⏳ Waiting 30 seconds before starting server hop...")
    task.wait(30)
    print("⏳ Wait complete. Proceeding with server hop...")

    if CURRENT_VERSION > CONFIG.MAX_VERSION then
        print("🔍 Current version > MAX_VERSION. Attempting to join accepted server...")
        local joined = tryJoinAcceptedServers()
        print("🔎 Join result:", joined and "Success" or "Failed")
        if not joined then
            print("🔍 Switching to normal server hop...")
            task.spawn(findAndHop)
        else
            print("✅ Already joined an accepted server. Checking stability...")
            wait(10)
            if game.JobId ~= "7394c826-face-4fae-9cfd-7a52f369a93d" then
                print("⛔ Disconnected from accepted server. Switching to normal hop...")
                task.spawn(findAndHop)
            else
                print("✅ Server stable. No further hopping needed.")
            end
        end
    else
        print("✅ Current version <= MAX_VERSION. Saving current server to AcceptedServers...")
        saveAcceptedServer(game.JobId, CURRENT_VERSION)
    end
end

print("🔧 Main execution completed.")