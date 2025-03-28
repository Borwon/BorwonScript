print("loadingchecking")

-- Wait for the game to load
if not game:IsLoaded() then
    print("[DEBUG] Waiting for the game to load...")
    game.Loaded:Wait()
end
print("[DEBUG] Game loaded successfully.")

-- Load the external script
local success, err = pcall(function()
    local response = game:HttpGet('https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/LoaderScript.lua')
    if not response or response == "" then
        error("Response is empty or invalid.")
    end
    local executor = loadstring or load
    if not executor then
        error("Neither loadstring nor load function is available.")
    end
    executor(response)()
end)

if not success then
    warn("❌ เกิดข้อผิดพลาดในการโหลดสคริปต์: " .. tostring(err))
else
    print("✅ โหลดสคริปต์สำเร็จ!")
end