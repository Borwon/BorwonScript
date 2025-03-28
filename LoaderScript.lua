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
            warn("❌ ไม่สามารถโหลด Service:", serviceName, "Error:", tostring(service))
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
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/AriseRam.lua"
    },
    [18668065416] = { -- ตัวอย่าง Game ID 2
        name = "BlueLockRivals",
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
        if not response or response == "" then
            error("Response is empty or invalid.")
        end
        local executor = loadstring or load
        if not executor then
            error("❌ Neither loadstring nor load function is available in this environment. Script execution is not supported.")
        end
        executor(response)()
    end)
    
    if not success then
        warn("❌ เกิดข้อผิดพลาดในการโหลดสคริปต์: " .. tostring(err))
    else
        print("✅ โหลดสคริปต์สำเร็จ!")
    end
else
    print("🚫 ไม่พบสคริปต์สำหรับเกมนี้ (Game ID: " .. currentGame .. ")")
end