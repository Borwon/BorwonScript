-- AttackOnTitan.lua - Horst Manager description for Attack On Titan.
-- Data sources:
-- Level:    PlayerGui.Interface.Gear_Up.HUD.Level.Title.Text
-- Gold:     PlayerGui.Interface.Topbar.Main.Currencies.Gold.Amount.Text
-- Gems:     PlayerGui.Interface.Topbar.Main.Currencies.Gems.Amount.Text
-- Prestige: PlayerGui.Interface.Equipment.Prestige.B_Prestige.Visible + Progress.Title.Text fallback

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer
repeat task.wait() until _G.Horst_SetDescription

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UPDATE_INTERVAL = 10
local AFK_IDLE_SECONDS = 10 * 60
local placeStartedAt = os.clock()

local function log(logType, message)
    local timeStr = os.date("%H:%M:%S")
    local text = "[AttackOnTitan][" .. timeStr .. "] " .. tostring(message)

    if logType == "error" or logType == "warning" then
        warn(text)
    else
        print(text)
    end
end

local function waitForPath(root, path, timeout)
    local current = root

    for _, name in ipairs(path) do
        if not current then
            return nil
        end

        current = current:WaitForChild(name, timeout)
    end

    return current
end

local function getText(object)
    if not object then
        return "N/A"
    end

    local ok, value = pcall(function()
        return object.Text
    end)

    if ok and value ~= nil and tostring(value) ~= "" then
        return tostring(value)
    end

    return "N/A"
end

local function isReadyText(value)
    value = tostring(value or "")
    local normalized = value:lower()

    return value ~= ""
        and value ~= "N/A"
        and value ~= "-"
        and normalized ~= "loading"
        and normalized ~= "loading..."
end

local function loadObjects()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 30)
    if not playerGui then
        return nil, "PlayerGui not found"
    end

    local objects = {
        Level = waitForPath(playerGui, { "Interface", "Gear_Up", "HUD", "Level", "Title" }, 30),
        Gold = waitForPath(playerGui, { "Interface", "Topbar", "Main", "Currencies", "Gold", "Amount" }, 30),
        Gems = waitForPath(playerGui, { "Interface", "Topbar", "Main", "Currencies", "Gems", "Amount" }, 30),
        Prestige = waitForPath(playerGui, { "Interface", "Equipment", "Prestige", "Progress", "Title" }, 30),
        PrestigeButton = waitForPath(playerGui, { "Interface", "Equipment", "Prestige", "B_Prestige" }, 30),
    }

    for name, object in pairs(objects) do
        if not object then
            return nil, name .. " object not found"
        end
    end

    return objects
end

local function waitForInitialData(objects, timeout)
    local startedAt = os.clock()

    repeat
        local levelText = getText(objects.Level)
        local goldText = getText(objects.Gold)
        local gemsText = getText(objects.Gems)

        if isReadyText(levelText) and isReadyText(goldText) and isReadyText(gemsText) then
            task.wait(3)
            return true
        end

        task.wait(1)
    until os.clock() - startedAt >= timeout

    return false
end

local function getPrestigeText(objects)
    local ok, visible = pcall(function()
        return objects.PrestigeButton.Visible
    end)

    if ok then
        if visible == false then
            return "✅"
        end

        local progressText = getText(objects.Prestige)
        if progressText ~= "N/A" then
            return "❌ " .. progressText
        end

        return "❌"
    end

    return getText(objects.Prestige)
end

local function getAfkText()
    if os.clock() - placeStartedAt >= AFK_IDLE_SECONDS then
        return "✅"
    end

    return "❌"
end

local function setDescription(message)
    local ok, err = pcall(function()
        _G.Horst_SetDescription(message)
    end)

    if not ok then
        log("warning", "Horst_SetDescription failed: " .. tostring(err))
    end
end

log("info", "Script started")

local objects, loadErr = loadObjects()
if not objects then
    log("error", loadErr or "Failed to load UI objects")
    setDescription("Level: N/A - Gold: N/A - Gems: N/A - Prestige: N/A - AFK:" .. getAfkText())
    return
end

log("success", "UI objects loaded")

if waitForInitialData(objects, 90) then
    log("success", "Initial game data loaded")
else
    log("warning", "Initial game data did not finish loading before timeout")
end

while true do
    local ok, err = pcall(function()
        local levelText = getText(objects.Level)
        local goldText = getText(objects.Gold)
        local gemsText = getText(objects.Gems)
        local prestigeText = getPrestigeText(objects)
        local afkText = getAfkText()

        local message = string.format(
            "Level: %s - Gold: %s - Gems: %s - Prestige: %s - AFK:%s",
            levelText,
            goldText,
            gemsText,
            prestigeText,
            afkText
        )

        setDescription(message)
        log("success", "Description updated: " .. message)
    end)

    if not ok then
        log("error", "Failed to update description: " .. tostring(err))
        local newObjects = loadObjects()
        if newObjects then
            objects = newObjects
        end
    end

    task.wait(UPDATE_INTERVAL)
end
