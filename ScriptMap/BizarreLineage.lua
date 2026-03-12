local Players = game:GetService("Players")

local RAMAccount
local MyAccount = nil

-- โหลด Library ของ RAMAccount
local function LoadRAMAccount()
    local success, result = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua'))()
    end)
    
    if success then
        RAMAccount = result
        return true
    end
    return false
end

-- เริ่มต้นใช้งาน RAMAccount
local function InitializeRAMAccount()
    if not RAMAccount then
        if not LoadRAMAccount() then
            warn("Failed to load RAMAccount library")
            return false
        end
    end

    repeat 
        task.wait()
        local success, account = pcall(function()
            return RAMAccount.new(Players.LocalPlayer.Name)
        end)
        if success then
            MyAccount = account
        end
    until MyAccount
    
    print("RAMAccount initialized successfully!")
    return true
end

-- เริ่มการติดตามข้อมูลผู้เล่น
local function StartMonitoring()
    local player = Players.LocalPlayer
    local playerData = player:WaitForChild("PlayerData", 10)
    
    if not playerData then
        warn("PlayerData not found!")
        return
    end

    local slotData = playerData:WaitForChild("SlotData", 10)
    
    if not slotData then
        warn("SlotData not found!")
        return
    end

    task.spawn(function()
        while true do
            local success, err = pcall(function()
                -- ดึงค่ามาจาก SlotData
                local prestige = slotData:FindFirstChild("Prestige") and slotData.Prestige.Value or 0
                local level = slotData:FindFirstChild("Level") and slotData.Level.Value or 0
                local money = slotData:FindFirstChild("Money") and slotData.Money.Value or 0

                -- ฟังก์ชันจัดการดึงเฉพาะค่า Name จากข้อความ JSON
                local HttpService = game:GetService("HttpService")
                local function ExtractNames(value)
                    if type(value) ~= "string" or value == "" or value == "[]" then return "None" end
                    local names = {}
                    pcall(function()
                        local decoded = HttpService:JSONDecode(value)
                        if type(decoded) == "table" then
                            -- ถ้าเป็นแบบ Array มีหลายอัน (เช่น StandStorage)
                            if #decoded > 0 then
                                for _, item in ipairs(decoded) do
                                    if type(item) == "table" and item.Name then
                                        table.insert(names, tostring(item.Name))
                                    end
                                end
                            -- ถ้าเป็น Object เดี่ยวๆ (เช่น Stand ปัจจุบัน)
                            elseif decoded.Name then
                                table.insert(names, tostring(decoded.Name))
                            end
                        end
                    end)
                    if #names == 0 then
                        return "None"
                    end
                    return table.concat(names, ", ")
                end

                local standValue = slotData:FindFirstChild("Stand") and slotData.Stand.Value or ""
                local standStorageValue = playerData:FindFirstChild("StandStorage") and playerData.StandStorage.Value or ""

                local currentStands = ExtractNames(standValue)
                local storageStands = ExtractNames(standStorageValue)

                -- ยิงเข้า Roblox Account Manager
                if MyAccount then
                    MyAccount:SetAlias("Prestige: " .. tostring(prestige))
                    MyAccount:SetDescription("Lv: " .. tostring(level) .. " | $: " .. tostring(money) .. " | Stand: " .. currentStands .. " | Storage: " .. storageStands)
                end
            end)

            if not success then
                warn("Failed to update RAM: " .. tostring(err))
            end

            -- อัปเดตทุกๆ 5 วินาที
            task.wait(5)
        end
    end)
end

-- รอให้เกมโหลดเสร็จสมบูรณ์
repeat task.wait() until game:IsLoaded()

-- ทำงานเมื่อสามารถโหลด RAMAccount ได้สำเร็จ
if InitializeRAMAccount() then
    StartMonitoring()
end
