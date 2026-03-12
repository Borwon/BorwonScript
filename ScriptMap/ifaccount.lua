repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- กำหนด ID ผู้เล่นที่อนุญาตให้สคริปต์ทำงาน (เปลี่ยนเป็น UserId ของคุณ)
-- สามารถใส่หลายไอดีได้ โดยกำหนดให้เป็น true
local allowedUserIds = {
    [2013408984] = true, -- เปลี่ยนเป็น ID ของคุณ
}

-- เพิ่มการรอ (wait) ก่อนตรวจสอบ
task.wait(1)

-- ตรวจสอบดึง Roblox ID ว่าอยู่ในตัวแปรด้านบนหรือไม่
if allowedUserIds[LocalPlayer.UserId] then
    -- หากเจอ (ID ตรงกัน) จะทำการโหลดสคริปต์และไปต่อ
    print("[LOG] User ID Match! Loading the main script...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
    
else
    -- ถ้าหากไม่เจอ จะรัน loadstring อันนี้แทน
    print("[LOG] User ID Not Found. Loading alternative script...")
    
end
