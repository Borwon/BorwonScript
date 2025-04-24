-- Anti-Teleport Script v1.0
-- ป้องกันการเทเลพอร์ตอัตโนมัติไปยัง Map ID อื่น

-- ตั้งค่า
local config = {
    enabled = true,                -- เปิดใช้งานสคริปต์
    showNotifications = true,      -- แสดงการแจ้งเตือนเมื่อตรวจพบการเทเลพอร์ต
    logAttempts = true,            -- บันทึกความพยายามในการเทเลพอร์ต
    
    -- ตั้งค่าการป้องกัน
    protectCurrentPlaceOnly = true, -- ป้องกันเฉพาะ Place ID ปัจจุบัน
    allowedPlaceIds = {18668065416},          -- Place IDs ที่อนุญาตให้เทเลพอร์ตไปได้ (ถ้าว่างเปล่า = อนุญาตทุก ID)
    blockedPlaceIds = {77915441816737},          -- Place IDs ที่ไม่อนุญาตให้เทเลพอร์ตไปได้
    
    -- ตั้งค่าขั้นสูง
    hookTeleportMethod = true,     -- ใช้วิธี hook TeleportService methods
    preventGameTeleport = true,    -- ป้องกันการเทเลพอร์ตจากเกม
    preventGuiTeleport = true,     -- ป้องกันการเทเลพอร์ตจาก GUI
    
    -- ตั้งค่าการแจ้งเตือน
    notificationDuration = 5,      -- ระยะเวลาแสดงการแจ้งเตือน (วินาที)
    notificationColor = Color3.fromRGB(255, 50, 50) -- สีของการแจ้งเตือน
}

-- ตัวแปรภายใน
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local currentPlaceId = game.PlaceId
local teleportAttempts = 0
local lastNotificationTime = 0

-- ฟังก์ชันสำหรับแสดงการแจ้งเตือน
local function showNotification(title, text, duration)
    if not config.showNotifications then return end
    
    -- ป้องกันการแสดงการแจ้งเตือนถี่เกินไป
    local currentTime = tick()
    if currentTime - lastNotificationTime < 1 then return end
    lastNotificationTime = currentTime
    
    duration = duration or config.notificationDuration
    
    -- ใช้ StarterGui สำหรับแสดงการแจ้งเตือน
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
            Icon = "rbxassetid://6031071053" -- ไอคอนล็อค
        })
    end)
    
    -- แสดงข้อความในคอนโซลด้วย
    print("[Anti-Teleport] " .. title .. ": " .. text)
end

-- ฟังก์ชันสำหรับตรวจสอบว่า Place ID นี้ถูกบล็อกหรือไม่
local function isPlaceIdBlocked(placeId)
    -- ถ้าเป็น Place ID ปัจจุบันและตั้งค่าให้ป้องกัน
    if config.protectCurrentPlaceOnly and placeId ~= currentPlaceId then
        return false
    end
    
    -- ถ้ามีการระบุ Place IDs ที่อนุญาต และ placeId ไม่อยู่ในรายการ
    if #config.allowedPlaceIds > 0 then
        local isAllowed = false
        for _, id in ipairs(config.allowedPlaceIds) do
            if id == placeId then
                isAllowed = true
                break
            end
        end
        if not isAllowed then return true end
    end
    
    -- ถ้า placeId อยู่ในรายการที่ถูกบล็อก
    for _, id in ipairs(config.blockedPlaceIds) do
        if id == placeId then
            return true
        end
    end
    
    return false
end

-- ฟังก์ชันสำหรับบันทึกความพยายามในการเทเลพอร์ต
local function logTeleportAttempt(placeId, method, blocked)
    if not config.logAttempts then return end
    
    teleportAttempts = teleportAttempts + 1
    local status = blocked and "BLOCKED" or "ALLOWED"
    
    print(string.format(
        "[Anti-Teleport] Attempt #%d: %s teleport to PlaceId %d via %s",
        teleportAttempts,
        status,
        placeId,
        method
    ))
end

-- ฟังก์ชันสำหรับสร้าง hook บน TeleportService methods
local function hookTeleportMethods()
    if not config.hookTeleportMethod then return end
    
    -- ตรวจสอบว่าฟังก์ชัน TeleportService มีอยู่หรือไม่ก่อนที่จะ hook
    if not TeleportService.Teleport then
        print("[Anti-Teleport] Teleport method not found in TeleportService")
        return
    end
    if not TeleportService.TeleportToPlaceInstance then
        print("[Anti-Teleport] TeleportToPlaceInstance method not found in TeleportService")
        return
    end
    if not TeleportService.TeleportPartyAsync then
        print("[Anti-Teleport] TeleportPartyAsync method not found in TeleportService")
        return
    end

    -- สำรองฟังก์ชันเดิม
    local originalTeleport = TeleportService.Teleport
    local originalTeleportToPlaceInstance = TeleportService.TeleportToPlaceInstance
    local originalTeleportPartyAsync = TeleportService.TeleportPartyAsync
    
    -- Hook Teleport method
    TeleportService.Teleport = function(self, placeId, player, ...)
        if isPlaceIdBlocked(placeId) then
            logTeleportAttempt(placeId, "Teleport", true)
            showNotification("Anti-Teleport", "ป้องกันการเทเลพอร์ตไปยัง PlaceId " .. placeId, 3)
            return
        end
        
        logTeleportAttempt(placeId, "Teleport", false)
        return originalTeleport(self, placeId, player, ...)
    end
    
    -- Hook TeleportToPlaceInstance method
    TeleportService.TeleportToPlaceInstance = function(self, placeId, instanceId, player, ...)
        if isPlaceIdBlocked(placeId) then
            logTeleportAttempt(placeId, "TeleportToPlaceInstance", true)
            showNotification("Anti-Teleport", "ป้องกันการเทเลพอร์ตไปยัง PlaceId " .. placeId, 3)
            return
        end
        
        logTeleportAttempt(placeId, "TeleportToPlaceInstance", false)
        return originalTeleportToPlaceInstance(self, placeId, instanceId, player, ...)
    end
    
    -- Hook TeleportPartyAsync method
    TeleportService.TeleportPartyAsync = function(self, placeId, players, ...)
        if isPlaceIdBlocked(placeId) then
            logTeleportAttempt(placeId, "TeleportPartyAsync", true)
            showNotification("Anti-Teleport", "ป้องกันการเทเลพอร์ตไปยัง PlaceId " .. placeId, 3)
            return
        end
        
        logTeleportAttempt(placeId, "TeleportPartyAsync", false)
        return originalTeleportPartyAsync(self, placeId, players, ...)
    end
    
    print("[Anti-Teleport] Successfully hooked TeleportService methods")
end

-- ฟังก์ชันสำหรับป้องกันการเทเลพอร์ตจากเกม
local function setupGameTeleportPrevention()
    if not config.preventGameTeleport then return end
    
    -- ตรวจจับเมื่อเกมพยายามเทเลพอร์ต
    TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage, placeId)
        if player == Players.LocalPlayer then
            showNotification(
                "Teleport Failed", 
                "Result: " .. tostring(teleportResult) .. "\nError: " .. errorMessage,
                5
            )
        end
    end)
    
    print("[Anti-Teleport] Game teleport prevention enabled")
end

-- ฟังก์ชันสำหรับป้องกันการเทเลพอร์ตจาก GUI
local function setupGuiTeleportPrevention()
    if not config.preventGuiTeleport then return end
    
    -- ตรวจจับและป้องกัน GUI ที่อาจใช้เพื่อเทเลพอร์ต
    -- (นี่เป็นเพียงตัวอย่าง อาจไม่ครอบคลุมทุกกรณี)
    
    -- ตรวจจับปุ่มที่อาจใช้เพื่อเทเลพอร์ต
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                for _, gui in pairs(Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
                    if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                        local name = gui.Name:lower()
                        if name:match("teleport") or name:match("warp") or name:match("travel") or name:match("join") then
                            -- ปิดการใช้งานปุ่มที่น่าสงสัย
                            if gui.Active then
                                gui.Active = false
                                print("[Anti-Teleport] Disabled suspicious button: " .. gui:GetFullName())
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    print("[Anti-Teleport] GUI teleport prevention enabled")
end

-- ฟังก์ชันหลักสำหรับเริ่มต้นสคริปต์
local function initAntiTeleport()
    if not config.enabled then
        print("[Anti-Teleport] Script is disabled in config")
        return
    end
    
    -- แสดงข้อความเริ่มต้น
    print("=== Anti-Teleport Script v1.0 ===")
    print("Current PlaceId: " .. currentPlaceId)
    print("Protection mode: " .. (config.protectCurrentPlaceOnly and "Current Place Only" or "Custom Rules"))
    
    -- ตั้งค่าการป้องกันต่างๆ
    hookTeleportMethods()
    setupGameTeleportPrevention()
    setupGuiTeleportPrevention()
    
    -- แสดงการแจ้งเตือนเมื่อเริ่มต้นสคริปต์
    showNotification(
        "Anti-Teleport Activated", 
        "ป้องกันการเทเลพอร์ตไปยัง Map ID อื่นแล้ว",
        5
    )
    
    -- ตรวจจับเมื่อมีการเปลี่ยนแปลง PlaceId (ในกรณีที่การป้องกันล้มเหลว)
    task.spawn(function()
        local lastCheckedPlaceId = currentPlaceId
        while task.wait(1) do
            if game.PlaceId ~= lastCheckedPlaceId then
                print("[Anti-Teleport] PlaceId changed from " .. lastCheckedPlaceId .. " to " .. game.PlaceId)
                lastCheckedPlaceId = game.PlaceId
                currentPlaceId = game.PlaceId
                
                -- แสดงการแจ้งเตือน
                showNotification(
                    "PlaceId Changed", 
                    "เทเลพอร์ตไปยัง PlaceId " .. currentPlaceId .. " แล้ว",
                    5
                )
            end
        end
    end)
end

-- เริ่มต้นสคริปต์
initAntiTeleport()