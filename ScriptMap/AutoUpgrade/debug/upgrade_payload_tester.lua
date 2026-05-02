-- upgrade_payload_tester.lua - No-hook payload tester for equipment upgrade.
-- This does not use hookmetamethod/hookfunction, so it should not crash from spying.

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")

local TESTER_SOURCE = [==[
repeat task.wait() until game:IsLoaded()

if getgenv().UpgradePayloadTesterRunning then
    warn("[UpgradeTester] Already running in Actor.")
    return
end
getgenv().UpgradePayloadTesterRunning = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local function log(message)
    print("[UpgradeTester][" .. os.date("%H:%M:%S") .. "] " .. tostring(message))
end

local assets = ReplicatedStorage:WaitForChild("Assets", 30)
local remotes = assets and assets:WaitForChild("Remotes", 30)
local Event = remotes and remotes:WaitForChild("GET", 30)

if not Event then
    warn("[UpgradeTester] Remote not found.")
    getgenv().UpgradePayloadTesterRunning = false
    return
end

local tests = {
    {
        name = "batch_list",
        args = function()
            return "S_Equipment", "Upgrade", upgrades
        end,
    },
    {
        name = "single_table_each",
        each = true,
        args = function(stat)
            return "S_Equipment", "Upgrade", { stat }
        end,
    },
    {
        name = "single_string_each",
        each = true,
        args = function(stat)
            return "S_Equipment", "Upgrade", stat
        end,
    },
    {
        name = "table_named_upgrades",
        args = function()
            return "S_Equipment", "Upgrade", { Upgrades = upgrades }
        end,
    },
    {
        name = "table_named_stats",
        args = function()
            return "S_Equipment", "Upgrade", { Stats = upgrades }
        end,
    },
    {
        name = "table_named_items",
        args = function()
            return "S_Equipment", "Upgrade", { Items = upgrades }
        end,
    },
}

local function invokeTest(test, stat)
    local ok, result = pcall(function()
        return Event:InvokeServer(test.args(stat))
    end)

    if ok then
        log(test.name .. (stat and (" / " .. stat) or "") .. " -> ok, result type: " .. typeof(result))
    else
        warn("[UpgradeTester] " .. test.name .. (stat and (" / " .. stat) or "") .. " -> error: " .. tostring(result))
    end

    task.wait(1)
end

log("Started. Watch the in-game upgrade level/resources while tests run.")

for _, test in ipairs(tests) do
    if test.each then
        for _, stat in ipairs(upgrades) do
            invokeTest(test, stat)
        end
    else
        invokeTest(test)
    end
end

log("Finished.")
getgenv().UpgradePayloadTesterRunning = false
]==]

local function log(message)
    print("[UpgradeTesterLauncher][" .. os.date("%H:%M:%S") .. "] " .. tostring(message))
end

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local actor = character:WaitForChild("Actor", 30)

if typeof(run_on_actor) == "function" and actor then
    log("Running inside Character.Actor")
    run_on_actor(actor, TESTER_SOURCE)
else
    log("run_on_actor unavailable, running direct fallback")
    loadstring(TESTER_SOURCE)()
end
