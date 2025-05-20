-- ===== BorwonCheck - Enhanced Loader Version 2.2 =====
-- Simplified script loader with beautiful debug system

-- ===== ระบบ Configuration =====
local config = {
    -- ตั้งค่าทั่วไป
    autoReload = true,                -- เปิดใช้งานการโหลดสคริปต์อัตโนมัติหลังจาก rejoin
    
    -- ตั้งค่า Debug
    debugMode = true,                 -- เปิดใช้งานโหมด debug
    coloredOutput = true,             -- เปิดใช้งานสีในการแสดงผล
    showTimestamps = true,            -- แสดงเวลาในข้อความ debug
    maxDebugMessages = 100,           -- จำกัดจำนวนข้อความ debug สูงสุด
    
    -- ตั้งค่า Performance
    checkPlaceIdInterval = 15,        -- ความถี่ในการตรวจสอบ PlaceId (วินาที)
    periodicReloadInterval = 600,     -- ความถี่ในการรีโหลดตามเวลา (วินาที)
    
    -- ตั้งค่า Universal Script
    universalScript = {
        enabled = true,               -- เปิดใช้งาน Universal Script หรือไม่
        name = "AutoKickandRejoin",   -- ชื่อของ Universal Script
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/other/AutoKickandRejoin.lua" -- ลิงก์ไปยังสคริปต์
    }
}

-- ===== ระบบ Debug ที่สวยงามและมีประสิทธิภาพ =====
local DebugSystem = {
    messageCount = 0
}

-- สีสำหรับข้อความประเภทต่างๆ (ใช้ได้กับบางเอ็กซีคิวเตอร์เท่านั้น)
DebugSystem.Colors = {
    reset = "\27[0m",
    info = "\27[1;36m",      -- สีฟ้าสว่าง
    success = "\27[1;32m",   -- สีเขียวสว่าง
    warning = "\27[1;33m",   -- สีเหลืองสว่าง
    error = "\27[1;31m",     -- สีแดงสว่าง
    debug = "\27[1;35m",     -- สีม่วงสว่าง
    system = "\27[1;37m",    -- สีขาวสว่าง
    highlight = "\27[1;34m"  -- สีน้ำเงินสว่าง
}

-- ไอคอนสำหรับข้อความประเภทต่างๆ
DebugSystem.Icons = {
    info = "ℹ️",
    success = "✅",
    warning = "⚠️",
    error = "❌",
    debug = "🔍",
    system = "⚙️",
    highlight = "🔆"
}

-- ฟังก์ชันสำหรับแสดงข้อความ debug ที่มีประสิทธิภาพ
function DebugSystem:log(type, message, forceShow)
    -- ตรวจสอบเงื่อนไขก่อนแสดงข้อความ
    if not config.debugMode and not forceShow then return end
    
    -- จำกัดจำนวนข้อความ debug
    self.messageCount = self.messageCount + 1
    if self.messageCount > config.maxDebugMessages and not forceShow then
        if self.messageCount == config.maxDebugMessages + 1 then
            print("จำกัดจำนวนข้อความ debug แล้ว - ข้อความต่อไปจะไม่แสดงเว้นแต่จะใช้ forceShow")
        end
        return
    end
    
    local icon = self.Icons[type] or "📝"
    local color = config.coloredOutput and self.Colors[type] or ""
    local resetColor = config.coloredOutput and self.Colors.reset or ""
    local timestamp = config.showTimestamps and os.date("[%H:%M:%S] ") or ""
    
    -- สร้างข้อความที่จะแสดง
    local formattedMessage = string.format("%s%s%s %s%s", 
        color, 
        timestamp, 
        icon, 
        message, 
        resetColor
    )
    
    -- แสดงข้อความตามประเภท
    if type == "error" then
        warn(formattedMessage)
    elseif type == "warning" then
        warn(formattedMessage)
    else
        print(formattedMessage)
    end
end

-- ฟังก์ชันสำหรับแสดงข้อความแบบสวยงาม
function DebugSystem:showBeautifulMessage(title, message, type)
    type = type or "info"
    
    local color = config.coloredOutput and self.Colors[type] or ""
    local resetColor = config.coloredOutput and self.Colors.reset or ""
    local icon = self.Icons[type] or "📝"
    
    -- สร้างเส้นคั่น
    local separator = string.rep("=", 50)
    
    -- แสดงข้อความ
    print(color .. separator .. resetColor)
    print(color .. icon .. " " .. title .. resetColor)
    print(color .. message .. resetColor)
    print(color .. separator .. resetColor)
end

-- Function to wait for game to load with optimized checks
local function waitForGameLoaded(timeout)
    timeout = timeout or 15 -- Default timeout of 15 seconds
    local startTime = tick()

    -- Wait until the game is loaded
    if not game:IsLoaded() then
        DebugSystem:log("info", "รอให้เกมโหลดเสร็จ...")
        repeat
            if tick() - startTime > timeout then
                DebugSystem:log("error", "เกมโหลดไม่เสร็จภายในเวลาที่กำหนด!", true)
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

    DebugSystem:log("success", "เกมโหลดเสร็จแล้ว", true)
    return true
end

-- Function to load and run a script with error handling
local function loadAndRunScript(name, url)
    DebugSystem:log("info", "กำลังโหลดสคริปต์: " .. name)
    local executor = loadstring or load
    if not executor then
        DebugSystem:log("error", "ไม่พบฟังก์ชัน loadstring หรือ load", true)
        return false
    end

    local success, err = pcall(function()
        local response = ""
        
        -- ลองโหลดจาก URL หลัก
        local mainSuccess, mainResponse = pcall(function()
            return game:HttpGet(url)
        end)
        
        if mainSuccess and mainResponse and mainResponse ~= "" then
            response = mainResponse
        else
            error("ไม่สามารถโหลดสคริปต์จาก URL ได้")
        end
        
        if not response or response == "" then
            error("ไม่พบข้อมูลสคริปต์หรือข้อมูลว่างเปล่า")
        end
        
        -- ใช้ pcall เพื่อป้องกันข้อผิดพลาดจากการรันสคริปต์
        local execSuccess, execErr = pcall(function()
            executor(response)()
        end)
        
        if not execSuccess then
            error("เกิดข้อผิดพลาดในการรันสคริปต์: " .. tostring(execErr))
        end
    end)

    if not success then
        DebugSystem:log("error", "โหลดสคริปต์ล้มเหลว: " .. tostring(err), true)
        return false
    else
        DebugSystem:log("success", "โหลดสคริปต์สำเร็จ: " .. name, true)
        return true
    end
end

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
    {
        ids = {116495829188952}, -- Deadrails
        name = "DeadRails",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/DeadRails.lua"
    },
    {
        ids = {126884695634066}, -- Grow a Garden
        name = "GrowaGarden",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/GrowaGarden.lua"
    },
}

-- Main function to run the loader with error recovery
local function runLoader()
    -- ใช้ pcall เพื่อป้องกันข้อผิดพลาดที่อาจทำให้ loader หยุดทำงาน
    local success, err = pcall(function()
        -- Wait for game to load
        local gameLoaded = waitForGameLoaded(15)
        if not gameLoaded then
            DebugSystem:log("error", "เกมโหลดไม่เสร็จภายในเวลาที่กำหนด!", true)
            return
        end

        -- Check current game ID
        local currentGame = game.PlaceId
        DebugSystem:log("info", "ตรวจสอบ ID เกม: " .. currentGame)

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
            DebugSystem:log("error", "'scripts' ไม่ใช่ตารางที่ถูกต้อง", true)
        end

        local mapName = "Unknown Map"
        if matchedScript then
            mapName = matchedScript.name
            local scriptUrl = matchedScript.url
            DebugSystem:log("success", "พบสคริปต์สำหรับแมพ: " .. mapName, true)
            loadAndRunScript(mapName, scriptUrl)
        else
            DebugSystem:log("warning", "ไม่พบสคริปต์สำหรับเกมนี้ (ID: " .. currentGame .. ")", true)
        end

        -- Always run the universal script
        if config and config.universalScript and config.universalScript.enabled then
            local universalName = config.universalScript.name
            local universalUrl = config.universalScript.url
            DebugSystem:log("info", "กำลังรันสคริปต์ Universal: " .. universalName .. " สำหรับแมพ: " .. mapName)
            loadAndRunScript(universalName, universalUrl)
        else
            DebugSystem:log("error", "'config' หรือ 'config.universalScript' ไม่ได้กำหนดค่าอย่างถูกต้อง", true)
        end
    end)
    
    -- จัดการกับข้อผิดพลาดที่อาจเกิดขึ้น
    if not success then
        DebugSystem:log("error", "เกิดข้อผิดพลาดในการรัน Loader: " .. tostring(err), true)
    end
end

-- ===== ระบบตรวจจับการเข้าเกมใหม่ =====

-- ฟังก์ชันสำหรับตรวจสอบเมื่อเข้าเกมใหม่
local function setupRejoinDetection()
    -- ตรวจจับเมื่อ LocalPlayer เข้าเกม
    game:GetService("Players").PlayerAdded:Connect(function(player)
        if player == game:GetService("Players").LocalPlayer then
            DebugSystem:log("highlight", "LocalPlayer เข้าเกมใหม่ - เตรียมรันสคริปต์อีกครั้ง", true)
            -- รอให้เกมโหลดเสร็จก่อนรันสคริปต์
            task.wait(5)
            runLoader()
        end
    end)
    
    -- ตรวจจับเมื่อ Character เกิดใหม่ (อาจเกิดจากการ respawn หรือ rejoin)
    if game:GetService("Players").LocalPlayer then
        game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
            DebugSystem:log("debug", "Character เกิดใหม่ - ตรวจสอบว่าเป็นการ rejoin หรือไม่")
            -- รอสักครู่เพื่อให้แน่ใจว่าเป็นการ rejoin จริงๆ
            task.wait(3)
            runLoader()
        end)
    end
    
    -- ตรวจจับเมื่อเกมโหลดเสร็จ (สำหรับกรณีที่สคริปต์ถูกรันก่อนเกมโหลดเสร็จ)
    if not game:IsLoaded() then
        game.Loaded:Connect(function()
            DebugSystem:log("success", "เกมโหลดเสร็จแล้ว - รันสคริปต์", true)
            task.wait(5)
            runLoader()
        end)
    end
    
    -- ตรวจจับการเปลี่ยนแปลง PlaceId (เมื่อเข้าแมพใหม่)
    local currentPlaceId = game.PlaceId
    task.spawn(function()
        while true do
            task.wait(config.checkPlaceIdInterval)
            if game.PlaceId ~= currentPlaceId then
                DebugSystem:log("highlight", "ตรวจพบการเปลี่ยนแมพ - รันสคริปต์อีกครั้ง", true)
                currentPlaceId = game.PlaceId
                runLoader()
            end
        end
    end)
    
    -- ตรวจจับเมื่อ TeleportService ทำงาน
    game:GetService("TeleportService").TeleportInitFailed:Connect(function()
        DebugSystem:log("warning", "การเทเลพอร์ตล้มเหลว - ลองรันสคริปต์อีกครั้ง", true)
        task.wait(5)
        runLoader()
    end)
end

-- ตั้งค่าการตรวจจับ rejoin
setupRejoinDetection()

-- แสดงข้อความเริ่มต้นสวยๆ
DebugSystem:showBeautifulMessage(
    "BorwonCheck Loader v2.2",
    "สคริปต์โหลดเดอร์ที่มีระบบ Debug สวยงาม\nพร้อมสำหรับการ rejoin และการเปลี่ยนแมพ",
    "highlight"
)

-- รันสคริปต์ครั้งแรก
DebugSystem:log("system", "รันสคริปต์ครั้งแรก", true)
runLoader()

-- เพิ่มการตรวจสอบเพื่อรันสคริปต์อีกครั้งหลังจากเวลาผ่านไป (เผื่อกรณีที่การตรวจจับอื่นๆ ล้มเหลว)
task.spawn(function()
    while config.autoReload do
        task.wait(config.periodicReloadInterval) -- ตรวจสอบตามเวลาที่กำหนดในการตั้งค่า
        DebugSystem:log("debug", "ตรวจสอบตามเวลา - รันสคริปต์อีกครั้งเพื่อความแน่ใจ")
        runLoader()
    end
end)

-- แสดงข้อความเมื่อสคริปต์เริ่มทำงานเสร็จสมบูรณ์
DebugSystem:log("success", "BorwonCheck Loader ทำงานเสร็จสมบูรณ์", true)