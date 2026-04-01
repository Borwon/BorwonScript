-- sailorpiece_setchecker.lua
-- ระบบเช็ค Set และจำนวนที่ทำได้
-- ยิงข้อมูลเข้า _G.Horst_SetDescription

-- ════════════════════════════════════════
--  CONFIG
-- ════════════════════════════════════════

-- Discord Webhook URL (ใส่ URL ของนายที่นี่)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1096787243873620089/9p5Z4nJyLYZXmJw6C4xYnW_juG_1b-x6aVhozcnWZC87nSwBsy1Gg8whagMqVlrAwZ_Y"

-- แจ้งเตือนเมื่อ set พร้อมทำ (true = เปิด, false = ปิด)
local NOTIFY_ON_READY = true

-- cooldown แจ้งเตือนแต่ละ set (วินาที) ป้องกัน spam
local NOTIFY_COOLDOWN = 300 -- 5 นาที

-- Item ที่อยากแสดงจำนวน (แก้ชื่อให้ตรงกับในเกม)
local SHOW_ITEMS = {
    "Trait Reroll",
    "Race Reroll",
    "Passive Shard",
    "Clan Reroll",
    "Aura Crate",
    "Mythical Chest",
}

local SET_DEFINITIONS = {
    {
        short = "SKN",
        full  = "Sukuna V.2",
        items = {
            ["Cursed Flesh"]           = 1,
            ["Malevolent Soul"]        = 3,
            ["Vessel Ring"]            = 7,
            ["Awakened Cursed Finger"] = 20,
        }
    },
    {
        short = "SBA",
        full  = "Saber Alter",
        items = {
            ["Corrupt Crown"]   = 1,
            ["Corruption Core"] = 3,
            ["Alter Essence"]   = 8,
            ["Morgan Remnant"]  = 15,
            ["Dark Grail"]      = 25,
        }
    },
    {
        short = "BD",
        full  = "Blessed Maiden",
        items = {
            ["Celestial Mark"] = 1,
            ["Aero Core"]      = 3,
            ["Gale Essence"]   = 8,
            ["Tide Remnant"]   = 14,
            ["Tempest Relic"]  = 25,
        }
    },
    {
        short = "MDR",
        full  = "Madara",
        items = {
            ["Path Fragment"] = 1,
            ["Eternal Core"]  = 3,
            ["Battle Sigil"]  = 8,
            ["Power Remnant"] = 15,
        }
    },
    {
        short = "Rmr",
        full  = "Rimuru",
        items = {
            ["Sage Pulse"]    = 9,
            ["Tempest Seal"]  = 6,
            ["Slime Remnant"] = 3,
            ["Slime Core"]    = 1,
        }
    },
    {
        short = "ATM",
        full  = "Atomic",
        items = {
            ["Atomic Omen"]      = 1,
            ["Eminence Essence"] = 3,
            ["Shadow Remnant"]   = 9,
            ["Magic Shard"]      = 16,
            ["Abyss Sigil"]      = 80,
        }
    },
    {
        short = "SHD",
        full  = "Shadow",
        items = {
            ["Atomic Core"]    = 1,
            ["Shadow Essence"] = 4,
            ["Void Seed"]      = 8,
            ["Umbral Capsule"] = 20,
        }
    },
    {
        short = "TAZ",
        full  = "True Aizen",
        items = {
            ["Evolution Fragment"]  = 1,
            ["Transcendent Core"]   = 3,
            ["Divinity Essence"]    = 8,
            ["Fusion Ring"]         = 15,
            ["Chrysalis Sigil"]     = 75,
        }
    },
    {
        short = "JWV2",
        full  = "Jinwoo V.2",
        items = {
            ["Monarch Core"]    = 10,
            ["Monarch Essence"] = 5,
            ["Kamish Dagger"]   = 2,
            ["Shadow Crystal"]  = 1,
        }
    },
    {
        short = "ANS",
        full  = "Anos",
        items = {
            ["Calamity Seal"]      = 65,
            ["Demonic Fragment"]   = 12,
            ["Demonic Shard"]      = 6,
            ["Destruction Eye"]    = 2,
            ["Imperial Mark"]      = 1,
        }
    },
    {
        short = "GIL",
        full  = "Gilgamesh",
        items = {
            ["Throne Remnant"] = 12,
            ["Ancient Shard"]  = 6,
            ["Golden Essence"] = 3,
            ["Phantasm Core"]  = 1,
        }
    },
    {
        short = "GJO",
        full  = "Gojo",
        items = {
            ["Infinity Essence"]  = 1,
            ["Blue Singularity"]  = 3,
            ["Reversal Pulse"]    = 9,
            ["Six Eyes"]          = 6,
        }
    },
    {
        short = "YMT",
        full  = "Yamato",
        items = {
            ["Azure Heart"]   = 1,
            ["Silent Storm"]  = 3,
            ["Yamato Essence"]= 7,
            ["Frozen Will"]   = 14,
        }
    },
}

-- ════════════════════════════════════════
--  LOGGING
-- ════════════════════════════════════════

local function log(logType, message)
    local t = os.date("%H:%M:%S")
    if logType == "info"        then print("[" .. t .. "] ℹ️ "  .. message)
    elseif logType == "success" then print("[" .. t .. "] ✅ "  .. message)
    elseif logType == "warning" then warn( "[" .. t .. "] ⚠️ "  .. message)
    elseif logType == "error"   then warn( "[" .. t .. "] ❌ "  .. message)
    end
end

-- ════════════════════════════════════════
--  INIT
-- ════════════════════════════════════════

log("info", "Set Checker Started")

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer
repeat task.wait() until _G.Horst_SetDescription

local RepStore = game:GetService("ReplicatedStorage")

-- ════════════════════════════════════════
--  INVENTORY FETCH
-- ════════════════════════════════════════

local inventoryData = {}

local function FetchInventory()
    local conn
    conn = RepStore.Remotes.UpdateInventory.OnClientEvent:Connect(function(category, items)
        inventoryData[category] = items
    end)
    RepStore.Remotes.RequestInventory:FireServer()
    task.wait(2)
    conn:Disconnect()
end

-- แปลง inventory Items เป็น map ชื่อ → จำนวน
local function BuildItemMap()
    local map = {}
    for _, item in pairs(inventoryData["Items"] or {}) do
        if type(item) == "table" and item.name then
            map[item.name] = item.quantity or 0
        end
    end
    return map
end

-- ════════════════════════════════════════
--  SET CHECKER
-- ════════════════════════════════════════

local function CheckSet(setDef, itemMap)
    local canMake = math.huge

    -- หาจำนวน set ที่ทำได้ (ถูกจำกัดโดย item ที่น้อยที่สุด)
    for itemName, required in pairs(setDef.items) do
        local owned = itemMap[itemName] or 0
        local possible = math.floor(owned / required)
        if possible < canMake then
            canMake = possible
        end
    end

    if canMake == math.huge then canMake = 0 end

    -- ถ้าทำไม่ได้เลย ให้หาว่าขาดอะไรบ้าง
    local missing = {}
    if canMake == 0 then
        for itemName, required in pairs(setDef.items) do
            local owned = itemMap[itemName] or 0
            if owned < required then
                local lack = required - owned
                table.insert(missing, itemName .. " x" .. lack)
            end
        end
        -- เรียงให้ดูง่าย
        table.sort(missing)
    end

    return canMake, missing
end

-- ════════════════════════════════════════
--  WEBHOOK
-- ════════════════════════════════════════

local webhookMessageId = nil -- เก็บ message_id สำหรับ edit

local function SendOrEditWebhook(setResults, itemResults)
    if not NOTIFY_ON_READY then return end
    if WEBHOOK_URL == "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL" then
        warn("[Webhook] ยังไม่ได้ตั้งค่า WEBHOOK_URL!")
        return
    end

    local playerName = game:GetService("Players").LocalPlayer.Name
    local HttpService = game:GetService("HttpService")

    -- สร้าง fields สำหรับแต่ละ set (ใช้ชื่อเต็ม)
    local fields = {}
    for _, r in ipairs(setResults) do
        local value
        if r.count > 0 then
            value = "✅ " .. r.count .. " Set"
        else
            value = "❌ " .. (r.missingStr ~= "" and r.missingStr or "ของไม่ครบ")
        end
        table.insert(fields, {
            name   = r.full,
            value  = value,
            inline = true,
        })
    end

    -- แยก items ออกเป็น field ต่างหาก
    table.insert(fields, {
        name  = "Items",
        value = itemResults,
        inline = false,
    })

    local payload = HttpService:JSONEncode({
        username = "SUNNYBUX",
        embeds = {{
            title  = "Set Checker — " .. playerName,
            color  = 3447003,
            fields = fields,
            footer = { text = "Sailor Piece Tracker" },
        }}
    })

    local ok, result = pcall(function()
        local fn = syn and syn.request or (http and http.request) or request

        if webhookMessageId then
            -- PATCH แก้ข้อความเดิม
            local url = WEBHOOK_URL .. "/messages/" .. webhookMessageId .. "?wait=true"
            return fn({
                Url     = url,
                Method  = "PATCH",
                Headers = { ["Content-Type"] = "application/json" },
                Body    = payload,
            })
        else
            -- POST ครั้งแรก
            local url = WEBHOOK_URL .. "?wait=true"
            return fn({
                Url     = url,
                Method  = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body    = payload,
            })
        end
    end)

    if ok and result then
        -- ดึง message_id จาก response
        local parsed = pcall(function()
            local data = HttpService:JSONDecode(result.Body)
            if data and data.id then
                webhookMessageId = data.id
                log("success", "Webhook message id: " .. webhookMessageId)
            end
        end)
        log("success", "Webhook sent/updated")
    else
        log("error", "Webhook failed: " .. tostring(result))
    end
end

-- ════════════════════════════════════════
--  MAIN LOOP
-- ════════════════════════════════════════

local UPDATE_INTERVAL = 30

while true do
    FetchInventory()
    local itemMap = BuildItemMap()

    local parts = {}
    local setResults = {}

    for _, setDef in ipairs(SET_DEFINITIONS) do
        local count, missing = CheckSet(setDef, itemMap)
        local missingStr = #missing > 0 and table.concat(missing, ", ") or ""

        if count > 0 then
            table.insert(parts, setDef.full .. " : " .. count .. " Set")
        else
            table.insert(parts, setDef.full .. " : ❌ ขาด " .. (missingStr ~= "" and missingStr or "ของไม่ครบ"))
        end

        table.insert(setResults, {
            short      = setDef.short,
            full       = setDef.full,
            count      = count,
            missingStr = missingStr,
        })
    end

    -- แสดงจำนวน item
    local itemParts = {}
    for _, name in ipairs(SHOW_ITEMS) do
        local qty = itemMap[name] or 0
        table.insert(itemParts, name .. " x" .. qty)
    end
    local itemStr = table.concat(itemParts, ", ")

    -- ส่ง webhook ครั้งเดียว (edit ถ้ามี message_id แล้ว)
    SendOrEditWebhook(setResults, itemStr)

    local messages = table.concat(parts, " ┃ ") .. " ┃ " .. itemStr

    _G.Horst_SetDescription(messages)
    log("success", "Updated: " .. messages)

    log("info", "Next update in " .. UPDATE_INTERVAL .. " seconds...")
    task.wait(UPDATE_INTERVAL)
end