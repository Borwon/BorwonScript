-- ZombieArena.lua — ScriptMap สำหรับ Zombie Arena
-- ใช้ _G.Horst_SetDescription แสดง TopWave, Credits, VoidShards
-- ข้อมูล:
--   Players.LocalPlayer.leaderstats.TopWave.Value
--   Players.LocalPlayer.Credits.Value
--   Players.LocalPlayer.VoidShards.Value

repeat task.wait() until game:IsLoaded()
repeat task.wait() until _G.Horst_SetDescription

local Players = game:GetService("Players")
local player = Players.LocalPlayer

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

local function getValue(instance, defaultValue)
    if instance == nil then
        return defaultValue
    end

    local ok, value = pcall(function()
        return instance.Value
    end)

    if ok and value ~= nil then
        return value
    end

    return defaultValue
end

local function formatShortNumber(value)
    local numberValue = tonumber(value) or 0
    local absValue = math.abs(numberValue)

    local function trimDecimal(text)
        text = string.gsub(text, "%.0$", "")
        return text
    end

    if absValue >= 1000000000000 then
        return trimDecimal(string.format("%.1fT", numberValue / 1000000000000))
    elseif absValue >= 1000000000 then
        return trimDecimal(string.format("%.1fB", numberValue / 1000000000))
    elseif absValue >= 1000000 then
        return trimDecimal(string.format("%.1fM", numberValue / 1000000))
    elseif absValue >= 1000 then
        return trimDecimal(string.format("%.1fK", numberValue / 1000))
    end

    return tostring(numberValue)
end

log("info", "Zombie Arena Script Started")

local leaderstats = player:WaitForChild("leaderstats", 15)
if not leaderstats then
    log("error", "leaderstats not found — script terminated.")
    return
end

local topWaveValue = leaderstats:WaitForChild("TopWave", 15)
if not topWaveValue then
    log("error", "leaderstats.TopWave not found — script terminated.")
    return
end

local creditsValue = player:WaitForChild("Credits", 15)
if not creditsValue then
    log("error", "Player.Credits not found — script terminated.")
    return
end

local voidShardsValue = player:WaitForChild("VoidShards", 15)
if not voidShardsValue then
    log("error", "Player.VoidShards not found — script terminated.")
    return
end

log("success", "Data ready. Starting monitoring loop.")

local UPDATE_INTERVAL = 10

while true do
    local success, err = pcall(function()
        local topWave = getValue(topWaveValue, 0)
        local credits = getValue(creditsValue, 0)
        local voidShards = getValue(voidShardsValue, 0)

        local messages = string.format(
            "🧟 Zombie Arena  🌊 TopWave: %s  💰 Credits: %s  💎 VoidShards: %s",
            tostring(topWave),
            formatShortNumber(credits),
            formatShortNumber(voidShards)
        )

        _G.Horst_SetDescription(messages)
        log("success", "Description updated: " .. messages)
    end)

    if not success then
        log("error", "Failed to update: " .. tostring(err))
    end

    task.wait(UPDATE_INTERVAL)
end
