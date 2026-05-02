-- auto_upgrade_gui_clicker.lua - Auto click the Equipment upgrade buttons.
-- GUI path:
-- Players.LocalPlayer.PlayerGui.Interface.Equipment.Stats.All
-- Players.LocalPlayer.PlayerGui.Interface.Equipment.Stat.Upgrade

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

getgenv().AutoUpgradeGuiConfig = getgenv().AutoUpgradeGuiConfig or {}

local config = getgenv().AutoUpgradeGuiConfig
if config.Enabled == nil then
    config.Enabled = true
end
config.Interval = tonumber(config.Interval) or 5
config.ClickHold = tonumber(config.ClickHold) or 0.05
config.WaitTimeout = tonumber(config.WaitTimeout) or 30
config.ScanButtons = config.ScanButtons ~= false
config.FireHiddenButtons = config.FireHiddenButtons ~= false
config.ForceVisible = config.ForceVisible ~= false
config.RestoreVisibility = config.RestoreVisibility ~= false

local function log(kind, message)
    local text = "[AutoUpgradeGui][" .. os.date("%H:%M:%S") .. "] " .. tostring(message)
    if kind == "error" or kind == "warning" then
        warn(text)
    else
        print(text)
    end
end

local function getEquipmentGui()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui", config.WaitTimeout)
    local interface = playerGui and playerGui:WaitForChild("Interface", config.WaitTimeout)
    local equipment = interface and interface:WaitForChild("Equipment", config.WaitTimeout)

    return equipment
end

local function getButtons()
    local equipment = getEquipmentGui()
    if not equipment then
        return nil, nil, nil
    end

    local stats = equipment and equipment:WaitForChild("Stats", config.WaitTimeout)
    local allButton = stats and stats:WaitForChild("All", config.WaitTimeout)
    local stat = equipment and equipment:WaitForChild("Stat", config.WaitTimeout)
    local upgradeButton = stat and stat:WaitForChild("Upgrade", config.WaitTimeout)

    return equipment, allButton, upgradeButton
end

local function isVisible(guiObject)
    local current = guiObject

    while current and current ~= Players.LocalPlayer.PlayerGui do
        if current:IsA("GuiObject") and current.Visible == false then
            return false
        end
        current = current.Parent
    end

    return true
end

local function makeVisibleForClick(guiObject)
    if not config.ForceVisible then
        return {}
    end

    local changed = {}
    local current = guiObject

    while current and current ~= Players.LocalPlayer.PlayerGui do
        if current:IsA("GuiObject") and current.Visible == false then
            table.insert(changed, { object = current, visible = false })
            current.Visible = true
        end
        current = current.Parent
    end

    task.wait()
    return changed
end

local function restoreVisibility(changed)
    if not config.RestoreVisibility then
        return
    end

    for i = #changed, 1, -1 do
        local item = changed[i]
        if item.object and item.object.Parent then
            item.object.Visible = item.visible
        end
    end
end

local function fireGuiSignals(guiObject)
    local fired = false

    if typeof(firesignal) == "function" then
        pcall(function()
            if guiObject.MouseButton1Down then
                firesignal(guiObject.MouseButton1Down)
                fired = true
            end
        end)

        pcall(function()
            if guiObject.MouseButton1Click then
                firesignal(guiObject.MouseButton1Click)
                fired = true
            end
        end)

        pcall(function()
            if guiObject.Activated then
                firesignal(guiObject.Activated)
                fired = true
            end
        end)

        pcall(function()
            if guiObject.MouseButton1Up then
                firesignal(guiObject.MouseButton1Up)
                fired = true
            end
        end)
    end

    return fired
end

local function clickGuiObject(guiObject)
    local changed = makeVisibleForClick(guiObject)
    local fired = fireGuiSignals(guiObject)

    if not isVisible(guiObject) then
        if config.FireHiddenButtons and fired then
            restoreVisibility(changed)
            return true, "signals(hidden)"
        end

        restoreVisibility(changed)
        return false, "button is hidden"
    end

    local position = guiObject.AbsolutePosition
    local size = guiObject.AbsoluteSize

    if size.X <= 0 or size.Y <= 0 then
        restoreVisibility(changed)
        return fired, fired and "fired signals only" or "button has zero size"
    end

    local x = math.floor(position.X + (size.X / 2))
    local y = math.floor(position.Y + (size.Y / 2))

    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(config.ClickHold)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)

    restoreVisibility(changed)
    return true, fired and "signals + mouse" or "mouse"
end

local equipmentGui, allButton, upgradeButton = getButtons()
if not allButton or not upgradeButton then
    log("error", "Button not found: PlayerGui.Interface.Equipment.Stats.All")
    return
end

local function getCandidateButtons()
    local candidates = {}

    if allButton then
        table.insert(candidates, allButton)
    end

    if not config.ScanButtons then
        return candidates
    end

    if not equipmentGui then
        return candidates
    end

    local keywords = {
        all = true,
        upgrade = true,
        buy = true,
        purchase = true,
        blade = true,
        odm = true,
        crit = true,
        damage = true,
        gas = true,
        range = true,
        control = true,
        speed = true,
    }

    local seen = {}
    for _, object in ipairs(equipmentGui:GetDescendants()) do
        if object:IsA("TextButton") or object:IsA("ImageButton") then
            local objectText = ""
            if object:IsA("TextButton") then
                objectText = object.Text or ""
            end

            local text = string.lower(object.Name .. " " .. tostring(objectText))
            for keyword in pairs(keywords) do
                if string.find(text, keyword, 1, true) then
                    if not seen[object] then
                        seen[object] = true
                        table.insert(candidates, object)
                    end
                    break
                end
            end
        end
    end

    return candidates
end

log("info", "Started. Target sequence: Stats.All -> Stat.Upgrade | Interval: " .. tostring(config.Interval) .. "s")

while config.Enabled do
    if allButton.Parent == nil or upgradeButton.Parent == nil then
        log("warning", "Button disappeared, waiting for it again.")
        equipmentGui, allButton, upgradeButton = getButtons()
    end

    local clicked = 0

    local sequence = { allButton, upgradeButton }
    for _, button in ipairs(sequence) do
        if button and button.Parent then
            local ok, method = clickGuiObject(button)
            if ok then
                clicked = clicked + 1
                log("success", "Clicked " .. button:GetFullName() .. " via " .. tostring(method))
            else
                log("warning", tostring(method))
            end
            task.wait(0.1)
        end
    end

    if clicked == 0 then
        for _, button in ipairs(getCandidateButtons()) do
            if button and button.Parent then
                local ok, method = clickGuiObject(button)
                if ok then
                    clicked = clicked + 1
                    log("success", "Clicked " .. button:GetFullName() .. " via " .. tostring(method))
                else
                    log("warning", tostring(method))
                end
                task.wait(0.1)
            end
        end
    end

    if clicked == 0 then
        if allButton then
            log("warning", "Button exists but is not visible. Open the Equipment upgrade UI.")
        else
            log("warning", "Button not found.")
        end
    end

    task.wait(config.Interval)
end

log("info", "Stopped.")
