-- ifaccount.lua — ScriptMap ตรวจสอบ User ID แล้ว loadstring ตามเงื่อนไข
-- ไม่ใช้ Horst API (ไม่มีข้อมูลสถิติเกม)

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- กำหนด ID ผู้เล่นที่อนุญาตให้สคริปต์ทำงาน
-- สามารถใส่หลายไอดีได้โดยกำหนดให้เป็น true
local allowedUserIds = {
    [2013408984] = true, -- เปลี่ยนเป็น ID ของคุณ
}

task.wait(1)

-- ตรวจสอบว่า User ID อยู่ในลิสต์หรือไม่
if allowedUserIds[LocalPlayer.UserId] then
    print("[ifaccount] User ID Match! Loading main script...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
else
    print("[ifaccount] User ID not found. No alternative script configured.")
    -- TODO: ใส่ loadstring alternative ที่นี่ถ้าต้องการ
    -- loadstring(game:HttpGet("URL_HERE"))()
end
