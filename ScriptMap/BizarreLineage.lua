-- BizarreLineage.lua — ScriptMap สำหรับ Bizarre Lineage
-- ใช้ _G.Horst_SetDescription แสดง Prestige, Level, Money, Stand, StandStorage
-- ข้อมูล: player.PlayerData.SlotData (Prestige/Level/Money/Stand) + PlayerData.StandStorage

local Players = game:GetService("Players")

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

-- แยกชื่อจาก JSON value
local function ExtractNames(value)
    if type(value) ~= "string" or value == "" or value == "[]" then return "None" end
    local names = {}
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local decoded = HttpService:JSONDecode(value)
        if type(decoded) == "table" then
            if #decoded > 0 then
                for _, item in ipairs(decoded) do
                    if type(item) == "table" and item.Name then
                        table.insert(names, tostring(item.Name))
                    end
                end
            elseif decoded.Name then
                table.insert(names, tostring(decoded.Name))
            end
        end
    end)
    return #names > 0 and table.concat(names, ", ") or "None"
end

log("info", "Bizarre Lineage Script Started")

repeat task.wait() until game:IsLoaded()

local player = Players.LocalPlayer
local playerData = player:WaitForChild("PlayerData", 15)

if not playerData then
    log("error", "PlayerData not found — script terminated.")
    return
end

local slotData = playerData:WaitForChild("SlotData", 15)

if not slotData then
    log("error", "SlotData not found — script terminated.")
    return
end

log("success", "Data ready. Starting monitoring loop.")

local UPDATE_INTERVAL = 5

task.spawn(function()
    while true do
        local success, err = pcall(function()
            local prestige = slotData:FindFirstChild("Prestige") and slotData.Prestige.Value or 0
            local level    = slotData:FindFirstChild("Level")    and slotData.Level.Value    or 0
            local money    = slotData:FindFirstChild("Money")    and slotData.Money.Value    or 0

            local standValue        = slotData:FindFirstChild("Stand")        and slotData.Stand.Value        or ""
            local standStorageValue = playerData:FindFirstChild("StandStorage") and playerData.StandStorage.Value or ""

            local currentStands  = ExtractNames(standValue)
            local storageStands  = ExtractNames(standStorageValue)

            -- Horst ห้ามใช้ | และ ; ในข้อความ
            local messages = string.format(
                "Prestige: %s - Lv: %s - Money: %s - Stand: %s - Storage: %s",
                tostring(prestige), tostring(level), tostring(money),
                currentStands, storageStands
            )
            _G.Horst_SetDescription(messages)
            log("success", "Description updated: " .. messages)
        end)

        if not success then
            log("error", "Failed to update: " .. tostring(err))
        end

        task.wait(UPDATE_INTERVAL)
    end
end)
