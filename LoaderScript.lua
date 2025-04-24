-- ===== BorwonCheck - Enhanced Loader Version =====
-- Improved script loader with beautiful debug and Discord notifications

-- ===== ระบบ Configuration =====
local config = {
    -- ตั้งค่าทั่วไป
    autoReload = true,                -- เปิดใช้งานการโหลดสคริปต์อัตโนมัติหลังจาก rejoin
    
    -- ตั้งค่า Debug
    debugMode = true,                 -- เปิดใช้งานโหมด debug
    coloredOutput = true,             -- เปิดใช้งานสีในการแสดงผล
    showTimestamps = true,            -- แสดงเวลาในข้อความ debug
    
    -- ตั้งค่า Discord Webhook
    discordNotifications = {
        enabled = true,               -- เปิดใช้งานการแจ้งเตือนผ่าน Discord
        webhookUrl = "https://discord.com/api/webhooks/1365021057970471104/yRNEmRXSnV0saY57-tXmJAQ98ubvfzt-2rmyBedVV4bbkhBmQ4s3vRKW7pRCmmATbKM1", -- URL ของ Discord Webhook
        notifyOnErrors = true,        -- แจ้งเตือนเมื่อเกิด error
        notifyOnScriptLoad = true,    -- แจ้งเตือนเมื่อโหลดสคริปต์สำเร็จ
        includeGameInfo = true,       -- รวมข้อมูลเกมในการแจ้งเตือน
        username = "BorwonCheck Bot", -- ชื่อที่แสดงใน Discord
        avatarUrl = "https://www.roblox.com/favicon.ico" -- รูปโปรไฟล์ที่แสดงใน Discord
    },
    
    -- ตั้งค่า Universal Script
    universalScript = {
        enabled = true,               -- เปิดใช้งาน Universal Script หรือไม่
        name = "AutoKickandRejoin",   -- ชื่อของ Universal Script
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/other/AutoKickandRejoin.lua" -- ลิงก์ไปยังสคริปต์
    }
}

-- ===== ระบบ Debug ที่สวยงาม =====
local DebugSystem = {}

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

-- ฟังก์ชันสำหรับแสดงข้อความ debug
function DebugSystem:log(type, message, forceShow)
    if not config.debugMode and not forceShow then return end
    
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
    
    -- ส่งข้อความไปยัง Discord ถ้าเป็น error และเปิดใช้งานการแจ้งเตือน
    if type == "error" and config.discordNotifications.enabled and config.discordNotifications.notifyOnErrors then
        self:sendDiscordNotification("Error", message)
    end
end

-- ฟังก์ชันสำหรับส่งข้อความไปยัง Discord Webhook
function DebugSystem:sendDiscordNotification(title, message)
    if not config.discordNotifications.enabled or not config.discordNotifications.webhookUrl then return end
    
    -- สร้างข้อมูลสำหรับส่งไปยัง Discord
    local gameInfo = ""
    if config.discordNotifications.includeGameInfo then
        local success, result = pcall(function()
            local placeId = game.PlaceId
            local placeName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
            local playerName = game:GetService("Players").LocalPlayer.Name
            return string.format("Game: %s (%d)\nPlayer: %s", placeName, placeId, playerName)
        end)
        
        if success then
            gameInfo = result
        else
            gameInfo = "Could not fetch game info"
        end
    end
    
    -- สร้าง payload สำหรับส่งไปยัง Discord
    local payload = {
        username = config.discordNotifications.username,
        avatar_url = config.discordNotifications.avatarUrl,
        embeds = {{
            title = title,
            description = message,
            color = (title == "Error") and 16711680 or 5814783, -- สีแดงสำหรับ Error, สีฟ้าสำหรับอื่นๆ
            fields = {},
            footer = {
                text = "BorwonCheck Loader"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    -- เพิ่มข้อมูลเกมถ้าเปิดใช้งาน
    if gameInfo ~= "" then
        table.insert(payload.embeds[1].fields, {
            name = "Game Information",
            value = gameInfo,
            inline = false
        })
    end
    
    -- แปลง payload เป็น JSON
    local jsonPayload = game:GetService("HttpService"):JSONEncode(payload)
    
    -- ส่งข้อมูลไปยัง Discord Webhook
    task.spawn(function()
        pcall(function()
            game:GetService("HttpService"):PostAsync(
                config.discordNotifications.webhookUrl,
                jsonPayload,
                Enum.HttpContentType.ApplicationJson
            )
        end)
    end)
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
        local response = game:HttpGet(url)
        if not response or response == "" then
            error("ไม่พบข้อมูลสคริปต์หรือข้อมูลว่างเปล่า")
        end
        executor(response)()
    end)

    if not success then
        DebugSystem:log("error", "โหลดสคริปต์ล้มเหลว: " .. tostring(err), true)
        
        -- ส่งการแจ้งเตือนไปยัง Discord
        if config.discordNotifications.enabled and config.discordNotifications.notifyOnErrors then
            DebugSystem:sendDiscordNotification(
                "Script Load Failed: " .. name,
                "Error: " .. tostring(err)
            )
        end
        
        return false
    else
        DebugSystem:log("success", "โหลดสคริปต์สำเร็จ: " .. name, true)
        
        -- ส่งการแจ้งเตือนไปยัง Discord
        if config.discordNotifications.enabled and config.discordNotifications.notifyOnScriptLoad then
            DebugSystem:sendDiscordNotification(
                "Script Loaded: " .. name,
                "Script has been loaded successfully."
            )
        end
        
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
}

-- Main function to run the loader
local function runLoader()
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
end

-- ===== ระบบตรวจจับการเข้าเกมใหม่ =====

-- ตัวแปรเก็บสถานะว่าสคริปต์ได้ทำงานแล้วหรือยัง
local hasRunInitially = false

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
            -- ตรวจสอบว่าเป็นการ rejoin จริงๆ หรือแค่ respawn ธรรมดา
            task.wait(2)
            if not hasRunInitially then
                DebugSystem:log("info", "รันสคริปต์ครั้งแรกหลังจาก Character เกิด")
                runLoader()
                hasRunInitially = true
            else
                -- ใช้ตัวแปรเพื่อป้องกันการรันซ้ำเมื่อเพิ่ง respawn ธรรมดา
                local lastRun = tick()
                task.wait(3) -- รอสักครู่เพื่อให้แน่ใจว่าเป็นการ rejoin จริงๆ
                if tick() - lastRun >= 3 then
                    DebugSystem:log("highlight", "ตรวจพบการ rejoin - รันสคริปต์อีกครั้ง", true)
                    runLoader()
                end
            end
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
            task.wait(5)
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
    
    -- ตรวจจับ error ทั่วไปและส่งไปยัง Discord
    task.spawn(function()
        local oldError = error
        error = function(message, level)
            if config.discordNotifications.enabled and config.discordNotifications.notifyOnErrors then
                DebugSystem:sendDiscordNotification(
                    "Script Error",
                    tostring(message)
                )
            end
            return oldError(message, level)
        end
    end)
end

-- ตั้งค่าการตรวจจับ rejoin
setupRejoinDetection()

-- แสดงข้อความเริ่มต้นสวยๆ
DebugSystem:showBeautifulMessage(
    "BorwonCheck Loader v2.0",
    "สคริปต์โหลดเดอร์ที่มีระบบ Debug สวยงามและการแจ้งเตือนผ่าน Discord\nพร้อมสำหรับการ rejoin และการเปลี่ยนแมพ",
    "highlight"
)

-- รันสคริปต์ครั้งแรก
if not hasRunInitially then
    DebugSystem:log("system", "รันสคริปต์ครั้งแรก", true)
    runLoader()
    hasRunInitially = true
end

-- เพิ่มการตรวจสอบเพื่อรันสคริปต์อีกครั้งหลังจากเวลาผ่านไป (เผื่อกรณีที่การตรวจจับอื่นๆ ล้มเหลว)
task.spawn(function()
    while config.autoReload do
        task.wait(300) -- ตรวจสอบทุก 5 นาที
        DebugSystem:log("debug", "ตรวจสอบตามเวลา - รันสคริปต์อีกครั้งเพื่อความแน่ใจ")
        runLoader()
    end
end)

-- ตรวจจับ error และส่งไปยัง Discord
local oldErrorHandler = game:GetService("ScriptContext").Error
game:GetService("ScriptContext").Error:Connect(function(message, stack, script)
    if config.discordNotifications.enabled and config.discordNotifications.notifyOnErrors then
        DebugSystem:log("error", "เกิด Error: " .. message, true)
        
        -- ส่งการแจ้งเตือนไปยัง Discord
        DebugSystem:sendDiscordNotification(
            "Roblox Script Error",
            "Error: " .. message .. "\n\nStack: " .. (stack or "N/A")
        )
    end
end)