-- Configuration Settings
local config = {
    low_mode = true,
    fps_cap = 10,
    disable_shadows = true,
    optimize_lighting = true
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

-- Check file writing capability
local canWriteFile = pcall(function() writefile("test.txt", "test") end)
if not canWriteFile then
    print("[WARNING] This Executor does not support file writing. File saving will be skipped.")
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
local validStyles = {"Shidou", "Yukimiya", "Sae", "Aiku", "Rin", "Don Lorenzo", "Kunigami", "NEL Isagi", "Kaiser"}
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

-- Data Management
local function LoadPlayerData()
    if not canWriteFile then return {} end
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

local function SavePlayerData(username, style, flow, level)
    if not canWriteFile then
        log("warning", "File writing not supported, skipping save.")
        return
    end

    local folderName = "Idcheck/PlayerData"
    local fileName = folderName .. "/player_data.txt"

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

    local playerData = LoadPlayerData()
    playerData[username] = { style = style, flow = flow, level = level }

    local lines = {}
    for uname, data in pairs(playerData) do
        table.insert(lines, string.format("%s:%s:%s:%d", uname, data.style, data.flow, data.level))
    end

    local success, err = pcall(function()
        writefile(fileName, table.concat(lines, "\n"))
    end)
    if not success then
        log("error", "Failed to save file: " .. tostring(err))
    else
        log("success", "Data saved successfully: " .. fileName)
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

local debounce = false
local initialRun = true
local function SaveAndSendData()
    if debounce then return end
    debounce = true

    if initialRun then
        log("info", "Initial run after join/rejoin, waiting for data stabilization...")
        task.wait(10)
        initialRun = false
    end

    local player = game:GetService("Players").LocalPlayer
    if not WaitForDataToLoad() then
        debounce = false
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
        debounce = false
        return
    end

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

    if dataSaved and dataSent then
        log("success", "Save and send operations completed successfully.")
    else
        log("error", "Save and send operations did not complete successfully.")
    end

    task.wait(2)
    debounce = false
end

-- Use PlayerRemoving instead of OnRemove
game.Players.PlayerRemoving:Connect(function(player)
    if player == game.Players.LocalPlayer then
        log("info", "Player is leaving, saving final data...")
        SaveAndSendData()
    end
end)

-- Initialize RAMAccount with event listeners
task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local stats = player:WaitForChild("ProfileStats", 10)
    local pStats = player:WaitForChild("PlayerStats", 10)

    if stats and pStats then
        SaveAndSendData()

        task.wait(10)
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

log("success", "Script fully initialized")