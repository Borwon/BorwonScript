print("loadingchecking")

-- Wait for the game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Load the external script
local success, err = pcall(function()
    local response = game:HttpGet('https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/LoaderScript.lua')
    if not response or response == "" then
        error("Response is empty or invalid.")
    end
    loadstring(response)()
end)

if not success then
    warn("❌ เกิดข้อผิดพลาดในการโหลดสคริปต์: " .. tostring(err))
else
    print("✅ โหลดสคริปต์สำเร็จ!")
end