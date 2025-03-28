print("loadingchecking")

-- Wait for the game to load
if not game:IsLoaded() then
    print("[DEBUG] Waiting for the game to load...")
    game.Loaded:Wait()
end
print("[DEBUG] Game loaded successfully.")

-- Load the external script
loadstring(game:HttpGet('https://raw.githubusercontent.com/Borwon/BorwonScript/refs/heads/Update/LoaderScript.lua'))()