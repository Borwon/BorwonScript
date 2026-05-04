-- AttackOnTitan.lua - Horst Manager description for Attack On Titan.
-- Data sources:
-- Level:    PlayerGui.Interface.Gear_Up.HUD.Level.Title.Text
-- Gold:     PlayerGui.Interface.Topbar.Main.Currencies.Gold.Amount.Text
-- Gems:     PlayerGui.Interface.Topbar.Main.Currencies.Gems.Amount.Text
-- Prestige: Player:GetAttribute("Prestige")
-- Items:    PlayerGui.Interface.Inventory.Main.Holder.Items

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer
repeat task.wait() until _G.Horst_SetDescription

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UPDATE_INTERVAL = 10
local AFK_IDLE_SECONDS = 10 * 60
local placeStartedAt = os.clock()

getgenv().AOTItemFilters = getgenv().AOTItemFilters or {
    "Serum",
    "Prestige",
    "Emperor",
    "Key",
}

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

local function normalizeText(value)
    return tostring(value or "")
        :lower()
        :gsub("'s", " ")
        :gsub("’s", " ")
        :gsub("[^%w]+", " ")
        :gsub("%s+", " ")
        :match("^%s*(.-)%s*$")
end

local function splitWords(value)
    local words = {}

    for word in normalizeText(value):gmatch("%S+") do
        if word ~= "s" then
            table.insert(words, word)
        end
    end

    return words
end

local function textMatchesFilter(text, filter)
    local normalizedText = normalizeText(text)
    local normalizedFilter = normalizeText(filter)

    if normalizedText == "" or normalizedFilter == "" then
        return false
    end

    if normalizedText:find(normalizedFilter, 1, true) then
        return true
    end

    for _, word in ipairs(splitWords(filter)) do
        if not normalizedText:find(word, 1, true) then
            return false
        end
    end

    return true
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

local function getPrestigeText()
    local ok, value = pcall(function()
        return LocalPlayer:GetAttribute("Prestige")
    end)

    if ok and value ~= nil then
        return tostring(value)
    end

    return "N/A"
end

local function getInventoryItemsRoot()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local interface = playerGui and playerGui:FindFirstChild("Interface")
    local inventory = interface and interface:FindFirstChild("Inventory")
    local main = inventory and inventory:FindFirstChild("Main")
    local holder = main and main:FindFirstChild("Holder")

    return holder and holder:FindFirstChild("Items")
end

local function cleanItemName(name)
    local cleaned = tostring(name or "")

    -- Item names sometimes start with slot/order numbers. Keep the real name only.
    cleaned = cleaned:gsub("^%s*%d+[%s%-%_%:%.)%]]*", "")
    cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")

    return cleaned ~= "" and cleaned or tostring(name or "Unknown")
end

local function getItemsText()
    local itemsRoot = getInventoryItemsRoot()
    if not itemsRoot then
        return "N/A"
    end

    local counts = {}
    local order = {}
    local matchedOrder = {}

    for _, filterName in ipairs(getgenv().AOTItemFilters) do
        table.insert(order, filterName)
    end

    for _, itemObject in ipairs(itemsRoot:GetChildren()) do
        local rawName = itemObject.Name
        local itemName = cleanItemName(rawName)

        if getgenv().AOTDebugItems then
            log("info", "Inventory candidate: raw=" .. tostring(rawName) .. " clean=" .. tostring(itemName))
        end

        for _, filterName in ipairs(order) do
            if textMatchesFilter(itemName, filterName) then
                if counts[itemName] == nil then
                    counts[itemName] = 0
                    table.insert(matchedOrder, itemName)
                end

                counts[itemName] = counts[itemName] + 1
                break
            end
        end
    end

    local parts = {}
    for _, itemName in ipairs(matchedOrder) do
        if counts[itemName] and counts[itemName] > 0 then
            if counts[itemName] == 1 then
                table.insert(parts, itemName)
            else
                table.insert(parts, itemName .. " x" .. tostring(counts[itemName]))
            end
        end
    end

    return #parts > 0 and table.concat(parts, ", ") or "None"
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
    setDescription("Level: N/A - Gold: N/A - Gems: N/A - Prestige: N/A - Items: N/A - AFK:" .. getAfkText())
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
        local prestigeText = getPrestigeText()
        local itemsText = getItemsText()
        local afkText = getAfkText()

        local message = string.format(
            "Level: %s - Gold: %s - Gems: %s - Prestige: %s - Items: %s - AFK:%s",
            levelText,
            goldText,
            gemsText,
            prestigeText,
            itemsText,
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
