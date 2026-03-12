-- 99night.lua — ScriptMap สำหรับ 99night
-- ใช้ _G.Horst_SetDescription แสดง Diamonds
-- ข้อมูล: PlayerGui.Interface.DiamondCount.Count.ContentText

repeat task.wait() until game:IsLoaded()
task.wait(5)

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

log("info", "99night Script Started")

local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 15)
local interface = playerGui and playerGui:WaitForChild("Interface", 15)
local diamondCountContainer = interface and interface:WaitForChild("DiamondCount", 15)
local countLabel = diamondCountContainer and diamondCountContainer:WaitForChild("Count", 15)

if not countLabel then
    log("error", "Diamond Count Label not found — script terminated.")
    return
end

log("success", "Script loaded successfully")

local UPDATE_INTERVAL = 10

while true do
    local currentDiamonds
    local success, err = pcall(function()
        currentDiamonds = countLabel.ContentText
    end)

    if success and currentDiamonds then
        log("info", "Diamonds: " .. tostring(currentDiamonds))
        local messages = string.format("Diamonds: %s", currentDiamonds)
        _G.Horst_SetDescription(messages)
        log("success", "Description updated: " .. messages)
    else
        log("error", "Data fetch failed: " .. tostring(err))
    end

    task.wait(UPDATE_INTERVAL)
end
