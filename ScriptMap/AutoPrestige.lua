wait(4)
local guiserv = game:GetService("GuiService")
local VIM = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function Rejoin()
    local Success, Error = pcall(function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
    if not Success then
        warn("Fail to rejoin")
    end
end
game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("S_Equipment","Talents")--Fire select remote
local memoriesstorage=require(game:GetService("ReplicatedStorage").Modules.Storage.Memories)
for i,v in pairs(memoriesstorage.Talents) do
    for k,j in pairs(v) do
        print(j.Tag)
        game:GetService("ReplicatedStorage").Assets.Remotes.GET:InvokeServer("S_Equipment","Prestige",{Boosts = "Luck Boost",Talents = j.Tag})--fire spam random remote
    end
end
Rejoin()
