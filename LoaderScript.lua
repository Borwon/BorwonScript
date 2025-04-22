-- ===== BorwonCheck - Enhanced UI Version 2.0 =====
-- Improved UI with smoother animations and better error handling

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
    pcall(function() -- Added pcall to handle potential CoreGui restrictions
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
end

-- Create main loading frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Darker background for better contrast
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Add corner radius to main frame
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10) -- Increased corner radius for modern look
MainCorner.Parent = MainFrame

-- Add drop shadow with improved appearance
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 40, 1, 40) -- Larger shadow for better effect
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4 -- Less transparent for more visible shadow
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.Parent = MainFrame

-- Create top gradient bar with improved gradient
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45) -- Slightly taller top bar
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

-- Add corner radius to top bar
local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10) -- Matching corner radius
TopBarCorner.Parent = TopBar

-- Create bottom cover to make top bar only rounded at top
local TopBarCover = Instance.new("Frame")
TopBarCover.Name = "TopBarCover"
TopBarCover.Size = UDim2.new(1, 0, 0, 15)
TopBarCover.Position = UDim2.new(0, 0, 1, -15)
TopBarCover.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBarCover.BorderSizePixel = 0
TopBarCover.Parent = TopBar

-- Add improved gradient to top bar
local TopBarGradient = Instance.new("UIGradient")
TopBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 70)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 35, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 40))
})
TopBarGradient.Rotation = 90
TopBarGradient.Parent = TopBar

-- Create title with improved font and positioning
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 55, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BorwonCheck"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 20 -- Larger text
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Create logo with improved positioning
local LogoImage = Instance.new("ImageLabel")
LogoImage.Name = "LogoImage"
LogoImage.Size = UDim2.new(0, 28, 0, 28) -- Slightly larger logo
LogoImage.Position = UDim2.new(0, 15, 0.5, -14)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = "rbxassetid://1168967957"
LogoImage.Parent = TopBar

-- Add subtle glow to the logo
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
LogoGlow.Parent = LogoImage

-- Create content frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -30, 1, -70) -- More padding
ContentFrame.Position = UDim2.new(0, 15, 0, 55)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Create logo container for center logo
local CenterLogoFrame = Instance.new("Frame")
CenterLogoFrame.Name = "CenterLogoFrame"
CenterLogoFrame.Size = UDim2.new(0, 130, 0, 130) -- Larger center logo
CenterLogoFrame.Position = UDim2.new(0.5, -65, 0.5, -65)
CenterLogoFrame.BackgroundTransparency = 1
CenterLogoFrame.Parent = ContentFrame

-- Create center logo
local CenterLogo = Instance.new("ImageLabel")
CenterLogo.Name = "CenterLogo"
CenterLogo.Size = UDim2.new(1, 0, 1, 0)
CenterLogo.BackgroundTransparency = 1
CenterLogo.Image = "rbxassetid://1168967957"
CenterLogo.Parent = CenterLogoFrame

-- Add enhanced glow effect to center logo
local LogoGlow = Instance.new("ImageLabel")
LogoGlow.Name = "LogoGlow"
LogoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
LogoGlow.BackgroundTransparency = 1
LogoGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
LogoGlow.Size = UDim2.new(1.7, 0, 1.7, 0) -- Larger glow
LogoGlow.ZIndex = -1
LogoGlow.Image = "rbxassetid://1168967957"
LogoGlow.ImageColor3 = Color3.fromRGB(0, 150, 255)
LogoGlow.ImageTransparency = 0.7
LogoGlow.Parent = CenterLogo

-- Create status label with improved styling
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 1, -50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Initializing..."
StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220) -- Slightly off-white for better readability
StatusLabel.TextSize = 16
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = ContentFrame

-- Create progress bar background with improved styling
local ProgressBarBg = Instance.new("Frame")
ProgressBarBg.Name = "ProgressBarBg"
ProgressBarBg.Size = UDim2.new(0.9, 0, 0, 8) -- Slightly taller progress bar
ProgressBarBg.Position = UDim2.new(0.05, 0, 1, -30)
ProgressBarBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ProgressBarBg.BorderSizePixel = 0
ProgressBarBg.Parent = ContentFrame

-- Add corner radius to progress bar background
local ProgressBarBgCorner = Instance.new("UICorner")
ProgressBarBgCorner.CornerRadius = UDim.new(0, 4) -- Increased corner radius
ProgressBarBgCorner.Parent = ProgressBarBg

-- Create progress bar fill with improved styling
local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Name = "ProgressBarFill"
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.Parent = ProgressBarBg

-- Add corner radius to progress bar fill
local ProgressBarFillCorner = Instance.new("UICorner")
ProgressBarFillCorner.CornerRadius = UDim.new(0, 4) -- Matching corner radius
ProgressBarFillCorner.Parent = ProgressBarFill

-- Add enhanced gradient to progress bar fill
local ProgressBarGradient = Instance.new("UIGradient")
ProgressBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 235))
})
ProgressBarGradient.Parent = ProgressBarFill

-- Create compact status frame with improved styling
local CompactFrame = Instance.new("Frame")
CompactFrame.Name = "CompactFrame"
CompactFrame.Size = UDim2.new(0, 220, 0, 45) -- Slightly larger for better visibility
CompactFrame.Position = UDim2.new(1, -230, 0, 10) -- Top-right corner
CompactFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CompactFrame.BorderSizePixel = 0
CompactFrame.Visible = false
CompactFrame.Parent = ScreenGui

-- Add corner radius to compact frame
local CompactCorner = Instance.new("UICorner")
CompactCorner.CornerRadius = UDim.new(0, 8)
CompactCorner.Parent = CompactFrame

-- Add improved drop shadow to compact frame
local CompactShadow = Instance.new("ImageLabel")
CompactShadow.Name = "CompactShadow"
CompactShadow.AnchorPoint = Vector2.new(0.5, 0.5)
CompactShadow.BackgroundTransparency = 1
CompactShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
CompactShadow.Size = UDim2.new(1, 25, 1, 25)
CompactShadow.ZIndex = -1
CompactShadow.Image = "rbxassetid://6014261993"
CompactShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
CompactShadow.ImageTransparency = 0.4
CompactShadow.ScaleType = Enum.ScaleType.Slice
CompactShadow.SliceCenter = Rect.new(49, 49, 450, 450)
CompactShadow.Parent = CompactFrame

-- Create compact status label with improved styling
local CompactStatusLabel = Instance.new("TextLabel")
CompactStatusLabel.Name = "CompactStatusLabel"
CompactStatusLabel.Size = UDim2.new(1, -45, 1, 0)
CompactStatusLabel.Position = UDim2.new(0, 40, 0, 0)
CompactStatusLabel.BackgroundTransparency = 1
CompactStatusLabel.Text = "Status: Ready"
CompactStatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
CompactStatusLabel.TextSize = 15 -- Slightly larger text
CompactStatusLabel.Font = Enum.Font.GothamSemibold -- Semibold for better readability
CompactStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
CompactStatusLabel.Parent = CompactFrame

-- Create a small logo for compact mode with improved positioning
local CompactLogo = Instance.new("ImageLabel")
CompactLogo.Name = "CompactLogo"
CompactLogo.Size = UDim2.new(0, 24, 0, 24)
CompactLogo.Position = UDim2.new(0, 10, 0.5, -12)
CompactLogo.BackgroundTransparency = 1
CompactLogo.Image = "rbxassetid://1168967957"
CompactLogo.Parent = CompactFrame

-- Add subtle glow to compact logo
local CompactLogoGlow = Instance.new("ImageLabel")
CompactLogoGlow.Name = "CompactLogoGlow"
CompactLogoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
CompactLogoGlow.BackgroundTransparency = 1
CompactLogoGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
CompactLogoGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
CompactLogoGlow.ZIndex = -1
CompactLogoGlow.Image = "rbxassetid://1168967957"
CompactLogoGlow.ImageColor3 = Color3.fromRGB(0, 150, 255)
CompactLogoGlow.ImageTransparency = 0.8
CompactLogoGlow.Parent = CompactLogo

-- Add hover effect to compact frame
local isHovering = false
CompactFrame.MouseEnter:Connect(function()
    isHovering = true
    -- Subtle grow effect on hover
    CompactFrame:TweenSize(
        UDim2.new(0, 225, 0, 48),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.2,
        true
    )
    CompactStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Brighter text on hover
end)

CompactFrame.MouseLeave:Connect(function()
    isHovering = false
    -- Return to normal size
    CompactFrame:TweenSize(
        UDim2.new(0, 220, 0, 45),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.2,
        true
    )
    CompactStatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220) -- Return to normal text color
end)

-- Function to update progress bar with smoother animation
local function updateProgress(percentage)
    -- Ensure percentage is within valid range
    percentage = math.clamp(percentage, 0, 100)
    
    -- Use smoother easing for progress bar
    ProgressBarFill:TweenSize(
        UDim2.new(percentage/100, 0, 1, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quart, -- Changed to Quart for smoother animation
        0.3, -- Slightly longer animation for smoother feel
        true
    )
end

-- Function to update status text with optional animation
local function updateStatusText(text)
    -- Optional fade animation for text updates
    local function animateTextChange()
        for i = 1, 0, -0.2 do
            StatusLabel.TextTransparency = i
            task.wait(0.01)
        end
        
        StatusLabel.Text = text
        
        for i = 0, 1, 0.2 do
            StatusLabel.TextTransparency = 1 - i
            task.wait(0.01)
        end
        StatusLabel.TextTransparency = 0
    end
    
    -- Use pcall to handle any animation errors gracefully
    local success = pcall(animateTextChange)
    if not success then
        -- Fallback if animation fails
        StatusLabel.Text = text
    end
end

-- Function to transition to compact mode with improved animations
local function transitionToCompactMode(status, color)
    -- Set the compact status
    CompactStatusLabel.Text = "Status: " .. status
    CompactStatusLabel.TextColor3 = color or Color3.fromRGB(0, 255, 0)
    
    -- Create a smoother fade out animation
    local tweenInfo = TweenInfo.new(
        0.5, -- Duration
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    -- Use pcall for safer tweening
    pcall(function()
        -- Fade out main elements
        local mainTween = game:GetService("TweenService"):Create(MainFrame, tweenInfo, {
            BackgroundTransparency = 1
        })
        mainTween:Play()
        
        -- Fade out other elements with slight delay between each
        for i, element in ipairs({
            TopBar, TopBarCover, TitleLabel, LogoImage, 
            StatusLabel, CenterLogo, ProgressBarBg, ProgressBarFill
        }) do
            task.spawn(function()
                task.wait(i * 0.03) -- Staggered delay for cascade effect
                local elementTween = game:GetService("TweenService"):Create(element, tweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 1,
                    ImageTransparency = 1
                })
                elementTween:Play()
            end)
        end
        
        -- Special handling for glow elements
        local glowTween = game:GetService("TweenService"):Create(LogoGlow, tweenInfo, {
            ImageTransparency = 1
        })
        glowTween:Play()
        
        -- Wait for main tween to complete
        mainTween.Completed:Wait()
        MainFrame.Visible = false
    end)
    
    -- Show compact frame with fade in animation
    CompactFrame.Visible = true
    CompactFrame.BackgroundTransparency = 1
    CompactStatusLabel.TextTransparency = 1
    CompactLogo.ImageTransparency = 1
    CompactShadow.ImageTransparency = 1
    CompactLogoGlow.ImageTransparency = 1
    
    -- Create fade in animation for compact mode
    tweenInfo = TweenInfo.new(
        0.4, -- Duration
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    pcall(function()
        -- Fade in compact elements
        local compactTween = game:GetService("TweenService"):Create(CompactFrame, tweenInfo, {
            BackgroundTransparency = 0
        })
        compactTween:Play()
        
        -- Fade in other compact elements with slight delay
        task.spawn(function()
            task.wait(0.1)
            local labelTween = game:GetService("TweenService"):Create(CompactStatusLabel, tweenInfo, {
                TextTransparency = 0
            })
            labelTween:Play()
        end)
        
        task.spawn(function()
            task.wait(0.15)
            local logoTween = game:GetService("TweenService"):Create(CompactLogo, tweenInfo, {
                ImageTransparency = 0
            })
            logoTween:Play()
        end)
        
        task.spawn(function()
            task.wait(0.2)
            local shadowTween = game:GetService("TweenService"):Create(CompactShadow, tweenInfo, {
                ImageTransparency = 0.4
            })
            shadowTween:Play()
            
            local glowTween = game:GetService("TweenService"):Create(CompactLogoGlow, tweenInfo, {
                ImageTransparency = 0.8
            })
            glowTween:Play()
        end)
    end)
end

-- Function to update compact status with animation
local function updateCompactStatus(status, color)
    -- Animate text change
    local function animateTextChange()
        for i = 0, 0.8, 0.2 do
            CompactStatusLabel.TextTransparency = i
            task.wait(0.01)
        end
        
        CompactStatusLabel.Text = "Status: " .. status
        CompactStatusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        
        for i = 0.8, 0, -0.2 do
            CompactStatusLabel.TextTransparency = i
            task.wait(0.01)
        end
    end
    
    -- Use pcall to handle any animation errors
    pcall(animateTextChange)
end

-- Make the logo pulse with improved animation
spawn(function()
    while task.wait(0.01) do -- Smoother animation with shorter wait time
        if MainFrame.Visible then
            -- Use sine wave for smoother pulsing
            for t = 0, math.pi * 2, 0.05 do
                if not MainFrame.Visible then break end
                
                -- Calculate size using sine wave (smoother transition)
                local scale = 0.95 + 0.1 * math.sin(t)
                
                -- Apply scale with proper centering
                CenterLogo.Size = UDim2.new(scale, 0, scale, 0)
                CenterLogo.Position = UDim2.new(0.5 - scale/2, 0, 0.5 - scale/2, 0)
                
                -- Scale glow slightly differently for interesting effect
                local glowScale = 1.5 + 0.2 * math.sin(t + math.pi/4)
                LogoGlow.Size = UDim2.new(glowScale, 0, glowScale, 0)
                
                task.wait(0.01)
            end
        end
    end
end)

-- Add subtle animation to compact logo
spawn(function()
    while task.wait(0.01) do
        if CompactFrame.Visible and not isHovering then
            -- Subtle rotation animation for compact logo
            for t = 0, math.pi * 2, 0.03 do
                if not CompactFrame.Visible or isHovering then break end
                
                -- Very subtle movement
                local offset = 1 + 0.5 * math.sin(t)
                CompactLogo.Position = UDim2.new(0, 10, 0.5, -12 + offset)
                
                -- Subtle glow pulsing
                local transparency = 0.8 + 0.1 * math.sin(t)
                CompactLogoGlow.ImageTransparency = transparency
                
                task.wait(0.02)
            end
        end
    end
end)

-- ===== LOADER SCRIPT FUNCTIONALITY =====

-- Function to wait for game to load with improved error handling
local function waitForGameLoaded(timeout)
    updateStatusText("Waiting for game to load...")
    updateProgress(5)
    
    timeout = timeout or 30 -- Default timeout of 30 seconds
    local startTime = tick()

    -- Wait until the game is loaded with better error handling
    if not game:IsLoaded() then
        local loadingStep = 0
        repeat
            if tick() - startTime > timeout then
                updateStatusText("⏳ Game loading timeout!")
                updateProgress(10)
                return false
            end
            
            -- Show different loading messages to indicate progress
            loadingStep = (loadingStep + 1) % 4
            local loadingText = "Waiting for game to load"
            for i = 1, loadingStep do
                loadingText = loadingText .. "."
            end
            updateStatusText(loadingText)
            
            updateProgress(10 + (tick() - startTime) / timeout * 20) -- Progress from 10% to 30%
            task.wait(0.5) -- Shorter wait for more responsive updates
        until game:IsLoaded()
    end

    updateStatusText("✅ Game loaded!")
    updateProgress(30)

    -- Check if important services are loaded with improved visual feedback
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

    local totalServices = #services
    local loadedServices = 0
    
    for i, serviceName in ipairs(services) do
        updateStatusText("Loading service: " .. serviceName)
        
        local success, service = pcall(function()
            return game:GetService(serviceName)
        end)
        
        if success and service then
            loadedServices = loadedServices + 1
            updateStatusText("✅ Loaded: " .. serviceName .. " (" .. loadedServices .. "/" .. totalServices .. ")")
        else
            updateStatusText("❌ Failed to load: " .. serviceName)
        end
        
        -- Update progress based on loaded services ratio
        updateProgress(30 + (loadedServices / totalServices) * 30)
        task.wait(0.1) -- Brief pause for visual feedback
    end

    return true
end

-- Function to update status with improved error handling
local function updateStatus(status, color)
    if type(status) == "string" then
        pcall(function()
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
        end)
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

-- Main function to run the loader with improved error handling
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
    
    -- Find matching script with improved error handling
    local matchedScript = nil
    
    pcall(function()
        for _, script in ipairs(scripts) do
            for _, id in ipairs(script.ids) do
                if id == currentGame then
                    matchedScript = script
                    break
                end
            end
            if matchedScript then break end
        end
    end)
    
    -- Check if a matching script was found with improved error handling
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
        
        -- Try to load and run the script with better error handling
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

-- Add click handler to compact frame to expand back to full UI with improved animation
CompactFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Create expand animation
        CompactFrame:TweenSize(
            UDim2.new(0, 230, 0, 50),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Back,
            0.2,
            true,
            function()
                -- After expansion, start transition
                CompactFrame.Visible = false
                MainFrame.Visible = true
                
                -- Reset transparencies with animation
                MainFrame.BackgroundTransparency = 1
                TopBar.BackgroundTransparency = 1
                TopBarCover.BackgroundTransparency = 1
                TitleLabel.TextTransparency = 1
                LogoImage.ImageTransparency = 1
                StatusLabel.TextTransparency = 1
                CenterLogo.ImageTransparency = 1
                LogoGlow.ImageTransparency = 1
                ProgressBarBg.BackgroundTransparency = 1
                ProgressBarFill.BackgroundTransparency = 1
                Shadow.ImageTransparency = 1
                
                -- Create fade in animation
                local tweenInfo = TweenInfo.new(
                    0.4,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )
                
                -- Fade in main elements
                local mainTween = game:GetService("TweenService"):Create(MainFrame, tweenInfo, {
                    BackgroundTransparency = 0
                })
                mainTween:Play()
                
                -- Fade in other elements with cascade effect
                for i, element in ipairs({
                    Shadow, TopBar, TopBarCover, TitleLabel, LogoImage, 
                    StatusLabel, CenterLogo, ProgressBarBg, ProgressBarFill
                }) do
                    task.spawn(function()
                        task.wait(i * 0.05) -- Staggered delay
                        local elementTween = game:GetService("TweenService"):Create(element, tweenInfo, {
                            BackgroundTransparency = 0,
                            TextTransparency = 0,
                            ImageTransparency = 0
                        })
                        elementTween:Play()
                    end)
                end
                
                -- Special handling for glow
                task.spawn(function()
                    task.wait(0.3)
                    local glowTween = game:GetService("TweenService"):Create(LogoGlow, tweenInfo, {
                        ImageTransparency = 0.7
                    })
                    glowTween:Play()
                end)
            end
        )
    end
end)

-- Add error handling for the entire script
local success, err = pcall(function()
    -- Start the loader
    runLoader()
end)

if not success then
    -- Create a simple error display if the main script fails
    pcall(function()
        local errorText = Instance.new("TextLabel")
        errorText.Size = UDim2.new(1, -20, 0, 30)
        errorText.Position = UDim2.new(0, 10, 0, 10)
        errorText.BackgroundTransparency = 1
        errorText.TextColor3 = Color3.fromRGB(255, 0, 0)
        errorText.Text = "Error: " .. tostring(err)
        errorText.TextSize = 14
        errorText.Font = Enum.Font.Gotham
        errorText.Parent = MainFrame
        
        MainFrame.Visible = true
        CompactFrame.Visible = false
    end)
end