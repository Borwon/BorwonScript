-- auto_upgrade.lua - Auto equipment upgrade from the game's Actor environment
-- Origin script path: Players.LocalPlayer.Character.Actor.Client
-- Remote path: ReplicatedStorage.Assets.Remotes.GET

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")

local ACTOR_SOURCE = [==[
    repeat task.wait() until game:IsLoaded()

    if getgenv().AutoUpgradeActorRunning then
        warn("[AutoUpgrade] Already running in Actor.")
        return
    end
    getgenv().AutoUpgradeActorRunning = true

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

    local config = getgenv().AutoUpgradeConfig or {}
    if config.Enabled == nil then
        config.Enabled = true
    end

    local interval = tonumber(config.Interval) or 5
    local upgradeDelay = tonumber(config.UpgradeDelay) or 0.2
    local maxErrors = tonumber(config.MaxErrors) or 20
    local mode = config.Mode or "BatchThenSingle" -- Batch, Single, BatchThenSingle

    local function log(kind, message)
        local text = "[AutoUpgrade][" .. os.date("%H:%M:%S") .. "] " .. tostring(message)
        if kind == "error" or kind == "warning" then
            warn(text)
        else
            print(text)
        end
    end

    local function waitForRemote()
        local assets = ReplicatedStorage:WaitForChild("Assets", 30)
        local remotes = assets and assets:WaitForChild("Remotes", 30)
        local remote = remotes and remotes:WaitForChild("GET", 30)
        return remote
    end

    local function findUpgradeNode(root, upgradeName, depth, seen)
        if type(root) ~= "table" then
            return nil
        end

        depth = depth or 0
        seen = seen or {}

        if depth > 12 or seen[root] then
            return nil
        end
        seen[root] = true

        local direct = root[upgradeName]
        if type(direct) == "table" then
            return direct
        end

        for _, child in pairs(root) do
            if type(child) == "table" then
                local found = findUpgradeNode(child, upgradeName, depth + 1, seen)
                if found then
                    return found
                end
            end
        end

        return nil
    end

    local function summarizeResult(result)
        if type(result) ~= "table" then
            return tostring(result)
        end

        local parts = {}
        for _, upgradeName in ipairs(upgrades) do
            local node = findUpgradeNode(result, upgradeName)
            if node then
                local level = node.Level or node.level or "?"
                local xp = node.XP or node.Exp or node.exp
                if xp ~= nil then
                    table.insert(parts, upgradeName .. "=Lv." .. tostring(level) .. " XP:" .. tostring(xp))
                else
                    table.insert(parts, upgradeName .. "=Lv." .. tostring(level))
                end
            end
        end

        if #parts == 0 then
            return "table returned, upgrade nodes not found"
        end

        return table.concat(parts, " | ")
    end

    local Event = waitForRemote()
    if not Event then
        log("error", "Remote not found: ReplicatedStorage.Assets.Remotes.GET")
        getgenv().AutoUpgradeActorRunning = false
        return
    end

    log("info", "Started in Actor environment. Mode: " .. tostring(mode) .. " | Interval: " .. tostring(interval) .. "s")

    local errors = 0

    local function invokeUpgrade(payload)
        local ok, result = pcall(function()
            return Event:InvokeServer(
                "S_Equipment",
                "Upgrade",
                payload
            )
        end)

        if ok then
            return true, result
        end

        return false, result
    end

    local function runBatch()
        local ok, result = invokeUpgrade(upgrades)
        if ok then
            log("success", "Batch invoked. " .. summarizeResult(result))
        end
        return ok, result
    end

    local function runSingle()
        local lastResult
        for _, upgradeName in ipairs(upgrades) do
            if not config.Enabled then
                break
            end

            local ok, result = invokeUpgrade({ upgradeName })
            lastResult = result

            if ok then
                log("success", "Single invoked: " .. tostring(upgradeName) .. ". " .. summarizeResult(result))
            else
                return false, result
            end

            task.wait(upgradeDelay)
        end

        return true, lastResult
    end

    while config.Enabled do
        local ok, result

        if mode == "Batch" then
            ok, result = runBatch()
        elseif mode == "Single" then
            ok, result = runSingle()
        else
            ok, result = runBatch()
            task.wait(upgradeDelay)
            if ok then
                ok, result = runSingle()
            end
        end

        if ok then
            errors = 0
        else
            errors = errors + 1
            log("warning", "Invoke failed (" .. tostring(errors) .. "/" .. tostring(maxErrors) .. "): " .. tostring(result))
            if errors >= maxErrors then
                break
            end
        end

        task.wait(interval)
    end

    getgenv().AutoUpgradeActorRunning = false
    log("info", "Stopped.")
]==]

local function log(kind, message)
    local text = "[AutoUpgradeLauncher][" .. os.date("%H:%M:%S") .. "] " .. tostring(message)
    if kind == "error" or kind == "warning" then
        warn(text)
    else
        print(text)
    end
end

local function runDirectFallback()
    log("warning", "run_on_actor/getactors not available. Running direct fallback.")
    loadstring(ACTOR_SOURCE)()
end

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local actor = character:WaitForChild("Actor", 30)

if typeof(run_on_actor) ~= "function" then
    runDirectFallback()
    return
end

if actor then
    log("info", "Running inside Character.Actor")
    run_on_actor(actor, ACTOR_SOURCE)
    return
end

if typeof(getactors) == "function" then
    for _, foundActor in ipairs(getactors()) do
        if foundActor.Name == "Actor" and foundActor:IsDescendantOf(character) then
            log("info", "Running inside found Character.Actor")
            run_on_actor(foundActor, ACTOR_SOURCE)
            return
        end
    end
end

runDirectFallback()
