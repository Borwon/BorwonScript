-- upgrade_remote_spy.lua - Lightweight Luau-safe spy for Actor remote calls.
-- Run this, manually click one real equipment upgrade, then copy [UpgradeSpy] logs.

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")

local SPY_SOURCE = [==[
repeat task.wait() until game:IsLoaded()

if getgenv().UpgradeSpyRunning then
    warn("[UpgradeSpy] Already running in Actor.")
    return
end
getgenv().UpgradeSpyRunning = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local assets = ReplicatedStorage:WaitForChild("Assets", 30)
local remotesFolder = assets and assets:WaitForChild("Remotes", 30)

if not remotesFolder then
    warn("[UpgradeSpy] ReplicatedStorage.Assets.Remotes not found.")
    return
end

local KEYWORDS = {
    "equipment",
    "upgrade",
    "blade",
    "odm",
    "crit",
    "durability",
    "damage",
    "gas",
    "range",
    "control",
    "speed",
}

local function copyValue(value, depth, seen)
    depth = depth or 0
    seen = seen or {}

    if depth > 3 then
        return "<max depth>"
    end

    local valueType = typeof(value)
    if valueType == "Instance" then
        return value:GetFullName()
    end

    if type(value) ~= "table" then
        return tostring(value)
    end

    if seen[value] then
        return "<cycle>"
    end
    seen[value] = true

    local output = {}
    local count = 0

    for key, child in pairs(value) do
        count = count + 1
        if count > 40 then
            output["..."] = "truncated"
            break
        end

        output[tostring(key)] = copyValue(child, depth + 1, seen)
    end

    return output
end

local function encodeArgs(args, startIndex)
    local output = {}

    for i = startIndex, args.n do
        output[#output + 1] = copyValue(args[i])
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(output)
    end)

    if ok then
        return encoded
    end

    return "<encode failed>"
end

local function isInteresting(remote, argText)
    local text = string.lower(tostring(remote.Name) .. " " .. tostring(remote.ClassName) .. " " .. tostring(argText))

    for _, keyword in ipairs(KEYWORDS) do
        if string.find(text, keyword, 1, true) then
            return true
        end
    end

    return false
end

print("[UpgradeSpy] Started in Actor. Click one equipment upgrade manually now.")

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(...)
    local self = ...
    local method = getnamecallmethod()

    if typeof(self) == "Instance"
        and self:IsDescendantOf(remotesFolder)
        and (method == "InvokeServer" or method == "FireServer")
    then
        local args = table.pack(...)
        local argText = encodeArgs(args, 2)

        if isInteresting(self, argText) then
            print("[UpgradeSpy] " .. self:GetFullName() .. ":" .. method .. " ARGS " .. argText)
        end
    end

    return oldNamecall(...)
end)
]==]

local function log(message)
    print("[UpgradeSpyLauncher][" .. os.date("%H:%M:%S") .. "] " .. tostring(message))
end

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local actor = character:WaitForChild("Actor", 30)

if typeof(run_on_actor) == "function" and actor then
    log("Running inside Character.Actor")
    run_on_actor(actor, SPY_SOURCE)
else
    log("run_on_actor unavailable, running direct fallback")
    loadstring(SPY_SOURCE)()
end
