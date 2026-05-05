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
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local UPDATE_INTERVAL = 10
local AFK_IDLE_SECONDS = 10 * 60
local INVENTORY_REFRESH_INTERVAL = 30
local placeStartedAt = os.clock()
local lastInventoryRefreshAt = 0

local ICON_LEVEL = "\u{2B50}"
local ICON_PRESTIGE = "\u{1F3C6}"
local ICON_GOLD = "\u{1FA99}"
local ICON_GEMS = "\u{1F4A0}"
local ICON_SERUM = "\u{1F9EA}"
local ICON_CHECK = "\u{2705}"
local ICON_CROSS = "\u{274C}"
local SEP = "\u{2503}"

getgenv().AOTItemFilters = getgenv().AOTItemFilters or {
    "Serum",
    "Prestige",
    "Emperor",
    "Key",
    "Scroll",
}
if getgenv().AOTRefreshInventory == nil then
    getgenv().AOTRefreshInventory = true
end

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

local function parseNumber(value)
    local text = tostring(value or "")
    local numberText = text:match("(%d+)")

    return numberText and tonumber(numberText) or nil
end

local function formatLevelText(levelText, prestigeText)
    local level = parseNumber(levelText)
    local prestige = parseNumber(prestigeText)

    local maxLevels = {
        [1] = 125,
        [2] = 150,
        [3] = 175,
        [4] = 200,
        [5] = 225,
    }

    if level and prestige and maxLevels[prestige] and level >= maxLevels[prestige] then
        return "Lv.Max(" .. tostring(level) .. ")"
    end

    if level then
        return "Lv." .. tostring(level)
    end

    return tostring(levelText or "N/A")
end

local function getInventoryItemsRoot()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local interface = playerGui and playerGui:FindFirstChild("Interface")
    local inventory = interface and interface:FindFirstChild("Inventory")
    local main = inventory and inventory:FindFirstChild("Main")
    local holder = main and main:FindFirstChild("Holder")

    return holder and holder:FindFirstChild("Items")
end

local function pressReturn()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.08)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    task.wait(0.08)
end

local function clickGui(button)
    if not button then
        return false
    end

    local ok = pcall(function()
        button.Selectable = true
        GuiService.SelectedObject = button
        pressReturn()
        GuiService.SelectedObject = nil
    end)

    GuiService.SelectedObject = nil
    return ok
end

local function forceVisible(guiObject)
    local changed = {}
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local current = guiObject

    while current and current ~= playerGui do
        if current:IsA("GuiObject") and current.Visible == false then
            table.insert(changed, { object = current, visible = false })
            current.Visible = true
        end
        current = current.Parent
    end

    task.wait()
    return changed
end

local function restoreVisible(changed)
    if getgenv().AOTKeepInventoryOpen then
        return
    end

    for i = #changed, 1, -1 do
        local item = changed[i]
        if item.object and item.object.Parent then
            item.object.Visible = item.visible
        end
    end
end

local function textObjectText(object)
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        return object.Text or ""
    end

    return ""
end

local function shouldClickInventoryButton(object)
    local text = normalizeText(object.Name .. " " .. textObjectText(object))

    return text:find("inventory", 1, true) ~= nil
        or text:find("bag", 1, true) ~= nil
        or text:find("backpack", 1, true) ~= nil
        or text:find("items", 1, true) ~= nil
end

local function refreshInventory()
    if not getgenv().AOTRefreshInventory then
        return
    end

    if os.clock() - lastInventoryRefreshAt < INVENTORY_REFRESH_INTERVAL then
        return
    end
    lastInventoryRefreshAt = os.clock()

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local interface = playerGui and playerGui:FindFirstChild("Interface")
    local inventory = interface and interface:FindFirstChild("Inventory")
    if not playerGui or not interface then
        return
    end

    local changed = {}
    if inventory then
        changed = forceVisible(inventory)
    end

    local clicked = 0
    for _, object in ipairs(interface:GetDescendants()) do
        if (object:IsA("TextButton") or object:IsA("ImageButton")) and shouldClickInventoryButton(object) then
            if clickGui(object) then
                clicked = clicked + 1
                task.wait(0.15)
            end
        end
    end

    task.wait(1)
    restoreVisible(changed)

    if getgenv().AOTDebugItems then
        log("info", "Inventory refresh attempted. Clicked buttons: " .. tostring(clicked))
    end
end

local function cleanItemName(name)
    local cleaned = tostring(name or "")

    -- Item names sometimes start with slot/order numbers. Keep the real name only.
    cleaned = cleaned:gsub("^%s*%d+[%s%-%_%:%.)%]]*", "")
    cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")

    return cleaned ~= "" and cleaned or tostring(name or "Unknown")
end

local function getItemsText()
    refreshInventory()

    local itemsRoot = getInventoryItemsRoot()
    if not itemsRoot then
        return "N/A"
    end

    if #itemsRoot:GetChildren() == 0 then
        lastInventoryRefreshAt = 0
        refreshInventory()
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
    local hasSerum = false
    for _, itemName in ipairs(matchedOrder) do
        if counts[itemName] and counts[itemName] > 0 then
            if textMatchesFilter(itemName, "Serum") then
                hasSerum = true
            end

            if counts[itemName] == 1 then
                table.insert(parts, itemName)
            else
                table.insert(parts, itemName .. " x" .. tostring(counts[itemName]))
            end
        end
    end

    return #parts > 0 and table.concat(parts, ", ") or "None", hasSerum
end

local function getAfkText()
    if os.clock() - placeStartedAt >= AFK_IDLE_SECONDS then
        return "✅"
    end

    return "❌"
end

local function getAfkIcon()
    if os.clock() - placeStartedAt >= AFK_IDLE_SECONDS then
        return ICON_CHECK
    end

    return ICON_CROSS
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
    setDescription(table.concat({
        ICON_LEVEL .. " N/A",
        ICON_PRESTIGE .. " N/A",
        ICON_GOLD .. " N/A",
        ICON_GEMS .. " N/A",
        ICON_SERUM .. SEP .. ICON_CROSS,
        "Items: N/A",
        "AFK:" .. getAfkIcon(),
    }, " " .. SEP .. " "))
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
        local formattedLevelText = formatLevelText(levelText, prestigeText)
        local itemsText, hasSerum = getItemsText()
        local serumText = ICON_SERUM .. ":" .. (hasSerum and ICON_CHECK or ICON_CROSS)
        local afkText = getAfkIcon()

        local message = table.concat({
            ICON_LEVEL .. " " .. formattedLevelText,
            ICON_PRESTIGE .. " " .. prestigeText,
            ICON_GOLD .. " " .. goldText,
            ICON_GEMS .. " " .. gemsText,
            serumText,
            "Items: " .. itemsText,
            "AFK:" .. afkText,
        }, " " .. SEP .. " ")

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
