-- ฟังก์ชันรอให้เกมโหลดเสร็จ
local function waitForGameLoaded(timeout)
    timeout = timeout or 30 -- ตั้งค่า Timeout เป็น 30 วินาที
    local startTime = tick()

    -- รอจนกว่าเกมจะโหลดเสร็จ
    if not game:IsLoaded() then
        repeat
            if tick() - startTime > timeout then
                warn("⏳ โหลดเกมนานเกินไป!")
                return false
            end
            task.wait()
        until game:IsLoaded()
    end

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

-- Table เก็บข้อมูลสคริปต์แต่ละเกม (รองรับหลาย ID ต่อแมพ)
local scripts = {
    {
        ids = {116614712661486}, -- ตัวอย่าง Game IDs สำหรับ AriseCrossoverAFK
        name = "AriseCrossoverAFK",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/AriseRam.lua"
    },
    {
        ids = {115110570222234, 18668065416}, -- ตัวอย่าง Game IDs สำหรับ BlueLockRivals
        name = "BlueLockRivals",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/BlueLockRam.lua"
    },
}

-- ตรวจสอบ Game ID ปัจจุบัน
local currentGame = game.PlaceId
local matchedScript = nil

-- ค้นหาแมพที่มี ID ตรงกับ currentGame
for _, script in ipairs(scripts) do
    for _, id in ipairs(script.ids) do
        if id == currentGame then
            matchedScript = script
            break
        end
    end
    if matchedScript then break end
end

-- ตรวจสอบว่าเจอแมพที่ตรงกับ ID หรือไม่
if matchedScript then
    local mapName = matchedScript.name
    local scriptUrl = matchedScript.url
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
        print("✅ โหลดสคริปต์ของแมพสำเร็จ!")
    end
else
    print("🚫 ไม่มีสคริปต์สำหรับเกมนี้ (ID: " .. currentGame .. ")")
end