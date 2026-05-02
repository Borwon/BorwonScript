repeat task.wait() until game:IsLoaded()

local TARGET_PLACE_ID = 14916516914

if game.PlaceId ~= TARGET_PLACE_ID then
    warn("[AutoPrestige] Disabled for PlaceId: " .. tostring(game.PlaceId))
    return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

repeat task.wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer

local LEVEL_CHECK_INTERVAL = 0.15
local TARGET_LEVELS = {
    [100] = true,
    [125] = true,
    [150] = true,
    [175] = true,
    [200] = true,
}

local function log(message)
    print("[AutoPrestige] " .. tostring(message))
end

local function Rejoin()
    local success = pcall(function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)

    if not success then
        warn("[AutoPrestige] Fail to rejoin")
    end
end

local function waitForPath(root, path, timeout)
    local current = root

    for _, name in ipairs(path) do
        if not current then
            return nil
        end

        current = current:WaitForChild(name, timeout)
    end

    return current
end

local function getLevelNumber(levelObject)
    if not levelObject then
        return nil
    end

    local ok, text = pcall(function()
        return levelObject.Text
    end)

    if not ok or not text then
        return nil
    end

    return tonumber(tostring(text):match("%d+"))
end

local function waitForTargetLevel()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local levelTitle = waitForPath(playerGui, { "Interface", "Gear_Up", "HUD", "Level", "Title" })

    while true do
        local level = getLevelNumber(levelTitle)

        if level and TARGET_LEVELS[level] then
            log("Target level found: " .. tostring(level))
            return level
        end

        task.wait(LEVEL_CHECK_INTERVAL)
    end
end

local function runPrestige()
    local getRemote = ReplicatedStorage.Assets.Remotes.GET

    getRemote:InvokeServer("S_Equipment", "Talents")

    local memoriesStorage = require(ReplicatedStorage.Modules.Storage.Memories)

    for _, talentGroup in pairs(memoriesStorage.Talents) do
        for _, talent in pairs(talentGroup) do
            if talent and talent.Tag then
                log("Prestige with talent: " .. tostring(talent.Tag))
                getRemote:InvokeServer("S_Equipment", "Prestige", {
                    Boosts = "Luck Boost",
                    Talents = talent.Tag,
                })
            end
        end
    end
end

waitForTargetLevel()
runPrestige()
Rejoin()
