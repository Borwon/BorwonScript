repeat task.wait() until game:IsLoaded()
getgenv().Config = {
    ["Slot"]="A",--B or C
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

local function fetchSettingsData()
    local ok, data = pcall(function()
        return RemoteGet:InvokeServer("Functions", "Settings", "Blur", "Off")
    end)

    if ok and type(data) == "table" then
        return data
    end

    return nil
end

local function getSlotData(data)
    if type(data) ~= "table" or type(data.Slots) ~= "table" then
        return nil
    end

    local slot = getgenv().Config["Slot"]
    return data.Slots[slot]
end

local function waitForMapData()
    local timeout = 60
    local started = os.clock()

    repeat
        result = fetchSettingsData()
        local slotData = getSlotData(result)

        if type(slotData) == "table"
            and type(slotData.Currency) == "table"
            and type(slotData.Inventory) == "table"
            and type(slotData.Progression) == "table"
            and type(slotData.Avatar) == "table" then
            return true
        end

        task.wait(1)
    until os.clock() - started >= timeout

    return false
end

waitForMapData()

local function famconf()
    return getSlotData(result) or {}
end
local function Status_upd ()
    result = fetchSettingsData() or result
    local slotData = famconf()
    Currency = slotData.Currency or {}
    Canes = Currency.Canes or 0
    Gems = Currency.Gems or 0
    Gold = Currency.Gold or 0
    Spin=slotData.Total_Spins or 0
    Inv=slotData.Inventory or {}
    local progression = slotData.Progression or {}
    local avatar = slotData.Avatar or {}
    leeevel=progression.Level or 1
    pressss=progression.Prestige or 0
	Family=avatar.Family or "None"
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
    return #serumList > 0 and table.concat(serumList, " | ") or "None"
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
    return #itemList > 0 and table.concat(itemList, " | ") or "None"
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
      task.wait()
      pcall(Status_upd)
            local _, lvl = pcall(getlvl) 
            local Leveil = (getgenv().Config["ShowStatus"]["Level"] and lvl) or "N/A"


            local _, Pres = pcall(getpresitage)
            local Pre = (getgenv().Config["ShowStatus"]["Presitage"] and Pres) or "N/A"

            local _, Goldss = pcall(getGold)
            local Thong = (getgenv().Config["ShowStatus"]["Gold"] and Goldss) or "N/A"

            local _, Gem = pcall(getgem)
            local phetch = (getgenv().Config["ShowStatus"]["Gem"] and Gem) or "N/A"

            local _, Spinn = pcall(getspin)
            local Gyro = (getgenv().Config["ShowStatus"]["Spin"] and Spinn) or "N/A"
            
            local _, serumm = pcall(getserum)
            local Sorum = (getgenv().Config["ShowStatus"]["Serum"] and serumm ) or "N/A"

            local _, cosme = pcall(getitem)
            local cosmics= (getgenv().Config["ShowStatus"]["Serum"] and cosme ) or "N/A"

            local Race= (getgenv().Config["ShowStatus"]["Serum"] and Family ) or "N/A"
            local json_strings = {	
									Racee=Race,
                                    Level=Leveil,
                                    Presitage=Pre,
                                    Money=Thong,
                                    Gem=phetch,
                                    Reroll=Gyro,
                                    Serum=Sorum,
                                    Cosmetics=cosmics
                                }
            local HttpService = game:GetService("HttpService") --  Get serivce ของเกม
            local EncodeJson = HttpService:JSONEncode(json_strings) -- Encode เป็น json ก่อนเสมอ


            pcall(function() 
                local description = string.format("🩸Family: %s  📃Level: %s  📜Presitage: %s  🥇Golds: %s  💎Gems: %s  ⚽Spins: %s  💉Serum: %s  🧥Cosmetics: %s",Race, Leveil, Pre, Thong, phetch, Gyro, Sorum,cosmics)
                _G.Horst_SetDescription(description,EncodeJson)
            end)
            if getgenv().Config["Swich_ALT"]["IsEnable"] and Pre >= getgenv().Config["Swich_ALT"]["When_Presitage"] and Leveil>= getgenv().Config["Swich_ALT"]["When_Level"] and Thong >= getgenv().Config["Swich_ALT"]["When_Money"] and ( getgenv().Config["Swich_ALT"]["When_ItemsAbove"] and CheckItemMember() )  then
                local ok, err = _G.Horst_AccountChangeDone()
                if ok then
                    print("Account change done sent successfully!")
                else
                    print("Failed to send DONE:", err)
                end
            end
  end

end)
