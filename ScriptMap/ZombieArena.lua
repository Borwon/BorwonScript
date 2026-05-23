-- ZombieArena.lua — ScriptMap สำหรับ Zombie Arena
-- ใช้ _G.Horst_SetDescription แสดง TopWave, Credits, VoidShards และสถานะอาวุธ
-- ข้อมูล:
--   Players.LocalPlayer.leaderstats.TopWave.Value
--   Players.LocalPlayer.Credits.Value
--   Players.LocalPlayer.VoidShards.Value
--   Players.LocalPlayer.PlayerGui.MainGui.Frames.UpgradeShop.ScrollingFrames.Weapons.<Weapon>.NotOwned.Visible

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

local WEAPON_NAMES = {
    "CosmicPistol",
    "Quasar",
    "Pulsar",
    "VoidScythe",
}

local function safeFindChild(parent, childName)
    if parent == nil then
        return nil
    end

    local ok, child = pcall(function()
        return parent:FindFirstChild(childName)
    end)

    if ok then
        return child
    end

    return nil
end

local function getWeaponsFrame()
    local playerGui = safeFindChild(player, "PlayerGui")
    local mainGui = safeFindChild(playerGui, "MainGui")
    local frames = safeFindChild(mainGui, "Frames")
    local upgradeShop = safeFindChild(frames, "UpgradeShop")
    local scrollingFrames = safeFindChild(upgradeShop, "ScrollingFrames")
    return safeFindChild(scrollingFrames, "Weapons")
end

local function isWeaponOwned(weaponsFrame, weaponName)
    local weapon = safeFindChild(weaponsFrame, weaponName)
    if not weapon then
        return false
    end

    local notOwned = safeFindChild(weapon, "NotOwned")
    if not notOwned then
        return false
    end

    local ok, visible = pcall(function()
        return notOwned.Visible
    end)

    if not ok then
        return false
    end

    -- NotOwned.Visible = true แปลว่ายังไม่ได้เป็นเจ้าของ
    -- NotOwned.Visible = false แปลว่าเป็นเจ้าของแล้ว
    return visible == false
end

local function getWeaponsDescription()
    local weaponsFrame = getWeaponsFrame()
    local parts = {}

    for _, weaponName in ipairs(WEAPON_NAMES) do
        local icon = isWeaponOwned(weaponsFrame, weaponName) and "✅" or "❌"
        table.insert(parts, weaponName .. icon)
    end

    return "Weapons: " .. table.concat(parts, " ")
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

local UPDATE_INTERVAL = 2

while true do
    local success, err = pcall(function()
        local topWave = getValue(topWaveValue, 0)
        local credits = getValue(creditsValue, 0)
        local voidShards = getValue(voidShardsValue, 0)

        local weaponsDescription = getWeaponsDescription()

        local messages = string.format(
            "🧟 Zombie Arena  🌊 TopWave: %s  💰 Credits: %s  💎 VoidShards: %s  %s",
            tostring(topWave),
            formatShortNumber(credits),
            formatShortNumber(voidShards),
            weaponsDescription
        )

        _G.Horst_SetDescription(messages)
        log("success", "Description updated: " .. messages)
    end)

    if not success then
        log("error", "Failed to update: " .. tostring(err))
    end

    task.wait(UPDATE_INTERVAL)
end
