-- get_upgrade_spy.lua - Focused spy for ReplicatedStorage.Assets.Remotes.GET.
-- Run this, click one real equipment upgrade, then copy the [GET SPY] log.

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")

local SPY_SOURCE = [==[
repeat task.wait() until game:IsLoaded()

if getgenv().GetUpgradeSpyRunning then
    warn("[GET SPY] Already running.")
    return
end
getgenv().GetUpgradeSpyRunning = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Event = ReplicatedStorage:WaitForChild("Assets", 30)
    and ReplicatedStorage.Assets:WaitForChild("Remotes", 30)
    and ReplicatedStorage.Assets.Remotes:WaitForChild("GET", 30)

if not Event then
    warn("[GET SPY] GET remote not found.")
    return
end

local function safeCopy(value, depth, seen)
    depth = depth or 0
    seen = seen or {}

    if depth > 6 then
        return "<max depth>"
    end

    local valueType = typeof(value)
    if valueType == "Instance" then
        return value:GetFullName()
    end

    if type(value) ~= "table" then
        return value
    end

    if seen[value] then
        return "<cycle>"
    end
    seen[value] = true

    local output = {}
    local count = 0

    for key, child in pairs(value) do
        count = count + 1
        if count > 80 then
            output["..."] = "truncated"
            break
        end

        output[tostring(key)] = safeCopy(child, depth + 1, seen)
    end

    return output
end

local function encodeArgs(args)
    local output = {}
    for i = 2, args.n do
        output[#output + 1] = safeCopy(args[i])
    end

    local ok, encoded = pcall(function()
        return HttpService.JSONEncode(HttpService, output)
    end)

    if ok then
        return encoded
    end

    return "<JSONEncode failed>"
end

local function isUpgradeCall(args)
    return args.n >= 4
        and args[2] == "S_Equipment"
        and args[3] == "Upgrade"
end

print("[GET SPY] Started. Click the real upgrade button once.")

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(...)
    local self = ...
    local method = getnamecallmethod()

    if rawequal(self, Event) and method == "InvokeServer" then
        local args = table.pack(...)

        if isUpgradeCall(args) then
            print("[GET SPY] InvokeServer ARGS " .. encodeArgs(args))
        end
    end

    return oldNamecall(...)
end)
]==]

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local actor = character:WaitForChild("Actor", 30)

if typeof(run_on_actor) == "function" and actor then
    print("[GET SPY Launcher] Running inside Character.Actor")
    run_on_actor(actor, SPY_SOURCE)
else
    print("[GET SPY Launcher] run_on_actor unavailable, running fallback")
    loadstring(SPY_SOURCE)()
end
