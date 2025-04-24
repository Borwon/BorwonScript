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
    debug_mode = true
}

-- ฟังก์ชันสำหรับแสดงข้อความ log
local function log(message)
    if config.debug_mode then
        local timeStr = os.date("%H:%M:%S")
        print("["..timeStr.."] " .. message)
    end
end

-- รอให้เกมโหลดเสร็จก่อน
repeat task.wait() until game:IsLoaded()
log("Script Started")

-- ฟังก์ชันสำหรับตรวจสอบ map ID ปัจจุบัน
local function getCurrentMapID()
    return game.PlaceId
end

-- ฟังก์ชันสำหรับเข้าแมพใหม่
local function joinGame(placeId)
    log("กำลังเข้าแมพ ID: " .. placeId)
    
    local success, errorMsg = pcall(function()
        game:GetService("TeleportService"):Teleport(placeId)
    end)
    
    if not success then
        log("เกิดข้อผิดพลาดในการเข้าแมพ: " .. errorMsg)
        
        -- ลองใช้วิธีอื่นถ้าวิธีแรกไม่สำเร็จ
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, game.JobId)
        end)
    end
end

-- ฟังก์ชันสำหรับเตะตัวเองและเข้าแมพใหม่
local function kickAndRejoin()
    log("กำลังเตะตัวเองและเข้าแมพใหม่...")
    
    -- เตะตัวเอง
    game.Players.LocalPlayer:Kick(config.kick_message)
    
    -- รอสักครู่ก่อนเข้าแมพใหม่
    task.wait(config.rejoin_delay)
    
    -- เข้าแมพใหม่
    joinGame(config.target_map_id)
end

-- ฟังก์ชันหลักสำหรับตรวจสอบและดำเนินการ
local function checkAndTeleport()
    local currentMapID = getCurrentMapID()
    log("แมพปัจจุบัน ID: " .. currentMapID)
    
    if currentMapID == config.restricted_map_id then
        log("พบว่าอยู่ในแมพที่ถูกจำกัด!")
        kickAndRejoin()
    else
        log("ไม่ได้อยู่ในแมพที่ถูกจำกัด ไม่ต้องดำเนินการใดๆ")
    end
end

-- ตรวจสอบทันทีเมื่อเริ่มสคริปต์
checkAndTeleport()

-- ตรวจสอบเป็นระยะ
while true do
    task.wait(config.check_interval)
    checkAndTeleport()
end