-- Configuration Settings
local config = {
    low_mode = true,
    fps_cap = 10,
    disable_shadows = true,
    optimize_lighting = true,
    save_cooldown = 5,
    max_retries = 3,
    retry_delay = 2
}

-- Ensure game is fully loaded before executing
repeat task.wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
print("Script Started")

-- Apply Configurations
setfpscap(config.fps_cap)
if config.disable_shadows then
    game:GetService("Lighting").GlobalShadows = false
end
if config.optimize_lighting then
    game:GetService("Lighting").Brightness = 1
    game:GetService("Lighting").TimeOfDay = "12:00:00"
end

-- Load RAMAccount Library with fallback
local RAMAccount
local success, err = pcall(function()
    RAMAccount = loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua'))()
end)
if not success then
    print("[ERROR] Failed to load RAMAccount: " .. tostring(err))
    RAMAccount = { new = function(name) return { SetAlias = function() end, SetDescription = function() end } end }
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

-- Style and Flow Validation
local validStyles = {"Shidou", "Yukimiya", "Sae", "Aiku", "Rin", "Don Lorenzo", "Kunigami", "NEL Isagi", "Kaiser", "King"}
local validFlows = {"Snake", "Prodigy", "Awakened Genius", "Dribbler", "Crow", "Trap", "Demon Wings", "Chameleon", "Wild Card", "Soul Harvester", "Emperor"}
local styleMap, flowMap = {}, {}
for _, s in ipairs(validStyles) do styleMap[s] = true end
for _, f in ipairs(validFlows) do flowMap[f] = true end

local function FormatStyle(style)
    return styleMap[style] and style or "none"
end

local function FormatFlow(flow)
    return flowMap[flow] and flow or "none"
end

-- File paths
local folderName = "Idcheck/PlayerData"
local fileName = folderName .. "/player_data.txt"
local backupFileName = folderName .. "/player_data_backup.txt"

-- Check file writing capability - AWP specific
local canWriteFile = pcall(function() writefile("test.txt", "test") end)
if not canWriteFile then
    print("[WARNING] This Executor does not support file writing. File saving will be skipped.")
end

-- Ensure folder exists - AWP compatible
if canWriteFile then
    pcall(function()
        if not isfolder(folderName) then
            makefolder(folderName)
            log("success", "Folder created: " .. folderName)
        end
    end)
end

-- Simple file operations for AWP
local function LoadPlayerData()
    if not canWriteFile then return {} end
    
    local data = {}
    local fileContent = ""
    
    -- Try to read the file
    pcall(function()
        if isfile(fileName) then
            fileContent = readfile(fileName)
        end
    end)
    
    if fileContent and fileContent ~= "" then
        -- Split the content by newlines
        local lines = {}
        for line in string.gmatch(fileContent, "[^\r\n]+") do
            table.insert(lines, line)
        end
        
        for _, line in ipairs(lines) do
            if line and line ~= "" then
                local parts = {}
                for part in string.gmatch(line, "[^:]+") do
                    table.insert(parts, part)
                end
                
                if #parts >= 4 then
                    local username = parts[1]
                    local style = parts[2]
                    local flow = parts[3]
                    local level = tonumber(parts[4]) or 1
                    
                    if username and username ~= "" then
                        data[username] = {
                            style = style ~= "" and style or "none",
                            flow = flow ~= "" and flow or "none",
                            level = level
                        }
                    end
                end
            end
        end
        
        local count = 0
        for _ in pairs(data) do count = count + 1 end
        log("info", "Loaded data for " .. count .. " players")
    else
        log("warning", "Failed to load player data or file is empty")
    end
    
    return data
end

-- Create backup - AWP compatible
local function BackupPlayerData()
    if not canWriteFile then return end
    
    pcall(function()
        if isfile(fileName) then
            writefile(backupFileName, readfile(fileName))
            log("success", "Backup created")
        end
    end)
end

-- Save player data - AWP compatible
local function SavePlayerData(username, style, flow, level)
    if not canWriteFile then
        log("warning", "File writing not supported, skipping save.")
        return false
    end
    
    if not username or username == "" then
        log("error", "Invalid username, skipping save.")
        return false
    end
    
    -- Create backup first
    BackupPlayerData()
    
    -- Load existing data
    local playerData = LoadPlayerData()
    
    -- Add or update the player entry
    playerData[username] = { 
        style = style or "none", 
        flow = flow or "none", 
        level = tonumber(level) or 1 
    }
    
    -- Count entries for verification
    local entryCount = 0
    for _ in pairs(playerData) do
        entryCount = entryCount + 1
    end
    
    -- Prepare data for saving
    local lines = {}
    for uname, data in pairs(playerData) do
        if uname and uname ~= "" then
            table.insert(lines, string.format("%s:%s:%s:%d", 
                uname, 
                data.style or "none", 
                data.flow or "none", 
                tonumber(data.level) or 1
            ))
        end
    end
    
    local fileContent = table.concat(lines, "\n")
    
    -- Direct save approach for AWP
    local success = pcall(function()
        writefile(fileName, fileContent)
    end)
    
    if success then
        log("success", "Data saved successfully: " .. entryCount .. " entries")
        
        -- Verify the save by checking file exists
        local fileExists = pcall(function() return isfile(fileName) end)
        
        if not fileExists then
            log("error", "File verification failed - file doesn't exist after save")
            return false
        end
        
        return true
    else
        log("error", "Failed to save data")
        return false
    end
end

-- Account Management
local function WaitForDataToLoad()
    local player = game:GetService("Players").LocalPlayer
    local stats, pStats

    -- Initial wait with retry
    for i = 1, 3 do
        stats = player:WaitForChild("ProfileStats", 10)
        pStats = player:WaitForChild("PlayerStats", 10)
        if stats and pStats then break end
        log("warning", "Stats not loaded, retrying (" .. i .. "/3)...")
        task.wait(5)
    end

    if not (stats and pStats) then
        log("error", "Failed to load ProfileStats or PlayerStats after retries.")
        return false
    end

    local money, level, style, flow
    for i = 1, 3 do
        money = stats:WaitForChild("Money", 5)
        level = stats:WaitForChild("Level", 5)
        style = pStats:WaitForChild("Style", 5)
        flow = pStats:WaitForChild("Flow", 5)
        if money and level and style and flow then break end
        log("warning", "Sub-stats not loaded, retrying (" .. i .. "/3)...")
        task.wait(3)
    end

    if not (money and level and style and flow) then
        log("error", "Failed to load all stats after retries.")
        return false
    end

    if money.Value < 0 or level.Value <= 0 then
        log("warning", "Initial data invalid, waiting for valid values...")
        task.wait(5)
        if money.Value < 0 or level.Value <= 0 then
            log("error", "Data still invalid after wait.")
            return false
        end
    end

    log("success", "All data loaded successfully.")
    return true
end

-- Simple debounce system
local isSaving = false
local lastSaveTime = 0
local saveCount = 0

local initialRun = true
local function SaveAndSendData()
    -- Don't save too frequently
    if os.time() - lastSaveTime < config.save_cooldown and not initialRun then
        return
    end
    
    -- Don't run multiple saves at once
    if isSaving then return end
    isSaving = true

    if initialRun then
        log("info", "Initial run after join/rejoin, waiting for data stabilization...")
        task.wait(10)
        initialRun = false
    end

    local player = game:GetService("Players").LocalPlayer
    if not WaitForDataToLoad() then
        isSaving = false
        return
    end

    local stats = player.ProfileStats
    local pStats = player.PlayerStats

    local money = stats.Money.Value
    local level = stats.Level.Value
    local style = FormatStyle(pStats.Style.Value)
    local flow = FormatFlow(pStats.Flow.Value)

    if money < 0 or level <= 0 then
        log("warning", "Invalid data detected (Money: " .. money .. ", Level: " .. level .. "), skipping save.")
        isSaving = false
        return
    end

    -- Save data
    local saveSuccess = SavePlayerData(player.Name, style, flow, level)
    if saveSuccess then
        lastSaveTime = os.time()
        saveCount = saveCount + 1
        log("success", "Save #" .. saveCount .. " completed")
    end

    -- Send data to RAM
    local sendSuccess, sendErr = pcall(function()
        local alias = string.format("Money: %s Level: %d", FormatCoins(money), level)
        local description = string.format("Style: \"%s\" Flow: \"%s\"", style == "none" and "" or style, flow == "none" and "" or flow)
        MyAccount:SetAlias(alias)
        MyAccount:SetDescription(description)
    end)
    
    if not sendSuccess then
        log("error", "Error sending data: " .. tostring(sendErr))
    else
        log("success", "Data sent to RAM successfully.")
    end
    
    isSaving = false
end

-- Force save on player leaving
game.Players.PlayerRemoving:Connect(function(player)
    if player == game.Players.LocalPlayer then
        log("info", "Player is leaving, saving final data...")
        -- Force immediate save
        isSaving = false
        lastSaveTime = 0
        SaveAndSendData()
        task.wait(1) -- Give time for save to complete
    end
end)

-- Initialize with event listeners
task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local stats = player:WaitForChild("ProfileStats", 10)
    local pStats = player:WaitForChild("PlayerStats", 10)

    if stats and pStats then
        -- Initial save
        SaveAndSendData()

        -- Set up change listeners with throttling
        local function setupChangeListener(instance, property)
            local lastChange = 0
            instance[property].Changed:Connect(function()
                if os.time() - lastChange > 1 then -- Throttle to prevent spam
                    lastChange = os.time()
                    SaveAndSendData()
                end
            end)
        end

        task.wait(10) -- Initial delay
        setupChangeListener(stats, "Money")
        setupChangeListener(stats, "Level")
        setupChangeListener(pStats, "Style")
        setupChangeListener(pStats, "Flow")
        
        -- Periodic save as a fallback
        task.spawn(function()
            while true do
                task.wait(60) -- Save every minute as a backup
                SaveAndSendData()
            end
        end)
    else
        log("error", "Failed to set up event listeners due to missing stats.")
    end
end)

-- Auto-Kick Functionality
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

task.spawn(function()
    log("info", "Starting auto-kick monitoring")
    task.wait(10)

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

-- Display stats periodically
task.spawn(function()
    while true do
        task.wait(30)
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            local stats = player:FindFirstChild("ProfileStats")
            local pStats = player:FindFirstChild("PlayerStats")
            
            if stats and pStats then
                local money = stats:FindFirstChild("Money") and stats.Money.Value or 0
                local level = stats:FindFirstChild("Level") and stats.Level.Value or 0
                local style = pStats:FindFirstChild("Style") and pStats.Style.Value or "none"
                local flow = pStats:FindFirstChild("Flow") and pStats.Flow.Value or "none"
                
                print("=== Player Stats ===")
                print("Money: " .. FormatCoins(money))
                print("Level: " .. level)
                print("Style: " .. style)
                print("Flow: " .. flow)
                print("Saves: " .. saveCount)
                print("==================")
            end
        end)
    end
end)

-- Perform initial data load to verify file system
task.spawn(function()
    if canWriteFile then
        local initialData = LoadPlayerData()
        local count = 0
        for _ in pairs(initialData) do count = count + 1 end
        log("info", "Initial data loaded with " .. count .. " player records")
    end
end)

log("success", "Script fully initialized")