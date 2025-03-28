-- ฟังก์ชันรอให้เกมโหลดเสร็จ
local function waitForGameLoaded(timeout)
    timeout = timeout or 30 -- ตั้งค่า Timeout เป็น 30 วินาที
    local startTime = tick()

    -- รอจนกว่าเกมจะโหลดเสร็จ
    repeat
        if tick() - startTime > timeout then
            warn("⏳ โหลดเกมนานเกินไป!")
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
            print("✅ โหลด:", serviceName)
        else
            warn("❌ โหลดไม่ได้:", serviceName)
        end
    end

    return true
end

-- เรียกใช้งานฟังก์ชันรอโหลด
if waitForGameLoaded() then
    print("✅ พร้อมทำงาน!")
else
    warn("🚫 โหลดเกมไม่สำเร็จ!")
end

-- Table เก็บข้อมูลสคริปต์แต่ละเกม
local scripts = {
    [116614712661486] = { -- ตัวอย่าง Game ID 1
        name = "AriseCrossoverAFK",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/AriseRam.lua"
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
    print("🌐 พบสคริปต์: " .. mapName .. " (ID: " .. currentGame .. ")")
    
    -- ตรวจสอบว่าฟังก์ชัน loadstring หรือ load พร้อมใช้งานหรือไม่
    local executor = loadstring or load
    if not executor then
        warn("❌ ไม่มีฟังก์ชัน loadstring/load. รันไม่ได้.")
        return
    end

    -- พยายามโหลดและรันสคริปต์
    local success, err = pcall(function()
        local response = game:HttpGet(scriptUrl)
        if not response or response == "" then
            error("Response ว่างหรือไม่ถูกต้อง.")
        end
        executor(response)()
    end)
    
    if not success then
        warn("❌ โหลดสคริปต์ล้มเหลว: " .. tostring(err))
    else
        print("✅ โหลดสคริปต์สำเร็จ!")
    end
else
    print("🚫 ไม่มีสคริปต์สำหรับเกมนี้ (ID: " .. currentGame .. ")")
end