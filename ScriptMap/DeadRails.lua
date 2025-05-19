local RAMAccount = loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua'))()
local MyAccount 

-- ฟังก์ชันแปลงค่าตัวเลขให้มีหน่วย
local function FormatCoins(value)
    if value >= 1e6 then
        return string.format("%.1fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.1fk", value / 1e3)
    else
        return tostring(value)
    end
end

-- รอจนกว่าจะสร้างบัญชีได้
repeat task.wait() 
    MyAccount = RAMAccount.new(game:GetService("Players").LocalPlayer.Name)
until MyAccount

-- หากบัญชีพร้อมใช้งาน
if MyAccount then
    task.spawn(function()
        local gui = game:GetService("Players").LocalPlayer.PlayerGui
        local bondDisplay = gui:FindFirstChild("BondDisplay", true)
        local bondInfo = bondDisplay and bondDisplay:FindFirstChild("BondInfo", true)
        local bondCount = bondInfo and bondInfo:FindFirstChild("BondCount", true)

        if bondCount and bondCount:IsA("TextLabel") and bondCount.Text ~= nil then
            print("[LOG] Script loaded successfully")

            while true do
                local bonds
                local success, err = pcall(function()
                    bonds = bondCount.Text
                end)

                if success and bonds then
                    print("[LOG] Data fetched successfully:", bonds)
                    local formatted_bonds = FormatCoins(tonumber(bonds))
                    print(string.format("[LOG] Updating account alias: Bonds : %s", formatted_bonds or "N/A"))

                    local update_success, update_err = pcall(function()
                        MyAccount:SetAlias(string.format("Bonds : %s", formatted_bonds or "N/A"))
                        MyAccount:SetDescription("")
                    end)

                    if not update_success then
                        warn("Error updating account: " .. tostring(update_err))
                    end
                else
                    warn("[LOG] Data fetch failed because: " .. tostring(err))
                end

                task.wait(300)
            end
        else
            warn("[LOG] BondCount not found or invalid.")
        end
    end)
end
