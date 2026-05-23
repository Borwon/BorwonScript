repeat task.wait() until game:IsLoaded()

getgenv().HorstConfig = {
    ["EnableLog"] = true,
    ["Whitescreen"] = false,
    ["EnableAddFriends"] = false,
    ["LockFps"] = {
        ["EnableLockFps"] = false,
        ["LockFpsAmount"] = 30 
    }
}

-- โหลด Horst หลักก่อนเสมอ
loadstring(game:HttpGet("https://raw.githubusercontent.com/HorstSpaceX/last_update/main/on_loaded.lua"))()

-- =============================================================
-- Place ID Map → ScriptMap URL
-- TODO: เปลี่ยน PlaceId และ URL ให้ตรงกับเกมที่ต้องการ
-- =============================================================
local placeScripts = {
     [77747658251236] = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/sailorpiece.lua",
     [14890802310] = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/BizarreLineage.lua",
     [90738171169572] = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/atsgems.lua",
     [79546208627805] = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/99night.lua",
     [74747090658891] = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/BizarreLineage.lua",
     [14916516914] = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/AttackOnTitan.lua",
     [114204398207377] = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/ZombieArena.lua",
}
-- =============================================================

local placeId = game.PlaceId
local scriptUrl = placeScripts[placeId]

if scriptUrl then
    print("[LoaderScript] Found map script for PlaceId:", placeId)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
    if not ok then
        warn("[LoaderScript] Error running map script: " .. tostring(err))
    end
else
    print("[LoaderScript] No script mapped for PlaceId:", placeId)
end
