-- upgrade_gui_finder.lua - Find possible equipment upgrade buttons in PlayerGui.
-- No hooks, no remotes. Run while the equipment/upgrade UI is open.

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 30)

local KEYWORDS = {
    "equipment",
    "upgrade",
    "blade",
    "odm",
    "crit",
    "durability",
    "damage",
    "gas",
    "range",
    "control",
    "speed",
}

local BUTTON_CLASSES = {
    TextButton = true,
    ImageButton = true,
}

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function isKeywordMatch(text)
    text = lower(text)
    for _, keyword in ipairs(KEYWORDS) do
        if string.find(text, keyword, 1, true) then
            return true
        end
    end
    return false
end

local function getTextFromObject(object)
    local parts = { object.Name, object.ClassName }

    if object:IsA("TextButton") or object:IsA("TextLabel") or object:IsA("TextBox") then
        table.insert(parts, object.Text)
    end

    for _, child in ipairs(object:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            table.insert(parts, child.Text)
        end
    end

    return table.concat(parts, " ")
end

local function describeButton(button)
    local visible = true
    local current = button

    while current and current ~= playerGui do
        if current:IsA("GuiObject") and current.Visible == false then
            visible = false
            break
        end
        current = current.Parent
    end

    local size = button.AbsoluteSize
    local pos = button.AbsolutePosition
    local text = getTextFromObject(button):gsub("%s+", " ")

    print(
        "[UpgradeGuiFinder] "
            .. button:GetFullName()
            .. " | class=" .. button.ClassName
            .. " | visible=" .. tostring(visible)
            .. " | pos=" .. tostring(math.floor(pos.X)) .. "," .. tostring(math.floor(pos.Y))
            .. " | size=" .. tostring(math.floor(size.X)) .. "x" .. tostring(math.floor(size.Y))
            .. " | text=" .. text
    )
end

print("[UpgradeGuiFinder] Started. Keep the equipment upgrade UI open.")

local found = 0

for _, object in ipairs(playerGui:GetDescendants()) do
    if BUTTON_CLASSES[object.ClassName] then
        local text = getTextFromObject(object)
        if isKeywordMatch(text) then
            found = found + 1
            describeButton(object)
        end
    end
end

print("[UpgradeGuiFinder] Finished. Found " .. tostring(found) .. " possible buttons.")
