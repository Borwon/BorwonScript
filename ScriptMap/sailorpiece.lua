-- sailorpiece.lua — ScriptMap สำหรับ Sailor Piece
-- ใช้ _G.Horst_SetDescription แสดง Level, Gems, Units
-- ข้อมูล: player.Data.Gems, player.Data.Level, workspace.PlayerUnit

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

log("info", "Sailor Piece Script Started")

-- รอให้ข้อมูลโหลด
local function WaitForDataToLoad()
    local player = game:GetService("Players").LocalPlayer
    local dataFolder, gemsObject, levelObject
    for i = 1, 3 do
        dataFolder = player:WaitForChild("Data", 10)
        gemsObject = dataFolder and dataFolder:FindFirstChild("Gems")
        levelObject = dataFolder and dataFolder:FindFirstChild("Level")
        if gemsObject and levelObject then break end
        log("warning", "Data not loaded yet, retrying (" .. i .. "/3)...")
        task.wait(5)
    end
    if not (gemsObject and levelObject) then
        log("error", "Failed to load Gems/Level after retries.")
        return false
    end
    log("success", "Data loaded successfully.")
    return true
end

if not WaitForDataToLoad() then
    log("error", "Data failed to load — script terminated.")
    return
end

log("info", "Waiting for data initialization...")
task.wait(20)

local UPDATE_INTERVAL = 30

while true do
    local gems, level
    local success, err = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local dataFolder = player:FindFirstChild("Data")
        if not dataFolder then return end

        local gemsObj = dataFolder:FindFirstChild("Gems")
        local levelObj = dataFolder:FindFirstChild("Level")

        if gemsObj then
            gems = tostring(gemsObj.Value or gemsObj.Text or "0")
        end
        if levelObj then
            level = tostring(levelObj.Value or levelObj.Text or "0")
        end
    end)

    if success and (gems or level) then
        local formatted_gems = "N/A"
        if gems then
            local num = tonumber(gems:gsub("[^%d%.]+", ""):gsub("%.+", "."))
            if num then formatted_gems = FormatCoins(num) end
        end

        local formatted_level = "N/A"
        if level then
            local num = tonumber(level:gsub("[^%d%.]+", ""):gsub("%.+", "."))
            if num then formatted_level = tostring(num) end
        end

        local unitNames = GetUnitNames()

        -- Horst ห้ามใช้ | และ ; ในข้อความ
        local messages = string.format("Lv: %s - Gems: %s - Units: %s", formatted_level, formatted_gems, unitNames)
        _G.Horst_SetDescription(messages)
        log("success", "Description updated: " .. messages)
    else
        log("error", "Error fetching data: " .. tostring(err))
    end

    log("info", "Next update in " .. UPDATE_INTERVAL .. " seconds...")
    task.wait(UPDATE_INTERVAL)
end
