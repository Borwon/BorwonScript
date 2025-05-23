-- Configuration
local CONFIG = {
    ENABLE_RAM_LOG = true  -- Enable/disable RAM logging (true = on, false = off)
}

-- Service Initialization
local Players = game:GetService("Players")
local LOCAL_PLAYER = Players.LocalPlayer

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
    local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
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
    
    -- Wait a bit for game to fully load
    log("info", "Waiting 5 seconds for game to load before first RAM update...", true)
    task.wait(5)

    -- Check if MyAccount is defined and has the required methods
    if not MyAccount then
        log("error", "MyAccount is not defined. RAM update cannot proceed.", true)
        return
    end

    log("debug", "MyAccount type: " .. typeof(MyAccount), true)
    if typeof(MyAccount) ~= "table" and typeof(MyAccount) ~= "Instance" then
        log("error", "MyAccount is not a valid type (expected table or Instance).", true)
        return
    end

    -- Check if SetAlias and SetDescription exist
    if not MyAccount.SetAlias or not MyAccount.SetDescription then
        log("error", "MyAccount does not have SetAlias or SetDescription methods.", true)
        return
    end

    while true do
        local sheckles = 0
        local leaderstats = game:GetService("Players").LocalPlayer:FindFirstChild("leaderstats")
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

        local items_summary = getTargetItemsSummary()

        local update_success, update_err = pcall(function()
            MyAccount:SetAlias("Money: " .. formatted_money)
            MyAccount:SetDescription(items_summary)
        end)

        if update_success then
            log("info", "RAMAccount updated - Money: " .. formatted_money .. ", Items: " .. items_summary, true)
        else
            log("error", "Failed to update RAMAccount: " .. tostring(update_err), true)
        end

        task.wait(60)
    end
end

-- Main Execution
print("🔧 Starting main execution...")

-- Start RAM update immediately
print("🔄 Starting RAM update loop immediately...")
task.spawn(startRAMUpdateLoop)

print("🔧 Main execution completed.")