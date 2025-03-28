print("loadingchecking")

-- Wait for the game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Ensure HTTP service is enabled
local httpService = game:GetService("HttpService")
if not httpService then
    warn("❌ HTTP Service is not enabled. Please enable it to proceed.")
    return
end

-- Function to safely load external scripts
local function loadExternalScript(url)
    local success, result = pcall(function()
        local response = game:HttpGet(url)
        if not response or response == "" then
            error("Response is empty or invalid.")
        end
        return loadstring(response)
    end)

    if success and result then
        return pcall(result)
    else
        return false, result
    end
end

-- Load the external script
local scriptUrl = 'https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/LoaderScript.lua'
local success, err = loadExternalScript(scriptUrl)

if not success then
    warn("❌ เกิดข้อผิดพลาดในการโหลดสคริปต์: " .. tostring(err))
    warn("⚠️ โปรดตรวจสอบ URL หรือสถานะการเชื่อมต่ออินเทอร์เน็ตของคุณ.")
else
    print("✅ โหลดสคริปต์สำเร็จ!")
end