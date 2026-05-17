repeat task.wait() until game:IsLoaded()
repeat task.wait() until _G.Horst_SetDescription
getgenv().Config = {
    ["Slot"]="A",--B or C
    ["DebugError"]=true,
    ["UpdateInterval"]=10,
    ["ShowStatus"] = {
        ["Level"]=true,
        ["Presitage"]=true,
        ["Gold"]=true,
        ["Gem"]=true,
        ["Spin"]=true,
        ["Serum"]=true,
        ["Cosmetics"]={
                ["IsEnable"]=true,
                ["Show_what"]= {
                    "Angel's Halo",
                    "Armored Scars",
                    "Attack Scars",
                    "Colossal Scars",
                    "Crystal Necklace",
                    "Female Scars",
                    "Grimmjow's Mask",
                    "Hardened Shield",
                    "Kitsune Mask",
                    "Memory Scroll",
                    "Regiment Cloak (black)",
                    "Scarf",
                    "Scorched Cloak",
                    "Shogun's Helm",
                    "Warrior's Armband",
                    "Warrior's Medallion"
                },
			["Family"]=true
        }
    },
    ["Swich_ALT"]={
        ["IsEnable"]=false,
        ["When_Presitage"]=5,--EZ
        ["When_Level"]=67,--EZ
        ["When_Money"]=6700,--EZ
        ["When_ItemsAbove"]=true
    }
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteGet = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("GET")
local result = nil
local Currency = {}
local Canes = 0
local Gems = 0
local Gold = 0
local Spin=0
local leeevel=1
local pressss=0
local Inv={}
local serum={}
local itemList = {}
local Family="None"

local debugLastPrint = {}
local function debugLog(key, ...)
    if not getgenv().Config["DebugError"] then
        return
    end

    local now = os.clock()
    if debugLastPrint[key] and now - debugLastPrint[key] < 5 then
        return
    end
    debugLastPrint[key] = now

    print("[AttackOnTitan DEBUG][" .. key .. "]", ...)
end

local function fetchSettingsData()
    local ok, data = pcall(function()
        return RemoteGet:InvokeServer("Functions", "Settings", "Blur", "Off")
    end)

    if not ok then
        debugLog("RemoteGet", "InvokeServer failed:", data)
        return nil
    end

    if type(data) ~= "table" then
        debugLog("RemoteGet", "Expected table, got:", typeof(data), data)
        return nil
    end

    return data
end

local function getSlotData(data)
    if type(data) ~= "table" then
        debugLog("SlotData", "Settings data is not a table:", typeof(data))
        return nil
    end

    if type(data.Slots) ~= "table" then
        debugLog("SlotData", "Missing Slots table")
        return nil
    end

    local slot = getgenv().Config["Slot"]
    local slotData = data.Slots[slot]
    if type(slotData) ~= "table" then
        debugLog("SlotData", "Missing slot:", tostring(slot))
        return nil
    end

    return slotData
end

local function sanitizeHorstText(value)
    value = tostring(value)
    value = string.gsub(value, "|", ",")
    value = string.gsub(value, ";", ",")
    return value
end

local function sanitizeHorstJson(data)
    local clean = {}
    for key, value in pairs(data) do
        if type(value) == "string" then
            clean[key] = sanitizeHorstText(value)
        else
            clean[key] = value
        end
    end
    return clean
end

local function famconf()
    return getSlotData(result) or {}
end
local function Status_upd ()
    local data = fetchSettingsData()
    if not data then
        return false, "fetchSettingsData returned nil"
    end

    result = data
    local slotData = famconf()
    if type(slotData) ~= "table" or next(slotData) == nil then
        return false, "slot data is empty"
    end

    Currency = slotData.Currency or {}
    Canes = Currency.Canes or 0
    Gems = Currency.Gems or 0
    Gold = Currency.Gold or 0
    Spin=slotData.Total_Spins or 0
    Inv=slotData.Inventory or {}

    local progression = slotData.Progression
    if type(progression) ~= "table" then
        debugLog("Progression", "Missing Progression table; Level fallback:", leeevel)
        progression = {}
    end

    local avatar = slotData.Avatar
    if type(avatar) ~= "table" then
        debugLog("Avatar", "Missing Avatar table; Family fallback:", Family)
        avatar = {}
    end

    leeevel=progression.Level or 1
    pressss=progression.Prestige or 0
	Family=avatar.Family or "None"

    debugLog("Status", "Level:", leeevel, "Prestige:", pressss, "Gold:", Gold, "Gems:", Gems, "Spin:", Spin, "Family:", Family)
    return true
end


local function getlvl()
    return leeevel
end
local function getpresitage()
    return pressss
end
local function getgem()
   return Gems
end
local function getGold()
   return Gold
end
local function getspin()
    return Spin
end
local function getserum()
    local serumList = {}
    for category, items in pairs(Inv) do
        for name, amount in pairs(items) do
            if string.find(name, "Serum") then
                table.insert(serumList, name .. " x" .. amount)
            end
        end
    end
    return #serumList > 0 and table.concat(serumList, ", ") or "None"
end
local function getitem()
    table.clear(itemList)
    local whitelist=getgenv().Config["ShowStatus"]["Cosmetics"]["Show_what"]
    for j,k in pairs(whitelist) do
        for category, items in pairs(Inv) do
            for name, amount in pairs(items) do
                if string.find(name, k) then
                    table.insert(itemList, name .. ": x" .. amount)
                end
            end
        end
     end
    return #itemList > 0 and table.concat(itemList, ", ") or "None"
end

local function CheckItemMember()
    local confitem=getgenv().Config["ShowStatus"]["Cosmetics"]["Show_what"]
    if #itemList >= #confitem then
        return true
    else
        return false
    end
end

task.spawn(function()
  while true do
      task.wait(getgenv().Config["UpdateInterval"] or 10)
            local statusOk, statusErr = Status_upd()
            if not statusOk then
                debugLog("Status_upd", statusErr)
                task.wait(1)
                continue
            end

            local okLvl, lvl = pcall(getlvl) 
            if not okLvl then debugLog("getlvl", lvl) end
            local Leveil = (getgenv().Config["ShowStatus"]["Level"] and okLvl and lvl) or "N/A"


            local okPres, Pres = pcall(getpresitage)
            if not okPres then debugLog("getpresitage", Pres) end
            local Pre = (getgenv().Config["ShowStatus"]["Presitage"] and okPres and Pres) or "N/A"

            local okGold, Goldss = pcall(getGold)
            if not okGold then debugLog("getGold", Goldss) end
            local Thong = (getgenv().Config["ShowStatus"]["Gold"] and okGold and Goldss) or "N/A"

            local okGem, Gem = pcall(getgem)
            if not okGem then debugLog("getgem", Gem) end
            local phetch = (getgenv().Config["ShowStatus"]["Gem"] and okGem and Gem) or "N/A"

            local okSpin, Spinn = pcall(getspin)
            if not okSpin then debugLog("getspin", Spinn) end
            local Gyro = (getgenv().Config["ShowStatus"]["Spin"] and okSpin and Spinn) or "N/A"
            
            local okSerum, serumm = pcall(getserum)
            if not okSerum then debugLog("getserum", serumm) end
            local Sorum = (getgenv().Config["ShowStatus"]["Serum"] and okSerum and serumm ) or "N/A"

            local okCosmetic, cosme = pcall(getitem)
            if not okCosmetic then debugLog("getitem", cosme) end
            local cosmics= (getgenv().Config["ShowStatus"]["Cosmetics"]["IsEnable"] and okCosmetic and cosme ) or "N/A"

            local Race= (getgenv().Config["ShowStatus"]["Cosmetics"]["Family"] and Family ) or "N/A"
            Race = sanitizeHorstText(Race)
            Sorum = sanitizeHorstText(Sorum)
            cosmics = sanitizeHorstText(cosmics)

            local json_strings = sanitizeHorstJson({
                Racee=Race,
                Level=Leveil,
                Presitage=Pre,
                Money=Thong,
                Gem=phetch,
                Reroll=Gyro,
                Serum=Sorum,
                Cosmetics=cosmics
            })
            local HttpService = game:GetService("HttpService") --  Get serivce ของเกม
            local EncodeJson = HttpService:JSONEncode(json_strings) -- Encode เป็น json ก่อนเสมอ


            local setOk, setErr = pcall(function() 
                local description = string.format("🩸Family: %s  📃Level: %s  📜Presitage: %s  🥇Golds: %s  💎Gems: %s  ⚽Spins: %s  💉Serum: %s  🧥Cosmetics: %s",Race, Leveil, Pre, Thong, phetch, Gyro, Sorum,cosmics)
                _G.Horst_SetDescription(description,EncodeJson)
                debugLog("Description", "Sent:", description)
            end)
            if not setOk then
                debugLog("Horst_SetDescription", setErr)
            end
            if getgenv().Config["Swich_ALT"]["IsEnable"] and Pre >= getgenv().Config["Swich_ALT"]["When_Presitage"] and Leveil>= getgenv().Config["Swich_ALT"]["When_Level"] and Thong >= getgenv().Config["Swich_ALT"]["When_Money"] and ( getgenv().Config["Swich_ALT"]["When_ItemsAbove"] and CheckItemMember() )  then
                local callOk, ok, err = pcall(function()
                    return _G.Horst_AccountChangeDone()
                end)
                if not callOk then
                    debugLog("Horst_AccountChangeDone", ok)
                    err = ok
                    ok = false
                end
                if ok then
                    print("Account change done sent successfully!")
                else
                    print("Failed to send DONE:", err)
                end
            end
  end

end)
