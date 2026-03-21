-- sailorpiece.lua — ScriptMap สำหรับ Sailor Piece
-- ใช้ _G.Horst_SetDescription แสดง Level, Money, Gems, Race, Clan, Haki, Swords
-- ข้อมูล: player.Data (Gems, Level, Money)
--         player:GetAttribute (CurrentRace, CurrentClan)
--         PlayerGui.StatsPanelUI (HakiLevel, ObservationHakiLevel, ConquerorHakiExperience)
--         ReplicatedStorage.Remotes (RequestInventory, UpdateInventory)

-- ════════════════════════════════════════
--  CONFIG
-- ════════════════════════════════════════

-- Sword ที่ไม่ต้องแสดง
local HIDDEN_SWORDS = { ["Katana"] = true, ["Dark Blade"] = true }

-- Race → Emoji
local RACE_EMOJI = {
    Human      = "👤",
    Fishman    = "🐟",
    Mink       = "🐾",
    Skypiean   = "🕊️",
    Lunarian   = "🔥",
    Vessel     = "👁️",
    Limitless  = "♾️",
    Shinigami  = "💀",
    Shadowburn = "🌑",
    Hollow     = "🕳️",
    Oni        = "👹",
    Kitsune    = "🦊",
    Leviathan  = "🌊",
    Slime      = "🟢",
    Servant    = "🔱",
}

-- Clan → Emoji
local CLAN_EMOJI = {
    None = "🚫",
}

-- ════════════════════════════════════════
--  UTILS
-- ════════════════════════════════════════

local function FormatCoins(value)
    if value >= 1e6 then
        return string.format("%.1fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.1fk", value / 1e3)
    else
        return tostring(value)
    end
end

local function ExtractLevel(text)
    if not text then return nil end
    return tonumber(text:match("(%d+)%s*$"))
end

local function HakiEmoji(text)
    local lv = ExtractLevel(text)
    return (lv and lv >= 2) and "✅" or "❌"
end

local function RaceLabel(race)
    local emoji = RACE_EMOJI[race] or "❓"
    return emoji .. race
end

local function ClanLabel(clan)
    local emoji = CLAN_EMOJI[clan] or "⚔️"
    return emoji .. clan
end

local function log(logType, message)
    local t = os.date("%H:%M:%S")
    if logType == "info"    then print("[" .. t .. "] ℹ️ "  .. message)
    elseif logType == "success" then print("[" .. t .. "] ✅ " .. message)
    elseif logType == "warning" then warn( "[" .. t .. "] ⚠️ "  .. message)
    elseif logType == "error"   then warn( "[" .. t .. "] ❌ " .. message)
    end
end

-- ════════════════════════════════════════
--  INIT
-- ════════════════════════════════════════

log("info", "Sailor Piece Script Started")

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer
repeat task.wait() until _G.Horst_SetDescription

local Players  = game:GetService("Players")
local RepStore = game:GetService("ReplicatedStorage")

local function WaitForDataToLoad()
    local player = Players.LocalPlayer
    local dataFolder, gemsObj, levelObj, moneyObj
    for i = 1, 3 do
        dataFolder = player:WaitForChild("Data", 10)
        gemsObj    = dataFolder and dataFolder:FindFirstChild("Gems")
        levelObj   = dataFolder and dataFolder:FindFirstChild("Level")
        moneyObj   = dataFolder and dataFolder:FindFirstChild("Money")
        if gemsObj and levelObj and moneyObj then break end
        log("warning", "Data not loaded yet, retrying (" .. i .. "/3)...")
        task.wait(5)
    end
    if not (gemsObj and levelObj and moneyObj) then
        log("error", "Failed to load Gems/Level/Money after retries.")
        return false
    end
    log("success", "Data loaded successfully.")
    return true
end

if not WaitForDataToLoad() then
    log("error", "Data failed to load — script terminated.")
    return
end

log("info", "Waiting for data initialization...")
task.wait(5)

-- ════════════════════════════════════════
--  INVENTORY (Sword) — ดึงผ่าน Remote
-- ════════════════════════════════════════

local inventoryData = {}

local function FetchInventory()
    local conn
    conn = RepStore.Remotes.UpdateInventory.OnClientEvent:Connect(function(category, items)
        inventoryData[category] = items
    end)
    RepStore.Remotes.RequestInventory:FireServer()
    task.wait(2)
    conn:Disconnect()
end

local function FetchTotalStats()
    local ok, data = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes.GetTotalStats:InvokeServer()
    end)
    if ok and data then return data end
    return {}
end

local function GetSwordList()
    local swords = {}
    for _, item in pairs(inventoryData["Sword"] or {}) do
        if type(item) == "table" and item.name then
            if not HIDDEN_SWORDS[item.name] then
                table.insert(swords, item.name)
            end
        end
    end
    return #swords > 0 and table.concat(swords, ", ") or "None"
end

-- Item ที่อยากแสดง + label ย่อ
local WANTED_ITEMS = {
    ["Clan Reroll"]   = "Clan",
    ["Race Reroll"]   = "Race",
    ["Trait Reroll"]  = "Trait",
    ["Aura Crate"]    = "Aura",
    ["Mythical Chest"]= "Mythical",
}

local function GetItemList()
    local parts = {}
    for _, item in pairs(inventoryData["Items"] or {}) do
        if type(item) == "table" and item.name then
            local label = WANTED_ITEMS[item.name]
            if label then
                table.insert(parts, label .. ":" .. tostring(item.quantity))
            end
        end
    end
    return #parts > 0 and table.concat(parts, ", ") or "N/A"
end

-- ════════════════════════════════════════
--  MAIN LOOP
-- ════════════════════════════════════════

local UPDATE_INTERVAL = 30

while true do
    local gems, level, money, race, clan
    local hakiText, obsHakiText, conqHakiText

    local success, err = pcall(function()
        local player     = Players.LocalPlayer
        local dataFolder = player:FindFirstChild("Data")
        if not dataFolder then return end

        local gemsObj  = dataFolder:FindFirstChild("Gems")
        local levelObj = dataFolder:FindFirstChild("Level")
        local moneyObj = dataFolder:FindFirstChild("Money")

        if gemsObj  then gems  = tostring(gemsObj.Value  or gemsObj.Text  or "0") end
        if levelObj then level = tostring(levelObj.Value or levelObj.Text or "0") end
        if moneyObj then money = tostring(moneyObj.Value or moneyObj.Text or "0") end

        race = player:GetAttribute("CurrentRace") or "None"
        clan = player:GetAttribute("CurrentClan") or "None"

        -- Haki จาก GUI
        local gui    = player:FindFirstChild("PlayerGui")
        local holder = gui
            and gui:FindFirstChild("StatsPanelUI")
            and gui.StatsPanelUI:FindFirstChild("MainFrame")
            and gui.StatsPanelUI.MainFrame:FindFirstChild("Frame")
            and gui.StatsPanelUI.MainFrame.Frame:FindFirstChild("Content")
            and gui.StatsPanelUI.MainFrame.Frame.Content:FindFirstChild("Page2")
            and gui.StatsPanelUI.MainFrame.Frame.Content.Page2:FindFirstChild("StatsHolder")

        if holder then
            local function getText(frameName, childName)
                local f = holder:FindFirstChild(frameName)
                local t = f and f:FindFirstChild("Txts")
                local c = t and t:FindFirstChild(childName)
                return c and c.Text or nil
            end
            hakiText     = getText("HakiProgressionFrame",        "HakiLevel")
            obsHakiText  = getText("ObservationHakiProgressionFrame", "ObservationHakiLevel")
            conqHakiText = getText("ConquerorHakiProgressionFrame",   "ConquerorHakiExperience")
        end
    end)

    if not success then
        log("error", "Error fetching data: " .. tostring(err))
    end

    -- ยิง SetDescription เสมอ แม้ข้อมูลบางส่วนจะหาไม่เจอ
    local function parseNum(str)
        if not str or str == "" then return nil end
        local cleaned = str:gsub("[^%d]+", "")
        if cleaned == "" then return nil end
        return tonumber(cleaned)
    end

    local gemsNum  = parseNum(gems)
    local moneyNum = parseNum(money)
    local levelNum = parseNum(level)

    local fmt_gems  = gemsNum  and FormatCoins(gemsNum)  or "N/A"
    local fmt_money = moneyNum and FormatCoins(moneyNum) or "N/A"
    local fmt_level = levelNum and tostring(levelNum)    or "N/A"

    -- ดึง Inventory ทุก loop
    FetchInventory()
    local swordList = GetSwordList()
    local itemList  = GetItemList()

    -- ดึง Luck และ Damage จาก Remote
    local totalStats = FetchTotalStats()
    local fmt_luck = totalStats.LuckTotal   and tostring(math.floor(totalStats.LuckTotal))   or "N/A"
    local fmt_dmg  = totalStats.DamageTotal and tostring(math.floor(totalStats.DamageTotal)) or "N/A"

    local messages = string.format(
        "⭐ %s ┃ 💵 %s ┃ 💠 %s ┃ %s ┃ %s ┃ Haki:%s Obs:%s ┃ 🍀 %s%% ┃ 💥 %s%% ┃ 🗡️ %s ┃ %s",
        fmt_level, fmt_money, fmt_gems,
        RaceLabel(race or "None"), ClanLabel(clan or "None"),
        HakiEmoji(hakiText), HakiEmoji(obsHakiText),
        fmt_luck, fmt_dmg,
        swordList, itemList
    )

    _G.Horst_SetDescription(messages)
    log("success", "Description updated: " .. messages)

    -- [DISABLED] AccountChangeDone
    --[[ AccountChangeDone disabled
    if levelNum and levelNum >= 11500 then
        local ok, doneErr = _G.Horst_AccountChangeDone()
        if ok then
            log("success", "AccountChangeDone sent! (Lv " .. levelNum .. " >= 11500)")
            break
        else
            log("error", "Failed to send AccountChangeDone: " .. tostring(doneErr))
        end
    else
        log("info", "Level " .. tostring(levelNum or "N/A") .. " — not yet 11500")
    end --]]

    log("info", "Next update in " .. UPDATE_INTERVAL .. " seconds...")
    task.wait(UPDATE_INTERVAL)
end