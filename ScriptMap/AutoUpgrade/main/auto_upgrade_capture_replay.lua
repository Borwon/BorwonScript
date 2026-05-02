-- auto_upgrade_capture_replay.lua - Auto replay equipment upgrade payload.
-- Default: starts automatically after the game/Actor/remote load.
-- Fallback: set AutoStart = false to capture one real click first.

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")

local SOURCE = [==[
repeat task.wait() until game:IsLoaded()

if getgenv().AutoUpgradeCaptureReplayRunning then
    warn("[AutoUpgradeReplay] Already running.")
    return
end
getgenv().AutoUpgradeCaptureReplayRunning = true

getgenv().AutoUpgradeCaptureReplayConfig = getgenv().AutoUpgradeCaptureReplayConfig or {}
local config = getgenv().AutoUpgradeCaptureReplayConfig
if config.Enabled == nil then
    config.Enabled = true
end
if config.AutoStart == nil then
    config.AutoStart = true
end
local interval = tonumber(config.Interval) or 5
local autoStartDelay = tonumber(config.AutoStartDelay) or 10
local maxErrors = tonumber(config.MaxErrors) or 20
local defaultPayload = config.Payload or {
    "Blade_Durability",
    "ODM_Damage",
    "ODM_Gas",
    "ODM_Range",
    "ODM_Control",
    "Crit_Chance",
    "Crit_Damage",
    "ODM_Speed",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = ReplicatedStorage:WaitForChild("Assets", 30)
    and ReplicatedStorage.Assets:WaitForChild("Remotes", 30)
    and ReplicatedStorage.Assets.Remotes:WaitForChild("GET", 30)

if not Event then
    warn("[AutoUpgradeReplay] GET remote not found.")
    getgenv().AutoUpgradeCaptureReplayRunning = false
    return
end

local function log(kind, message)
    local text = "[AutoUpgradeReplay][" .. os.date("%H:%M:%S") .. "] " .. tostring(message)
    if kind == "error" or kind == "warning" then
        warn(text)
    else
        print(text)
    end
end

local function copyTable(value, seen)
    if type(value) ~= "table" then
        return value
    end

    seen = seen or {}
    if seen[value] then
        return value
    end
    seen[value] = true

    local output = {}
    for key, child in pairs(value) do
        output[key] = copyTable(child, seen)
    end

    return output
end

local function shortPayload(payload)
    if type(payload) ~= "table" then
        return tostring(payload)
    end

    local parts = {}
    for key, value in pairs(payload) do
        table.insert(parts, tostring(key) .. "=" .. tostring(value))
    end
    table.sort(parts)
    return table.concat(parts, ", ")
end

local function isUpgradeCall(args)
    return args.n >= 4
        and args[2] == "S_Equipment"
        and args[3] == "Upgrade"
        and type(args[4]) == "table"
end

local capturedService
local capturedAction
local capturedPayload
local replaying = false
local replayStarted = false

local function replayLoop(reason)
    if replayStarted then
        return
    end
    replayStarted = true

    task.spawn(function()
        task.wait(1)
        log("info", "Replay loop started (" .. tostring(reason or "manual") .. "). Interval: " .. tostring(interval) .. "s")

        local errors = 0
        while config.Enabled do
            replaying = true
            local ok, result = pcall(function()
                return Event:InvokeServer(capturedService, capturedAction, copyTable(capturedPayload))
            end)
            replaying = false

            if ok then
                errors = 0
                log("success", "Replayed upgrade. Result type: " .. typeof(result))
            else
                errors = errors + 1
                log("warning", "Replay failed (" .. tostring(errors) .. "/" .. tostring(maxErrors) .. "): " .. tostring(result))
                if errors >= maxErrors then
                    break
                end
            end

            task.wait(interval)
        end

        getgenv().AutoUpgradeCaptureReplayRunning = false
        log("info", "Stopped.")
    end)
end

if config.AutoStart then
    capturedService = "S_Equipment"
    capturedAction = "Upgrade"
    capturedPayload = copyTable(defaultPayload)

    log("info", "AutoStart enabled. Waiting " .. tostring(autoStartDelay) .. "s before replay. Payload: " .. shortPayload(capturedPayload))
    task.delay(autoStartDelay, function()
        replayLoop("auto")
    end)
else
    log("info", "AutoStart disabled. Waiting for one real manual upgrade click.")
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(...)
    local self = ...
    local method = getnamecallmethod()

    if not replaying and rawequal(self, Event) and method == "InvokeServer" then
        local args = table.pack(...)

        if isUpgradeCall(args) and not capturedPayload then
            capturedService = args[2]
            capturedAction = args[3]
            capturedPayload = copyTable(args[4])

            log("success", "Captured payload: " .. shortPayload(capturedPayload))
            replayLoop("capture")
        end
    end

    return oldNamecall(...)
end)
]==]

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local actor = character:WaitForChild("Actor", 30)

if typeof(run_on_actor) == "function" and actor then
    print("[AutoUpgradeReplayLauncher] Running inside Character.Actor")
    run_on_actor(actor, SOURCE)
else
    print("[AutoUpgradeReplayLauncher] run_on_actor unavailable, running fallback")
    loadstring(SOURCE)()
end
