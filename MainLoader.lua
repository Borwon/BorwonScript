-- ===== BorwonScript MainLoader =====
-- รันสคริปต์นี้ใน Executor เพื่อโหลด LoaderScript จาก GitHub

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/LoaderScript.lua"

local ok, err = pcall(function()
    local response = game:HttpGet(url)
    if not response or response == "" then
        error("ไม่ได้รับ response จาก URL")
    end
    local fn, compileErr = loadstring(response)
    if not fn then
        error("Compile error: " .. tostring(compileErr))
    end
    fn()
end)

if ok then
    print("[BorwonScript] MainLoader โหลดสำเร็จ")
else
    warn("[BorwonScript] MainLoader ERROR: " .. tostring(err))
end