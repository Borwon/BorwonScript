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

-- Ensure game is fully loaded
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
    print("[ERROR] Failed to load RAMAccount: " .. err)
    RAMAccount = { new = function(name) return { SetAlias = function() end, SetDescription = function() end } end }
end

local MyAccount
success, err = pcall(function()
    MyAccount = RAMAccount.new(game:GetService("Players").LocalPlayer.Name)
end)
if not success or not MyAccount then
    print("[ERROR] Failed to initialize RAMAccount: " .. err)
    return
end

-- Format large numbers
local function FormatCoins(value)
    if value >= 1e6 then
        return string.format("%.1fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.1fk", value / 1e3)
    else
        return tostring(value)
    end
end

-- Simple Logging
local function log(type, message)
    local timeStr = os.date("%H:%M:%S")
    if type == "info" then
        print("["..timeStr.."] ℹ️ " .. message)
    elseif type == "success" then
        print("["..timeStr.."] ✅ " .. message)
    elseif type == "error" then
        warn("["..timeStr.."] ❌ " .. message)
    end
end

log("info", "Script Started")

-- Style and Flow Lists
local validStyles = {"Shidou", "Yukimiya", "Sae", "Aiku", "Rin", "Don Lorenzo", "Kunigami", "NEL Isagi", "Kaiser", "King", "NEL Bachira"}
local validFlows = {"Snake", "Prodigy", "Awakened Genius", "Dribbler", "Crow", "Trap", "Demon Wings", "Chameleon", "Wild Card", "Soul Harvester", "Emperor", "Bee Freestyle"}
local styleMap, flowMap = {}, {}
for _, s in ipairs(validStyles) do styleMap[s] = true end
for _, f in ipairs(validFlows) do flowMap[f] = true end

-- Format Style and Flow (only valid ones, else "none")
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

-- Check file writing capability (AWP compatible)
local canWriteFile = pcall(function() writefile("test.txt", "test") end)
if not canWriteFile then
    log("error", "Executor does not support file writing. File saving disabled.")
end

-- Ensure folder exists
if canWriteFile then
    pcall(function()
        if not isfolder(folderName) then
            makefolder(folderName)
            log("success", "Folder created: " .. folderName)
        end
    end)
end

-- Load Player Data
local function LoadPlayerData()
    if not canWriteFile then return {} end

    local data = {}
    local success, content = pcall(function()
        if isfile(fileName) then
            return readfile(fileName)
        end
        return ""
    end)

    if success and content ~= "" then
        for line in content:gmatch("[^\r\n]+") do
            local parts = {}
            for part in line:gmatch("[^:]+") do
                table.insert(parts, part)
            end
            if #parts >= 4 and parts[1] ~= "" then
                data[parts[1]] = {
                    style = parts[2] ~= "" and parts[2] or "none",
                    flow = parts[3] ~= "" and parts[3] or "none",
                    level = tonumber(parts[4]) or 1
                }
            end
        end
        local count = 0
        for _ in pairs(data) do count = count + 1 end
        log("info", "Loaded " .. count .. " players from file")
    else
        log("error", "Failed to read file or file is empty")
    end
    return data
end

-- Simple Backup
local function BackupPlayerData()
    if not canWriteFile then return end
    pcall(function()
        if isfile(fileName) then
            writefile(backupFileName, readfile(fileName))
            log("success", "Backup created")
        end
    end)
end

-- Save Player Data with Simple Retry
local function SavePlayerData(username, style, flow, level)
    if not canWriteFile then
        log("error", "File writing not supported")
        return false
    end

    style = FormatStyle(style)
    flow = FormatFlow(flow)
    level = tonumber(level) or 1

    local existingData = LoadPlayerData()
    existingData[username] = { style = style, flow = flow, level = level }

    local lines = {}
    for uname, data in pairs(existingData) do
        if uname ~= "" then
            table.insert(lines, string.format("%s:%s:%s:%d", uname, data.style, data.flow, data.level))
        end
    end
    local fileContent = table.concat(lines, "\n")

    local retryCount = 0
    while retryCount < config.max_retries do
        local success = pcall(function()
            BackupPlayerData()
            writefile(fileName, fileContent)
        end)
        if success then
            log("success", "Data saved for " .. username)
            return true
        end
        retryCount = retryCount + 1
        log("error", "Save failed, retrying (" .. retryCount .. "/" .. config.max_retries .. ")")
        task.wait(config.retry_delay)
    end
    log("error", "Failed to save data after " .. config.max_retries .. " retries")
    return false
end

-- Wait for Data to Load
local function WaitForDataToLoad()
    local player = game:GetService("Players").LocalPlayer
    local stats = player:WaitForChild("ProfileStats", 10)
    local pStats = player:WaitForChild("PlayerStats", 10)
    if not (stats and pStats) then
        log("error", "Failed to load ProfileStats or PlayerStats")
        return false
    end

    local money = stats:WaitForChild("Money", 5)
    local level = stats:WaitForChild("Level", 5)
    local style = pStats:WaitForChild("Style", 5)
    local flow = pStats:WaitForChild("Flow", 5)
    if not (money and level and style and flow) then
        log("error", "Failed to load stats")
        return false
    end
    return true
end

-- Save and Send Data
local isSaving = false
local lastSaveTime = 0
local function SaveAndSendData()
    if isSaving or (os.time() - lastSaveTime < config.save_cooldown) then
        return
    end
    isSaving = true

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

    SavePlayerData(player.Name, style, flow, level)

    local success, err = pcall(function()
        local alias = string.format("Money: %s Level: %d", FormatCoins(money), level)
        local description = string.format("Style: \"%s\" Flow: \"%s\"", style == "none" and "" or style, flow == "none" and "" or flow)
        MyAccount:SetAlias(alias)
        MyAccount:SetDescription(description)
    end)
    if not success then
        log("error", "Failed to send data to RAM: " .. err)
    else
        log("success", "Data sent to RAM")
    end

    lastSaveTime = os.time()
    isSaving = false
end

-- Auto-Kick if Style and Flow Match
local function CheckAndKickSelf()
    local player = game:GetService("Players").LocalPlayer
    local pStats = player:FindFirstChild("PlayerStats")
    if not pStats then return end

    local style = pStats:FindFirstChild("Style") and pStats.Style.Value or "none"
    local flow = pStats:FindFirstChild("Flow") and pStats.Flow.Value or "none"
    if styleMap[style] and flowMap[flow] then
        log("info", "Self-kick triggered: Style = " .. style .. ", Flow = " .. flow)
        SaveAndSendData()
        task.wait(1)
        player:Kick("Kicked due to matching Style & Flow")
    end
end

-- Initialize
task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local stats = player:WaitForChild("ProfileStats", 10)
    local pStats = player:WaitForChild("PlayerStats", 10)
    if stats and pStats then
        SaveAndSendData()

        local function setupChangeListener(instance, property)
            instance[property].Changed:Connect(function()
                task.spawn(SaveAndSendData)
            end)
        end
        setupChangeListener(stats, "Money")
        setupChangeListener(stats, "Level")
        setupChangeListener(pStats, "Style")
        setupChangeListener(pStats, "Flow")

        task.spawn(function()
            while true do
                task.wait(60)
                SaveAndSendData()
            end
        end)
    else
        log("error", "Failed to set up listeners")
    end
end)

-- Auto-Kick Monitoring
task.spawn(function()
    task.wait(10)
    while true do
        pcall(CheckAndKickSelf)
        task.wait(10)
    end
end)

-- Save on Leave
game.Players.PlayerRemoving:Connect(function(player)
    if player == game.Players.LocalPlayer then
        log("info", "Player leaving, saving data")
        isSaving = false
        lastSaveTime = 0
        SaveAndSendData()
        task.wait(1)
    end
end)

-- Periodic Stats Display
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
                print("==================")
            end
        end)
    end
end)

log("success", "Script initialized")