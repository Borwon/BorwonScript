# AutoUpgrade

โฟลเดอร์นี้แยกสคริปต์ auto upgrade ล่าสุดออกจาก `ScriptMap` หลัก

## ใช้งานจริง

ใช้ไฟล์นี้:

```lua
ScriptMap/AutoUpgrade/main/auto_upgrade_capture_replay.lua
```

ค่าเริ่มต้นคือ auto start:

- รอเกมโหลด
- เข้า `Character.Actor`
- รอ remote `ReplicatedStorage.Assets.Remotes.GET`
- รอเพิ่ม 10 วินาที
- replay upgrade ทุก 5 วินาที

ตัวอย่าง config:

```lua
getgenv().AutoUpgradeCaptureReplayConfig = {
    Enabled = true,
    AutoStart = true,
    AutoStartDelay = 5,
    Interval = 1,
}
```

## Debug

ไฟล์ใน `debug/` เป็นไฟล์ที่ใช้ไล่ remote, GUI, module signature ตอนแก้ปัญหา ไม่ต้องรันตอนใช้งานปกติ
