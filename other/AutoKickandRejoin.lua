-- Simple Configuration
local config = {
    -- Map ID ที่ต้องการตรวจสอบ (ถ้าอยู่ในแมพนี้จะโดนเตะออก)
    restricted_map_id = 77915441816737, -- เปลี่ยนเป็น ID ของแมพที่ต้องการตรวจสอบ
    
    -- Map ID ที่ต้องการเข้าหลังจากโดนเตะ
    target_map_id = 18668065416, -- เปลี่ยนเป็น ID ของแมพที่ต้องการเข้าหลังจากโดนเตะ
    
    -- ความถี่ในการตรวจสอบ (วินาที)
    check_interval = 5,
    
    -- ข้อความที่แสดงเมื่อโดนเตะ
    kick_message = "กำลังย้ายไปยังแมพอื่น...",
    
    -- เวลารอก่อนเข้าแมพใหม่ (วินาที)
    rejoin_delay = 3,
    
    -- แสดงข้อความ debug หรือไม่
    debug_mode = false
}

-- ฟังก์ชันสำหรับแสดงข้อความ log
local function log(message)
    if config.debug_mode then
        local timeStr = os.date("%H:%M:%S")
        print("["..timeStr.."] " .. message)
    end
end

-- รอให้เกมโหลดเสร็จก่อน
repeat
    log("Waiting for the game to load...")
    task.wait()
until game:IsLoaded()
log("Game loaded successfully. Script Started.")

-- ฟังก์ชันสำหรับตรวจสอบ map ID ปัจจุบัน
local function getCurrentMapID()
    local mapID = game.PlaceId
    log("Current Map ID: " .. mapID)
    return mapID
end

-- ฟังก์ชันสำหรับเข้าแมพใหม่
local function joinGame(placeId)
    log("Attempting to join game with Map ID: " .. placeId)
    
    local success, errorMsg = pcall(function()
        game:GetService("TeleportService"):Teleport(placeId)
    end)
    
    if not success then
        log("Error during teleportation: " .. errorMsg)
        
        -- ลองใช้วิธีอื่นถ้าวิธีแรกไม่สำเร็จ
        pcall(function()
            log("Retrying teleportation using TeleportToPlaceInstance...")
            game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, game.JobId)
        end)
    else
        log("Teleportation successful.")
    end
end

-- ฟังก์ชันสำหรับเตะตัวเองและเข้าแมพใหม่
local function kickAndRejoin()
    log("Initiating kick and rejoin process...")
    
    -- เตะตัวเอง
    log("Kicking player with message: " .. config.kick_message)
    game.Players.LocalPlayer:Kick(config.kick_message)
    
    -- รอสักครู่ก่อนเข้าแมพใหม่
    log("Waiting for " .. config.rejoin_delay .. " seconds before rejoining...")
    task.wait(config.rejoin_delay)
    
    -- เข้าแมพใหม่
    joinGame(config.target_map_id)
end

-- ฟังก์ชันหลักสำหรับตรวจสอบและดำเนินการ
local function checkAndTeleport()
    log("Running checkAndTeleport...")
    local currentMapID = getCurrentMapID()
    
    if currentMapID == config.restricted_map_id then
        log("Player is in a restricted map!")
        kickAndRejoin()
    else
        log("Player is not in a restricted map. No action required.")
    end
end

-- ตรวจสอบทันทีเมื่อเริ่มสคริปต์
log("Performing initial map check...")
checkAndTeleport()

-- ตรวจสอบเป็นระยะ
while true do
    log("Waiting for the next check (" .. config.check_interval .. " seconds)...")
    task.wait(config.check_interval)
    checkAndTeleport()
end