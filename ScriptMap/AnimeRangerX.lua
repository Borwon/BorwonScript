local RAMAccount = loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua'))()
local MyAccount 

-- Logging System
local function log(type, message)
    local timeStr = os.date("%H:%M:%S")
    if type == "info" then
        print("["..timeStr.."] ℹ️ " .. message)
    elseif type == "success" then
        print("["..timeStr.."] ✅ " .. message)
    elseif type == "warning" then
        warn("["..timeStr.."] ⚠️ " .. message)
    elseif type == "error" then
        warn("["..timeStr.."] ❌ " .. message)
    end
end

log("info", "Script Started")

-- ฟังก์ชันแปลงค่าตัวเลขให้มีหน่วย
local function FormatCoins(value)
    if value >= 1e6 then
        return string.format("%.1fM", value / 1e6) -- แปลงเป็นล้าน (M) และแสดงทศนิยม 1 ตำแหน่ง
    elseif value >= 1e3 then
        return string.format("%.1fk", value / 1e3) -- แปลงเป็นพัน (k) และแสดงทศนิยม 1 ตำแหน่ง
    else
        return tostring(value) -- แสดงตัวเลขปกติ
    end
end

-- Function to fetch unit names
local function GetUnitNames()
    local playerName = game:GetService("Players").LocalPlayer.Name
    local playerUnits = workspace:FindFirstChild("PlayerUnit") and workspace.PlayerUnit:FindFirstChild(playerName)
    if not playerUnits then
        log("warning", "No units found for player: " .. playerName)
        return "No Units"
    end

    local unitNames = {}
    for _, unit in ipairs(playerUnits:GetChildren()) do
        local unitName = unit.Name:match("([^/]+)") -- Extract name before '/'
        if unitName then
            table.insert(unitNames, unitName)
        end
    end

    return #unitNames > 0 and table.concat(unitNames, ", ") or "No Units"
end

-- Function to wait for data to load
local function WaitForDataToLoad()
    local player = game:GetService("Players").LocalPlayer
    local playerGui, hud, menuFrame, gemsFrame

    -- Initial wait with retry
    for i = 1, 3 do
        playerGui = player:WaitForChild("PlayerGui", 10)
        hud = playerGui:FindFirstChild("HUD")
        menuFrame = hud and hud:FindFirstChild("MenuFrame")
        gemsFrame = menuFrame and menuFrame:FindFirstChild("LeftSide") and menuFrame.LeftSide.Frame:FindFirstChild("Gems")
        if gemsFrame then break end
        log("warning", "HUD or Gems data not loaded, retrying (" .. i .. "/3)...")
        task.wait(5)
    end

    if not gemsFrame then
        log("error", "Failed to load HUD or Gems data after retries.")
        return false
    end

    local gemsText
    for i = 1, 3 do
        gemsText = gemsFrame:FindFirstChild("Numbers")
        if gemsText then break end
        log("warning", "Gems text not loaded, retrying (" .. i .. "/3)...")
        task.wait(3)
    end

    if not gemsText then
        log("error", "Failed to load Gems text after retries.")
        return false
    end

    log("success", "All data loaded successfully.")
    return true
end

-- Wait for data to load before proceeding
if not WaitForDataToLoad() then
    log("error", "Data failed to load. Script will terminate.")
    return
end

-- Add a delay to account for the loading screen
log("info", "Waiting for loading screen to finish...")
task.wait(15) -- รอ 15 วินาทีสำหรับ loading screen

-- Ensure Gems data is fully loaded
local function WaitForGemsData()
    local player = game:GetService("Players").LocalPlayer
    local gemsFrame, gemsText

    for i = 1, 5 do -- ลองโหลดข้อมูล Gems 5 ครั้ง
        local success = pcall(function()
            gemsFrame = player.PlayerGui.HUD.MenuFrame.LeftSide.Frame:FindFirstChild("Gems")
            gemsText = gemsFrame and gemsFrame:FindFirstChild("Numbers")
        end)

        if success and gemsText then
            log("success", "Gems data loaded successfully.")
            return true
        end

        log("warning", "Gems data not loaded, retrying (" .. i .. "/5)...")
        task.wait(3) -- รอ 3 วินาทีก่อนลองใหม่
    end

    log("error", "Failed to load Gems data after retries.")
    return false
end

if not WaitForGemsData() then
    log("error", "Gems data failed to load. Script will terminate.")
    return
end

-- รอจนกว่าจะสร้างบัญชีได้
repeat task.wait() 
    MyAccount = RAMAccount.new(game:GetService("Players").LocalPlayer.Name)
until MyAccount

-- หากบัญชีพร้อมใช้งาน
if MyAccount then
    task.spawn(function()
        local updateInterval = 300 -- อัปเดตทุกๆ 300 วินาที
        while true do
            local gems
            local success, err = pcall(function()
                gems = game:GetService("Players").LocalPlayer.PlayerGui.HUD.MenuFrame.LeftSide.Frame.Gems.Numbers.Text
            end)

            if success and gems then
                -- ลบตัวอักษรที่ไม่ใช่ตัวเลขหรือจุดทศนิยม
                local cleaned_gems = gems:gsub("[^%d%.]", ""):gsub("%.+", ".") -- เก็บเฉพาะตัวเลขและจุดทศนิยมเดียว
                local numeric_gems = tonumber(cleaned_gems)
                if numeric_gems then
                    local formatted_gems = FormatCoins(numeric_gems) -- ใช้ฟังก์ชัน FormatCoins
                    local unitNames = GetUnitNames() -- Fetch unit names

                    -- อัปเดตข้อมูลในบัญชี
                    local update_success, update_err = pcall(function()
                        MyAccount:SetAlias(string.format("Gem : %s", formatted_gems or "N/A"))
                        MyAccount:SetDescription(string.format("Units: %s", unitNames))
                    end)

                    if update_success then
                        log("success", "Account updated successfully: Gem = " .. formatted_gems .. ", Units = " .. unitNames)
                    else
                        log("error", "Error updating account: " .. tostring(update_err))
                    end
                else
                    log("warning", "Gem amount is not a valid number after cleaning: " .. tostring(gems))
                end
            else
                log("error", "Error fetching gem amount: " .. tostring(err))
            end

            log("info", "Waiting for next update in " .. updateInterval .. " seconds...")
            task.wait(updateInterval)
        end
    end)
end
