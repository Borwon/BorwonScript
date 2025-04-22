-- Logging System
local function log(type, message)
    local timeStr = os.date("%H:%M:%S")
    if type == "info" then
        print("[" .. timeStr .. "] ℹ️ " .. message)
    elseif type == "success" then
        print("[" .. timeStr .. "] ✅ " .. message)
    elseif type == "warning" then
        warn("[" .. timeStr .. "] ⚠️ " .. message)
    elseif type == "error" then
        warn("[" .. timeStr .. "] ❌ " .. message)
    end
end

-- Load Mercury UI Library with error handling
local Mercury
local executor = loadstring or load -- Check for executor compatibility
if not executor then
    log("error", "Executor does not support loadstring or load.")
    return
end

local success, err = pcall(function()
    Mercury = executor(game:HttpGet("https://raw.githubusercontent.com/x2Swiftz/UI-Library/main/Mercury.lua"))()
end)

if not success or not Mercury then
    log("error", "Failed to load Mercury UI Library: " .. tostring(err))
    return
else
    log("success", "Mercury UI Library loaded successfully.")
end

-- Create a new UI
local UI = Mercury:Create{
    Name = "Test UI",
    Size = UDim2.fromOffset(400, 300),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/x2Swiftz/UI-Library"
}
log("success", "UI created successfully.")

-- Add a tab for testing
local Tab = UI:Tab{
    Name = "Status",
    Icon = "rbxassetid://6023426915" -- Example icon
}
log("success", "Tab added successfully.")

-- Add a label to display the current status
local StatusLabel = Tab:Label{
    Text = "Status: Initializing..."
}
log("success", "Status label added successfully.")

-- Function to update the status label
local function updateStatus(status, color)
    StatusLabel:SetText("Status: " .. status)
    StatusLabel:SetColor(color)
    log("info", "Status updated to: " .. status)
end

-- Simulate status updates for testing
task.spawn(function()
    local statuses = {
        { "Loading...", Color3.fromRGB(255, 255, 0) }, -- Yellow
        { "Ready", Color3.fromRGB(0, 255, 0) },       -- Green
        { "Error", Color3.fromRGB(255, 0, 0) },       -- Red
        { "No Script Found", Color3.fromRGB(255, 165, 0) } -- Orange
    }

    for _, status in ipairs(statuses) do
        updateStatus(status[1], status[2])
        task.wait(3) -- Wait 3 seconds before updating to the next status
    end
end)

-- Add a button for testing actions
Tab:Button{
    Name = "Test Button",
    Description = "Click to test",
    Callback = function()
        log("info", "Test button clicked!")
    end
}

-- Add a toggle for enabling/disabling features
Tab:Toggle{
    Name = "Enable Feature",
    StartingState = false,
    Description = "Toggle a feature on or off",
    Callback = function(state)
        log("info", "Feature state changed to: " .. tostring(state))
    end
}
