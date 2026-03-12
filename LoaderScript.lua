repeat task.wait() until game:IsLoaded()

getgenv().HorstConfig = {
    ["EnableLog"] = true,
    ["Whitescreen"] = false,
    ["EnableAddFriends"] = false,
}

-- โหลด Horst หลักก่อนเสมอ
loadstring(game:HttpGet("https://raw.githubusercontent.com/HorstSpaceX/last_update/main/on_loaded.lua"))()

-- =============================================================
-- Place ID Map → ScriptMap URL
-- TODO: เปลี่ยน PlaceId และ URL ให้ตรงกับเกมที่ต้องการ
-- =============================================================
local placeScripts = {
     [77747658251236] = "https://raw.githubusercontent.com/<user>/<repo>/main/ScriptMap/99night.lua",
     [14890802310] = "https://raw.githubusercontent.com/<user>/<repo>/main/ScriptMap/sailorpiece.lua",
     [90738171169572] = "https://raw.githubusercontent.com/<user>/<repo>/main/ScriptMap/BizarreLineage.lua",
     [79546208627805] = "https://raw.githubusercontent.com/<user>/<repo>/main/ScriptMap/atsgems.lua",
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