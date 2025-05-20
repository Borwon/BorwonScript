-- รอให้เกมโหลดสมบูรณ์
repeat task.wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer

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
    return
end

-- ลิสต์ไอเทมที่ไม่ต้องการรวม
local EXCLUDE_ITEMS = {
    ["wateringcan"] = true,
    ["watering can"] = true,
    ["shovel"] = true,
    ["carrotseed"] = true,
    ["carrot seed"] = true
}

-- ฟังก์ชัน log กระชับ
local function log(type, message)
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
    -- แปลงเป็น lowercase และตัดช่องว่าง
    return cleanedName:lower():gsub("%s+", "")
end

-- ฟังก์ชันรวมชื่อและจำนวนไอเทมใน Backpack
local function GetBackpackSummary()
    local summary = {}
    local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
    if not backpack then
        log("error", "No Backpack found")
        return "No Backpack"
    end

    for _, item in ipairs(backpack:GetChildren()) do
        local cleanedName = CleanItemName(item.Name)
        log("debug", "Checking item: " .. item.Name .. " (cleaned: " .. cleanedName .. ")")
        if not EXCLUDE_ITEMS[cleanedName] then
            local amount = ""
            if item:FindFirstChild("Amount") and tonumber(item.Amount.Value) then
                amount = tostring(item.Amount.Value)
            elseif item:FindFirstChild("Value") and tonumber(item.Value.Value) then
                amount = tostring(item.Value.Value)
            end
            local displayName = amount ~= "" and string.format("%s x%s", item.Name, amount) or item.Name
            table.insert(summary, displayName)
            log("debug", "Included item: " .. displayName)
        else
            log("debug", "Excluded item: " .. item.Name)
        end
    end

    if #summary == 0 then
        return "No Items"
    end
    return table.concat(summary, ", ")
end

-- วนลูปหลักเพื่ออัปเดต RAMAccount
task.spawn(function()
    log("info", "Script loaded successfully")
    while true do
        -- ดึงข้อมูลเงิน
        local sheckles = 0
        local leaderstats = game:GetService("Players").LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:FindFirstChild("Sheckles") then
            sheckles = leaderstats.Sheckles.Value
        else
            log("error", "Sheckles not found in leaderstats")
        end
        local formatted_money = FormatMoney(sheckles)

        -- ดึงข้อมูลไอเทม
        local items_summary = GetBackpackSummary()

        -- อัปเดต RAMAccount
        local update_success, update_err = pcall(function()
            MyAccount:SetAlias("Money: " .. formatted_money)
            MyAccount:SetDescription(items_summary)
        end)

        if update_success then
            log("info", "RAMAccount updated - Money: " .. formatted_money .. ", Items: " .. items_summary)
        else
            log("error", "Failed to update RAMAccount: " .. tostring(update_err))
        end

        task.wait(60) -- อัปเดตทุก 5 นาที
    end
end)