-- sailorpiece.lua — ScriptMap สำหรับ Sailor Piece
-- ใช้ _G.Horst_SetDescription แสดง Level, Money, Gems, Race, Clan, Haki
-- ข้อมูล: player.Data.Gems, player.Data.Level, player.Data.Money
--         player:GetAttribute("CurrentRace"), player:GetAttribute("CurrentClan")
--         PlayerGui.StatsPanelUI (HakiLevel, ObservationHakiLevel, ConquerorHakiExperience)

-- ฟังก์ชันแปลงตัวเลขให้มีหน่วย (k / M)
local function FormatCoins(value)
    if value >= 1e6 then
        return string.format("%.1fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.1fk", value / 1e3)
    else
        return tostring(value)
    end
end

-- ดึงตัวเลข Level จาก Text เช่น "Haki Lv. 35" → 35
local function ExtractLevel(text)
    if not text then return nil end
    -- จับตัวเลขหลังสุดใน string (ครอบคลุม "Lv. 35", "Level: 1", ฯลฯ)
    local num = tonumber(text:match("(%d+)%s*$"))
    return num
end

-- แปลง Level เป็น Emoji (nil หรือ <= 1 = ❌, >= 2 = ✅)
local function HakiEmoji(text)
    local lv = ExtractLevel(text)
    if lv and lv >= 2 then
        return "✅"
    else
        return "❌"
    end
end

-- Logging
local function log(logType, message)
    local timeStr = os.date("%H:%M:%S")
    if logType == "info" then
        print("[" .. timeStr .. "] ℹ️ " .. message)
    elseif logType == "success" then
        print("[" .. timeStr .. "] ✅ " .. message)
    elseif logType == "warning" then
        warn("[" .. timeStr .. "] ⚠️ " .. message)
    elseif logType == "error" then
        warn("[" .. timeStr .. "] ❌ " .. message)
    end
end

log("info", "Sailor Piece Script Started")

-- รอให้ game โหลดและ LocalPlayer พร้อม
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer
repeat task.wait() until _G.Horst_SetDescription

-- รอให้ข้อมูลโหลด
local function WaitForDataToLoad()
    local player = game:GetService("Players").LocalPlayer
    local dataFolder, gemsObject, levelObject, moneyObject
    for i = 1, 3 do
        dataFolder  = player:WaitForChild("Data", 10)
        gemsObject  = dataFolder and dataFolder:FindFirstChild("Gems")
        levelObject = dataFolder and dataFolder:FindFirstChild("Level")
        moneyObject = dataFolder and dataFolder:FindFirstChild("Money")
        if gemsObject and levelObject and moneyObject then break end
        log("warning", "Data not loaded yet, retrying (" .. i .. "/3)...")
        task.wait(5)
    end
    if not (gemsObject and levelObject and moneyObject) then
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
task.wait(20)

local UPDATE_INTERVAL = 30

while true do
    local gems, level, money, race, clan
    local hakiText, obsHakiText, conqHakiText

    local success, err = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local dataFolder = player:FindFirstChild("Data")
        if not dataFolder then return end

        local gemsObj  = dataFolder:FindFirstChild("Gems")
        local levelObj = dataFolder:FindFirstChild("Level")
        local moneyObj = dataFolder:FindFirstChild("Money")

        if gemsObj  then gems  = tostring(gemsObj.Value  or gemsObj.Text  or "0") end
        if levelObj then level = tostring(levelObj.Value or levelObj.Text or "0") end
        if moneyObj then money = tostring(moneyObj.Value or moneyObj.Text or "0") end

        -- Attribute จาก player โดยตรง
        race = player:GetAttribute("CurrentRace") or "None"
        clan = player:GetAttribute("CurrentClan") or "None"

        -- ดึง Haki Text จาก GUI
        local gui       = player:FindFirstChild("PlayerGui")
        local statsUI   = gui       and gui:FindFirstChild("StatsPanelUI")
        local mainFrame = statsUI   and statsUI:FindFirstChild("MainFrame")
        local frame     = mainFrame and mainFrame:FindFirstChild("Frame")
        local content   = frame     and frame:FindFirstChild("Content")
        local page2     = content   and content:FindFirstChild("Page2")
        local holder    = page2     and page2:FindFirstChild("StatsHolder")

        if holder then
            local hakiFrame = holder:FindFirstChild("HakiProgressionFrame")
            local obsFrame  = holder:FindFirstChild("ObservationHakiProgressionFrame")
            local conqFrame = holder:FindFirstChild("ConquerorHakiProgressionFrame")

            local hakiTxts = hakiFrame and hakiFrame:FindFirstChild("Txts")
            local obsTxts  = obsFrame  and obsFrame:FindFirstChild("Txts")
            local conqTxts = conqFrame and conqFrame:FindFirstChild("Txts")

            local hakiLvObj  = hakiTxts  and hakiTxts:FindFirstChild("HakiLevel")
            local obsLvObj   = obsTxts   and obsTxts:FindFirstChild("ObservationHakiLevel")
            local conqExpObj = conqTxts  and conqTxts:FindFirstChild("ConquerorHakiExperience")

            if hakiLvObj  then hakiText     = hakiLvObj.Text  end
            if obsLvObj   then obsHakiText  = obsLvObj.Text   end
            if conqExpObj then conqHakiText = conqExpObj.Text end
        end
    end)

    if success and (gems or level or money) then

        -- Format Gems
        local formatted_gems = "N/A"
        if gems then
            local cleaned = gems:gsub("[^%d%.]+", ""):gsub("%.+", ".")
            local num = tonumber(cleaned)
            if num then formatted_gems = FormatCoins(num) end
        end

        -- Format Money
        local formatted_money = "N/A"
        if money then
            local cleaned = money:gsub("[^%d%.]+", ""):gsub("%.+", ".")
            local num = tonumber(cleaned)
            if num then formatted_money = FormatCoins(num) end
        end

        -- Format Level
        local formatted_level = "N/A"
        local raw_level = nil
        if level then
            local cleaned = level:gsub("[^%d%.]+", ""):gsub("%.+", ".")
            local num = tonumber(cleaned)
            if num then
                formatted_level = tostring(num)
                raw_level = num
            end
        end

        -- Haki Emoji
        local hakiEmoji = HakiEmoji(hakiText)
        local obsEmoji  = HakiEmoji(obsHakiText)
        local conqEmoji = HakiEmoji(conqHakiText)

        -- Horst ห้ามใช้ | และ ; ในข้อความ
        local messages = string.format(
            "⭐ Lv.%s, 💵 Money.%s, 💠 Gems.%s, Race.[%s], Clan.[%s], Haki:%s Obs:%s Conq:%s",
            formatted_level, formatted_money, formatted_gems,
            race or "None", clan or "None",
            hakiEmoji, obsEmoji, conqEmoji
        )

        _G.Horst_SetDescription(messages)
        log("success", "Description updated: " .. messages)

        -- [DISABLED] ส่ง AccountChangeDone เฉพาะเมื่อ Level >= 11500
        --[[ AccountChangeDone disabled
        if raw_level and raw_level >= 11500 then
            local ok, doneErr = _G.Horst_AccountChangeDone()
            if ok then
                log("success", "AccountChangeDone sent successfully! (Lv " .. raw_level .. " >= 11500)")
                break -- หยุดลูปทันที ไม่ให้ SetDescription วนซ้ำ reset status กลับ
            else
                log("error", "Failed to send AccountChangeDone: " .. tostring(doneErr))
            end
        else
            log("info", "Level " .. tostring(raw_level or "N/A") .. " — not yet 11500, skipping AccountChangeDone")
        end --]]
    else
        log("error", "Error fetching data: " .. tostring(err))
    end

    log("info", "Next update in " .. UPDATE_INTERVAL .. " seconds...")
    task.wait(UPDATE_INTERVAL)
end