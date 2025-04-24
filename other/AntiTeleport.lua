-- Anti-Teleport Script v2.0
-- ป้องกันการเทเลพอร์ตอัตโนมัติไปยัง Map ID อื่น (ทำงานใน LocalScript)

-- ตั้งค่า
local config = {
    enabled = true,                -- เปิดใช้งานสคริปต์
    showNotifications = true,      -- แสดงการแจ้งเตือนเมื่อตรวจพบการเทเลพอร์ต
    logAttempts = true,            -- บันทึกความพยายามในการเทเลพอร์ต
    protectCurrentPlaceOnly = true, -- ป้องกันเฉพาะ Place ID ปัจจุบัน
    allowedPlaceIds = {18668065416}, -- Place IDs ที่อนุญาต
    blockedPlaceIds = {77915441816737}, -- Place IDs ที่ไม่อนุญาต
    notificationDuration = 5,      -- ระยะเวลาแสดงการแจ้งเตือน (วินาที)
    notificationColor = Color3.fromRGB(255, 50, 50), -- สีของการแจ้งเตือน
    preventGuiTeleport = true      -- ป้องกันการเทเลพอร์ตจาก GUI
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
    
    local currentTime = tick()
    if currentTime - lastNotificationTime < 1 then return end
    lastNotificationTime = currentTime
    
    duration = duration or config.notificationDuration
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
            Icon = "rbxassetid://6031071053" -- ไอคอนล็อค
        })
    end)
    
    print("[Anti-Teleport] " .. title .. ": " .. text)
end

-- ฟังก์ชันสำหรับตรวจสอบว่า Place ID นี้ถูกบล็อกหรือไม่
local function isPlaceIdBlocked(placeId)
    if config.protectCurrentPlaceOnly and placeId ~= currentPlaceId then
        return true
    end
    
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

-- ฟังก์ชันสำหรับตรวจจับการเทเลพอร์ต
local function setupTeleportDetection()
    -- ตรวจจับเมื่อการเทเลพอร์ตล้มเหลว
    TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage, placeId)
        if player == Players.LocalPlayer then
            logTeleportAttempt(placeId, "TeleportInitFailed", true)
            showNotification(
                "Teleport Blocked",
                "ป้องกันการเทเลพอร์ตไปยัง PlaceId " .. placeId .. "\nError: " .. errorMessage,
                5
            )
        end
    end)
    
    -- ตรวจจับการเปลี่ยนแปลง Place ID
    task.spawn(function()
        local lastCheckedPlaceId = currentPlaceId
        while task.wait(1) do
            if game.PlaceId ~= lastCheckedPlaceId then
                logTeleportAttempt(game.PlaceId, "PlaceIdChange", isPlaceIdBlocked(game.PlaceId))
                showNotification(
                    "PlaceId Changed",
                    "ตรวจพบการเทเลพอร์ตไปยัง PlaceId " .. game.PlaceId,
                    5
                )
                lastCheckedPlaceId = game.PlaceId
                currentPlaceId = game.PlaceId
            end
        end
    end)
    
    print("[Anti-Teleport] Teleport detection enabled")
end

-- ฟังก์ชันสำหรับป้องกันการเทเลพอร์ตจาก GUI
local function setupGuiTeleportPrevention()
    if not config.preventGuiTeleport then return end
    
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                for _, gui in pairs(Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
                    if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                        local name = gui.Name:lower()
                        if name:match("teleport") or name:match("warp") or name:match("travel") or name:match("join") then
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
    
    print("=== Anti-Teleport Script v2.0 ===")
    print("Current PlaceId: " .. currentPlaceId)
    print("Protection mode: " .. (config.protectCurrentPlaceOnly and "Current Place Only" or "Custom Rules"))
    
    setupTeleportDetection()
    setupGuiTeleportPrevention()
    
    showNotification(
        "Anti-Teleport Activated",
        "ป้องกันการเทเลพอร์ตไปยัง Map ID อื่นแล้ว",
        5
    )
end

-- เริ่มต้นสคริปต์
initAntiTeleport()