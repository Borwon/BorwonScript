-- Configuration
local CONFIG = {
    ENABLE_RAM_LOG = false,       -- Enable/disable RAM logging (true = on, false = off)
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

    -- Only process target items if DISPLAY_TARGET_ITEMS is true
    if not CONFIG.DISPLAY_TARGET_ITEMS then
        log("info", "Target items display disabled", true)
        return "Target items display disabled"
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

        local items_summary = CONFIG.DISPLAY_ITEMS and getTargetItemsSummary() or "Items display disabled"

        -- Prepare output based on config
        local output = {}
        if CONFIG.DISPLAY_MONEY then
            table.insert(output, "Money: " .. formatted_money)
        end
        if CONFIG.DISPLAY_ITEMS then
            table.insert(output, "Items: " .. items_summary)
        end
        local full_output = table.concat(output, ", ")

        local update_success, update_err = pcall(function()
            if CONFIG.DISPLAY_MONEY then
                MyAccount:SetAlias("Money: " .. formatted_money)
            else
                MyAccount:SetAlias("Money display disabled")
            end
            if CONFIG.DISPLAY_ITEMS then
                MyAccount:SetDescription(items_summary)
            else
                MyAccount:SetDescription("Items display disabled")
            end
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