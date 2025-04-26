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
local tempFileName = folderName .. "/player_data_temp.txt"
local archiveFileName = folderName .. "/player_data_archive.txt"

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

-- Improved file operations for AWP
local function LoadPlayerData(filePath)
    if not canWriteFile then return {} end
    
    filePath = filePath or fileName
    
    local data = {}
    local fileContent = ""
    
    -- Try to read the file
    local success, result = pcall(function()
        if isfile(filePath) then
            return readfile(filePath)
        end
        return ""
    end)
    
    if success and result and result ~= "" then
        fileContent = result
    else
        log("warning", "Failed to read file: " .. filePath)
        return {}
    end
    
    -- Process file content
    if fileContent and fileContent ~= "" then
        -- Split the content by newlines
        local lines = {}
        for line in string.gmatch(fileContent, "[^\r\n]+") do
            if line and line ~= "" then
                table.insert(lines, line)
            end
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
        log("info", "Loaded " .. count .. " players from " .. filePath)
    else
        log("warning", "File is empty: " .. filePath)
    end
    
    return data
end

-- Create comprehensive backup system
local function BackupPlayerData()
    if not canWriteFile then return end
    
    -- Create standard backup
    pcall(function()
        if isfile(fileName) then
            writefile(backupFileName, readfile(fileName))
            log("success", "Standard backup created")
        end
    end)
    
    -- Create timestamped archive backup once per hour
    pcall(function()
        if isfile(fileName) then
            local currentHour = os.date("%Y-%m-%d_%H")
            local archiveFile = folderName .. "/archive_" .. currentHour .. ".txt"
            
            -- Only create archive if it doesn't exist for this hour
            if not isfile(archiveFile) then
                writefile(archiveFile, readfile(fileName))
                log("success", "Archive backup created: " .. archiveFile)
            end
        end
    end)
end

-- Improved save function with verification
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
    local existingData = LoadPlayerData()
    local initialCount = 0
    for _ in pairs(existingData) do initialCount = initialCount + 1 end
    
    -- Add or update the player entry
    existingData[username] = { 
        style = style or "none", 
        flow = flow or "none", 
        level = tonumber(level) or 1 
    }
    
    -- Count entries after update
    local updatedCount = 0
    for _ in pairs(existingData) do updatedCount = updatedCount + 1 end
    
    -- Prepare data for saving
    local lines = {}
    for uname, data in pairs(existingData) do
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
    
    -- Save to temporary file first
    local tempSuccess = pcall(function()
        writefile(tempFileName, fileContent)
    end)
    
    if not tempSuccess then
        log("error", "Failed to write temporary file")
        return false
    end
    
    -- Verify temporary file
    local tempData = LoadPlayerData(tempFileName)
    local tempCount = 0
    for _ in pairs(tempData) do tempCount = tempCount + 1 end
    
    if tempCount < updatedCount then
        log("error", "Temporary file verification failed: Expected " .. updatedCount .. " entries, got " .. tempCount)
        return false
    end
    
    -- Move temporary file to main file
    local moveSuccess = pcall(function()
        writefile(fileName, fileContent)
    end)
    
    if not moveSuccess then
        log("error", "Failed to move temporary file to main file")
        return false
    end
    
    -- Final verification
    local finalData = LoadPlayerData()
    local finalCount = 0
    for _ in pairs(finalData) do finalCount = finalCount + 1 end
    
    if finalCount < updatedCount then
        log("error", "Final verification failed: Expected " .. updatedCount .. " entries, got " .. finalCount)
        
        -- Try to restore from backup
        pcall(function()
            if isfile(backupFileName) then
                writefile(fileName, readfile(backupFileName))
                log("warning", "Restored from backup due to verification failure")
            end
        end)
        
        return false
    end
    
    log("success", "Data saved and verified: " .. finalCount .. " entries (Added: " .. (updatedCount - initialCount) .. ")")
    return true
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

-- Improved debounce system
local isSaving = false
local lastSaveTime = 0
local saveCount = 0
local saveQueue = {}

-- Process save queue
local function ProcessSaveQueue()
    if isSaving or #saveQueue == 0 then return end
    
    isSaving = true
    
    -- Get the latest save request
    local saveData = saveQueue[#saveQueue]
    saveQueue = {} -- Clear queue
    
    -- Execute the save
    local saveSuccess = SavePlayerData(
        saveData.username,
        saveData.style,
        saveData.flow,
        saveData.level
    )
    
    if saveSuccess then
        lastSaveTime = os.time()
        saveCount = saveCount + 1
        log("success", "Save #" .. saveCount .. " completed")
    else
        -- If save failed, try to requeue
        task.delay(2, function()
            table.insert(saveQueue, saveData)
            ProcessSaveQueue()
        end)
    end
    
    isSaving = false
    
    -- Process next item if any were added during this save
    if #saveQueue > 0 then
        task.delay(0.5, ProcessSaveQueue)
    end
end

-- Improved save function
local initialRun = true
local function SaveAndSendData()
    -- Don't save too frequently
    if os.time() - lastSaveTime < config.save_cooldown and not initialRun then
        return
    end

    if initialRun then
        log("info", "Initial run after join/rejoin, waiting for data stabilization...")
        task.wait(10)
        initialRun = false
    end

    local player = game:GetService("Players").LocalPlayer
    if not WaitForDataToLoad() then
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
        return
    end

    -- Queue the save operation
    table.insert(saveQueue, {
        username = player.Name,
        style = style,
        flow = flow,
        level = level
    })
    
    -- Process the queue
    task.spawn(ProcessSaveQueue)

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
end

-- Periodic data verification
task.spawn(function()
    while true do
        task.wait(300) -- Check every 5 minutes
        
        if canWriteFile and isfile(fileName) then
            local data = LoadPlayerData()
            local count = 0
            for _ in pairs(data) do count = count + 1 end
            
            log("info", "Periodic verification: " .. count .. " player records")
            
            -- If count is suspiciously low, try to recover
            if count < 40 and isfile(backupFileName) then
                local backupData = LoadPlayerData(backupFileName)
                local backupCount = 0
                for _ in pairs(backupData) do backupCount = backupCount + 1 end
                
                if backupCount > count then
                    log("warning", "Data loss detected! Backup has " .. backupCount .. " records vs current " .. count)
                    
                    -- Restore from backup
                    pcall(function()
                        writefile(fileName, readfile(backupFileName))
                        log("success", "Restored from backup due to data loss")
                    end)
                end
            end
        end
    end
end)

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
                
                -- Show data count
                if canWriteFile and isfile(fileName) then
                    local data = LoadPlayerData()
                    local count = 0
                    for _ in pairs(data) do count = count + 1 end
                    print("Saved Players: " .. count)
                end
                
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