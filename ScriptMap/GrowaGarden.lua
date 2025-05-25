-- Configuration
local CONFIG = {
    ENABLE_RAM_LOG = false,       -- Enable/disable RAM logging (true = on, false = off)
    ENABLE_RAM_UPDATE = true,     -- Enable/disable RAM updating (true = on, false = off)
    DISPLAY_MONEY = true,        -- Enable/disable displaying money in RAM/console (true = on, false = off)
    DISPLAY_ITEMS = true,        -- Enable/disable displaying items in RAM/console (true = on, false = off)
    DISPLAY_TARGET_ITEMS = false  -- Enable/disable displaying specific target items (true = on, false = off)
}

-- Service Initialization
local Players = game:GetService("Players")
local LOCAL_PLAYER = Players.LocalPlayer

-- Load RAMAccount
local RAMAccount
local MyAccount
local success, err = pcall(function()
    RAMAccount = loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua'))()
end)
if success then
    print("✅ Successfully loaded RAMAccount")
else
    warn("❌ Failed to load RAMAccount: " .. tostring(err))
end

-- Wait until MyAccount is initialized
repeat
    task.wait()
    MyAccount = RAMAccount and RAMAccount.new(LOCAL_PLAYER.Name)
until MyAccount
print("✅ MyAccount initialized successfully for player: " .. LOCAL_PLAYER.Name)

-- Test MyAccount functionality
local test_success, test_err = pcall(function()
    MyAccount:SetAlias("Test Alias")
end)
if test_success then
    print("✅ MyAccount test successful")
else
    warn("❌ MyAccount test failed: " .. tostring(test_err))
end

-- Utility Functions
local function log(type, message, isRAMLog)
    if isRAMLog and not CONFIG.ENABLE_RAM_LOG then return end
    local timeStr = os.date("%H:%M:%S")
    if type == "info" then
        print("[" .. timeStr .. "] ℹ️ " .. message)
    elseif type == "error" then
        warn("[" .. timeStr .. "] ❌ " .. message)
    elseif type == "debug" then
        print("[" .. timeStr .. "] 🔍 " .. message)
    end
end

local function formatMoney(value)
    value = tonumber(value) or 0
    if value >= 1e12 then
        return string.format("%.2fT", value / 1e12)
    elseif value >= 1e9 then
        return string.format("%.2fB", value / 1e9)
    elseif value >= 1e6 then
        return string.format("%.2fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.2fk", value / 1e3)
    else
        return tostring(value)
    end
end

local function cleanItemName(itemName)
    local cleanedName = itemName:match("^[^%[]+"):gsub("%s+$", "")
    return cleanedName:lower():gsub("[_%s]+", "")
end

local function getTargetItemsSummary()
    local summary = {}
    local backpack = LOCAL_PLAYER:FindFirstChild("Backpack")
    if not backpack then
        log("error", "No Backpack found", true)
        return "No Items"
    end

    log("debug", "Raw items in Backpack:", true)
    for _, item in ipairs(backpack:GetChildren()) do
        log("debug", "- " .. item.Name, true)
    end

    local targetItems = {"Candy Blossom Seed", "Night Seed Pack", "Night Egg", "Bug Egg"}
    local targetSet = {}
    for _, target in ipairs(targetItems) do
        targetSet[cleanItemName(target)] = true
    end

    log("debug", "Target items (cleaned):", true)
    for target, _ in pairs(targetSet) do
        log("debug", "- " .. target, true)
    end

    for _, item in ipairs(backpack:GetChildren()) do
        local cleanedName = cleanItemName(item.Name)
        log("debug", "Checking item: " .. item.Name .. " (cleaned: " .. cleanedName .. ")", true)
        for targetCleaned in pairs(targetSet) do
            if cleanedName:find(targetCleaned) or targetCleaned:find(cleanedName) then
                local amount = ""
                if item:FindFirstChild("Amount") and tonumber(item.Amount.Value) then
                    amount = " x" .. tostring(item.Amount.Value)
                elseif item:FindFirstChild("Value") and tonumber(item.Value.Value) then
                    amount = " x" .. tostring(item.Value.Value)
                end
                table.insert(summary, item.Name .. amount)
                log("debug", "Found item: " .. item.Name .. amount, true)
                break
            end
        end
    end

    if #summary == 0 then
        return "No Candy Blossom Seed, Night Seed Pack, Night Egg, or Bug Egg"
    end
    return table.concat(summary, ", ")
end

local function startRAMUpdateLoop()
    log("info", "Starting RAM update loop", true)
    
    -- Wait longer for game to fully load
    log("info", "Waiting 10 seconds for game to load before first RAM update...", true)
    task.wait(10)

    while true do
        local sheckles = 0
        local leaderstats = LOCAL_PLAYER:FindFirstChild("leaderstats")
        if leaderstats then
            local shecklesObj = leaderstats:FindFirstChild("Sheckles")
            if shecklesObj then
                sheckles = shecklesObj.Value
                log("debug", "Sheckles value: " .. tostring(sheckles), true)
            else
                log("error", "Sheckles not found in leaderstats", true)
            end
        else
            log("error", "leaderstats not found", true)
        end
        local formatted_money = formatMoney(sheckles)

        local items_summary = getTargetItemsSummary() -- Always get full items summary

        -- Prepare output based on ENABLE_RAM_UPDATE
        local alias_text, desc_text
        if CONFIG.ENABLE_RAM_UPDATE then
            -- Use configured display settings
            alias_text = CONFIG.DISPLAY_MONEY and "Money: " .. formatted_money or "Money display disabled"
            desc_text = CONFIG.DISPLAY_ITEMS and "Items: " .. items_summary or "Items display disabled"
        else
            -- Show all data when RAM update is disabled
            alias_text = "Money: " .. formatted_money
            desc_text = "Items: " .. items_summary
        end

        local full_output = alias_text .. ", " .. desc_text

        local update_success, update_err = pcall(function()
            MyAccount:SetAlias(alias_text)
            MyAccount:SetDescription(desc_text)
        end)

        if update_success then
            log("info", "RAMAccount updated - " .. full_output, true)
        else
            log("error", "Failed to update RAMAccount: " .. tostring(update_err), true)
            log("info", "Falling back to console output - " .. full_output, true)
        end

        task.wait(60) -- Update every 60 seconds
    end
end

-- Main Execution
print("🔧 Starting main execution...")

-- Start RAM update immediately
print("🔄 Starting RAM update loop immediately...")
task.spawn(startRAMUpdateLoop)

print("🔧 Main execution completed.")