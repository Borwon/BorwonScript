-- ฟังก์ชันรอให้เกมโหลดเสร็จ
local function waitForGameLoaded(timeout)
    timeout = timeout or 30 -- ตั้งค่า Timeout เป็น 30 วินาที
    local startTime = tick()

    -- รอจนกว่าเกมจะโหลดเสร็จ
    repeat
        if tick() - startTime > timeout then
            warn("⏳ การโหลดเกมใช้เวลานานเกินไป!")
            return false
        end
        task.wait()
    until game:IsLoaded()

    print("✅ เกมโหลดเสร็จ!")

    -- ตรวจสอบว่า Service สำคัญทั้งหมดโหลดครบหรือยัง
    local services = {
        "Players",
        "ReplicatedStorage",
        "Workspace",
        "StarterGui",
        "StarterPack",
        "Lighting",
        "TweenService",
        "ContentProvider",
        "HttpService",
        "TeleportService"
    }

    for _, serviceName in ipairs(services) do
        local success, service = pcall(function()
            return game:GetService(serviceName)
        end)
        if success and service then
            print("✅ โหลด Service:", serviceName)
        else
            print("❌ ไม่สามารถโหลด Service:", serviceName)
        end
    end

    return true
end

-- เรียกใช้งานฟังก์ชันรอโหลด
if waitForGameLoaded() then
    print("✅ พร้อมทำงานต่อ!")
else
    warn("🚫 เกมโหลดไม่สำเร็จภายในเวลาที่กำหนด!")
end

-- Table เก็บข้อมูลสคริปต์แต่ละเกม
local scripts = {
    [116614712661486] = { -- ตัวอย่าง Game ID 1
        name = "AriseCrossoverAFK",
        url = "https://pastebin.com/raw/your-script-1"
    },
    [9876543210] = { -- ตัวอย่าง Game ID 2
        name = "แมพตัวอย่างที่ 2",
        url = "https://pastebin.com/raw/your-script-2"
    },
}

-- ตรวจสอบ Game ID ปัจจุบัน
local currentGame = game.PlaceId

-- ตรวจสอบว่า Game ID ตรงกับสคริปต์ใน table หรือไม่
if scripts[currentGame] then
    local mapName = scripts[currentGame].name
    local scriptUrl = scripts[currentGame].url
    print("🌐 พบสคริปต์สำหรับเกม: " .. mapName .. " (Game ID: " .. currentGame .. ")")
    
    -- พยายามโหลดและรันสคริปต์
    local success, err = pcall(function()
        local response = game:HttpGet(scriptUrl)
        loadstring(response)()
    end)
    
    if not success then
        warn("❌ เกิดข้อผิดพลาดในการโหลดสคริปต์: " .. tostring(err))
    else
        print("✅ โหลดสคริปต์สำเร็จ!")
    end
else
    print("🚫 ไม่พบสคริปต์สำหรับเกมนี้ (Game ID: " .. currentGame .. ")")
end
