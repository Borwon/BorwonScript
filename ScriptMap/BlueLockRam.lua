-- Configuration Settings
local config = {
    low_mode = true,
    fps_cap = 10,
    disable_shadows = true,
    optimize_lighting = true,
    save_cooldown = 5,
    max_retries = 5,  -- เพิ่มจำนวนครั้งในการ retry
    retry_delay = 2,  -- เวลาเริ่มต้นในการ retry
    
    -- การตั้งค่าใหม่
    data_validation = {
        enabled = true,           -- เปิดใช้งานการตรวจสอบข้อมูล
        min_level = 1,            -- ระดับต่ำสุดที่ยอมรับได้
        require_valid_style = false, -- ไม่จำเป็นต้องมี style ที่ถูกต้อง
        require_valid_flow = false,  -- ไม่จำเป็นต้องมี flow ที่ถูกต้อง
        retry_invalid_data = true,  -- ลองใหม่เมื่อข้อมูลไม่ถูกต้อง
        max_validation_retries = 3  -- จำนวนครั้งสูงสุดในการลองตรวจสอบข้อมูล
    },
    
    smart_retry = {
        enabled = true,               -- เปิดใช้งานระบบ retry ที่ฉลาดขึ้น
        use_exponential_backoff = true, -- ใช้การถอยหลังแบบ exponential
        max_backoff = 30,             -- เวลาสูงสุดในการถอยหลัง (วินาที)
        jitter = true,                -- เพิ่มความสุ่มในการถอยหลัง
        success_reset_delay = true    -- รีเซ็ตเวลาถอยหลังเมื่อสำเร็จ
    }
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

-- Improved Logging System
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
    elseif type == "debug" then
        if config.debug_mode then
            print("["..timeStr.."] 🔍 " .. message)
        end
    end
end

log("info", "Script Started")

-- Style and Flow Validation
local validStyles = {"Shidou", "Yukimiya", "Sae", "Aiku", "Rin", "Don Lorenzo", "Kunigami", "NEL Isagi", "Kaiser", "King", "NEL Bachira"}
local validFlows = {"Snake", "Prodigy", "Awakened Genius", "Dribbler", "Crow", "Trap", "Demon Wings", "Chameleon", "Wild Card", "Soul Harvester", "Emperor", "Bee Freestyle"}
local styleMap, flowMap = {}, {}
for _, s in ipairs(validStyles) do styleMap[s] = true end
for _, f in ipairs(validFlows) do flowMap[f] = true end

-- ระบบตรวจสอบข้อมูลที่ดีขึ้น
local function ValidatePlayerData(username, style, flow, level)
    if not username or username == "" then
        return false, "Invalid username"
    end
    
    -- แก้ไขการตรวจสอบ style ให้ยอมรับค่า "none"
    if config.data_validation.require_valid_style and style ~= "none" and not styleMap[style] then
        return false, "Invalid style: " .. tostring(style)
    end
    
    -- แก้ไขการตรวจสอบ flow ให้ยอมรับค่า "none"
    if config.data_validation.require_valid_flow and flow ~= "none" and not flowMap[flow] then
        return false, "Invalid flow: " .. tostring(flow)
    end
    
    local numLevel = tonumber(level)
    if not numLevel or numLevel < config.data_validation.min_level then
        return false, "Invalid level: " .. tostring(level)
    end
    
    return true, "Data validated successfully"
end

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
                    
                    -- เพิ่มการตรวจสอบข้อมูลที่ดีขึ้น
                    if username and username ~= "" then
                        -- ตรวจสอบข้อมูลก่อนเพิ่มลงในตาราง
                        local isValid = true
                        if config.data_validation.enabled then
                            if (config.data_validation.require_valid_style and style ~= "none" and not styleMap[style]) or
                               (config.data_validation.require_valid_flow and flow ~= "none" and not flowMap[flow]) or
                               (level < config.data_validation.min_level) then
                                isValid = false
                            end
                        end
                        
                        if isValid then
                            data[username] = {
                                style = style ~= "" and style or "none",
                                flow = flow ~= "" and flow or "none",
                                level = level
                            }
                        else
                            log("warning", "Skipped invalid data for " .. username)
                        end
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

-- Create backup system (simplified, removed archive)
local function BackupPlayerData()
    if not canWriteFile then return end
    
    -- Create standard backup
    pcall(function()
        if isfile(fileName) then
            writefile(backupFileName, readfile(fileName))
            log("success", "Backup created")
        end
    end)
end

-- ระบบ Auto-Retry ที่ฉลาดขึ้น
local retryState = {
    count = 0,
    delay = config.retry_delay,
    lastAttempt = 0,
    lastSuccess = 0
}

local function GetNextRetryDelay()
    if not config.smart_retry.enabled then
        return config.retry_delay
    end
    
    local delay = config.retry_delay
    
    if config.smart_retry.use_exponential_backoff then
        -- คำนวณเวลาถอยหลังแบบ exponential
        delay = config.retry_delay * (2 ^ retryState.count)
        
        -- จำกัดเวลาสูงสุด
        delay = math.min(delay, config.smart_retry.max_backoff)
    end
    
    -- เพิ่มความสุ่ม (jitter) เพื่อป้องกันการชนกันของคำขอ
    if config.smart_retry.jitter then
        delay = delay * (0.5 + (math.random() * 0.5))
    end
    
    return delay
end

local function ResetRetryState()
    retryState.count = 0
    retryState.delay = config.retry_delay
    retryState.lastSuccess = os.time()
end

-- Improved save function with verification and smart retry
local function SavePlayerData(username, style, flow, level)
    if not canWriteFile then
        log("warning", "File writing not supported, skipping save.")
        return false
    end
    
    -- ตรวจสอบข้อมูลก่อนบันทึก
    local isValid, validationMessage = ValidatePlayerData(username, style, flow, level)
    if not isValid then
        log("error", "Data validation failed: " .. validationMessage)
        
        -- ถ้าเปิดใช้งานการลองใหม่เมื่อข้อมูลไม่ถูกต้อง
        if config.data_validation.retry_invalid_data and retryState.count < config.data_validation.max_validation_retries then
            retryState.count = retryState.count + 1
            local nextDelay = GetNextRetryDelay()
            log("warning", "Will retry validation in " .. nextDelay .. " seconds (Attempt " .. retryState.count .. "/" .. config.data_validation.max_validation_retries .. ")")
            
            task.delay(nextDelay, function()
                SavePlayerData(username, style, flow, level)
            end)
        end
        
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
        
        -- ใช้ระบบ retry ที่ฉลาดขึ้น
        if config.smart_retry.enabled and retryState.count < config.max_retries then
            retryState.count = retryState.count + 1
            retryState.lastAttempt = os.time()
            
            local nextDelay = GetNextRetryDelay()
            log("warning", "Will retry saving in " .. nextDelay .. " seconds (Attempt " .. retryState.count .. "/" .. config.max_retries .. ")")
            
            task.delay(nextDelay, function()
                SavePlayerData(username, style, flow, level)
            end)
        end
        
        return false
    end
    
    -- Verify temporary file
    local tempData = LoadPlayerData(tempFileName)
    local tempCount = 0
    for _ in pairs(tempData) do tempCount = tempCount + 1 end
    
    if tempCount < updatedCount then
        log("error", "Temporary file verification failed: Expected " .. updatedCount .. " entries, got " .. tempCount)
        
        -- ใช้ระบบ retry ที่ฉลาดขึ้น
        if config.smart_retry.enabled and retryState.count < config.max_retries then
            retryState.count = retryState.count + 1
            retryState.lastAttempt = os.time()
            
            local nextDelay = GetNextRetryDelay()
            log("warning", "Will retry verification in " .. nextDelay .. " seconds (Attempt " .. retryState.count .. "/" .. config.max_retries .. ")")
            
            task.delay(nextDelay, function()
                SavePlayerData(username, style, flow, level)
            end)
        end
        
        return false
    end
    
    -- Move temporary file to main file
    local moveSuccess = pcall(function()
        writefile(fileName, fileContent)
    end)
    
    if not moveSuccess then
        log("error", "Failed to move temporary file to main file")
        
        -- ใช้ระบบ retry ที่ฉลาดขึ้น
        if config.smart_retry.enabled and retryState.count < config.max_retries then
            retryState.count = retryState.count + 1
            retryState.lastAttempt = os.time()
            
            local nextDelay = GetNextRetryDelay()
            log("warning", "Will retry moving file in " .. nextDelay .. " seconds (Attempt " .. retryState.count .. "/" .. config.max_retries .. ")")
            
            task.delay(nextDelay, function()
                SavePlayerData(username, style, flow, level)
            end)
        end
        
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
        
        -- ใช้ระบบ retry ที่ฉลาดขึ้น
        if config.smart_retry.enabled and retryState.count < config.max_retries then
            retryState.count = retryState.count + 1
            retryState.lastAttempt = os.time()
            
            local nextDelay = GetNextRetryDelay()
            log("warning", "Will retry final verification in " .. nextDelay .. " seconds (Attempt " .. retryState.count .. "/" .. config.max_retries .. ")")
            
            task.delay(nextDelay, function()
                SavePlayerData(username, style, flow, level)
            end)
        end
        
        return false
    end
    
    -- รีเซ็ตสถานะ retry เมื่อสำเร็จ
    if config.smart_retry.success_reset_delay then
        ResetRetryState()
    end
    
    log("success", "Data saved and verified: " .. finalCount .. " entries (Added: " .. (updatedCount - initialCount) .. ")")
    return true
end

-- Account Management with improved data validation
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

-- Improved save function with data validation
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

    -- ตรวจสอบข้อมูลก่อนบันทึก
    local isValid, validationMessage = ValidatePlayerData(player.Name, style, flow, level)
    if not isValid then
        log("warning", "Data validation failed: " .. validationMessage .. " - Skipping save")
        
        -- ถ้าเปิดใช้งานการลองใหม่เมื่อข้อมูลไม่ถูกต้อง
        if config.data_validation.retry_invalid_data then
            task.delay(5, SaveAndSendData)
        end
        
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
                print("Retry Count: " .. retryState.count)
                
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