-- Configuration Settings
local config = {
    low_mode = true, -- If true, reduces graphical effects for better performance
    fps_cap = 10, -- Max FPS limit
    disable_shadows = true, -- Disable global shadows
    optimize_lighting = true, -- Adjust lighting settings for performance
}

-- Ensure game is fully loaded before executing
repeat task.wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
print("Script Started")

-- Apply Configurations
setfpscap(config.fps_cap) -- Set FPS cap

if config.disable_shadows then
    game:GetService("Lighting").GlobalShadows = false
end

if config.optimize_lighting then
    game:GetService("Lighting").Brightness = 1
    game:GetService("Lighting").TimeOfDay = "12:00:00"
end

-- Load RAMAccount Library with error handling
local RAMAccount
local success, err = pcall(function()
    RAMAccount = loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua'))()
end)
if not success then
    print("[ERROR] Failed to load RAMAccount: " .. tostring(err))
    return
end

local MyAccount
success, err = pcall(function()
    MyAccount = RAMAccount.new(game:GetService("Players").LocalPlayer.Name)
end)
if not success or not MyAccount then
    print("[ERROR] Failed to initialize RAMAccount: " .. tostring(err))
    return
end

-- Function to format large numbers
local function FormatCoins(value)
    if value >= 1e6 then
        return string.format("%.1fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.1fk", value / 1e3)
    else
        return tostring(value)
    end
end

-- =====================
-- LOGGING SYSTEM
-- =====================
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

-- =====================
-- STYLE AND FLOW VALIDATION
-- =====================
local validStyles = {"Shidou", "Yukimiya", "Sae", "Aiku", "Rin", "Don Lorenzo", "Kunigami", "NEL Isagi", "Kaiser"}
local validFlows = {"Snake", "Prodigy", "Awakened Genius", "Dribbler", "Crow", "Trap", "Demon Wings", "Chameleon", "Wild Card", "Soul Harvester", "Emperor"}

-- Create lookup tables for faster validation
local styleMap, flowMap = {}, {}
for _, s in ipairs(validStyles) do styleMap[s] = true end
for _, f in ipairs(validFlows) do flowMap[f] = true end

-- Function to validate Style
local function FormatStyle(style)
    return styleMap[style] and style or "none"
end

-- Function to validate Flow
local function FormatFlow(flow)
    return flowMap[flow] and flow or "none"
end

-- =====================
-- DATA MANAGEMENT
-- =====================
-- Function to load player data from file
local function LoadPlayerData()
    local fileName = "Idcheck/PlayerData/player_data.txt"
    if not isfile(fileName) then return {} end

    local data, lines = {}, readfile(fileName):split("\n")
    for _, line in ipairs(lines) do
        local username, style, flow, level = line:match("([^:]+):([^:]*):([^:]*):([^:]*)")
        if username then
            data[username] = {
                style = style ~= "" and style or "none",
                flow = flow ~= "" and flow or "none",
                level = tonumber(level) or 1
            }
        end
    end
    return data
end

-- Function to save player data
local function SavePlayerData(username, style, flow, level)
    local folderName = "Idcheck/PlayerData"
    local fileName = folderName .. "/player_data.txt"

    -- Ensure folder exists
    if not isfolder(folderName) then
        local success, err = pcall(function()
            makefolder(folderName)
        end)
        if not success then
            log("error", "Failed to create folder: " .. tostring(err))
            return
        else
            log("success", "Folder created: " .. folderName)
        end
    end

    -- Load existing data
    local playerData = LoadPlayerData()

    -- Update player data
    playerData[username] = { style = style, flow = flow, level = level }

    -- Prepare data for saving
    local lines = {}
    for uname, data in pairs(playerData) do
        table.insert(lines, string.format("%s:%s:%s:%d", uname, data.style, data.flow, data.level))
    end

    -- Write data to file
    local success, err = pcall(function()
        writefile(fileName, table.concat(lines, "\n"))
    end)
    if not success then
        log("error", "Failed to save file: " .. tostring(err))
    else
        log("success", "Data saved successfully: " .. fileName)
    end
end

-- =====================
-- ACCOUNT MANAGEMENT
-- =====================
-- Function to ensure all data is loaded before proceeding with timeout
local function WaitForDataToLoad()
    local player = game:GetService("Players").LocalPlayer
    local stats = player:WaitForChild("ProfileStats", 10) -- Timeout 10 seconds
    local pStats = player:WaitForChild("PlayerStats", 10)

    if not (stats and pStats) then
        log("error", "Failed to load ProfileStats or PlayerStats within 10 seconds.")
        return false
    end

    local money = stats:WaitForChild("Money", 5)
    local level = stats:WaitForChild("Level", 5)
    local style = pStats:WaitForChild("Style", 5)
    local flow = pStats:WaitForChild("Flow", 5)

    if not (money and level and style and flow) then
        log("error", "Failed to load all stats within timeout.")
        return false
    end

    log("success", "All data loaded successfully.")
    return true
end

-- Function to handle data saving and sending
local function SaveAndSendData()
    local player = game:GetService("Players").LocalPlayer
    if not WaitForDataToLoad() then return end

    local stats = player.ProfileStats
    local pStats = player.PlayerStats

    -- Extract data
    local money = stats.Money.Value
    local level = stats.Level.Value
    local style = FormatStyle(pStats.Style.Value)
    local flow = FormatFlow(pStats.Flow.Value)

    -- Save data
    local dataSaved = false
    local saveSuccess, saveErr = pcall(function()
        SavePlayerData(player.Name, style, flow, level)
        dataSaved = true
    end)
    if not saveSuccess then
        log("error", "Error saving data: " .. tostring(saveErr))
    else
        log("success", "Data saved successfully.")
    end

    -- Send data to RAMAccount
    local dataSent = false
    local sendSuccess, sendErr = pcall(function()
        local alias = string.format("Money: %s Level: %d", FormatCoins(money), level)
        local description = string.format("Style: \"%s\" Flow: \"%s\"", style == "none" and "" or style, flow == "none" and "" or flow)
        MyAccount:SetAlias(alias)
        MyAccount:SetDescription(description)
        dataSent = true
    end)
    if not sendSuccess then
        log("error", "Error sending data: " .. tostring(sendErr))
    else
        log("success", "Data sent successfully.")
    end

    -- Final confirmation
    if dataSaved and dataSent then
        log("success", "Save and send operations completed successfully.")
    else
        log("error", "Save and send operations did not complete successfully.")
    end
end

-- Initialize RAMAccount with event listeners
task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local stats = player:WaitForChild("ProfileStats", 10)
    local pStats = player:WaitForChild("PlayerStats", 10)

    if stats and pStats then
        -- Initial save
        SaveAndSendData()

        -- Use event listeners to update on change
        stats.Money.Changed:Connect(function()
            SaveAndSendData()
        end)
        stats.Level.Changed:Connect(function()
            SaveAndSendData()
        end)
        pStats.Style.Changed:Connect(function()
            SaveAndSendData()
        end)
        pStats.Flow.Changed:Connect(function()
            SaveAndSendData()
        end)
    else
        log("error", "Failed to set up event listeners due to missing stats.")
    end
end)

-- =====================
-- AUTO-KICK FUNCTIONALITY
-- =====================
local function CheckAndKickSelf()
    local player = game:GetService("Players").LocalPlayer
    local pStats = player:FindFirstChild("PlayerStats")
    if not pStats then return end

    local style = pStats:FindFirstChild("Style") and pStats.Style.Value or "none"
    local flow = pStats:FindFirstChild("Flow") and pStats.Flow.Value or "none"

    local isValidStyle = styleMap[style] or false
    local isValidFlow = flowMap[flow] or false

    if isValidStyle and isValidFlow then
        log("warning", "Self-kick triggered: Style = " .. style .. ", Flow = " .. flow)
        task.spawn(function()
            SaveAndSendData()
            task.wait(1)
            player:Kick("You have been kicked due to matching Style & Flow.")
        end)
    end
end

-- Check self when the game loads
task.spawn(function()
    log("info", "Starting auto-kick monitoring")
    task.wait(5)

    local success, err = pcall(function()
        CheckAndKickSelf()
    end)

    if not success then
        log("error", "Error during initial check: " .. tostring(err))
    end

    while true do
        task.wait(10)
        local success, err = pcall(function()
            CheckAndKickSelf()
        end)
        if not success then
            log("error", "Error during periodic check: " .. tostring(err))
        end
    end
end)

log("success", "Script fully initialized")