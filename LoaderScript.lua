-- ===== BorwonScript Loader v3.0 =====
-- Flow: MainLoader -> LoaderScript -> PlaceId -> ScriptMap

-- ===== Config =====
local debugMode = true -- ตั้ง false เพื่อปิด log ทั้งหมด ยกเว้นข้อความสำคัญ

-- ===== Debug System =====
local function log(msgType, msg, force)
    if not debugMode and not force then return end
    local prefix = {
        info    = "[INFO]",
        success = "[OK]  ",
        warning = "[WARN]",
        error   = "[ERR] ",
        debug   = "[DBG] ",
    }
    local tag = prefix[msgType] or "[LOG] "
    local out = "[BorwonScript] " .. tag .. " " .. msg
    if msgType == "error" or msgType == "warning" then
        warn(out)
    else
        print(out)
    end
end

-- ===== ScriptMap: PlaceId -> Script =====
-- ห้ามแก้ id และ url — เฉพาะแมพ
local scripts = {
    {
        ids  = {116614712661486},
        name = "AriseCrossoverAFK",
        url  = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/AriseRam.lua"
    },
    {
        ids  = {18668065416},
        name = "BlueLockRivals",
        url  = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/BlueLockRam.lua"
    },
    {
        ids  = {72829404259339},
        name = "AnimeRangerX",
        url  = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/AnimeRangerX.lua"
    },
    {
        ids  = {116495829188952},
        name = "DeadRails",
        url  = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/DeadRails.lua"
    },
    {
        ids  = {126884695634066},
        name = "GrowaGarden",
        url  = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/GrowaGarden.lua"
    },
}

-- ===== Wait for game to load =====
local function waitForGameLoaded(timeout)
    timeout = timeout or 15
    if game:IsLoaded() then return true end

    log("info", "รอให้เกมโหลดเสร็จ...")
    local start = tick()
    repeat
        task.wait(0.2)
        if tick() - start > timeout then
            log("error", "เกมโหลดไม่เสร็จภายในเวลาที่กำหนด!", true)
            return false
        end
    until game:IsLoaded()
    return true
end

-- ===== Load & run script from URL =====
local function loadAndRunScript(name, url)
    log("info", "กำลังโหลดสคริปต์: " .. name)

    local ok, err = pcall(function()
        local response = game:HttpGet(url)
        if not response or response == "" then
            error("Response ว่างเปล่าจาก URL")
        end

        local fn, compileErr = loadstring(response)
        if not fn then
            error("Compile error: " .. tostring(compileErr))
        end

        local runOk, runErr = pcall(fn)
        if not runOk then
            error("Runtime error: " .. tostring(runErr))
        end
    end)

    if ok then
        log("success", "โหลดสคริปต์สำเร็จ: " .. name, true)
        return true
    else
        log("error", "โหลดสคริปต์ล้มเหลว [" .. name .. "]: " .. tostring(err), true)
        return false
    end
end

-- ===== Main Loader =====
local function runLoader()
    log("system", "=== BorwonScript Loader v3.0 เริ่มทำงาน ===", true)

    local ok, err = pcall(function()
        -- 1. รอเกมโหลด
        if not waitForGameLoaded(15) then return end

        -- 2. ดู PlaceId
        local placeId = game.PlaceId
        log("info", "PlaceId: " .. tostring(placeId))

        -- 3. หา script ที่ตรงกับ PlaceId
        local matched = nil
        for _, entry in ipairs(scripts) do
            for _, id in ipairs(entry.ids) do
                if id == placeId then
                    matched = entry
                    break
                end
            end
            if matched then break end
        end

        -- 4. โหลด script ตามแมพ
        if matched then
            log("success", "พบสคริปต์: " .. matched.name, true)
            loadAndRunScript(matched.name, matched.url)
        else
            log("warning", "ไม่พบสคริปต์สำหรับ PlaceId: " .. tostring(placeId), true)
        end
    end)

    if not ok then
        log("error", "Loader หยุดทำงาน: " .. tostring(err), true)
    end

    log("info", "=== BorwonScript Loader เสร็จสิ้น ===", true)
end

-- ===== Run =====
runLoader()