-- upgrade_replay_spy.lua - Capture the real GET upgrade args, then replay them.
-- Focused hook only. Run this, click one real upgrade manually.

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")

local SOURCE = [==[
repeat task.wait() until game:IsLoaded()

if getgenv().UpgradeReplaySpyRunning then
    warn("[UpgradeReplay] Already running.")
    return
end
getgenv().UpgradeReplaySpyRunning = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = ReplicatedStorage:WaitForChild("Assets", 30)
    and ReplicatedStorage.Assets:WaitForChild("Remotes", 30)
    and ReplicatedStorage.Assets.Remotes:WaitForChild("GET", 30)

if not Event then
    warn("[UpgradeReplay] GET remote not found.")
    return
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

print("[UpgradeReplay] Started. Click one real upgrade manually.")

local replaying = false
local captured = false

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(...)
    local self = ...
    local method = getnamecallmethod()

    if not replaying and rawequal(self, Event) and method == "InvokeServer" then
        local args = table.pack(...)

        if isUpgradeCall(args) then
            print("[UpgradeReplay] Captured real call payload: " .. shortPayload(args[4]))

            if not captured then
                captured = true

                local service = args[2]
                local action = args[3]
                local payload = copyTable(args[4])

                task.defer(function()
                    task.wait(0.75)
                    print("[UpgradeReplay] Replaying captured call once.")

                    replaying = true
                    local ok, result = pcall(function()
                        return Event:InvokeServer(service, action, payload)
                    end)
                    replaying = false

                    print("[UpgradeReplay] Replay result ok=" .. tostring(ok) .. " type=" .. (ok and typeof(result) or type(result)) .. " value=" .. tostring(result))
                end)
            end
        end
    end

    return oldNamecall(...)
end)
]==]

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local actor = character:WaitForChild("Actor", 30)

if typeof(run_on_actor) == "function" and actor then
    print("[UpgradeReplayLauncher] Running inside Character.Actor")
    run_on_actor(actor, SOURCE)
else
    print("[UpgradeReplayLauncher] run_on_actor unavailable, running fallback")
    loadstring(SOURCE)()
end
