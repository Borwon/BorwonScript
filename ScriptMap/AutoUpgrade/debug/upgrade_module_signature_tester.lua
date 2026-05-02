-- upgrade_module_signature_tester.lua - Try likely Equipment.Increase signatures.

repeat task.wait() until game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function log(message)
    print("[UpgradeSigTester][" .. os.date("%H:%M:%S") .. "] " .. tostring(message))
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

local upgrades = {
    "Blade_Durability",
    "ODM_Damage",
    "ODM_Gas",
    "ODM_Range",
    "ODM_Control",
    "Crit_Chance",
    "Crit_Damage",
    "ODM_Speed",
}

local moduleScript = findEquipmentModule()
if not moduleScript then
    warn("[UpgradeSigTester] Equipment module not found.")
    return
end

local okRequire, equipment = pcall(require, moduleScript)
if not okRequire then
    warn("[UpgradeSigTester] require failed: " .. tostring(equipment))
    return
end

if type(equipment) ~= "table" or type(equipment.Increase) ~= "function" then
    warn("[UpgradeSigTester] Equipment.Increase not found.")
    return
end

local states = {
    { name = "equipment.State", value = equipment.State },
    { name = "Out", value = "Out" },
    { name = "In", value = "In" },
    { name = "nil", value = nil },
    { name = "module", value = equipment },
}

local categories = {
    "All",
    "Upgrade_Category",
    "Stats",
    "Stat",
    "Upgrade",
    "Crit",
    "Blade",
    "ODM",
}

for _, stat in ipairs(upgrades) do
    table.insert(categories, stat)
end

local payloads = {
    { name = "upgrades-list", value = upgrades },
    { name = "named-Upgrades", value = { Upgrades = upgrades } },
    { name = "all-true-map", value = {
        Blade_Durability = true,
        ODM_Damage = true,
        ODM_Gas = true,
        ODM_Range = true,
        ODM_Control = true,
        Crit_Chance = true,
        Crit_Damage = true,
        ODM_Speed = true,
    } },
}

log("Started. Module: " .. moduleScript:GetFullName())

for _, state in ipairs(states) do
    for _, category in ipairs(categories) do
        for _, payload in ipairs(payloads) do
            local ok, result = pcall(function()
                return equipment.Increase(state.value, category, payload.value)
            end)

            if ok then
                log("ok state=" .. state.name .. " category=" .. tostring(category) .. " payload=" .. payload.name .. " result=" .. typeof(result))
            else
                log("err state=" .. state.name .. " category=" .. tostring(category) .. " payload=" .. payload.name .. " error=" .. tostring(result))
            end

            task.wait(0.2)
        end
    end
end

log("Finished.")
