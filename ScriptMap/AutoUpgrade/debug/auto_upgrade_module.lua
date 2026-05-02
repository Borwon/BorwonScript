-- auto_upgrade_module.lua - Auto upgrade through the game's Equipment module.
-- Based on stack trace:
-- ReplicatedStorage.Modules.User Interface.Equipment, line 660 - function Increase

repeat task.wait() until game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage")

getgenv().AutoUpgradeModuleConfig = getgenv().AutoUpgradeModuleConfig or {}

local config = getgenv().AutoUpgradeModuleConfig
if config.Enabled == nil then
    config.Enabled = true
end
config.Interval = tonumber(config.Interval) or 5
config.MaxErrors = tonumber(config.MaxErrors) or 20
if config.Mode == nil or config.Mode == "SelfThenDirect" or config.Mode == "Self" or config.Mode == "Direct" then
    config.Mode = "AutoSignature"
end
-- AutoSignature, Signature
config.State = config.State or "Out"
config.Category = config.Category or "All"

local upgrades = config.Upgrades or {
    "Blade_Durability",
    "ODM_Damage",
    "ODM_Gas",
    "ODM_Range",
    "ODM_Control",
    "Crit_Chance",
    "Crit_Damage",
    "ODM_Speed",
}

local function log(kind, message)
    local text = "[AutoUpgradeModule][" .. os.date("%H:%M:%S") .. "] " .. tostring(message)
    if kind == "error" or kind == "warning" then
        warn(text)
    else
        print(text)
    end
end

local function findEquipmentModule()
    local modules = ReplicatedStorage:WaitForChild("Modules", 30)
    if not modules then
        return nil
    end

    for _, object in ipairs(modules:GetDescendants()) do
        if object:IsA("ModuleScript") and object.Name == "Equipment" then
            return object
        end
    end

    return nil
end

local moduleScript = findEquipmentModule()
if not moduleScript then
    log("error", "ModuleScript not found: ReplicatedStorage.Modules.*.Equipment")
    return
end

local okRequire, equipmentModule = pcall(require, moduleScript)
if not okRequire then
    log("error", "Failed to require Equipment module: " .. tostring(equipmentModule))
    return
end

local increase = type(equipmentModule) == "table" and equipmentModule.Increase
if type(increase) ~= "function" then
    log("error", "Equipment module has no Increase function. Type: " .. type(increase))
    return
end

log("info", "Started. Module: " .. moduleScript:GetFullName() .. " | Mode: " .. tostring(config.Mode) .. " | Interval: " .. tostring(config.Interval) .. "s")

local errors = 0

local function callIncrease()
    if config.Mode == "AutoSignature" then
        local states = {
            equipmentModule.State,
            config.State,
            "Out",
            "In",
        }

        local categories = {
            config.Category,
            "All",
        }

        local lastResult
        for _, state in ipairs(states) do
            if state ~= nil then
                for _, category in ipairs(categories) do
                    lastResult = increase(state, category, upgrades)
                    task.wait(0.15)
                end
            end
        end

        return lastResult
    end

    if config.Mode == "Signature" then
        return increase(config.State, config.Category, upgrades)
    end

    if config.Mode == "Self" then
        return increase(equipmentModule, upgrades)
    end

    if config.Mode == "Direct" then
        return increase(upgrades)
    end

    local result = increase(equipmentModule, upgrades)
    increase(upgrades)
    return result
end

while config.Enabled do
    local ok, result = pcall(function()
        return callIncrease()
    end)

    if ok then
        errors = 0
        log("success", "Increase called. Result type: " .. typeof(result))
    else
        errors = errors + 1
        log("warning", "Increase failed (" .. tostring(errors) .. "/" .. tostring(config.MaxErrors) .. "): " .. tostring(result))

        if errors >= config.MaxErrors then
            log("error", "Stopped after too many errors.")
            break
        end
    end

    task.wait(config.Interval)
end

log("info", "Stopped.")
