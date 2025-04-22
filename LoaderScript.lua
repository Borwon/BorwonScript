-- ===== BorwonCheck - Enhanced UI Version =====
-- Improved UI with original functionality

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BorwonCheckUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Try to parent to PlayerGui first, fall back to CoreGui for executors
local success, result = pcall(function()
    local player = game:GetService("Players").LocalPlayer
    if player and player:FindFirstChild("PlayerGui") then
        ScreenGui.Parent = player.PlayerGui
        return true
    end
    return false
end)

if not success or not result then
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- Create main loading frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Add corner radius to main frame
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Add drop shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.Parent = MainFrame

-- Create top gradient bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

-- Add corner radius to top bar
local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

-- Create bottom cover to make top bar only rounded at top
local TopBarCover = Instance.new("Frame")
TopBarCover.Name = "TopBarCover"
TopBarCover.Size = UDim2.new(1, 0, 0, 10)
TopBarCover.Position = UDim2.new(0, 0, 1, -10)
TopBarCover.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TopBarCover.BorderSizePixel = 0
TopBarCover.Parent = TopBar

-- Add gradient to top bar
local TopBarGradient = Instance.new("UIGradient")
TopBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
})
TopBarGradient.Rotation = 90
TopBarGradient.Parent = TopBar

-- Create title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 50, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BorwonCheck"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Create logo
local LogoImage = Instance.new("ImageLabel")
LogoImage.Name = "LogoImage"
LogoImage.Size = UDim2.new(0, 24, 0, 24)
LogoImage.Position = UDim2.new(0, 10, 0.5, -12)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = "rbxassetid://1168967957"
LogoImage.Parent = TopBar

-- Create content frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Create logo container for center logo
local CenterLogoFrame = Instance.new("Frame")
CenterLogoFrame.Name = "CenterLogoFrame"
CenterLogoFrame.Size = UDim2.new(0, 120, 0, 120)
CenterLogoFrame.Position = UDim2.new(0.5, -60, 0.5, -60)
CenterLogoFrame.BackgroundTransparency = 1
CenterLogoFrame.Parent = ContentFrame

-- Create center logo
local CenterLogo = Instance.new("ImageLabel")
CenterLogo.Name = "CenterLogo"
CenterLogo.Size = UDim2.new(1, 0, 1, 0)
CenterLogo.BackgroundTransparency = 1
CenterLogo.Image = "rbxassetid://1168967957"
CenterLogo.Parent = CenterLogoFrame

-- Add glow effect to center logo
local LogoGlow = Instance.new("ImageLabel")
LogoGlow.Name = "LogoGlow"
LogoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
LogoGlow.BackgroundTransparency = 1
LogoGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
LogoGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
LogoGlow.ZIndex = -1
LogoGlow.Image = "rbxassetid://1168967957"
LogoGlow.ImageColor3 = Color3.fromRGB(0, 150, 255)
LogoGlow.ImageTransparency = 0.7
LogoGlow.Parent = CenterLogo

-- Create status label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 1, -50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Initializing..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 16
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = ContentFrame

-- Create progress bar background
local ProgressBarBg = Instance.new("Frame")
ProgressBarBg.Name = "ProgressBarBg"
ProgressBarBg.Size = UDim2.new(0.9, 0, 0, 6)
ProgressBarBg.Position = UDim2.new(0.05, 0, 1, -30)
ProgressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ProgressBarBg.BorderSizePixel = 0
ProgressBarBg.Parent = ContentFrame

-- Add corner radius to progress bar background
local ProgressBarBgCorner = Instance.new("UICorner")
ProgressBarBgCorner.CornerRadius = UDim.new(0, 3)
ProgressBarBgCorner.Parent = ProgressBarBg

-- Create progress bar fill
local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Name = "ProgressBarFill"
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.Parent = ProgressBarBg

-- Add corner radius to progress bar fill
local ProgressBarFillCorner = Instance.new("UICorner")
ProgressBarFillCorner.CornerRadius = UDim.new(0, 3)
ProgressBarFillCorner.Parent = ProgressBarFill

-- Add gradient to progress bar fill
local ProgressBarGradient = Instance.new("UIGradient")
ProgressBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200))
})
ProgressBarGradient.Parent = ProgressBarFill

-- Create compact status frame (initially hidden)
local CompactFrame = Instance.new("Frame")
CompactFrame.Name = "CompactFrame"
CompactFrame.Size = UDim2.new(0, 200, 0, 40)
CompactFrame.Position = UDim2.new(1, -210, 0, 10) -- Top-right corner
CompactFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
CompactFrame.BorderSizePixel = 0
CompactFrame.Visible = false
CompactFrame.Parent = ScreenGui

-- Add corner radius to compact frame
local CompactCorner = Instance.new("UICorner")
CompactCorner.CornerRadius = UDim.new(0, 6)
CompactCorner.Parent = CompactFrame

-- Add drop shadow to compact frame
local CompactShadow = Instance.new("ImageLabel")
CompactShadow.Name = "CompactShadow"
CompactShadow.AnchorPoint = Vector2.new(0.5, 0.5)
CompactShadow.BackgroundTransparency = 1
CompactShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
CompactShadow.Size = UDim2.new(1, 20, 1, 20)
CompactShadow.ZIndex = -1
CompactShadow.Image = "rbxassetid://6014261993"
CompactShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
CompactShadow.ImageTransparency = 0.5
CompactShadow.ScaleType = Enum.ScaleType.Slice
CompactShadow.SliceCenter = Rect.new(49, 49, 450, 450)
CompactShadow.Parent = CompactFrame

-- Create compact status label
local CompactStatusLabel = Instance.new("TextLabel")
CompactStatusLabel.Name = "CompactStatusLabel"
CompactStatusLabel.Size = UDim2.new(1, -40, 1, 0)
CompactStatusLabel.Position = UDim2.new(0, 35, 0, 0)
CompactStatusLabel.BackgroundTransparency = 1
CompactStatusLabel.Text = "Status: Ready"
CompactStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CompactStatusLabel.TextSize = 14
CompactStatusLabel.Font = Enum.Font.Gotham
CompactStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
CompactStatusLabel.Parent = CompactFrame

-- Create a small logo for compact mode
local CompactLogo = Instance.new("ImageLabel")
CompactLogo.Name = "CompactLogo"
CompactLogo.Size = UDim2.new(0, 20, 0, 20)
CompactLogo.Position = UDim2.new(0, 8, 0.5, -10)
CompactLogo.BackgroundTransparency = 1
CompactLogo.Image = "rbxassetid://1168967957"
CompactLogo.Parent = CompactFrame

-- Function to update progress bar
local function updateProgress(percentage)
    ProgressBarFill:TweenSize(
        UDim2.new(percentage/100, 0, 1, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.2,
        true
    )
end

-- Function to update status text
local function updateStatusText(text)
    StatusLabel.Text = text
end

-- Function to transition to compact mode
local function transitionToCompactMode(status, color)
    -- Set the compact status
    CompactStatusLabel.Text = "Status: " .. status
    CompactStatusLabel.TextColor3 = color or Color3.fromRGB(0, 255, 0)
    
    -- Fade out main frame
    for i = 0, 1, 0.1 do
        MainFrame.BackgroundTransparency = i
        TopBar.BackgroundTransparency = i
        TopBarCover.BackgroundTransparency = i
        TitleLabel.TextTransparency = i
        LogoImage.ImageTransparency = i
        StatusLabel.TextTransparency = i
        CenterLogo.ImageTransparency = i
        LogoGlow.ImageTransparency = 0.7 + (i * 0.3)
        ProgressBarBg.BackgroundTransparency = i
        ProgressBarFill.BackgroundTransparency = i
        Shadow.ImageTransparency = 0.5 + (i * 0.5)
        task.wait(0.02)
    end
    
    MainFrame.Visible = false
    
    -- Show compact frame
    CompactFrame.Visible = true
    CompactFrame.BackgroundTransparency = 1
    CompactStatusLabel.TextTransparency = 1
    CompactLogo.ImageTransparency = 1
    CompactShadow.ImageTransparency = 1
    
    -- Fade in compact frame
    for i = 1, 0, -0.1 do
        CompactFrame.BackgroundTransparency = i
        CompactStatusLabel.TextTransparency = i
        CompactLogo.ImageTransparency = i
        CompactShadow.ImageTransparency = 0.5 + (i * 0.5)
        task.wait(0.02)
    end
end

-- Function to update compact status
local function updateCompactStatus(status, color)
    CompactStatusLabel.Text = "Status: " .. status
    CompactStatusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
end

-- Make the logo pulse slightly
spawn(function()
    while task.wait(0.03) do
        if MainFrame.Visible then
            for i = 0.95, 1.05, 0.005 do
                if not MainFrame.Visible then break end
                CenterLogo.Size = UDim2.new(i, 0, i, 0)
                CenterLogo.Position = UDim2.new(0.5 - (i/2), 0, 0.5 - (i/2), 0)
                LogoGlow.Size = UDim2.new(1.5 + (i - 1), 0, 1.5 + (i - 1), 0)
                task.wait(0.03)
            end
            for i = 1.05, 0.95, -0.005 do
                if not MainFrame.Visible then break end
                CenterLogo.Size = UDim2.new(i, 0, i, 0)
                CenterLogo.Position = UDim2.new(0.5 - (i/2), 0, 0.5 - (i/2), 0)
                LogoGlow.Size = UDim2.new(1.5 + (i - 1), 0, 1.5 + (i - 1), 0)
                task.wait(0.03)
            end
        end
    end
end)

-- ===== LOADER SCRIPT FUNCTIONALITY =====

-- Function to wait for game to load
local function waitForGameLoaded(timeout)
    updateStatusText("Waiting for game to load...")
    updateProgress(5)
    
    timeout = timeout or 30 -- Default timeout of 30 seconds
    local startTime = tick()

    -- Wait until the game is loaded
    if not game:IsLoaded() then
        repeat
            if tick() - startTime > timeout then
                updateStatusText("⏳ Game loading timeout!")
                updateProgress(10)
                return false
            end
            updateProgress(10 + (tick() - startTime) / timeout * 20) -- Progress from 10% to 30%
            task.wait()
        until game:IsLoaded()
    end

    updateStatusText("✅ Game loaded!")
    updateProgress(30)

    -- Check if important services are loaded
    local services = {
        "Players",
        "ReplicatedStorage",
        "Workspace",
        "StarterGui",
        "StarterPack",
        "Lighting",
        "TweenService",
        "ContentProvider",
        "HttpService",
        "TeleportService"
    }

    for i, serviceName in ipairs(services) do
        updateStatusText("Loading service: " .. serviceName)
        updateProgress(30 + (i / #services) * 30) -- Progress from 30% to 60%
        
        local success, service = pcall(function()
            return game:GetService(serviceName)
        end)
        
        if success and service then
            updateStatusText("✅ Loaded: " .. serviceName)
        else
            updateStatusText("❌ Failed to load: " .. serviceName)
        end
        
        task.wait(0.1) -- Brief pause for visual feedback
    end

    return true
end

-- Function to update status
local function updateStatus(status, color)
    if type(status) == "string" then
        updateStatusText("Status: " .. status)
        
        -- Update progress based on status
        if status:find("Loading") then
            -- Already handled by waitForGameLoaded
        elseif status == "Ready" then
            updateProgress(100)
            task.wait(0.5)
            transitionToCompactMode(status, Color3.fromRGB(0, 255, 0))
        elseif status:find("Running:") then
            updateProgress(100)
            task.wait(0.5)
            transitionToCompactMode(status, Color3.fromRGB(0, 255, 0))
        elseif status:find("Error") then
            updateProgress(100)
            task.wait(0.5)
            transitionToCompactMode(status, Color3.fromRGB(255, 0, 0))
        elseif status == "No Script Found" then
            updateProgress(100)
            task.wait(0.5)
            transitionToCompactMode(status, Color3.fromRGB(255, 165, 0))
        end
    end
end

-- Table of scripts for different games
local scripts = {
    {
        ids = {116614712661486}, -- Example Game IDs for AriseCrossoverAFK
        name = "AriseCrossoverAFK",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/AriseRam.lua"
    },
    {
        ids = {115110570222234, 18668065416}, -- Example Game IDs for BlueLockRivals
        name = "BlueLockRivals",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/BlueLockRam.lua"
    },
    {
        ids = {72829404259339}, -- Example Game IDs for AnimeRangerX
        name = "AnimeRangerX",
        url = "https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/ScriptMap/AnimeRangerX.lua"
    },
}

-- Main function to run the loader
local function runLoader()
    -- Initial UI setup
    updateStatusText("Initializing loader...")
    updateProgress(0)
    
    -- Wait for game to load
    updateStatusText("Waiting for game to load...")
    local gameLoaded = waitForGameLoaded()
    
    if gameLoaded then
        updateStatus("Ready", Color3.fromRGB(0, 255, 0))
        updateStatusText("✅ Ready to load scripts!")
        updateProgress(60)
    else
        updateStatus("Error: Game Load Failed", Color3.fromRGB(255, 0, 0))
        return
    end
    
    -- Check current game ID
    local currentGame = game.PlaceId
    updateStatusText("Checking game ID: " .. currentGame)
    updateProgress(70)
    
    -- Find matching script
    local matchedScript = nil
    
    for _, script in ipairs(scripts) do
        for _, id in ipairs(script.ids) do
            if id == currentGame then
                matchedScript = script
                break
            end
        end
        if matchedScript then break end
    end
    
    -- Check if a matching script was found
    if matchedScript then
        local mapName = matchedScript.name
        local scriptUrl = matchedScript.url
        
        updateStatusText("🌐 Found script: " .. mapName)
        updateProgress(80)
        
        -- Check if loadstring or load is available
        local executor = loadstring or load
        if not executor then
            updateStatus("Error: No Executor", Color3.fromRGB(255, 0, 0))
            updateStatusText("❌ No loadstring/load function available.")
            return
        end
        
        -- Try to load and run the script
        updateStatusText("Loading script for: " .. mapName)
        updateProgress(90)
        
        local success, err = pcall(function()
            local response = game:HttpGet(scriptUrl)
            if not response or response == "" then
                error("Empty or invalid response.")
            end
            executor(response)()
        end)
        
        if not success then
            updateStatus("Error: Script Load Failed", Color3.fromRGB(255, 0, 0))
            updateStatusText("❌ Script load failed: " .. tostring(err))
        else
            updateStatus("Running: " .. mapName, Color3.fromRGB(0, 255, 0))
            updateStatusText("✅ Script loaded successfully!")
            updateProgress(100)
        end
    else
        updateStatus("No Script Found", Color3.fromRGB(255, 165, 0))
        updateStatusText("🚫 No script found for this game (ID: " .. currentGame .. ")")
        updateProgress(100)
    end
end

-- Add click handler to compact frame to expand back to full UI
CompactFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Expand UI back to full size
        CompactFrame.Visible = false
        MainFrame.Visible = true
        
        -- Reset transparencies
        MainFrame.BackgroundTransparency = 0
        TopBar.BackgroundTransparency = 0
        TopBarCover.BackgroundTransparency = 0
        TitleLabel.TextTransparency = 0
        LogoImage.ImageTransparency = 0
        StatusLabel.TextTransparency = 0
        CenterLogo.ImageTransparency = 0
        LogoGlow.ImageTransparency = 0.7
        ProgressBarBg.BackgroundTransparency = 0
        ProgressBarFill.BackgroundTransparency = 0
        Shadow.ImageTransparency = 0.5
    end
end)

-- Start the loader
runLoader()