--[[
    AriseRam.lua
    Auto QoL Monitor System
    
    Features:
    - Inventory monitoring
    - Discord webhook integration
    - RAM Account management
    - Performance optimization
    - Debug logging system
]]--

-------------------
-- CONFIGURATION --
-------------------
local config = {
    -- Performance Settings
    low_mode = true,              -- Reduces graphical effects
    fps_cap = 10,                 -- FPS limit
    disable_shadows = true,       -- Disable shadows
    optimize_lighting = true,     -- Optimize lighting
    disable_3d_rendering = true,  -- Disable 3D rendering
    
    -- Monitoring Settings
    check_interval = 10,          -- Check interval (seconds)
    check_all_folders = false,    -- Monitor all folders
    target_folders = {"Pets"},    -- Specific folders to monitor
    
    -- Notification Settings
    debug_mode = true,            -- Enable debug logs
}

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

----------------------
-- HELPER FUNCTIONS --
----------------------
-- Debug logging function
local function Debug(level, message)
    if not config.debug_mode then return end

    local prefix = {
        info = "ℹ️ INFO",
        warn = "⚠️ WARN",
        error = "❌ ERROR",
        success = "✅ SUCCESS"
    }

    print(string.format("[%s] %s", prefix[level] or "INFO", message))
end

-- Alias `log` to `Debug` for consistency
local log = Debug

-- Load RAMAccount Library
local RAMAccount
local function LoadRAMAccount()
    local success, result = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua'))()
    end)
    
    if success then
        RAMAccount = result
        Debug("success", "RAMAccount library loaded successfully")
        return true
    else
        Debug("error", "Failed to load RAMAccount library: " .. tostring(result))
        return false
    end
end

-----------------
-- CACHE STATE --
-----------------
-- Removed sentItemsCache and related logic
local MyAccount = nil -- RAMAccount instance

-------------------------
-- INVENTORY FUNCTIONS --
-------------------------
local function WaitForInventory()
    Debug("info", "Waiting for player and inventory to load...")
    local player = Players.LocalPlayer

    -- Wait for leaderstats
    while not player:FindFirstChild("leaderstats") do
        task.wait(1)
        Debug("info", "Waiting for leaderstats...")
    end

    -- Wait for inventory inside leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    while not leaderstats:FindFirstChild("Inventory") do
        task.wait(1)
        Debug("info", "Waiting for inventory...")
    end

    Debug("success", "Leaderstats and inventory loaded successfully!")
    return player, leaderstats:FindFirstChild("Inventory")
end

local function CheckInventoryAndUpdateAccount()
    log("info", "Checking inventory...")
    local player, inventory = WaitForInventory()

    if not inventory then
        log("error", "Inventory not found!")
        return
    end

    log("info", "Processing inventory folders...")

    local totalItems = 0
    local allItemNames = {}

    -- Process only folders specified in config.target_folders
    for _, folderName in ipairs(config.target_folders) do
        local folder = inventory:FindFirstChild(folderName)
        if folder and folder:IsA("Folder") then
            local items = folder:GetChildren()
            for _, item in ipairs(items) do
                table.insert(allItemNames, item.Name) -- Add item name to the list
                log("info", "Collected item: " .. item.Name) -- Debug log for each item
            end
            totalItems = totalItems + #items -- Count all items in the folder
        else
            log("warn", "Folder '" .. folderName .. "' not found or is not a valid folder")
        end
    end

    -- Ensure RAMAccount is updated correctly
    if MyAccount then
        local alias = string.format("Total Items: %d", totalItems)
        local description = string.format("Items: %s", #allItemNames > 0 and table.concat(allItemNames, ", ") or "None")

        local successAlias, errAlias = pcall(function()
            MyAccount:SetAlias(alias)
        end)
        local successDesc, errDesc = pcall(function()
            MyAccount:SetDescription(description)
        end)

        if successAlias and successDesc then
            log("success", "RAMAccount updated with inventory data")
        else
            log("error", "Failed to update RAMAccount: Alias Error: " .. tostring(errAlias) .. ", Description Error: " .. tostring(errDesc))
        end
    else
        log("error", "RAMAccount not initialized!")
    end

    log("success", "Inventory check completed.")
end

------------------------
-- STARTUP FUNCTIONS --
------------------------
local function InitializeRAMAccount()
    if not RAMAccount then
        if not LoadRAMAccount() then
            Debug("error", "Could not initialize RAMAccount - library not loaded")
            return false
        end
    end

    repeat 
        task.wait()
        local success, account = pcall(function()
            return RAMAccount.new(Players.LocalPlayer.Name)
        end)
        if success then
            MyAccount = account
        end
    until MyAccount
    
    Debug("success", "RAMAccount initialized successfully!")
    return true
end

local function ApplyPerformanceSettings()
    if config.disable_3d_rendering then
        RunService:Set3dRenderingEnabled(false)
    end
    -- ...existing code...
end

---------------------
-- INITIALIZATION --
---------------------
Debug("info", "Starting initialization...")

-- Wait for game load
repeat task.wait() until game:IsLoaded()
Debug("success", "Game loaded successfully!")

-- Apply performance settings
ApplyPerformanceSettings()

-- Initialize core components
local player, inventory = WaitForInventory()
if not InitializeRAMAccount() then
    Debug("warn", "Continuing without RAMAccount functionality")
end

---------------------
-- MAIN LOOP --
---------------------
task.spawn(function()
    while true do
        local success, err = pcall(function()
            CheckInventoryAndUpdateAccount()
        end)
        if not success then
            Debug("error", "Error in inventory check: " .. tostring(err))
        end
        task.wait(config.check_interval)
    end
end)

Debug("success", "Monitor system is now active and running continuously!")