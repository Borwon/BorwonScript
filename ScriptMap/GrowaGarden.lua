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
        return "No Items"
    end

    local targetItems = {"Candy Blossom Seed", "Night Seed Pack", "Night Egg", "Bug Egg", "Moon Blossom Seed"}
    local targetSet = {}
    for _, target in ipairs(targetItems) do
        targetSet[cleanItemName(target)] = true
    end

    for _, item in ipairs(backpack:GetChildren()) do
        local cleanedName = cleanItemName(item.Name)
        for targetCleaned in pairs(targetSet) do
            if cleanedName:find(targetCleaned) or targetCleaned:find(cleanedName) then
                local amount = ""
                if item:FindFirstChild("Amount") and tonumber(item.Amount.Value) then
                    amount = " x" .. tostring(item.Amount.Value)
                elseif item:FindFirstChild("Value") and tonumber(item.Value.Value) then
                    amount = " x" .. tostring(item.Value.Value)
                end
                table.insert(summary, item.Name .. amount)
                break
            end
        end
    end

    if #summary == 0 then
        return "No Candy Blossom Seed, Night Seed Pack, Night Egg, Bug Egg, or Moon Blossom Seed"
    end
    return table.concat(summary, ", ")
end

local function startRAMUpdateLoop()
    print("ℹ️ Starting RAM update loop")
    task.wait(10) -- Wait for game to load

    while true do
        local sheckles = 0
        local leaderstats = LOCAL_PLAYER:FindFirstChild("leaderstats")
        if leaderstats then
            local shecklesObj = leaderstats:FindFirstChild("Sheckles")
            if shecklesObj then
                sheckles = shecklesObj.Value
            end
        end
        local formatted_money = formatMoney(sheckles)
        local items_summary = getTargetItemsSummary()

        local update_success, update_err = pcall(function()
            MyAccount:SetAlias("Money: " .. formatted_money)
            MyAccount:SetDescription(items_summary)
        end)

        if update_success then
            print("✅ RAMAccount updated - Money: " .. formatted_money .. ", Items: " .. items_summary)
        else
            warn("❌ Failed to update RAMAccount: " .. tostring(update_err))
        end

        task.wait(60)
    end
end

-- Main Execution
print("🔧 Starting main execution...")
task.spawn(startRAMUpdateLoop)
print("🔧 Main execution completed.")