local AbyssLib = {}

-- // Library Init \\ --
local Start = tick()
local LoadTime = tick()
local Secure = setmetatable({}, {
    __index = function(Idx, Val)
        return game:GetService(Val)
    end
})
--
local UserInput = Secure.UserInputService
local RunService = Secure.RunService
local CoreGui = Secure.CoreGui
local Players = Secure.Players
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local HttpService = Secure.HttpService
local Mouse = LocalPlayer:GetMouse()
local InputGUI = Instance.new("ScreenGui", CoreGui)
-- local Stats = Secure.Stats.Network.ServerStatsItem["Data Ping"] 
--
-- Aimware = {6, [[{"Outline":"000005","Accent":"c82828","LightText":"e8e8e8","DarkText":"afafaf","LightContrast":"2b2b2b","CursorOutline":"191919","DarkContrast":"191919","TextBorder":"0a0a0a","Inline":"373737"}]]},
--
local Library = {
    Theme = {
        Accent = {
            Color3.fromHex("#7885f5"), -- Color3.fromHex("#a280d9"), -- Color3.fromRGB(255, 42, 10), Color3.fromHex("#3599d4")
            Color3.fromRGB(180, 156, 255),
            Color3.fromRGB(114, 0, 198),
            Color3.fromRGB(139, 130, 185),
            Color3.fromHex("#a83299")
        },
        Notification = {
            Error = Color3.fromHex("#c82828"),
            Warning = Color3.fromHex("#fc9803")
        },
        Hitbox = Color3.fromRGB(69, 69, 69),
        Friend = Color3.fromRGB(0, 200, 0),
        Outline = Color3.fromHex("#000005"),
        Inline = Color3.fromHex("#323232"),
        LightContrast = Color3.fromHex("#202020"),
        DarkContrast = Color3.fromHex("#191919"),
        Text = Color3.fromHex("#e8e8e8"),
        TextInactive = Color3.fromHex("#aaaaaa"),
        Font = Drawing.Fonts.Plex,
        TextSize = 13,
        UseOutline = false
    },
    Icons = {},
    Flags = {},
    Items = {},
    Drawings = {},
    Ignores = {},
    Keybind = {},
    Watermark = {},
    Connections = {},
    Keys = {
        KeyBoard = {["Q"] = "Q", ["W"] = "W", ["E"] = "E", ["R"] = "R", ["T"] = "T", ["Y"] = "Y", ["U"] = "U", ["I"] = "I", ["O"] = "O", ["P"] = "P", ["A"] = "A", ["S"] = "S", ["D"] = "D", ["F"] = "F", ["G"] = "G", ["H"] = "H", ["J"] = "J", ["K"] = "K", ["L"] = "L", ["Z"] = "Z", ["X"] = "X", ["C"] = "C", ["V"] = "V", ["B"] = "B", ["N"] = "N", ["M"] = "M", ["One"] = {"1", "!"}, ["Two"] = {"2", "\""}, ["Three"] = {"3", "£"}, ["Four"] = {"4", "$"}, ["Five"] = {"5", "%"}, ["Six"] = {"6", "^"}, ["Seven"] = {"7", "&"}, ["Eight"] = {"8", "*"}, ["Nine"] = {"9", "("}, ["Zero"] = {"0", ")"}, ["Space"] = " ", ["Slash"] = {"/", "?"}, ["BackSlash"] = {"\\", "|"}, ["Minus"] = {"-", "_"}, ["Equals"] = {"=", "+"}, ["RightBracket"] = {"]", "}"}, ["LeftBracket"] = {"[", "{"}, ["Semicolon"] = {";", ":"}, ["Quote"] = {"'", "@"}, ["Comma"] = {",", "<"}, ["Period"] = {".", ">"}},
        Letters = {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M"},
        KeyCodes = {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M", "One", "Two", "Three", "Four", "Five", "Six", "Seveen", "Eight", "Nine", "Zero", "Insert", "Tab", "Home", "End", "LeftAlt", "LeftControl", "LeftShift", "RightAlt", "RightControl", "RightShift", "CapsLock"},
        Inputs = {"MouseButton1", "MouseButton2", "MouseButton3"},
        Shortened = {["MouseButton1"] = "M1", ["MouseButton2"] = "M2", ["MouseButton3"] = "M3", ["Insert"] = "INS", ["LeftAlt"] = "LA", ["LeftControl"] = "LC", ["LeftShift"] = "LS", ["RightAlt"] = "RA", ["RightControl"] = "RC", ["RightShift"] = "RS", ["CapsLock"] = "CL"}
    },
    Input = {
        Caplock = false,
        LeftShift = false
    },
    Images = {},
    WindowVisible = true,
    Communication = Instance.new("BindableEvent")
}
--
local Utility = {}
--
getgenv().Library = Library
getgenv().Utility = Utility
-----------------------------------------------------------------
do
    Utility.AddInstance = function(NewInstance, Properties)
        local NewInstance = Instance.new(NewInstance)
        --
        for Index, Value in pairs(Properties) do
            NewInstance[Index] = Value
        end
        --
        return NewInstance
    end
    --
    Utility.CLCheck = function()
        repeat task.wait() until iswindowactive()
        do
            local InputHandle = Utility.AddInstance("TextBox", {
                Position = UDim2.new(0, 0, 0, 0)
            })
            --
            InputHandle:CaptureFocus() task.wait() keypress(0x4E) task.wait() keyrelease(0x4E) InputHandle:ReleaseFocus()
            Library.Input.Caplock = InputHandle.Text == "N" and true or false
            InputHandle:Destroy()
        end
    end
    --
    Utility.Loop = function(Delay, Call)
        local Callback = typeof(Call) == "function" and Call or function() end
        --
        task.spawn(function()
            while task.wait(Delay) do
                local Success, Error = pcall(function()
                    Callback()
                end)
                --
                if Error then 
                    return 
                end
            end
        end)
    end
    --
    Utility.RemoveDrawing = function(Instance, Location)
        local SpecificDrawing = 0
        --
        Location = Location or Library.Drawings
        --
        for Index, Value in pairs(Location) do 
            if Value[1] == Instance then
                if Value[1] then
                    Value[1]:Remove()
                end
                if Value[2] then
                    Value[2] = nil
                end
                SpecificDrawing = Index
            end
        end
        --
        table.remove(Location, table.find(Location, Location[SpecificDrawing]))
    end
    --
    Utility.AddConnection = function(Type, Callback)
        local Connection = Type:Connect(Callback)
        --
        Library.Connections[#Library.Connections + 1] = Connection
        --
        return Connection
    end
    --
    Utility.Round = function(Num, Float)
        local Bracket = 1 / Float;
        return math.floor(Num * Bracket) / Bracket;
    end
    --
    Utility.AddDrawing = function(Instance, Properties, Location)
        local InstanceType = Instance
        local Instance = Drawing.new(Instance)
        --
        for Index, Value in pairs(Properties) do
            Instance[Index] = Value
            if InstanceType == "Text" then
                if Index == "Font" then
                    Instance.Font = Library.Theme.Font
                end
                if Index == "Size" then
                    Instance.Size = Library.Theme.TextSize
                end
            end
        end
        --
        if Properties.ZIndex ~= nil then
            Instance.ZIndex = Properties.ZIndex + 20
        else
            Instance.ZIndex = 20
        end
        --
        Location = Location or Library.Drawings
        if InstanceType == "Image" then
            Location[#Location + 1] = {Instance, true}
        else
            Location[#Location + 1] = {Instance}
        end
        --
        return Instance
    end
    --
    Utility.OnMouse = function(Instance)
        local Mouse = UserInput:GetMouseLocation()
        if Instance.Visible and (Mouse.X > Instance.Position.X) and (Mouse.X < Instance.Position.X + Instance.Size.X) and (Mouse.Y > Instance.Position.Y) and (Mouse.Y < Instance.Position.Y + Instance.Size.Y) then
            if Library.WindowVisible then
                return true
            end
        end
    end
    --
    Utility.Rounding = function(Num, DecimalPlaces)
        return tonumber(string.format("%." .. (DecimalPlaces or 0) .. "f", Num))
    end
    --
    Utility.AddDrag = function(Sensor, List)
        local DragUtility = {
            MouseStart = Vector2.new(), MouseEnd = Vector2.new(), Dragging = false
        }
        --
        Utility.AddConnection(UserInput.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if Utility.OnMouse(Sensor) then
                    DragUtility.Dragging = true
                end
            end
        end)
        --
        Utility.AddConnection(UserInput.InputEnded, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                DragUtility.Dragging = false
            end
        end)
        --
        Utility.AddConnection(RunService.RenderStepped, function()
            DragUtility.MouseStart = UserInput:GetMouseLocation()
            --
            for Index, Value in pairs(List) do
                if Index ~= nil and Value ~= nil then
                    if DragUtility.Dragging then
                        Value[1].Position = Vector2.new(
                            Value[1].Position.X + (DragUtility.MouseStart.X - DragUtility.MouseEnd.X), 
                            Value[1].Position.Y + (DragUtility.MouseStart.Y - DragUtility.MouseEnd.Y)
                        )
                    end
                end
            end
            --
            DragUtility.MouseEnd = UserInput:GetMouseLocation()
        end)
    end
    --
    Utility.AddCursor = function(Instance)
        local CursorOutline = Utility.AddDrawing("Triangle", {
            Color = Library.Theme.Accent[1],
            Thickness = 1,
            Filled = false,
            ZIndex = 5
        }, Library.Ignores)
        --
        local Cursor = Utility.AddDrawing("Triangle", {
            Color = Library.Theme.Accent[1],
            Thickness = 3,
            Filled = true,
            Transparency = 1,
            ZIndex = 5
        }, Library.Ignores)
        --
        Utility.AddConnection(Library.Communication.Event, function(Type, Color)
            if Type == "Accent" then
                Cursor.Color = Color
                CursorOutline.Color = Color
            end
        end)
        --
        Utility.AddConnection(RunService.RenderStepped, function()
            local Mouse = UserInput:GetMouseLocation()
            --
            if Library.WindowVisible then
                CursorOutline.Visible = true
                CursorOutline.PointA = Vector2.new(Mouse.X, Mouse.Y)
                CursorOutline.PointB = Vector2.new(Mouse.X + 15, Mouse.Y + 5)
                CursorOutline.PointC = Vector2.new(Mouse.X + 5, Mouse.Y + 15)

                Cursor.Visible = true
                Cursor.PointA = Vector2.new(Mouse.X, Mouse.Y)
                Cursor.PointB = Vector2.new(Mouse.X + 15, Mouse.Y + 5)
                Cursor.PointC = Vector2.new(Mouse.X + 5, Mouse.Y + 15)
            else
                CursorOutline.Visible = false
                Cursor.Visible = false
            end
        end)
    end
    --
    Utility.MiddlePos = function(Instance)
        return Vector2.new(
            (Camera.ViewportSize.X / 2) - (Instance.Size.X / 2), 
            (Camera.ViewportSize.Y / 2) - (Instance.Size.Y / 2)
        )
    end
    --
    Utility.SaveConfig = function(Config)
        writefile(
            "Abyss/Configs/" .. tostring(game.PlaceId) .. "/" .. Config .. ".json", 
            HttpService:JSONEncode(UISettings.Flags)
        )
    end
    --
    Utility.DeleteConfig = function(Config)
        delfile(
            "Abyss/Configs/" .. tostring(game.PlaceId) .. "/" .. Config .. ".json"
        )
    end
    --
    Utility.LoadConfig = function(Config)
        local Config = HttpService:JSONDecode(readfile("Abyss/Configs/" .. tostring(game.PlaceId) .. "/" .. Config .. ".json"))
        --
        Library.Flags = LoadedConfig
        --
        for Index, Value in pairs(Library.Flags) do
            if Library.Items[Index].TypeOf == "Keybind" then
                Library.Items[Index]:Set(Value[1], Value[2], Value[3], true)
            elseif Library.Items[Index].TypeOf == "Colorpicker" then
                Library.Items[Index]:SetHue(Value[1])
                Library.Items[Index]:SetSaturationX(Value[2])
                Library.Items[Index]:SetSaturationY(Value[3])
            else
                Library.Items[Index]:Set(Value)
            end
        end
        --
        rconsoleinfo("Debug: Loaded a config! 0 error.")
    end
    --
    Utility.AddFolder = function(GetFolder)
        local Folder = isfolder(GetFolder)
        --
        if Folder then
            return
        else
            makefolder(GetFolder)
            return true
        end
    end
    --
    Utility.AddImage = function(Image, Url, UI)
        local ImageFile = nil
        --
        if isfile(Image) then
            ImageFile = readfile(Image)
        else
            ImageFile = game:HttpGet(Url)
            writefile(Image, ImageFile)
        end
        --
        return ImageFile
    end
end
--
do
    function Library.CreateLoader(Title, WindowSize)
        local Window = {
            Max = 2, Current = 0
        }
        --
        Library.Theme.Logo = Utility.AddImage("Abyss/Assets/UI/Logo2.png", "https://i.imgur.com/HI4UTmZ.png")
        --
        local WindowOutline = Utility.AddDrawing("Square", {
            Size = WindowSize,
            Thickness = 0,
            Color = Library.Theme.Outline,
            Visible = true,
            Filled = true
        })
        --
        WindowOutline.Position = Utility.MiddlePos(WindowOutline)
        --
        local WindowOutlineBorder = Utility.AddDrawing("Square", {
            Size = Vector2.new(WindowOutline.Size.X - 2, WindowOutline.Size.Y - 2),
            Position = Vector2.new(WindowOutline.Position.X + 1, WindowOutline.Position.Y + 1),
            Thickness = 0,
            Color = Library.Theme.Accent[1],
            Visible = true,
            Filled = true
        })
        --
        local WindowFrame = Utility.AddDrawing("Square", {
            Size = Vector2.new(WindowOutlineBorder.Size.X - 2, WindowOutlineBorder.Size.Y - 2),
            Position = Vector2.new(WindowOutlineBorder.Position.X + 1, WindowOutlineBorder.Position.Y + 1),
            Thickness = 0,
            Transparency = 1,
            Color = Library.Theme.DarkContrast,
            Visible = true,
            Filled = true
        })
        --
        local WindowTopline = Utility.AddDrawing("Square", {
            Size = Vector2.new(WindowOutline.Size.X - 2, 2),
            Position = Vector2.new(WindowOutlineBorder.Position.X, WindowOutlineBorder.Position.Y),
            Thickness = 0,
            Color = Library.Theme.Accent[1],
            Visible = false,
            Filled = true
        })
        --
        local WindowImage = Utility.AddDrawing("Image", {
            Size = WindowFrame.Size,
            Position = WindowFrame.Position,
            Transparency = 1, 
            Visible = true,
            Data = Library.Theme.Gradient
        })
        --
        local WindowTitle = Utility.AddDrawing("Text", {
            Font = Library.Theme.Font,
            Size = Library.Theme.TextSize,
            Color = Library.Theme.Text,
            Text = Title,
            Position = Vector2.new(WindowFrame.Position.X + (WindowFrame.Size.X / 2), WindowOutlineBorder.Position.Y + 8),
            Visible = true,
            Center = true,
            Outline = false
        })
        --
        local WindowText = Utility.AddDrawing("Text", {
            Font = Library.Theme.Font,
            Size = Library.Theme.TextSize,
            Color = Library.Theme.Text,
            Visible = true,
            Center = true,
            Outline = false
        })
        --
        local SliderInline = Utility.AddDrawing("Square", {
            Size = Vector2.new(205, 15),
            Color = Library.Theme.Inline,
            Position = Vector2.new(WindowFrame.Position.X + (WindowFrame.Size.X / 2), WindowOutlineBorder.Position.Y + 8),
            Transparency = 0.75,
            Thickness = 0,
            Visible = true,
            Filled = true
        })
        --
        local SliderOutline = Utility.AddDrawing("Square", {
            Size = Vector2.new(SliderInline.Size.X - 2, SliderInline.Size.Y - 2),
            Color = Library.Theme.Outline,
            Transparency = 0.5,
            Thickness = 0,
            Visible = true,
            Filled = true
        })
        --
        local SliderFrame = Utility.AddDrawing("Square", {
            Size = Vector2.new(((SliderInline.Size.X - 2) / (Window.Max / math.clamp(Window.Current, 0, Window.Max))), SliderInline.Size.Y - 2),
            Color = Library.Theme.Accent[1],
            Transparency = 0.75,
            Thickness = 0,
            Visible = true,
            Filled = true
        })
        --
        local SliderFrameShader = Utility.AddDrawing("Image", {
            Size = Vector2.new(SliderInline.Size.X - 2, SliderInline.Size.Y - 2),
            Transparency = 1, 
            Visible = true,
            Data = Library.Theme.Gradient
        })
        --
        local MiddleIcon = Utility.AddDrawing("Image", {
            Size = Vector2.new(175, 175),
            Rounding = 5,
            Transparency = 1, 
            Visible = true,
            Data = Library.Theme.Logo
        })
        --
        MiddleIcon.Position = Vector2.new(WindowOutline.Position.X + (WindowOutline.Size.X / 2) - (MiddleIcon.Size.X / 2), WindowOutline.Position.Y + (WindowOutline.Size.Y / 2) - (MiddleIcon.Size.Y / 2) - 15)
        --
        Window.SetText = function(Val, Txt)
            SliderFrame.Size = Vector2.new(((SliderInline.Size.X - 2) / (Window.Max / math.clamp(Val, 0, Window.Max))), SliderInline.Size.Y - 2)
            WindowText.Text = Txt
        end
        --
        SliderInline.Position = Vector2.new(WindowOutline.Position.X + (WindowOutline.Size.X / 2) - (SliderOutline.Size.X / 2), (WindowOutline.Position.Y + WindowOutline.Size.Y) - 30)
        SliderOutline.Position = Vector2.new(SliderInline.Position.X + 1, SliderInline.Position.Y + 1)
        SliderFrame.Position = Vector2.new(SliderInline.Position.X + 1, SliderInline.Position.Y + 1)
        SliderFrameShader.Position = Vector2.new(SliderInline.Position.X + 1, SliderInline.Position.Y + 1)
        WindowText.Position = Vector2.new(WindowFrame.Position.X + (WindowFrame.Size.X / 2), SliderInline.Position.Y - 16)
        --
        Window.SetText(0, "UI Initialization [ Downloading ]")
        --
        Utility.AddFolder("Abyss")
        Utility.AddFolder("Abyss/Caches")
        Utility.AddFolder("Abyss/Assets")
        Utility.AddFolder("Abyss/Assets/UI")
        Utility.AddFolder("Abyss/Configs")
        Utility.AddFolder("Abyss/Scripts")
        --
        Library.Theme.Gradient = Utility.AddImage("Abyss/Assets/UI/Gradient.png", "https://raw.githubusercontent.com/mvonwalk/Exterium/main/Gradient.png")
        -- Library.Theme.SecondIcon = Utility.AddImage("Abyss/Assets/UI/Gradient.png", "https://raw.githubusercontent.com/mvonwalk/Exterium/main/Gradient.png")
        Library.Theme.Hue = Utility.AddImage("Abyss/Assets/UI/Hue.png", "https://raw.githubusercontent.com/mvonwalk/Exterium/main/HuePicker.png")
        Library.Theme.Saturation = Utility.AddImage("Abyss/Assets/UI/Saturation.png", "https://raw.githubusercontent.com/mvonwalk/Exterium/main/SaturationPicker.png")
        Library.Theme.SaturationCursor = Utility.AddImage("Abyss/Assets/UI/HueCursor.png", "https://raw.githubusercontent.com/mvonwalk/splix-assets/main/Images-cursor.png")
        --
        Library.Theme.Astolfo = Utility.AddImage("Abyss/Assets/UI/Astolfo.png", "https://i.imgur.com/T20cWY9.png")
        Library.Theme.Aiko = Utility.AddImage("Abyss/Assets/UI/Aiko.png", "https://i.imgur.com/1gRIdko.png")
        Library.Theme.Rem = Utility.AddImage("Abyss/Assets/UI/Rem.png", "https://i.imgur.com/ykbRkhJ.png")
        Library.Theme.Violet = Utility.AddImage("Abyss/Assets/UI/Violet.png", "https://i.imgur.com/7B56w4a.png")
        Library.Theme.Asuka = Utility.AddImage("Abyss/Assets/UI/Asuka.png", "https://i.imgur.com/3hwztNM.png")
        --
        Window.SetText(1, "Checking Assets")
        --
        Window.SetText(1, "Checking Input")
        Utility.CLCheck(Window)
        --
        Window.SetText(2, "Finished")
        --
        Utility.RemoveDrawing(WindowOutline)
        Utility.RemoveDrawing(WindowOutlineBorder)
        Utility.RemoveDrawing(WindowTopline)
        Utility.RemoveDrawing(WindowFrame)
        Utility.RemoveDrawing(WindowTitle)
        Utility.RemoveDrawing(WindowText)
        Utility.RemoveDrawing(SliderOutline)
        Utility.RemoveDrawing(SliderInline)
        Utility.RemoveDrawing(SliderFrame)
        Utility.RemoveDrawing(SliderFrameShader)
        Utility.RemoveDrawing(MiddleIcon)
        Utility.RemoveDrawing(WindowImage)
        --
        UserInput.MouseIconEnabled = false
        --
        return Window
    end
end
--
do
    --
    function Library:ChangeVisible(State)
        Library.WindowVisible = State
        UserInput.MouseIconEnabled = not Library.WindowVisible
        for Idx, Val in pairs(Library.Drawings) do
            if Val[2] then
                Val[1].Transparency = Library.WindowVisible and 1 or 0
            else
                if Val[1].Color ~= Library.Theme.Hitbox then
                    Val[1].Transparency = Library.WindowVisible and 1 or 0
                end
            end
        end
    end
    --
    function Library:UpdateTheme(Config)
        if Config.Accent ~= nil then
            Library.Theme.Accent[1] = Config.Accent
            Library.Communication:Fire("Accent", Config.Accent)
        end
        if Config.Outline ~= nil then
            Library.Theme.Outline = Config.Outline
            Library.Communication:Fire("Outline", Config.Outline)
        end
        if Config.Inline ~= nil then
            Library.Theme.Inline = Config.Inline
            Library.Communication:Fire("Inline", Config.Inline)
        end
        if Config.LightContrast ~= nil then
            Library.Theme.LightContrast = Config.LightContrast
            Library.Communication:Fire("LightContrast", Config.LightContrast)
        end
        if Config.DarkContrast ~= nil then
            Library.Theme.DarkContrast = Config.DarkContrast
            Library.Communication:Fire("DarkContrast", Config.DarkContrast)
        end
    end
    --
    function Library.SelfDestruct()
        --
        UserInput.MouseIconEnabled = true
        --
        for Index, Value in pairs(Library.Connections) do
            Value:Disconnect()
        end
        --
        for Index, Value in pairs(Library.Drawings) do
            if Value[1] then    
                Value[1]:Remove()
            end
        end
        --
        for Index, Value in pairs(Library.Watermark) do
            if Value[1] then
                Value[1]:Remove()
            end
        end
        --
        for Index, Value in pairs(Library.Keybind) do
            if Value[1] then
                Value[1]:Remove()
            end
        end
        --
        for Index, Value in pairs(Library.Ignores) do
            if Value[1] then
                Value[1]:Remove()
            end
        end
        --
        Library.Drawings = {}
        Library.Watermark = {}
        Library.Keybind = {}
        Library.Ignores = {}
        --
    end
    --
    function Library.Window(Title, Size)
        local Window = {
            Notification = 0,
            Tabs = {},
            LastTab = nil,
            SelectedTab = nil,
            BindList = ""
        }
        --
        local Blur = Utility.AddDrawing("Image", {
            Position = Vector2.new(0, 0),
            Size = Vector2.new(1920, 1080),
            Transparency = 0,
            Visible = true,
        }, Library.Ignores)
        --
        do
            local WindowOutline = Utility.AddDrawing("Square", {
                Size = Vector2.new(120, 20),
                Thickness = 0,  
                Color = Library.Theme.Outline,
                Visible = true,
                Filled = true
            }, Library.Keybind)
            --
            WindowOutline.Position = Vector2.new(10, (Camera.ViewportSize.Y / 2) - (WindowOutline.Size.Y / 2))
            --
            local WindowOutlineBorder = Utility.AddDrawing("Square", {
                Size = Vector2.new(WindowOutline.Size.X - 2, WindowOutline.Size.Y - 2),
                Position = Vector2.new(WindowOutline.Position.X + 1, WindowOutline.Position.Y + 1),
                Thickness = 0,
                Color = Library.Theme.Accent[1],
                Visible = false,
                Filled = true
            }, Library.Keybind)
            --
            local WindowFrame = Utility.AddDrawing("Square", {
                Size = Vector2.new(WindowOutlineBorder.Size.X - 2, WindowOutlineBorder.Size.Y - 2),
                Position = Vector2.new(WindowOutlineBorder.Position.X + 1, WindowOutlineBorder.Position.Y + 1),
                Thickness = 0,
                Transparency = 1,
                Color = Library.Theme.DarkContrast,
                Visible = true,
                Filled = true
            }, Library.Keybind)
            --
            local WindowTopline = Utility.AddDrawing("Square", {
                Size = Vector2.new(WindowOutlineBorder.Size.X, 1),
                Position = Vector2.new(WindowOutlineBorder.Position.X, WindowOutlineBorder.Position.Y),
                Thickness = 0,
                Color = Library.Theme.Accent[1],
                Visible = true,
                Filled = true
            }, Library.Keybind)
            --
            local WindowImage = Utility.AddDrawing("Image", {
                Size = WindowFrame.Size,
                Position = WindowFrame.Position,
                Transparency = 1, 
                Visible = true,
                Data = Library.Theme.Gradient
            }, Library.Keybind)
            --
            local WindowText = Utility.AddDrawing("Text", {
                Font = Library.Theme.Font,
                Size = Library.Theme.TextSize,
                Color = Library.Theme.Text,
                Text = "Keybinds",
                Position = Vector2.new(WindowOutlineBorder.Position.X + (WindowOutlineBorder.Size.X / 2), WindowOutlineBorder.Position.Y + 2),
                Visible = true,
                Center = true,
                Outline = false
            }, Library.Keybind)
            --
            local CurrentBinds = Utility.AddDrawing("Text", {
                Font = Library.Theme.Font,
                Size = Library.Theme.TextSize,
                Color = Library.Theme.Text,
                Text = "",
                Position = Vector2.new(WindowOutlineBorder.Position.X + 3, WindowOutlineBorder.Position.Y + 8),
                Visible = true,
                Center = false,
                Outline = false
            }, Library.Keybind)
            --
            Utility.AddConnection(RunService.RenderStepped, function(Type, Color)
                CurrentBinds.Text = Window.BindList

                local CalcuationSize = CurrentBinds.Text ~= "" and Vector2.new(CurrentBinds.TextBounds.X >= 120 and CurrentBinds.TextBounds.X + 6 or 120, 20 + CurrentBinds.TextBounds.Y - 6) or Vector2.new(120, 20)
                WindowOutline.Size = CalcuationSize
                
                WindowOutlineBorder.Size = Vector2.new(WindowOutline.Size.X - 2, WindowOutline.Size.Y - 2)
                WindowOutlineBorder.Position = Vector2.new(WindowOutline.Position.X + 1, WindowOutline.Position.Y + 1)

                WindowTopline.Size = Vector2.new(WindowOutlineBorder.Size.X, 1)
                WindowTopline.Position = Vector2.new(WindowOutlineBorder.Position.X, WindowOutlineBorder.Position.Y)

                WindowImage.Size = WindowFrame.Size
                WindowImage.Position = WindowFrame.Position

                WindowText.Position = Vector2.new(WindowOutlineBorder.Position.X + (WindowOutlineBorder.Size.X / 2), WindowOutlineBorder.Position.Y + 2)
            end)
            --
            Utility.AddDrag(WindowOutline, Library.Keybind)
            --
            Utility.AddConnection(Library.Communication.Event, function(Type, Color)
                if Type == "Accent" then
                    WindowOutlineBorder.Color = Color
                    WindowTopline.Color = Color
                elseif Type == "Outline" then
                    WindowOutline.Color = Color
                elseif Type == "DarkContrast" then
                    WindowFrame.Color = Color
                elseif Type == "Text" then
                    WindowText.Color = Color
                end
            end)
        end
        --
        local Anime = Utility.AddDrawing("Image", {
            Transparency = 0.5, 
            Visible = false
        }, Library.Ignores)
        --
        local WindowOutline = Utility.AddDrawing("Square", {
            Size = Size,
            Thickness = 0,
            Color = Library.Theme.Outline,
            Visible = true,
            Filled = true
        })
        --
        WindowOutline.Position = Utility.MiddlePos(WindowOutline)
        --
        local WindowOutlineBorder = Utility.AddDrawing("Square", {
            Size = Vector2.new(WindowOutline.Size.X - 2, WindowOutline.Size.Y - 2),
            Position = Vector2.new(WindowOutline.Position.X + 1, WindowOutline.Position.Y + 1),
            Thickness = 0,
            Color = Library.Theme.Accent[1],
            Visible = true,
            Filled = true
        })
        --
        local WindowFrame = Utility.AddDrawing("Square", {
            Size = Vector2.new(WindowOutlineBorder.Size.X - 2, WindowOutlineBorder.Size.Y - 2),
            Position = Vector2.new(WindowOutlineBorder.Position.X + 1, WindowOutlineBorder.Position.Y + 1),
            Thickness = 0,
            Transparency = 1,
            Color = Library.Theme.DarkContrast,
            Visible = true,
            Filled = true
        })
        --
        local WatermarkIcon = Utility.AddDrawing("Image", {
            Size = Vector2.new(70, 70),
            Position = Vector2.new(WindowFrame.Position.X + (WindowFrame.Size.X / 2) - 35, WindowFrame.Position.Y - 4),
            Transparency = 1,
            ZIndex = 3,
            Visible = false,
            Data = Library.Theme.Logo
        })
        --
        Utility.AddCursor(WindowFrame)
        --
        local WindowHeader = Utility.AddDrawing("Square", {
            Size = Vector2.new(WindowOutlineBorder.Size.X - 2, 70),
            Position = Vector2.new(WindowOutlineBorder.Position.X + 1, WindowOutlineBorder.Position.Y + 1),
            Thickness = 0,
            Transparency = 0,
            Color = Library.Theme.Hitbox,
            Visible = true,
            Filled = true
        })
        --
        Utility.AddDrag(WindowHeader, Library.Drawings)
        --
        local WindowTopline = Utility.AddDrawing("Square", {
            Size = Vector2.new(WindowOutlineBorder.Size.X, 1),
            Position = Vector2.new(WindowOutlineBorder.Position.X, WindowOutlineBorder.Position.Y),
            Thickness = 0,
            Color = Library.Theme.Accent[1],
            Visible = false,
            Filled = true
        })
        --
        local WindowImage = Utility.AddDrawing("Image", {
            Size = WindowFrame.Size,
            Position = WindowFrame.Position,
            Transparency = 1, 
            Visible = true,
            Data = Library.Theme.Gradient
        })
        --
        local WindowTitle = Utility.AddDrawing("Text", {
            Font = Library.Theme.Font,
            Size = Library.Theme.TextSize,
            Color = Library.Theme.Text,
            Text = Title,
            Position = Vector2.new(WindowOutlineBorder.Position.X + 8, WindowOutlineBorder.Position.Y + 6),
            Visible = true,
            Center = false,
            Outline = false
        })
        --
        local SecondBorderInline = Utility.AddDrawing("Square", {
            Size = Vector2.new(Size.X - 17, Size.Y - 50),
            Position = Vector2.new(WindowOutlineBorder.Position.X + 8, WindowOutlineBorder.Position.Y + 42),
            Thickness = 0,
            Color = Library.Theme.Inline,
            Visible = true,
            Filled = true
        })
        --
        local SecondBorderOutline = Utility.AddDrawing("Square", {
            Size = Vector2.new(SecondBorderInline.Size.X - 2, SecondBorderInline.Size.Y - 2),
            Position = Vector2.new(SecondBorderInline.Position.X + 1, SecondBorderInline.Position.Y + 1),
            Thickness = 0,
            Color = Library.Theme.LightContrast,
            Visible = true,
            Filled = true
        })
        --
        local TabLine = Utility.AddDrawing("Square", {
            Thickness = 0,
            Color = Library.Theme.Accent[1],
            Visible = true,
            Filled = true,
            ZIndex = 2
        })
        --
        local DisableLine = Utility.AddDrawing("Square", {
            Thickness = 0,
            Color = Library.Theme.LightContrast,
            Visible = true,
            Filled = true,
            ZIndex = 3
        })
        --
        Utility.AddConnection(Library.Communication.Event, function(Type, Color)
            if Type == "Accent" then
                WindowOutlineBorder.Color = Color
                WindowTopline.Color = Color
                TabLine.Color = Color
            elseif Type == "Outline" then
                WindowOutline.Color = Color
            elseif Type == "LightContrast" then
                DisableLine.Color = Color
                SecondBorderOutline.Color = Color
            elseif Type == "DarkContrast" then
                WindowFrame.Color = Color
            elseif Type == "Text" then
                WindowTitle.Color = Color
            elseif Type == "Inline" then
                SecondBorderInline.Color = Color
            end
        end)
        --
        Window["PageCover"] = SecondBorderInline
        --
        function Window.ChangeAnime(Name)
            Anime.Data = (
                Name == "Astolfo" and Library.Theme.Astolfo or
                Name == "Aiko" and Library.Theme.Aiko or
                Name == "Rem" and Library.Theme.Rem or
                Name == "Violet" and Library.Theme.Violet or
                Name == "Asuka" and Library.Theme.Asuka
            )

            Anime.Size = (
                Name == "Astolfo" and Vector2.new(412, 605) or
                Name == "Aiko" and Vector2.new(390, 630) or
                Name == "Rem" and Vector2.new(390, 639) or
                Name == "Violet" and Vector2.new(1029 / 3, 1497 / 3) or
                Name == "Asuka" and Vector2.new(415, 601)
            )

            Anime.Position = Vector2.new(Camera.ViewportSize.X - 400, Camera.ViewportSize.Y - Anime.Size.Y)
        end
        --
        function Window.ToggleAnime(State)
            Anime.Visible = State
        end
        --
        function Window.SendNotification(Type, Title, Duration)
            local Notification, Removed = Window.Notification, false
            --
            local NotificationInline = Utility.AddDrawing("Square", {
                Size = Vector2.new(0, 21),
                Position = Vector2.new(0, (Window.Notification * 25) + 100),
                Thickness = 0,
                Color = Library.Theme.Inline,
                Visible = true,
                Filled = true
            }, Library.Ignores)
            --
            local NotificationOutline = Utility.AddDrawing("Square", {
                Size = Vector2.new(0, NotificationInline.Size.Y - 1),
                Position = Vector2.new(NotificationInline.Position.X + 2, NotificationInline.Position.Y + 2),
                Thickness = 0,
                Color = Library.Theme.DarkContrast,
                Visible = true,
                Filled = true
            }, Library.Ignores)
            --
            local NotificationOutlineBorder = Utility.AddDrawing("Square", {
                Size = Vector2.new(NotificationOutline.Size.X - 2, NotificationOutline.Size.Y + 5),
                Position = Vector2.new(NotificationOutline.Position.X + 1, NotificationOutline.Position.Y + 1),
                Thickness = 0,
                Color = Library.Theme.Accent[1],
                Visible = false,
                Filled = true
            }, Library.Ignores)
            --
            local NotificationTopline = Utility.AddDrawing("Square", {
                Size = Vector2.new(NotificationOutline.Size.X, 1),
                Position = Vector2.new(NotificationOutline.Position.X, NotificationOutline.Position.Y),
                Thickness = 0,
                Color = Type == "Warning" and Library.Theme.Notification.Warning or Type == "Error" and Library.Theme.Notification.Error or Library.Theme.DarkContrast,
                Visible = Type == "Warning" or Type == "Error",
                Filled = true
            }, Library.Ignores)
            --
            local NotificationLeftline = Utility.AddDrawing("Square", {
                Size = Vector2.new(1, NotificationOutline.Size.Y),
                Position = Vector2.new(NotificationOutline.Position.X, NotificationOutline.Position.Y),
                Thickness = 0,
                Color = Type == "Normal" and Library.Theme.Accent[1] or Library.Theme.DarkContrast,
                Visible = Type == "Normal",
                Filled = true
            }, Library.Ignores)
            --
            local NotificationImage = Utility.AddDrawing("Image", {
                Size = NotificationOutlineBorder.Size,
                Position = NotificationOutlineBorder.Position,
                Transparency = 1, 
                Visible = true,
                Data = Library.Theme.Gradient
            }, Library.Ignores)
            --
            local NotificationText = Utility.AddDrawing("Text", {
                Font = Library.Theme.Font,
                Size = Library.Theme.TextSize,
                Color = Library.Theme.Text,
                Text = Title,
                Position = Vector2.new(NotificationOutlineBorder.Position.X + 6, NotificationOutlineBorder.Position.Y + 3),
                Visible = true,
                Center = false,
                Outline = false
            }, Library.Ignores)
            --
            NotificationInline.Size = Vector2.new(NotificationText.TextBounds.X + 15, 21)
            --
            NotificationOutline.Size = Vector2.new(NotificationInline.Size.X - 1, NotificationInline.Size.Y - 1)
            NotificationOutline.Position = Vector2.new(NotificationInline.Position.X + 2, NotificationInline.Position.Y + 2)
            --
            NotificationOutlineBorder.Size = Vector2.new(NotificationOutline.Size.X - 2, NotificationOutline.Size.Y - 2)
            NotificationOutlineBorder.Position = Vector2.new(NotificationOutline.Position.X + 2, NotificationOutline.Position.Y + 2)
            --
            NotificationLeftline.Size = Vector2.new(2, NotificationOutline.Size.Y)
            --
            NotificationTopline.Size = Vector2.new(NotificationOutline.Size.X, 1)
            --
            NotificationImage.Size = NotificationOutline.Size
            NotificationImage.Position = NotificationOutline.Position
            --
            task.spawn(function()
                for Index = -100, 0, 2 do
                    pcall(function()
                        NotificationInline.Position = Vector2.new(Index, (Notification * 25) + 100)
                        NotificationOutline.Position = Vector2.new(NotificationInline.Position.X + 2, NotificationInline.Position.Y + 2)
                        NotificationOutlineBorder.Position = Vector2.new(NotificationOutline.Position.X + 2, NotificationOutline.Position.Y + 2)
                        NotificationText.Position = Vector2.new(NotificationOutline.Position.X + 6, NotificationOutline.Position.Y + 3)
                        NotificationTopline.Position = Vector2.new(NotificationOutline.Position.X, NotificationOutline.Position.Y)
                        NotificationImage.Position = NotificationOutline.Position
                        NotificationLeftline.Position = Vector2.new(NotificationOutline.Position.X, NotificationOutline.Position.Y)
                    end)
                    task.wait()
                end
            end)
            --
            Utility.AddConnection(Library.Communication.Event, function(Type)
                if Type == "UpdateNotification" then
                    Notification -= 1
                    pcall(function()
                        NotificationInline.Size = Vector2.new(Index, (Notification * 25) + 100)
                        NotificationOutline.Position = Vector2.new(NotificationInline.Position.X + 2, NotificationInline.Position.Y + 2)
                        NotificationText.Position = Vector2.new(NotificationOutline.Position.X + 6, NotificationOutline.Position.Y + 3)
                        NotificationTopline.Position = Vector2.new(NotificationOutline.Position.X, NotificationOutline.Position.Y)
                        NotificationImage.Position = NotificationOutline.Position
                        NotificationLeftline.Position = Vector2.new(NotificationOutline.Position.X, NotificationOutline.Position.Y)
                    end)
                end
            end)
            --
            Window.Notification += 1
            --
            task.spawn(function()
                task.wait(Duration)
                --
                pcall(function()
                    Utility.RemoveDrawing(NotificationInline, Library.Ignores)
                    Utility.RemoveDrawing(NotificationLeftline, Library.Ignores)
                    Utility.RemoveDrawing(NotificationOutline, Library.Ignores)
                    Utility.RemoveDrawing(NotificationOutlineBorder, Library.Ignores)
                    Utility.RemoveDrawing(NotificationText, Library.Ignores)
                    Utility.RemoveDrawing(NotificationTopline, Library.Ignores)
                    Utility.RemoveDrawing(NotificationImage, Library.Ignores)
                end)
                --
                Library.Communication:Fire("UpdateNotification")
                --
                Window.Notification -= 1
            end)
        end
        --
        function Window:RefreshPages()
            for Index, Value in pairs(Window.Tabs) do
                Value:Resize(Index)
            end
        end
        --
        function Window:SwitchTab(Tab)
            for Index, Value in pairs(self.Tabs) do
                Value["TabTitle"].Color = Library.Theme.TextInactive
                Value["TabOutline"].Color = Library.Theme.DarkContrast

                for _, Render in pairs(Value["Render"]) do
                    Render.Visible = false
                end
            end

            Tab["TabOutline"].Color = Library.Theme.LightContrast
            Tab["TabTitle"].Color = Library.Theme.Text

            TabLine.Size = Vector2.new(Tab["TabOutline"].Size.X, 1)
            TabLine.Position = Vector2.new(Tab["TabOutline"].Position.X, Tab["TabOutline"].Position.Y)
            DisableLine.Size = Vector2.new(Tab["TabOutline"].Size.X, 1)
            DisableLine.Position = Vector2.new(Tab["TabOutline"].Position.X, Tab["TabOutline"].Position.Y + Tab["TabOutline"].Size.Y)
            Window.SelectedTab = Tab.CurrentTab

            for _, Render in pairs(Tab["Render"]) do
                Render.Visible = true
            end
        end
        --
        function Window:Tab(Title)
            local Tab = {
                Visible = {},
                SectionAxis = {0, 0},
                Sections = {},
                Dropdowns = {
                    ["Left"] = {}, 
                    ["Right"] = {}
                },
                CurrentTab = #self.Tabs
            }
            --
            local TabInline = Utility.AddDrawing("Square", {
                Position = Vector2.new(SecondBorderInline.Position.X, SecondBorderOutline.Position.Y - 20),
                Size = Vector2.new(0, 20),
                Thickness = 0,
                Color = Library.Theme.Inline,
                Visible = true,
                Filled = true
            })
            --
            local TabOutline = Utility.AddDrawing("Square", {
                Size = Vector2.new(TabInline.Size.X - 2, TabInline.Size.Y - 2),
                Position = Vector2.new(TabInline.Position.X + 1, TabInline.Position.Y + 1),
                Thickness = 0,
                Color = Library.Theme.DarkContrast,
                Visible = true,
                Filled = true
            })
            --
            local TabTitle = Utility.AddDrawing("Text", {
                Text = Title,
                Center = true,
                Outline = false,
                Font = Library.Theme.Font,
                Size = Library.Theme.TextSize,
                Color = Library.Theme.Text,
                Visible = true,
                ZIndex = 2
            })
            --
            Utility.AddConnection(Library.Communication.Event, function(Type, Color)
                if Type == "DarkContrast" and Window.SelectedTab == Tab then
                    TabOutline.Color = Color
                elseif Type == "LightContrast" and Window.SelectedTab ~= Tab then
                    TabOutline.Color = Color
                elseif Type == "Text" then
                    TabTitle.Color = Color
                elseif Type == "Inline" then
                    TabInline.Color = Color
                end
            end)
            --
            function Tab:Install()
                TabInline.Size = Vector2.new(TabTitle.TextBounds.X + 50, 20)
                TabInline.Position = Vector2.new((Window.LastTab ~= nil and Window.LastTab.Position.X + Window.LastTab.Size.X + 5 or SecondBorderInline.Position.X), SecondBorderOutline.Position.Y - 20)

                TabOutline.Size = Vector2.new(TabInline.Size.X - 2, TabInline.Size.Y - 2)
                TabOutline.Position = Vector2.new(TabInline.Position.X + 1, TabInline.Position.Y + 1)

                if Window.LastTab == nil then
                    TabLine.Size = Vector2.new(TabOutline.Size.X, 1)
                    TabLine.Position = Vector2.new(TabOutline.Position.X + 1, TabOutline.Position.Y)

                    DisableLine.Size = Vector2.new(TabOutline.Size.X, 1)
                    DisableLine.Position = Vector2.new(TabOutline.Position.X, TabOutline.Position.Y + TabOutline.Size.Y)

                    Window.SelectedTab = Tab.CurrentTab
                end

                TabTitle.Position = Vector2.new(TabOutline.Position.X + (TabOutline.Size.X / 2), TabOutline.Position.Y + (TabOutline.Size.Y / 2) - 7)
            end
            --
            function Tab:RemoveDrawing(Instance)
                local SpecificDrawing = 0
                for Index, Value in pairs(Tab["Render"]) do 
                    if Value == Instance then
                        SpecificDrawing = Index
                    end
                end
                table.remove(Tab["Render"], table.find(Tab["Render"], Tab["Render"][SpecificDrawing]))
                --
                local SpecificDrawing2 = 0
                for Index, Value in pairs(Library.Drawings) do 
                    if Value[1] == Instance then
                        if Value[1] then
                            Value[1]:Remove()
                        end
                        if Value[2] then
                            Value[2] = nil
                        end
                        SpecificDrawing2 = Index
                    end
                end
                table.remove(Library.Drawings, table.find(Library.Drawings, Library.Drawings[SpecificDrawing2]))
            end
            --
            function Tab:Section(Title, Side)
                local Section = {
                    ContentAxis = 0
                }
                --
                local AxisX = Side == "Left" and SecondBorderOutline.Position.X + 6 or SecondBorderOutline.Position.X + ((SecondBorderOutline.Size.X / 2) - 10) + 12
                local SectionInline = Utility.AddDrawing("Square", {
                    Position = Vector2.new(AxisX, (Tab.SectionAxis[Side == "Left" and 1 or 2] == 0 and TabOutline.Position.Y + TabOutline.Size.Y + 6 or 6 + Tab.SectionAxis[Side == "Left" and 1 or 2])),
                    Size = Vector2.new((SecondBorderOutline.Size.X / 2) - 8, 24),
                    Thickness = 0,
                    Color = Library.Theme.Inline,
                    Visible = true,
                    Filled = true
                })
                --
                local SectionOutline = Utility.AddDrawing("Square", {
                    Size = Vector2.new(SectionInline.Size.X - 2, SectionInline.Size.Y - 2),
                    Position = Vector2.new(SectionInline.Position.X + 1, SectionInline.Position.Y + 1),
                    Thickness = 0,
                    Color = Library.Theme.DarkContrast,
                    Visible = true,
                    Filled = true
                })
                --
                local SectionTopline = Utility.AddDrawing("Square", {
                    Size = Vector2.new(SectionOutline.Size.X, 1),
                    Position = Vector2.new(SectionOutline.Position.X, SectionOutline.Position.Y),
                    Thickness = 0,
                    Color = Library.Theme.Accent[1],
                    Visible = true,
                    Filled = true
                })
                --
                local SectionTitle = Utility.AddDrawing("Text", {
                    Text = Title,
                    Position = Vector2.new(SectionOutline.Position.X + 4, SectionOutline.Position.Y + 4),
                    Center = false,
                    Outline = false,
                    Font = Library.Theme.Font,
                    Size = Library.Theme.TextSize,
                    Color = Library.Theme.Text,
                    Visible = true,
                    ZIndex = 2
                })
                --
                Utility.AddConnection(Library.Communication.Event, function(Type, Color)
                    if Type == "Accent" then
                        SectionTopline.Color = Color
                    elseif Type == "DarkContrast" then
                        SectionOutline.Color = Color
                    elseif Type == "Text" then
                        SectionTitle.Color = Color
                    elseif Type == "Inline" then
                        SectionInline.Color = Color
                    end
                end)
                --
                function Section:UpdateSizeY(SizeY)
                    SectionInline.Size = Vector2.new(SectionInline.Size.X, SizeY + 10)

                    SectionOutline.Size = Vector2.new(SectionInline.Size.X - 2, SectionInline.Size.Y - 2)
                    SectionOutline.Position = Vector2.new(SectionInline.Position.X + 1, SectionInline.Position.Y + 1)
                end
                --
                Tab.SectionAxis = {
                    Side == "Left" and SectionInline.Position.Y + SectionInline.Size.Y or Tab.SectionAxis[1], 
                    Side == "Right" and SectionInline.Position.Y + SectionInline.Size.Y or Tab.SectionAxis[2]
                }
                --
                Tab["Render"][#Tab["Render"] + 1] = SectionInline
                Tab["Render"][#Tab["Render"] + 1] = SectionOutline
                Tab["Render"][#Tab["Render"] + 1] = SectionTopline
                Tab["Render"][#Tab["Render"] + 1] = SectionTitle
                --
                function Section:Toggle(Options)
                    local Toggle = {
                        Axis = Section.ContentAxis,
                        Toggled = Options.State,
                        Drop = false,
                        Callback = typeof(Options.Callback) == "function" and Options.Callback or function() end
                    }
                    --
                    Options.Flag = Options.Flag or "AWGWJIjgAWJIGIJAWG"
                    Library.Flags[Options.Flag] = false
                    --
                    local ToggleInline = Utility.AddDrawing("Square", {
                        Position = Vector2.new(SectionInline.Position.X + 8, SectionInline.Position.Y + 23 + Toggle.Axis),
                        Size = Vector2.new(13, 13),
                        Thickness = 0,
                        Color = Library.Theme.Inline,
                        Visible = true,
                        Filled = true
                    })
                    --
                    local ToggleOutline = Utility.AddDrawing("Square", {
                        Size = Vector2.new(ToggleInline.Size.X - 2, ToggleInline.Size.Y - 2),
                        Position = Vector2.new(ToggleInline.Position.X + 1, ToggleInline.Position.Y + 1),
                        Thickness = 0,
                        Color = Library.Theme.LightContrast,
                        Visible = true,
                        Filled = true
                    })
                    --
                    local ToggleHitbox = Utility.AddDrawing("Square", {
                        Size = Vector2.new(SectionOutline.Size.X - 60, ToggleInline.Size.Y - 2),
                        Position = Vector2.new(ToggleInline.Position.X + 1, ToggleInline.Position.Y + 1),
                        Thickness = 0,
                        Color = Library.Theme.Hitbox,
                        Transparency = 0,
                        Visible = true,
                        Filled = true
                    })
                    --
                    local ToggleGradient = Utility.AddDrawing("Image", {
                        Size = Vector2.new(ToggleInline.Size.X - 2, ToggleInline.Size.Y - 2),
                        Position = Vector2.new(ToggleInline.Position.X + 1, ToggleInline.Position.Y + 1),
                        Data = Library.Theme.Gradient,
                        Transparency = 0.5,
                        Visible = true
                    })
                    --
                    local ToggleTitle = Utility.AddDrawing("Text", {
                        Text = Options.Title,
                        Position = Vector2.new(ToggleInline.Position.X + ToggleInline.Size.X + 8, ToggleInline.Position.Y),
                        Center = false,
                        Outline = false,
                        Font = Library.Theme.Font,
                        Size = Library.Theme.TextSize,
                        Color = Options.Type ~= nil and Options.Type == "Dangerous" and Library.Theme.Accent[1] or Library.Theme.Text,
                        Visible = true,
                        ZIndex = 2
                    })
                    --
                    function Toggle:Set(State)
                        Toggle.Toggled = State
                        ToggleOutline.Color = Toggle.Toggled and Library.Theme.Accent[1] or Library.Theme.DarkContrast
                        Library.Flags[Options.Flag] = Toggle.Toggled
                        Toggle.Callback(Toggle.Toggled)
                    end
                    --
                    Utility.AddConnection(UserInput.InputBegan, function(Input, Useless)
                        
                        for Index, Value in pairs(Tab.Dropdowns[Side]) do
                            if Value then
                                return
                            end
                        end
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 and Utility.OnMouse(ToggleHitbox) then
                            Toggle.Toggled = not Toggle.Toggled
                            Toggle:Set(Toggle.Toggled)
                        end
                    end)
                    --
                    Utility.AddConnection(UserInput.InputChanged, function(Input, Useless)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement then
                            if Utility.OnMouse(ToggleHitbox) then
                                ToggleInline.Color = Library.Theme.Accent[1]
                            else
                                ToggleInline.Color = Library.Theme.Inline
                            end
                        end
                    end)
                    --
                    Utility.AddConnection(Library.Communication.Event, function(Type, Color)
                        if Type == "Accent" and Toggle.Toggled then
                            ToggleOutline.Color = Color
                            if Options.Type == "Dangerous" then
                                ToggleTitle.Color = Color
                            end
                        elseif Type == "LightContrast" and not Toggle.Toggled then
                            ToggleOutline.Color = Color
                        elseif Type == "Text" then
                            ToggleTitle.Color = Color
                        elseif Type == "Inline" then
                            ToggleInline.Color = Color
                        end
                    end)
                    --
                    Section.ContentAxis = Section.ContentAxis + ToggleOutline.Size.Y + 8
                    Tab.SectionAxis = {
                        Side == "Left" and Tab.SectionAxis[1] + ToggleOutline.Size.Y + 8 or Tab.SectionAxis[1], 
                        Side == "Right" and Tab.SectionAxis[2] + ToggleOutline.Size.Y + 8 or Tab.SectionAxis[2]
                    }
                    --
                    self:UpdateSizeY(Section.ContentAxis + ToggleOutline.Size.Y)
                    --
                    Tab["Render"][#Tab["Render"] + 1] = ToggleInline
                    Tab["Render"][#Tab["Render"] + 1] = ToggleOutline
                    Tab["Render"][#Tab["Render"] + 1] = ToggleTitle
                    Tab["Render"][#Tab["Render"] + 1] = ToggleGradient
                    Tab["Render"][#Tab["Render"] + 1] = ToggleHitbox
                    --
                    return Toggle
                end
                --
                return Section
            end
            --
            Tab["TabInline"] = TabInline
            Tab["TabOutline"] = TabOutline
            Tab["TabTitle"] = TabTitle
            --
            Tab:Install()
            --
            Window.LastTab = TabInline
            self.Tabs[#self.Tabs + 1] = Tab
            Tab["Render"] = {}
            return Tab
        end
        --
        return Window
    end
end

--
Utility.AddConnection(UserInput.InputBegan, function(Input, Useless)
    if Useless then
        return
    end
    if Input.KeyCode == Enum.KeyCode.RightShift then
        Library:ChangeVisible(not Library.WindowVisible)
    end
end)
--
local Maid = {
    Connections = {}
}

Maid.AddConnection = function(Specific, Type, Callback)
    local Connection = Type:Connect(Callback)

    Specific = Specific or #Maid.Connections + 1
    Maid.Connections[Specific] = Connection
    
    return Connection
end

Maid.DelConnection = function(Specific)
    Maid.Connections[Specific]:Disconnect()
end

Maid.DisconnectAll = function()
    for Idx, Val in pairs(Maid.Connections) do
        Val:Disconnect()
    end
end

-- Add a Loading function
function AbyssLib:Loading(text, cancelable)
    print("Creating Loading GUI...")

    -- Create GUI elements
    local screenGui = Instance.new("ScreenGui")
    local textLabel = Instance.new("TextLabel")

    screenGui.Name = "LoadingGui"
    screenGui.Parent = game:GetService("CoreGui")

    textLabel.Name = "LoadingText"
    textLabel.Parent = screenGui
    textLabel.Size = UDim2.new(0, 300, 0, 50)
    textLabel.Position = UDim2.new(0.5, -150, 0.5, -25)
    textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Text = text
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextSize = 24

    -- Return methods for the Loading GUI
    return {
        Text = function(newText)
            textLabel.Text = newText
        end,
        TextColor = function(color)
            textLabel.TextColor3 = color
        end,
        Destroy = function()
            screenGui:Destroy()
            print("Loading GUI destroyed.")
        end
    }
end

-- Return the AbyssLib table for external usage
return AbyssLib
