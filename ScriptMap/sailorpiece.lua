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
        -- log("warning", "No units found for player: " .. playerName)
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
    local dataFolder, gemsObject, levelObject

    -- Initial wait with retry
    for i = 1, 3 do
        dataFolder = player:WaitForChild("Data", 10)
        gemsObject = dataFolder and dataFolder:FindFirstChild("Gems")
        levelObject = dataFolder and dataFolder:FindFirstChild("Level")
        if gemsObject and levelObject then break end
        log("warning", "Data (Gems/Level) not loaded, retrying (" .. i .. "/3)...")
        task.wait(5)
    end

    if not (gemsObject and levelObject) then
        log("error", "Failed to load Data (Gems/Level) after retries.")
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

-- Add a longer delay to account for the loading screen and data initialization
log("info", "Waiting for loading screen and data initialization...")
task.wait(20) -- รอ 20 วินาทีสำหรับ loading screen และการโหลดข้อมูล

-- รอจนกว่าจะสร้างบัญชีได้
repeat task.wait() 
    MyAccount = RAMAccount.new(game:GetService("Players").LocalPlayer.Name)
until MyAccount

-- หากบัญชีพร้อมใช้งาน
if MyAccount then
    task.spawn(function()
        local updateInterval = 30 -- อัปเดตทุกๆ 30 วินาที
        while true do
            local gems, level
            local success, err = pcall(function()
                local dataFolder = game:GetService("Players").LocalPlayer:FindFirstChild("Data")
                if not dataFolder then return end

                local gemsObj = dataFolder:FindFirstChild("Gems")
                local levelObj = dataFolder:FindFirstChild("Level")
                
                -- ตรวจสอบและดึงค่า Gems
                if gemsObj then
                    if gemsObj:IsA("ValueBase") or gemsObj:IsA("StringValue") or gemsObj:IsA("IntValue") or gemsObj:IsA("NumberValue") then
                        gems = tostring(gemsObj.Value)
                    elseif gemsObj:IsA("TextLabel") or gemsObj:IsA("TextBox") then
                        gems = gemsObj.Text
                    else
                        gems = tostring(gemsObj.Value or gemsObj.Text)
                    end
                end

                -- ตรวจสอบและดึงค่า Level
                if levelObj then
                    if levelObj:IsA("ValueBase") or levelObj:IsA("StringValue") or levelObj:IsA("IntValue") or levelObj:IsA("NumberValue") then
                        level = tostring(levelObj.Value)
                    elseif levelObj:IsA("TextLabel") or levelObj:IsA("TextBox") then
                        level = levelObj.Text
                    else
                        level = tostring(levelObj.Value or levelObj.Text)
                    end
                end
            end)

            if success and (gems or level) then
                local formatted_gems = "N/A"
                if gems then
                    local cleaned_gems = gems:gsub("[^%d%.]", ""):gsub("%.+", ".")
                    local numeric_gems = tonumber(cleaned_gems)
                    if numeric_gems then
                        formatted_gems = FormatCoins(numeric_gems)
                    end
                end

                local formatted_level = "N/A"
                if level then
                    local cleaned_level = level:gsub("[^%d%.]", ""):gsub("%.+", ".")
                    local numeric_level = tonumber(cleaned_level)
                    if numeric_level then
                        formatted_level = tostring(numeric_level)
                    end
                end

                local unitNames = GetUnitNames() -- Fetch unit names

                -- อัปเดตข้อมูลในบัญชีด้วย Level และ Gems ที่ Alias
                local update_success, update_err = pcall(function()
                    MyAccount:SetAlias(string.format("Lv: %s | Gems: %s", formatted_level, formatted_gems))
                    MyAccount:SetDescription(string.format("Units: %s", unitNames))
                end)

                if update_success then
                    log("success", "Account updated: Lv = " .. formatted_level .. ", Gems = " .. formatted_gems .. ", Units = " .. unitNames)
                else
                    log("error", "Error updating account: " .. tostring(update_err))
                end
            else
                log("error", "Error fetching gems/level amount: " .. tostring(err))
            end

            log("info", "Waiting for next update in " .. updateInterval .. " seconds...")
            task.wait(updateInterval)
        end
    end)
end
