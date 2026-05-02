-- upgrade_module_inspector.lua - Inspect upgrade-related modules without hooks.

repeat task.wait() until game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function log(message)
    print("[UpgradeInspector][" .. os.date("%H:%M:%S") .. "] " .. tostring(message))
end

local function findModuleByName(name)
    local modules = ReplicatedStorage:WaitForChild("Modules", 30)
    if not modules then
        return nil
    end

    for _, object in ipairs(modules:GetDescendants()) do
        if object:IsA("ModuleScript") and object.Name == name then
            return object
        end
    end

    return nil
end

local function listTableKeys(label, value)
    if type(value) ~= "table" then
        log(label .. " is " .. type(value))
        return
    end

    local keys = {}
    for key, child in pairs(value) do
        table.insert(keys, tostring(key) .. ":" .. type(child))
    end
    table.sort(keys)
    log(label .. " keys = " .. table.concat(keys, ", "))
end

local function inspectFunction(label, fn)
    if type(fn) ~= "function" then
        log(label .. " is " .. type(fn))
        return
    end

    log(label .. " = " .. tostring(fn))

    if debug and debug.getinfo then
        local ok, info = pcall(debug.getinfo, fn)
        if ok and info then
            log(label .. " info source=" .. tostring(info.source) .. " line=" .. tostring(info.linedefined) .. " params=" .. tostring(info.numparams) .. " vararg=" .. tostring(info.isvararg))
        end
    end

    if debug and debug.getconstants then
        local ok, constants = pcall(debug.getconstants, fn)
        if ok and type(constants) == "table" then
            local parts = {}
            for i, constant in ipairs(constants) do
                if i > 80 then
                    table.insert(parts, "...")
                    break
                end
                table.insert(parts, tostring(i) .. "=" .. tostring(constant))
            end
            log(label .. " constants = " .. table.concat(parts, " | "))
        end
    end

    if debug and debug.getupvalues then
        local ok, upvalues = pcall(debug.getupvalues, fn)
        if ok and type(upvalues) == "table" then
            local parts = {}
            for i, upvalue in ipairs(upvalues) do
                if i > 50 then
                    table.insert(parts, "...")
                    break
                end
                table.insert(parts, tostring(i) .. ":" .. type(upvalue) .. "=" .. tostring(upvalue))
            end
            log(label .. " upvalues = " .. table.concat(parts, " | "))
        end
    end
end

local moduleNames = {
    "Equipment",
    "Interactions",
    "Effects",
}

for _, moduleName in ipairs(moduleNames) do
    local moduleScript = findModuleByName(moduleName)
    if not moduleScript then
        log("Module not found: " .. moduleName)
        continue
    end

    log("Module found: " .. moduleScript:GetFullName())

    local ok, moduleValue = pcall(require, moduleScript)
    if not ok then
        log("Require failed for " .. moduleName .. ": " .. tostring(moduleValue))
        continue
    end

    listTableKeys(moduleName, moduleValue)

    if type(moduleValue) == "table" then
        inspectFunction(moduleName .. ".Increase", moduleValue.Increase)
        inspectFunction(moduleName .. ".Invoke", moduleValue.Invoke)
        inspectFunction(moduleName .. ".Get", moduleValue.Get)
        inspectFunction(moduleName .. ".Init", moduleValue.Init)
    end
end
