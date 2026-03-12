if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- รอให้ข้อมูลในเกมโหลดเล็กน้อย
task.wait(5)

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
        local player = game:GetService("Players").LocalPlayer
        local leaderstats = player:WaitForChild("leaderstats", 10)
        local shillings = leaderstats and leaderstats:WaitForChild("Shillings", 10)

        if shillings then
            print("[LOG] Script loaded successfully")

            while true do
                local currentShillings
                local success, err = pcall(function()
                    currentShillings = shillings.Value
                end)

                if success and currentShillings then
                    print("[LOG] Data fetched successfully:", currentShillings)
                    local formatted_shillings = FormatCoins(tonumber(currentShillings))
                    print(string.format("[LOG] Updating account alias: Shillings : %s", formatted_shillings or "N/A"))

                    local update_success, update_err = pcall(function()
                        MyAccount:SetAlias(string.format("Shillings : %s", formatted_shillings or "N/A"))
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
            warn("[LOG] Shillings not found in leaderstats or took too long to load.")
        end
    end)
end
