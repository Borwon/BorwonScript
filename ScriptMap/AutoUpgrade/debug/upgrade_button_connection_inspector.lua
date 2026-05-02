-- upgrade_button_connection_inspector.lua - Inspect actual upgrade button callbacks.
-- No hooks. Opens no remotes. Run after the Equipment UI exists.

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")

local function log(message)
    print("[UpgradeButtonInspector][" .. os.date("%H:%M:%S") .. "] " .. tostring(message))
end

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 30)
local equipment = playerGui
    and playerGui:WaitForChild("Interface", 30)
    and playerGui.Interface:WaitForChild("Equipment", 30)

if not equipment then
    warn("[UpgradeButtonInspector] Equipment UI not found.")
    return
end

local buttons = {
    equipment:FindFirstChild("Stats") and equipment.Stats:FindFirstChild("All"),
    equipment:FindFirstChild("Stat") and equipment.Stat:FindFirstChild("Upgrade"),
}

local function inspectFunction(label, fn)
    if type(fn) ~= "function" then
        log(label .. " callback is " .. type(fn))
        return
    end

    log(label .. " callback=" .. tostring(fn))

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
            log(label .. " constants=" .. table.concat(parts, " | "))
        end
    end

    if debug and debug.getupvalues then
        local ok, upvalues = pcall(debug.getupvalues, fn)
        if ok and type(upvalues) == "table" then
            local parts = {}
            for i, upvalue in ipairs(upvalues) do
                if i > 60 then
                    table.insert(parts, "...")
                    break
                end
                table.insert(parts, tostring(i) .. ":" .. type(upvalue) .. "=" .. tostring(upvalue))
            end
            log(label .. " upvalues=" .. table.concat(parts, " | "))
        end
    end
end

local function inspectSignal(button, signalName)
    if not button or not button[signalName] then
        return
    end

    if typeof(getconnections) ~= "function" then
        log("getconnections is not available.")
        return
    end

    local ok, connections = pcall(getconnections, button[signalName])
    if not ok or type(connections) ~= "table" then
        log(button:GetFullName() .. "." .. signalName .. " getconnections failed: " .. tostring(connections))
        return
    end

    log(button:GetFullName() .. "." .. signalName .. " connections=" .. tostring(#connections))

    for index, connection in ipairs(connections) do
        local fn = connection.Function or connection.func or connection._function
        inspectFunction(button.Name .. "." .. signalName .. "[" .. tostring(index) .. "]", fn)
    end
end

for _, button in ipairs(buttons) do
    if button then
        log("Button: " .. button:GetFullName() .. " class=" .. button.ClassName)
        inspectSignal(button, "MouseButton1Click")
        inspectSignal(button, "Activated")
        inspectSignal(button, "MouseButton1Down")
        inspectSignal(button, "MouseButton1Up")
    end
end

log("Finished.")
