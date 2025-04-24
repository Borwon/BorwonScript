-- ===== BorwonCheck - Enhanced Loader Version =====
-- Improved script loader without UI

-- Function to wait for game to load with optimized checks
local function waitForGameLoaded(timeout)
    timeout = timeout or 15 -- Default timeout of 15 seconds
    local startTime = tick()

    -- Wait until the game is loaded
    if not game:IsLoaded() then
        repeat
            if tick() - startTime > timeout then
                return false
            end
            task.wait(0.2) -- Reduced wait time for faster checks
        until game:IsLoaded()
    end

    -- Check if important services are loaded
    local services = {
        "Players",
        "ReplicatedStorage",
        "Workspace",
        "StarterGui",
        "TweenService"
    }

    for _, serviceName in ipairs(services) do
        pcall(function()
            game:GetService(serviceName)
        end)
        task.wait(0.05) -- Reduced delay for service checks
    end

    return true
end

-- Main function to run the loader
local function runLoader()
    -- Wait for game to load
    local gameLoaded = waitForGameLoaded(15)
    if not gameLoaded then
        warn("Game loading timeout!")
        return
    end

    -- Check current game ID
    local currentGame = game.PlaceId
    print("Checking game ID: " .. currentGame)

    -- Run map-specific script if found
    local matchedScript = nil
    for _, script in ipairs(scripts) do
        for _, id in ipairs(script.ids) do
            if id == currentGame then
                matchedScript = script
                break
            end
        end
        if matchedScript then break end
    end

    if matchedScript then
        local mapName = matchedScript.name
        local scriptUrl = matchedScript.url
        print("Found script: " .. mapName)
        loadAndRunScript(mapName, scriptUrl)
    else
        print("No map-specific script found for this game (ID: " .. currentGame .. ")")
    end

    -- Always run the universal script
    if config.universalScript.enabled then
        local universalName = config.universalScript.name
        local universalUrl = config.universalScript.url
        print("Running universal script: " .. universalName)
        loadAndRunScript(universalName, universalUrl)
    end
end

-- Function to load and run a script with error handling
local function loadAndRunScript(name, url)
    print("Loading script for: " .. name)
    local executor = loadstring or load
    if not executor then
        warn("No loadstring/load function available.")
        return
    end

    local success, err = pcall(function()
        local response = game:HttpGet(url)
        if not response or response == "" then
            error("Empty or invalid response.")
        end
        executor(response)()
    end)

    if not success then
        warn("Script load failed: " .. tostring(err))
    else
        print("Script loaded successfully: " .. name)
    end
end

-- Configuration table for easier management
local config = {
    universalScript = {
        enabled = true, -- Enable or disable the universal script
        name = "AutoKickandRejoin",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/other/AutoKickandRejoin.lua"
    }
}

-- Table of scripts for different games
local scripts = {
    {
        ids = {116614712661486}, -- Example Game IDs for AriseCrossoverAFK
        name = "AriseCrossoverAFK",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/AriseRam.lua"
    },
    {
        ids = {115110570222234, 18668065416}, -- Example Game IDs for BlueLockRivals
        name = "BlueLockRivals",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/BlueLockRam.lua"
    },
    {
        ids = {72829404259339}, -- Example Game IDs for AnimeRangerX
        name = "AnimeRangerX",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/AnimeRangerX.lua"
    },
}

-- Start the loader
runLoader()
