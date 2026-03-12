-- atsgems.lua — ScriptMap สำหรับ ATS Gems
-- ใช้ _G.Horst_SetDescription แสดง Gems และ Units
-- ข้อมูล: PlayerGui.HUD.LocalScript.Gems_Numbers (Value/Text), workspace.PlayerUnit

-- ฟังก์ชันแปลงตัวเลขให้มีหน่วย (k / M)
local function FormatCoins(value)
    if value >= 1e6 then
        return string.format("%.1fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.1fk", value / 1e3)
    else
        return tostring(value)
    end
end

-- ดึงชื่อ Units ของผู้เล่น
local function GetUnitNames()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local playerUnits = workspace:FindFirstChild("PlayerUnit") and workspace.PlayerUnit:FindFirstChild(playerName)
    if not playerUnits then
        return "No Units"
    end
    local unitNames = {}
    for _, unit in ipairs(playerUnits:GetChildren()) do
        local unitName = unit.Name:match("([^/]+)")
        if unitName then
            table.insert(unitNames, unitName)
        end
    end
    return #unitNames > 0 and table.concat(unitNames, ", ") or "No Units"
end

-- Logging
local function log(logType, message)
    local timeStr = os.date("%H:%M:%S")
    if logType == "info" then
        print("[" .. timeStr .. "] ℹ️ " .. message)
    elseif logType == "success" then
        print("[" .. timeStr .. "] ✅ " .. message)
    elseif logType == "warning" then
        warn("[" .. timeStr .. "] ⚠️ " .. message)
    elseif logType == "error" then
        warn("[" .. timeStr .. "] ❌ " .. message)
    end
end

log("info", "ATS Gems Script Started")

-- รอให้ HUD โหลด
local function WaitForGemsObject()
    local player = game:GetService("Players").LocalPlayer
    local gemsObject
    for i = 1, 3 do
        local playerGui   = player:WaitForChild("PlayerGui", 10)
        local hud         = playerGui and playerGui:FindFirstChild("HUD")
        local localScript = hud and hud:FindFirstChild("LocalScript")
        gemsObject        = localScript and localScript:FindFirstChild("Gems_Numbers")
        if gemsObject then break end
        log("warning", "HUD or Gems_Numbers not loaded, retrying (" .. i .. "/3)...")
        task.wait(5)
    end
    return gemsObject
end

local gemsObject = WaitForGemsObject()
if not gemsObject then
    log("error", "Failed to find Gems_Numbers — script terminated.")
    return
end

log("success", "Data loaded successfully.")
log("info", "Waiting for data initialization...")
task.wait(20)

local UPDATE_INTERVAL = 30

while true do
    local gems
    local success, err = pcall(function()
        local gemsObj = game:GetService("Players").LocalPlayer.PlayerGui.HUD.LocalScript.Gems_Numbers
        if gemsObj:IsA("ValueBase") or gemsObj:IsA("StringValue") or gemsObj:IsA("IntValue") or gemsObj:IsA("NumberValue") then
            gems = tostring(gemsObj.Value)
        elseif gemsObj:IsA("TextLabel") or gemsObj:IsA("TextBox") then
            gems = gemsObj.Text
        else
            gems = tostring(gemsObj.Value or gemsObj.Text)
        end
    end)

    if success and gems then
        local cleaned = gems:gsub("[^%d%.]+", ""):gsub("%.+", ".")
        local numeric = tonumber(cleaned)
        if numeric then
            local formatted_gems = FormatCoins(numeric)
            local unitNames = GetUnitNames()

            -- Horst ห้ามใช้ | และ ; ในข้อความ
            local messages = string.format("Gem: %s - Units: %s", formatted_gems, unitNames)
            _G.Horst_SetDescription(messages)
            log("success", "Description updated: " .. messages)
        else
            log("warning", "Gems value is not a valid number: " .. tostring(gems))
        end
    else
        log("error", "Error fetching gems: " .. tostring(err))
    end

    log("info", "Next update in " .. UPDATE_INTERVAL .. " seconds...")
    task.wait(UPDATE_INTERVAL)
end
