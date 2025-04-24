-- ===== BorwonCheck - Enhanced Loader Version =====
-- Improved script loader with auto-rejoin support

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
        enabled = true, -- เปิดใช้งาน Universal Script หรือไม่
        name = "AutoKickandRejoin", -- ชื่อของ Universal Script
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/other/AutoKickandRejoin.lua" -- ลิงก์ไปยังสคริปต์
    },
    autoReload = true, -- เปิดใช้งานการโหลดสคริปต์อัตโนมัติหลังจาก rejoin
    debugMode = true -- เปิดใช้งานโหมด debug
}

-- Table of scripts for different games
local scripts = {
    {
        ids = {116614712661486}, -- Example Game IDs for AriseCrossoverAFK
        name = "AriseCrossoverAFK",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/AriseRam.lua"
    },
    {
        ids = {18668065416}, -- Example Game IDs for BlueLockRivals
        name = "BlueLockRivals",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/BlueLockRam.lua"
    },
    {
        ids = {72829404259339}, -- Example Game IDs for AnimeRangerX
        name = "AnimeRangerX",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/AnimeRangerX.lua"
    },
}

-- Debugging function
local function debugLog(message)
    if config.debugMode then
        print("[DEBUG] " .. message)
    end
end

-- Debugging: Print the state of 'scripts' and 'config'
debugLog("scripts = " .. (type(scripts) == "table" and "table" or tostring(scripts)))
debugLog("config = " .. (type(config) == "table" and "table" or tostring(config)))

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
    if type(scripts) == "table" then -- Ensure 'scripts' is a valid table
        for _, script in ipairs(scripts) do
            for _, id in ipairs(script.ids) do
                if id == currentGame then
                    matchedScript = script
                    break
                end
            end
            if matchedScript then break end
        end
    else
        warn("'scripts' is not a valid table. Debug: scripts = " .. tostring(scripts))
    end

    local mapName = "Unknown Map"
    if matchedScript then
        mapName = matchedScript.name
        local scriptUrl = matchedScript.url
        print("Found script: " .. mapName)
        loadAndRunScript(mapName, scriptUrl)
    else
        print("No map-specific script found for this game (ID: " .. currentGame .. ")")
    end

    -- Always run the universal script
    if config and config.universalScript and config.universalScript.enabled then
        local universalName = config.universalScript.name
        local universalUrl = config.universalScript.url
        print("Running universal script: " .. universalName .. " for map: " .. mapName)
        loadAndRunScript(universalName, universalUrl)
    else
        warn("'config' or 'config.universalScript' is not properly defined. Debug: config = " .. tostring(config))
    end
end

-- ===== เพิ่มระบบตรวจจับการเข้าเกมใหม่ =====

-- ตัวแปรเก็บสถานะว่าสคริปต์ได้ทำงานแล้วหรือยัง
local hasRunInitially = false

-- ฟังก์ชันสำหรับตรวจสอบเมื่อเข้าเกมใหม่
local function setupRejoinDetection()
    -- ตรวจจับเมื่อ LocalPlayer เข้าเกม
    game:GetService("Players").PlayerAdded:Connect(function(player)
        if player == game:GetService("Players").LocalPlayer then
            debugLog("LocalPlayer เข้าเกมใหม่ - เตรียมรันสคริปต์อีกครั้ง")
            -- รอให้เกมโหลดเสร็จก่อนรันสคริปต์
            task.wait(5)
            runLoader()
        end
    end)
    
    -- ตรวจจับเมื่อ Character เกิดใหม่ (อาจเกิดจากการ respawn หรือ rejoin)
    if game:GetService("Players").LocalPlayer then
        game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
            debugLog("Character เกิดใหม่ - ตรวจสอบว่าเป็นการ rejoin หรือไม่")
            -- ตรวจสอบว่าเป็นการ rejoin จริงๆ หรือแค่ respawn ธรรมดา
            task.wait(2)
            if not hasRunInitially then
                debugLog("รันสคริปต์ครั้งแรกหลังจาก Character เกิด")
                runLoader()
                hasRunInitially = true
            else
                -- ใช้ตัวแปรเพื่อป้องกันการรันซ้ำเมื่อเพิ่ง respawn ธรรมดา
                local lastRun = tick()
                task.wait(3) -- รอสักครู่เพื่อให้แน่ใจว่าเป็นการ rejoin จริงๆ
                if tick() - lastRun >= 3 then
                    debugLog("ตรวจพบการ rejoin - รันสคริปต์อีกครั้ง")
                    runLoader()
                end
            end
        end)
    end
    
    -- ตรวจจับเมื่อเกมโหลดเสร็จ (สำหรับกรณีที่สคริปต์ถูกรันก่อนเกมโหลดเสร็จ)
    if not game:IsLoaded() then
        game.Loaded:Connect(function()
            debugLog("เกมโหลดเสร็จแล้ว - รันสคริปต์")
            task.wait(5)
            runLoader()
        end)
    end
    
    -- ตรวจจับการเปลี่ยนแปลง PlaceId (เมื่อเข้าแมพใหม่)
    local currentPlaceId = game.PlaceId
    task.spawn(function()
        while true do
            task.wait(5)
            if game.PlaceId ~= currentPlaceId then
                debugLog("ตรวจพบการเปลี่ยนแมพ - รันสคริปต์อีกครั้ง")
                currentPlaceId = game.PlaceId
                runLoader()
            end
        end
    end)
    
    -- ตรวจจับเมื่อ TeleportService ทำงาน
    game:GetService("TeleportService").TeleportInitFailed:Connect(function()
        debugLog("การเทเลพอร์ตล้มเหลว - ลองรันสคริปต์อีกครั้ง")
        task.wait(5)
        runLoader()
    end)
end

-- ตั้งค่าการตรวจจับ rejoin
setupRejoinDetection()

-- รันสคริปต์ครั้งแรก
if not hasRunInitially then
    debugLog("รันสคริปต์ครั้งแรก")
    runLoader()
    hasRunInitially = true
end

-- เพิ่มการตรวจสอบเพื่อรันสคริปต์อีกครั้งหลังจากเวลาผ่านไป (เผื่อกรณีที่การตรวจจับอื่นๆ ล้มเหลว)
task.spawn(function()
    while config.autoReload do
        task.wait(300) -- ตรวจสอบทุก 5 นาที
        debugLog("ตรวจสอบตามเวลา - รันสคริปต์อีกครั้งเพื่อความแน่ใจ")
        runLoader()
    end
end)

-- แสดงข้อความเมื่อสคริปต์เริ่มทำงาน
print("BorwonCheck Loader ทำงานแล้ว - พร้อมสำหรับการ rejoin")