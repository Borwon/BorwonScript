if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- รอให้ข้อมูลในเกมโหลดเล็กน้อย
task.wait(5)

local RAMAccount = loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua'))()
local MyAccount 

-- รอจนกว่าจะสร้างบัญชีได้
repeat task.wait() 
    MyAccount = RAMAccount.new(game:GetService("Players").LocalPlayer.Name)
until MyAccount

-- หากบัญชีพร้อมใช้งาน
if MyAccount then
    task.spawn(function()
        local player = game:GetService("Players").LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui", 10)
        local interface = playerGui and playerGui:WaitForChild("Interface", 10)
        local diamondCountContainer = interface and interface:WaitForChild("DiamondCount", 10)
        local countLabel = diamondCountContainer and diamondCountContainer:WaitForChild("Count", 10)

        if countLabel then
            print("[LOG] Script loaded successfully")

            while true do
                local currentDiamonds
                local success, err = pcall(function()
                    currentDiamonds = countLabel.ContentText
                end)

                if success and currentDiamonds then
                    print("[LOG] Data fetched successfully:", currentDiamonds)
                    print(string.format("[LOG] Updating account alias: Diamonds : %s", currentDiamonds or "N/A"))

                    local update_success, update_err = pcall(function()
                        MyAccount:SetAlias(string.format("Diamonds : %s", currentDiamonds or "N/A"))
                        MyAccount:SetDescription("")
                    end)

                    if not update_success then
                        warn("Error updating account: " .. tostring(update_err))
                    end
                else
                    warn("[LOG] Data fetch failed because: " .. tostring(err))
                end

                task.wait(10)
            end
        else
            warn("[LOG] Diamond Count Label not found in PlayerGui or took too long to load.")
        end
    end)
end
