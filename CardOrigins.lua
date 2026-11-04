--[[
    ========================================================================
    SuiSuiHUB | Card Origins (ID: 78312396550517)
    Tác giả: dj & VANTA
    Giao diện: inventory.lua (Shared UI Library)
    ========================================================================
]]

repeat task.wait(0.5) until game:IsLoaded()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
repeat task.wait(0.5) until localPlayer and localPlayer:FindFirstChild("PlayerGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- ========================================================================
-- 2. HỆ THỐNG THÔNG BÁO & LOGGING AN TOÀN (SILENT MODE CHỐNG QUÉT F9)
-- ========================================================================
_G.SilentMode = true -- Mặc định BẬT chế độ im lặng, không in log ra F9 để bảo vệ tài khoản an toàn tuyệt đối

local function safeLog(...)
    if not _G.SilentMode then
        pcall(print, ...)
    end
end

local function safeWarn(...)
    if not _G.SilentMode then
        pcall(warn, ...)
    end
end

local function Notification(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title or "SuiSuiHUB - Card Origins"),
            Text = tostring(text or ""),
            Duration = tonumber(duration or 4)
        })
    end)
    safeLog(string.format("[SuiSuiHUB] [%s] %s", tostring(title or "INFO"), tostring(text or "")))
end
_G.Notification = Notification

-- ========================================================================
-- 1. LOAD SHARED UI LIBRARY (inventory.lua)
-- ========================================================================
local library
local function loadLibrary()
    -- 1. Load trực tiếp từ GitHub chính thức của SuiSuiHUB (Cộng đồng load tức thì 0s)
    pcall(function()
        library = loadstring(game:HttpGet("https://raw.githubusercontent.com/suisuimommy-code/SuiSuiHUB/main/inventory.lua"))()
    end)
    -- 2. Link dự phòng nếu GitHub chính bị chặn hoặc timeout
    if not library then
        pcall(function()
            library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FZ8nj2VdyKq/inventory/main/ADS%20inventory.lua"))()
        end)
    end
    -- 3. Đọc từ local workspace nếu executor có sẵn file
    if not library and isfile and readfile and isfile("inventory.lua") then
        pcall(function()
            library = loadstring(readfile("inventory.lua"))()
        end)
    end
    -- 4. Fallback server test local (Port 8000 - chỉ dành cho dev)
    if not library then
        pcall(function()
            library = loadstring(game:HttpGet("http://127.0.0.1:8000/inventory.lua"))()
        end)
    end
    return library
end

library = loadLibrary()
if not library then
    safeWarn("[SuiSuiHUB] Khong the tai inventory.lua! Vui long kiem tra lai ket noi hoac start_local_test.bat.")
    return
end

-- ========================================================================
-- 3. CẤU HÌNH REMOTE SĂN BOSS & TELEPORT MAP
-- ========================================================================
local eventRemotes = ReplicatedStorage:WaitForChild("EventRemotes", 5)
local reportVictoryRemote = eventRemotes and eventRemotes:FindFirstChild("ReportBossVictory") or ReplicatedStorage:FindFirstChild("ReportBossVictory", true)
local getCooldownRemote = eventRemotes and eventRemotes:FindFirstChild("GetBossCooldown") or ReplicatedStorage:FindFirstChild("GetBossCooldown", true)
local buildMiniBossRemote = eventRemotes and eventRemotes:FindFirstChild("BuildMiniBossBattle") or ReplicatedStorage:FindFirstChild("BuildMiniBossBattle", true)
local skinsRemote = ReplicatedStorage:FindFirstChild("SkinsRemote", true)
local worldsTeleportRemote = ReplicatedStorage:FindFirstChild("WorldsTeleportRequest", true)
local wheelRemote = ReplicatedStorage:FindFirstChild("WheelRemote", true)
local getQuestsRemote = ReplicatedStorage:FindFirstChild("GetQuests", true)

-- Remotes chuẩn xác cho RiftGATE (Bắt trực tiếp từ Server Card Origins)
local riftGateEnterRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateEnterRequest") or ReplicatedStorage:FindFirstChild("RiftGateEnterRequest", true)
local buildRiftBattleRemote = eventRemotes and eventRemotes:FindFirstChild("BuildRiftGateBattle") or ReplicatedStorage:FindFirstChild("BuildRiftGateBattle", true)
local riftStartFightRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateStartFight") or ReplicatedStorage:FindFirstChild("RiftGateStartFight", true)
local reportRiftVictoryRemote = eventRemotes and eventRemotes:FindFirstChild("ReportRiftGateVictory") or ReplicatedStorage:FindFirstChild("ReportRiftGateVictory", true)
local riftRewardRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateReward") or ReplicatedStorage:FindFirstChild("RiftGateReward", true)
local riftGateLeaveRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateLeave") or ReplicatedStorage:FindFirstChild("RiftGateLeave", true)
local riftGateSpawnedRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateSpawned") or ReplicatedStorage:FindFirstChild("RiftGateSpawned", true)
local riftGateClosedRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateClosed") or ReplicatedStorage:FindFirstChild("RiftGateClosed", true)

local isServerRiftGateOpen = false
if riftGateSpawnedRemote and riftGateSpawnedRemote.OnClientEvent then
    pcall(function()
        riftGateSpawnedRemote.OnClientEvent:Connect(function(...)
            isServerRiftGateOpen = true
            safeLog("[SuiSuiHUB] Nhận tín hiệu Server: Cổng RiftGate vừa mở (RiftGateSpawned)!")
            Notification("RiftGATE", "CỔNG RIFTGATE VỪA MỞ TRÊN MAP!", 5)
        end)
    end)
end
if riftGateClosedRemote and riftGateClosedRemote.OnClientEvent then
    pcall(function()
        riftGateClosedRemote.OnClientEvent:Connect(function(...)
            isServerRiftGateOpen = false
            safeLog("[SuiSuiHUB] Nhận tín hiệu Server: Cổng RiftGate đã đóng (RiftGateClosed)!")
        end)
    end)
end

-- Helper: Kích hoạt nút GUI bằng giả lập click (Firesignal / VirtualClick)
local function triggerGuiButton(btn)
    if not btn then return false end
    if firesignal and (btn:IsA("GuiButton") or btn:IsA("ImageButton") or btn:IsA("TextButton")) then
        pcall(function() firesignal(btn.MouseButton1Click) end)
        pcall(function() firesignal(btn.Activated) end)
        return true
    elseif btn.MouseButton1Click then
        pcall(function()
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in ipairs(getconnections(btn.Activated)) do
                conn:Fire()
            end
        end)
        return true
    end
    return false
end

-- ========================================================================
-- 4. BIẾN TRẠNG THÁI TOÀN CỤC (GLOBAL FLAGS)
-- ========================================================================
-- Boss Farm States
local GAME_WORLDS = {
    ["01: LOBBY (Main Hub)"] = {
        mapId = "lobby",
        miniBosses = {},
        mainBoss = nil
    },
    ["02: DUNGEON (Solo Leveling)"] = {
        mapId = "sjwmap",
        miniBosses = {
            { id = "chahaein", name = "Cha Hae-In (Dancer of Light)" },
            { id = "guildmaster", name = "Guild Master" }
        },
        mainBoss = {
            id = "queen",
            name = "The Shadow Monarch",
            difficulties = { "Normal", "Calamity", "Umbral", "Astral", "Paradox", "Origin", "Gold" }
        }
    },
    ["03: ENDLESS CASTLE (Vô Hạn)"] = {
        mapId = "infcastle",
        miniBosses = {},
        mainBoss = nil
    },
    ["04: LIMITLESS DOMAIN (Jujutsu Kaisen)"] = {
        mapId = "gojodomainv2",
        miniBosses = {
            { id = "sukuna", name = "Ryomen Sukuna" },
            { id = "yuta", name = "Yuta Okkotsu" }
        },
        mainBoss = {
            id = "gojo",
            name = "Limitless Sorcerer (Gojo)",
            difficulties = { "Normal", "Calamity", "Umbral", "Astral", "Paradox", "Origin", "Gold" }
        }
    },
    ["05: DEVIL HEART (Date A Live)"] = {
        mapId = "kurumimapspawn",
        miniBosses = {
            { id = "yuno", name = "Yuno Gasai" },
            { id = "swordempress", name = "Sword Empress" }
        },
        mainBoss = {
            id = "kurumi",
            name = "Clockmaiden (Kurumi)",
            difficulties = { "Normal", "Calamity", "Umbral", "Astral", "Paradox", "Origin", "Gold" }
        }
    },
    ["06: THE MYSTERIOUS LIBRARY (Klein)"] = {
        mapId = "kleinspawn",
        miniBosses = {},
        mainBoss = nil
    }
}

local MapOptions = {
    "01: LOBBY (Main Hub)",
    "02: DUNGEON (Solo Leveling)",
    "03: ENDLESS CASTLE (Vô Hạn)",
    "04: LIMITLESS DOMAIN (Jujutsu Kaisen)",
    "05: DEVIL HEART (Date A Live)",
    "06: THE MYSTERIOUS LIBRARY (Klein)"
}

_G.SelectedMap = _G.SelectedMap or "02: DUNGEON (Solo Leveling)"
_G.AutoMiniBoss = _G.AutoMiniBoss or false
_G.SelectedMiniBosses = _G.SelectedMiniBosses or {"chahaein", "guildmaster"}
_G.AutoMainBoss = _G.AutoMainBoss or false
_G.SelectedMainBosses = _G.SelectedMainBosses or {"The Shadow Monarch (queen)"}
_G.SelectedMainDifficulty = _G.SelectedMainDifficulty or "02: CALAMITY (Gold)"
_G.BossDelay = _G.BossDelay or 0.5

-- Cấu hình RiftGATE (Chu kỳ 15 phút: 00, 15, 30, 45)
_G.AutoRiftGate = _G.AutoRiftGate or false
_G.RiftNotify = (_G.RiftNotify == nil) and true or _G.RiftNotify
_G.PriorityMode = _G.PriorityMode or "RiftGate > Boss Chính > Boss Mini (Mặc Định)"

-- Cấu hình SIEGE
_G.AutoSiege = _G.AutoSiege or false
_G.SiegeMode = _G.SiegeMode or "Tự Động Tăng Stage (Auto Next)"
_G.SiegeStage = _G.SiegeStage or 1
_G.SiegeStopStage = _G.SiegeStopStage or 20
_G.SiegeCurrentStage = _G.SiegeCurrentStage or 1
_G.SiegeDelay = _G.SiegeDelay or 1.0

_G.AntiAFK = _G.AntiAFK or true
_G.WhiteScreen = _G.WhiteScreen or false
_G.FPSBoost = _G.FPSBoost or false

_G.AutoSpinWheel = _G.AutoSpinWheel or false
_G.SpinAmount = _G.SpinAmount or 11
_G.SpinDelay = _G.SpinDelay or 1.0

_G.AutoGetQuests = _G.AutoGetQuests or false
_G.QuestDelay = _G.QuestDelay or 10

_G.SelectedNpcTeleport = _G.SelectedNpcTeleport or "trait system npc"

-- ========================================================================
-- 4. HỆ THỐNG LƯU / TẢI CẤU HÌNH TỰ ĐỘNG (PERSISTENT CONFIG SYSTEM)
-- ========================================================================
local CONFIG_FILE_NAME = "!SuiSuiHUB/CardOrigins_Config.json"

local function saveConfig()
    pcall(function()
        if not writefile then return end
        if isfolder and makefolder and not isfolder("!SuiSuiHUB") then
            makefolder("!SuiSuiHUB")
        end
        local cfg = {
            SelectedMap = _G.SelectedMap,
            SelectedMiniBosses = _G.SelectedMiniBosses,
            AutoMiniBoss = _G.AutoMiniBoss,
            SelectedMainBosses = _G.SelectedMainBosses,
            SelectedMainDifficulty = _G.SelectedMainDifficulty,
            BossDelay = _G.BossDelay,
            AutoMainBoss = _G.AutoMainBoss,
            
            -- Siege
            AutoSiege = _G.AutoSiege,
            SiegeMode = _G.SiegeMode,
            SiegeStage = _G.SiegeStage,
            SiegeStopStage = _G.SiegeStopStage,
            SiegeCurrentStage = _G.SiegeCurrentStage,
            SiegeDelay = _G.SiegeDelay,
            
            -- Utilities
            SpinAmount = _G.SpinAmount,
            SpinDelay = _G.SpinDelay,
            AutoSpinWheel = _G.AutoSpinWheel,
            AutoGetQuests = _G.AutoGetQuests,
            QuestDelay = _G.QuestDelay,
            SelectedNpcTeleport = _G.SelectedNpcTeleport,
            
            -- RiftGATE & Priority
            AutoRiftGate = _G.AutoRiftGate,
            RiftNotify = _G.RiftNotify,
            PriorityMode = _G.PriorityMode,
            
            -- Settings
            SilentMode = _G.SilentMode,
            AntiAFK = _G.AntiAFK,
            WhiteScreen = _G.WhiteScreen,
            FPSBoost = _G.FPSBoost,
            WalkSpeedEnabled = _G.WalkSpeedEnabled,
            WalkSpeedValue = _G.WalkSpeedValue
        }
        writefile(CONFIG_FILE_NAME, HttpService:JSONEncode(cfg))
    end)
end

local function loadConfig()
    pcall(function()
        if not isfile or not readfile then return end
        if isfile(CONFIG_FILE_NAME) then
            local raw = readfile(CONFIG_FILE_NAME)
            local data = HttpService:JSONDecode(raw)
            if data and typeof(data) == "table" then
                if data.SelectedMap ~= nil then _G.SelectedMap = data.SelectedMap end
                if data.SelectedMiniBosses ~= nil then _G.SelectedMiniBosses = data.SelectedMiniBosses end
                if data.AutoMiniBoss ~= nil then _G.AutoMiniBoss = data.AutoMiniBoss end
                if data.SelectedMainBosses ~= nil then _G.SelectedMainBosses = data.SelectedMainBosses end
                if data.SelectedMainDifficulty ~= nil then _G.SelectedMainDifficulty = data.SelectedMainDifficulty end
                if data.BossDelay ~= nil then _G.BossDelay = data.BossDelay end
                if data.AutoMainBoss ~= nil then _G.AutoMainBoss = data.AutoMainBoss end
                
                if data.AutoSiege ~= nil then _G.AutoSiege = data.AutoSiege end
                if data.SiegeMode ~= nil then _G.SiegeMode = data.SiegeMode end
                if data.SiegeStopStage ~= nil then
                    _G.SiegeStopStage = data.SiegeStopStage
                elseif data.SiegeStage ~= nil then
                    _G.SiegeStopStage = data.SiegeStage
                end
                if data.SiegeCurrentStage ~= nil then _G.SiegeCurrentStage = data.SiegeCurrentStage end
                if data.SiegeDelay ~= nil then _G.SiegeDelay = data.SiegeDelay end
                
                if data.SpinAmount ~= nil then _G.SpinAmount = data.SpinAmount end
                if data.SpinDelay ~= nil then _G.SpinDelay = data.SpinDelay end
                if data.AutoSpinWheel ~= nil then _G.AutoSpinWheel = data.AutoSpinWheel end
                if data.AutoGetQuests ~= nil then _G.AutoGetQuests = data.AutoGetQuests end
                if data.QuestDelay ~= nil then _G.QuestDelay = data.QuestDelay end
                if data.SelectedNpcTeleport ~= nil then _G.SelectedNpcTeleport = data.SelectedNpcTeleport end
                
                if data.AutoRiftGate ~= nil then _G.AutoRiftGate = data.AutoRiftGate end
                if data.RiftNotify ~= nil then _G.RiftNotify = data.RiftNotify end
                if data.PriorityMode ~= nil then _G.PriorityMode = data.PriorityMode end
                
                if data.SilentMode ~= nil then _G.SilentMode = data.SilentMode end
                if data.AntiAFK ~= nil then _G.AntiAFK = data.AntiAFK end
                if data.WhiteScreen ~= nil then _G.WhiteScreen = data.WhiteScreen end
                if data.FPSBoost ~= nil then _G.FPSBoost = data.FPSBoost end
                if data.WalkSpeedEnabled ~= nil then _G.WalkSpeedEnabled = data.WalkSpeedEnabled end
                if data.WalkSpeedValue ~= nil then _G.WalkSpeedValue = data.WalkSpeedValue end
            end
        end
    end)
end

-- Tự động nạp cấu hình đã lưu ngay khi khởi động
loadConfig()

-- ========================================================================
-- 5. CÁC HÀM THỰC THI (CORE LOGIC)
-- ========================================================================

-- Khôi phục và đảm bảo nhân vật di chuyển bình thường khi tải script
pcall(function()
    if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = 16
        hum.PlatformStand = false
    end
end)

-- A. Chống văng AFK (Anti-AFK an toàn, không chiếm quyền điều khiển nhân vật)
task.spawn(function()
    localPlayer.Idled:Connect(function()
        if _G.AntiAFK then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    end)
end)

-- H. Các hàm hỗ trợ Săn Boss & Teleport
local mainBossModelCache = {}
local miniBossModelCache = {}

local function findMiniBossModel(bossId)
    local target = (bossId or ""):lower():gsub("%s+", "")
    if target == "" then return nil end

    local cached = miniBossModelCache[target]
    if cached and cached.Parent then return cached end

    local function matchMiniModel(model)
        if not model or not model:IsA("Model") then return nil end
        local attrId = model:GetAttribute("MiniBossId") or model:GetAttribute("BossId")
        if attrId and tostring(attrId):lower():gsub("%s+", "") == target then
            miniBossModelCache[target] = model
            return model
        end
        local objName = model.Name:lower():gsub("%s+", "")
        if (target == "guildmaster" and objName:find("guild"))
            or (target == "chahaein" and (objName:find("dancer") or objName:find("chahaein")))
            or (objName:find(target)) then
            miniBossModelCache[target] = model
            return model
        end
        return nil
    end

    local containers = {
        workspace:FindFirstChild("NPCs"),
        workspace:FindFirstChild("Bosses"),
        workspace:FindFirstChild("Boss"),
        workspace:FindFirstChild("Live"),
        workspace:FindFirstChild("Characters")
    }

    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                local m = matchMiniModel(item)
                if m then return m end
            end
        end
    end

    for _, item in ipairs(workspace:GetChildren()) do
        if item:IsA("Model") and not item:IsA("Workspace") then
            local m = matchMiniModel(item)
            if m then return m end
        end
    end

    return nil
end

-- Tự động quét tất cả Mini Boss thực tế đang có trong Workspace trên Map hiện tại (Quét siêu tốc 0% lag)
local function scanCurrentMapMiniBosses()
    local detected = {}
    local seen = {}
    local function checkModel(obj)
        if obj and obj:IsA("Model") then
            local attrId = obj:GetAttribute("MiniBossId") or obj:GetAttribute("BossId")
            if attrId then
                local bId = tostring(attrId)
                if not seen[bId] then
                    seen[bId] = true
                    table.insert(detected, bId)
                end
            elseif obj.Name:lower():find("mini boss") or obj.Name:lower():find("miniboss") then
                local rawName = obj.Name:lower():gsub(" mini boss", ""):gsub("miniboss", ""):gsub("%s+", "")
                if #rawName > 0 and not seen[rawName] then
                    seen[rawName] = true
                    table.insert(detected, rawName)
                end
            end
        end
    end

    local containers = {
        workspace:FindFirstChild("NPCs"),
        workspace:FindFirstChild("Bosses"),
        workspace:FindFirstChild("Boss"),
        workspace:FindFirstChild("Live")
    }
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                checkModel(item)
            end
        end
    end
    for _, item in ipairs(workspace:GetChildren()) do
        if item:IsA("Model") then
            checkModel(item)
        end
    end
    return detected
end

-- Tự động quét toàn bộ Trùm Cuối & Mini Boss từ bộ nhớ (GC) và ReplicatedStorage
local function scanAllBossesFromMemory()
    local allFound = {}

    -- 1. Quét Garbage Collector của executor
    if getgc then
        for _, t in ipairs(getgc(true)) do
            if typeof(t) == "table" then
                local isBossTable = rawget(t, "chahaein") or rawget(t, "queen") or rawget(t, "yuta") or rawget(t, "guildmaster")
                if isBossTable then
                    for k, _ in pairs(t) do
                        if typeof(k) == "string" and #k >= 3 and not k:find("^__") then
                            allFound[k] = true
                        end
                    end
                end
            end
        end
    end

    -- 2. Quét ReplicatedStorage ModuleScripts
    for _, mod in ipairs(ReplicatedStorage:GetDescendants()) do
        if mod:IsA("ModuleScript") then
            local ok, res = pcall(require, mod)
            if ok and typeof(res) == "table" then
                local json = ""
                pcall(function() json = HttpService:JSONEncode(res) end)
                if json:lower():find("queen") or json:lower():find("chahaein") or json:lower():find("yuta") then
                    for k, _ in pairs(res) do
                        if typeof(k) == "string" and #k >= 3 and not k:find("^__") then
                            allFound[k] = true
                        end
                    end
                end
            end
        end
    end

    local list = {}
    for bName, _ in pairs(allFound) do
        table.insert(list, bName)
    end
    table.sort(list)
    return list
end

local function teleportToMiniBoss(bossId)
    local model = findMiniBossModel(bossId)
    if model and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local cf = model:GetPivot()
        localPlayer.Character.HumanoidRootPart.CFrame = cf * CFrame.new(0, 0, 4)
        Notification("Teleport", "Đã bay tới Boss: " .. tostring(bossId), 2)
        return true
    end
    Notification("Teleport", "Chưa tìm thấy model của Boss trên Map hiện tại!", 3)
    return false
end

-- Bảng ánh xạ độ khó hiển thị trên UI sang giá trị thực tế của Server
local DIFFICULTY_ALIAS_TO_INTERNAL = {
    ["01: NORMAL (Normal)"]    = "Normal",
    ["02: CALAMITY (Gold)"]    = "Gold",
    ["03: UMBRAL (Rainbow)"]   = "Rainbow",
    ["04: ASTRAL"]             = "Astral",
    ["05: PARADOX"]            = "Paradox",
    ["06: ORIGIN"]             = "Origin",
    -- Fallbacks
    ["Normal"]                 = "Normal",
    ["Calamity"]               = "Gold",
    ["Gold"]                   = "Gold",
    ["Umbral"]                 = "Rainbow",
    ["Rainbow"]                = "Rainbow",
    ["Astral"]                 = "Astral",
    ["Paradox"]                = "Paradox",
    ["Origin"]                 = "Origin",
}

local function resolveDifficulty(diff)
    return DIFFICULTY_ALIAS_TO_INTERNAL[diff] or diff or "Normal"
end

local ALL_MINI_BOSS_LIST = {
    "chahaein",
    "guildmaster",
    "sukuna",
    "yuta",
    "yuno",
    "swordempress"
}

local ALL_MAIN_BOSS_LIST = {
    "The Shadow Monarch (queen)",
    "Limitless Sorcerer (gojo)",
    "Clockmaiden (kurumi)",
    "Endless Castle Boss (castleboss)"
}

local function resolveMainBossId(title)
    if not title then return "queen" end
    local extracted = title:match("%((.-)%)")
    if extracted and #extracted > 0 then
        return extracted:lower():gsub("%s+", "")
    end
    local map = {
        ["queen"] = "queen",
        ["gojo"] = "gojo",
        ["kurumi"] = "kurumi",
        ["castleboss"] = "castleboss"
    }
    for k, v in pairs(map) do
        if title:lower():find(k) then
            return v
        end
    end
    return title:lower():gsub("%s+", "")
end

local BOSS_TO_MAP_ID = {
    ["queen"] = "sjwmap",
    ["gojo"] = "gojodomainv2",
    ["kurumi"] = "kurumimapspawn",
    ["castleboss"] = "infcastle"
}

local function getMainBossMapId(bossId)
    local b = (bossId or ""):lower():gsub("%s+", "")
    return BOSS_TO_MAP_ID[b] or "sjwmap"
end

local function isSuiSuiHubElement(desc)
    if not desc then return false end
    if getgenv and getgenv().uilib and (desc == getgenv().uilib or desc:IsDescendantOf(getgenv().uilib)) then
        return true
    end
    local root = desc:FindFirstAncestorOfClass("ScreenGui")
    if root then
        local rName = tostring(root.Name)
        if rName:find("SuiSuiHUB") or rName == "StatBySmell" or rName == "Watermark" then
            return true
        end
    end
    return false
end

local function parseTimeStringToSeconds(str)
    if not str then return 0 end
    local min, sec = str:match("(%d+):(%d+)")
    if min and sec then
        return (tonumber(min) or 0) * 60 + (tonumber(sec) or 0)
    end
    local secOnly = str:match("(%d+)%s*s")
    if secOnly then
        return tonumber(secOnly) or 0
    end
    local num = str:match("%d+")
    if num then
        return tonumber(num) or 0
    end
    return 0
end

-- ĐỊNH VỊ CHÍNH XÁC 100% THEO CẤU TRÚC THỰC TẾ TRONG GAME (GojoBossGui, SjwBossGui, KurumiBossGui, EydisBossGui)
-- Path chuẩn: [BossGui].BossOverlay.Root.Panel.Frame.Hit (TextButton thực tế của game)
-- Path nhãn: [BossGui].BossOverlay.Root.Panel.Frame.Lift.Label (TextLabel: "FIGHT" hoặc "BACK IN M:SS")

local function getActiveBossScreenGui()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local gName = gui.Name
            if gName:find("BossGui") or gName:find("WorldBossGui") or gName:find("Boss") then
                local overlay = gui:FindFirstChild("BossOverlay")
                if overlay and overlay.Visible ~= false then
                    return gui
                end
            end
        end
    end
    return nil
end

-- Tìm nút FIGHT (TextButton "Hit") chính xác 100%
local function findFightButton()
    local bossGui = getActiveBossScreenGui()
    if not bossGui then return nil end

    local bossOverlay = bossGui:FindFirstChild("BossOverlay")
    if not bossOverlay then return nil end
    local root = bossOverlay:FindFirstChild("Root")
    local panel = root and root:FindFirstChild("Panel")
    if not panel then return nil end

    local frame = panel:FindFirstChild("Frame")
    if not frame then return nil end

    -- 1. Kiểm tra nếu nút đang hiển thị Cooldown ("BACK IN M:SS")
    local lift = frame:FindFirstChild("Lift")
    local label = lift and lift:FindFirstChild("Label")
    if label and label:IsA("TextLabel") then
        local txt = (label.Text or ""):lower()
        if txt:find("back%s*in") then
            return nil, "cooldown"
        end
    end

    -- 2. Nút bấm thực tế của game là TextButton "Hit" tại Panel.Frame.Hit
    local hitBtn = frame:FindFirstChild("Hit")
    if hitBtn and hitBtn:IsA("GuiButton") then
        return hitBtn
    end

    -- 3. Ưu tiên fallback: Tìm Frame.Hit nếu có cấu trúc biến thể
    for _, child in ipairs(panel:GetChildren()) do
        if child.Name == "Frame" then
            local hit = child:FindFirstChild("Hit")
            if hit and hit:IsA("GuiButton") then return hit end
        end
    end

    return nil
end

-- Đọc thời gian Cooldown từ Label của nút hoặc TextLabel trên Panel
local function getGuiBossCooldownSeconds()
    local bossGui = getActiveBossScreenGui()
    if not bossGui then return 0 end

    local bossOverlay = bossGui:FindFirstChild("BossOverlay")
    if bossOverlay then
        local root = bossOverlay:FindFirstChild("Root")
        local panel = root and root:FindFirstChild("Panel")
        if panel then
            -- 1. Đọc từ Frame.Lift.Label (nơi hiển thị "BACK IN 1:55")
            local frame = panel:FindFirstChild("Frame")
            local lift = frame and frame:FindFirstChild("Lift")
            local label = lift and lift:FindFirstChild("Label")
            if label and label:IsA("TextLabel") then
                local txt = (label.Text or ""):lower()
                if txt:find("back%s*in") then
                    local s = parseTimeStringToSeconds(txt)
                    if s > 0 then return s end
                end
            end
            -- 2. Đọc từ Panel.Left.TextLabel (nơi hiển thị "ON COOLDOWN • 1:55")
            local left = panel:FindFirstChild("Left")
            if left then
                for _, lbl in ipairs(left:GetChildren()) do
                    if lbl:IsA("TextLabel") and lbl.Text:lower():find("cooldown") then
                        local s = parseTimeStringToSeconds(lbl.Text)
                        if s > 0 then return s end
                    end
                end
            end
        end
    end

    return 0
end

local BOSS_COOLDOWN_DURATION = 150 -- 2 phút 30 giây (150s) theo chuẩn cơ chế của game
local lastDefeatedBossTime = {}
local remoteCooldownCache = {}
local lastRemoteCallTime = {}

local function checkMainBossCooldown(bossId, diff)
    if not bossId then return 0 end
    diff = resolveDifficulty(diff)
    local cacheKey = tostring(bossId) .. "_" .. tostring(diff)
    local now = os.time()

    local remoteCooldown = 0

    -- Giảm tần suất gọi InvokeServer qua mạng: Tối đa 1 lần mỗi 3.0s cho mỗi Boss (Tránh lag mạng với Ping cao)
    local lastCall = lastRemoteCallTime[cacheKey] or 0
    if (now - lastCall) < 3.0 and remoteCooldownCache[cacheKey] ~= nil then
        local elapsed = now - lastCall
        remoteCooldown = math.max(0, remoteCooldownCache[cacheKey] - elapsed)
    else
        if not getCooldownRemote then
            getCooldownRemote = eventRemotes and eventRemotes:FindFirstChild("GetBossCooldown") or ReplicatedStorage:FindFirstChild("GetBossCooldown", true)
        end

        if getCooldownRemote then
            local ok, cd = pcall(function()
                return getCooldownRemote:InvokeServer(bossId, diff)
            end)
            lastRemoteCallTime[cacheKey] = now
            if ok and cd then
                if typeof(cd) == "number" then
                    if cd > 1000000000 then
                        remoteCooldown = math.max(0, math.floor(cd - now))
                    else
                        remoteCooldown = math.max(0, math.floor(cd))
                    end
                elseif typeof(cd) == "table" then
                    local num = cd.Cooldown or cd.Remaining or cd.Time or cd[1]
                    if typeof(num) == "number" then
                        if num > 1000000000 then
                            remoteCooldown = math.max(0, math.floor(num - now))
                        else
                            remoteCooldown = math.max(0, math.floor(num))
                        end
                    end
                elseif typeof(cd) == "string" then
                    remoteCooldown = parseTimeStringToSeconds(cd)
                end
                remoteCooldownCache[cacheKey] = remoteCooldown
            elseif remoteCooldownCache[cacheKey] then
                remoteCooldown = math.max(0, remoteCooldownCache[cacheKey] - (now - lastCall))
            end
        end
    end

    -- Bộ đếm nội bộ dự phòng 150s (2m30s) chống trễ server ngay sau khi vừa đấm xong boss
    local localFallback = 0
    if lastDefeatedBossTime[bossId] then
        local elapsed = now - lastDefeatedBossTime[bossId]
        if elapsed < BOSS_COOLDOWN_DURATION then
            localFallback = BOSS_COOLDOWN_DURATION - elapsed
        else
            lastDefeatedBossTime[bossId] = nil
        end
    end

    -- Sử dụng trực tiếp Cooldown từ Server (Remote là nguồn tin cậy tuyệt đối, không bị kẹt bởi chữ trên GUI đóng)
    return math.max(remoteCooldown, localFallback)
end
local checkBossCooldown = checkMainBossCooldown

-- ========================================================================
-- HỆ THỐNG ĐIỀU PHỐI ĐỘ ƯU TIÊN (PRIORITY ENGINE)
-- MẶC ĐỊNH: [1] RiftGate -> [2] Boss Chính -> [3] Boss Mini
-- ========================================================================
local isRiftGateFighting = false
local isRiftGatePending = false
local isMainBossFighting = false
local isMiniBossBusy = false
local bossUnreachableUntil = {}

local function shouldYieldToRiftGate()
    local mode = _G.PriorityMode or "RiftGate > Boss Chính > Boss Mini (Mặc Định)"
    if mode:find("Tự Do") then return false end
    
    if mode:find("RiftGate >") then
        return (isRiftGateFighting or isRiftGatePending or isServerRiftGateOpen) and _G.AutoRiftGate
    end
    return false
end

local function shouldYieldToMainBoss()
    local mode = _G.PriorityMode or "RiftGate > Boss Chính > Boss Mini (Mặc Định)"
    if mode:find("Tự Do") then return false end
    
    return isMainBossFighting
end

local currentLoadedMapId = nil

local function detectCurrentMapId()
    -- 1. Quét nhanh theo Model hiện có trong workspace (Ground Truth 100%)
    if findMainBossModel("queen") or findMiniBossModel("chahaein") or findMiniBossModel("guildmaster") then
        currentLoadedMapId = "sjwmap"
        return "sjwmap", "queen"
    elseif findMainBossModel("gojo") or findMiniBossModel("sukuna") or findMiniBossModel("yuta") then
        currentLoadedMapId = "gojodomainv2"
        return "gojodomainv2", "gojo"
    elseif findMainBossModel("kurumi") or findMiniBossModel("yuno") or findMiniBossModel("kurumi_mini") then
        currentLoadedMapId = "kurumimapspawn"
        return "kurumimapspawn", "kurumi"
    elseif findMainBossModel("castleboss") then
        currentLoadedMapId = "infcastle"
        return "infcastle", "castleboss"
    end

    -- 2. Nếu đã từng tele tới map nào đó và đang chờ load asset
    if currentLoadedMapId and currentLoadedMapId ~= "lobby" then
        return currentLoadedMapId, nil
    end

    -- 3. Mặc định: Người chơi đang ở Lobby / Sảnh chính (KHÔNG ĐƯỢC giả định là sjwmap)
    return "lobby", nil
end

local function findReadyBossOrSmallestCd(selectedList, diff)
    if not selectedList or #selectedList == 0 then return nil, 0, nil end
    diff = resolveDifficulty(diff)
    local curMapId, curBossId = detectCurrentMapId()
    local now = os.time()

    -- 1. ƯU TIÊN SỐ 1: Boss trong Map hiện tại nếu đang SẴN SÀNG (cd <= 0)
    if curBossId then
        for _, bTitle in ipairs(selectedList) do
            local bId = resolveMainBossId(bTitle)
            if bId == curBossId then
                local cd = checkMainBossCooldown(bId, diff)
                if cd <= 0 then
                    return bId, 0, curMapId
                end
            end
        end
    end

    -- 2. ƯU TIÊN SỐ 2: Nếu Boss map này đang hồi chiêu, kiểm tra các Boss KHÁC trong danh sách có sẵn sàng không
    for _, bTitle in ipairs(selectedList) do
        local bId = resolveMainBossId(bTitle)
        local unreach = bossUnreachableUntil[bId] or 0
        if now >= unreach then
            local bMap = getMainBossMapId(bId)
            local cd = checkMainBossCooldown(bId, diff)
            if cd <= 0 then
                return bId, 0, bMap
            end
        end
    end

    -- 3. Nếu TẤT CẢ các Boss đều đang Cooldown: Tìm Boss có thời gian hồi chiêu ngắn nhất
    local lowestCd = math.huge
    local lowestBoss = nil
    local lowestMap = nil

    for _, bTitle in ipairs(selectedList) do
        local bId = resolveMainBossId(bTitle)
        local unreach = bossUnreachableUntil[bId] or 0
        if now >= unreach then
            local bMap = getMainBossMapId(bId)
            local cd = checkMainBossCooldown(bId, diff)
            if cd < lowestCd then
                lowestCd = cd
                lowestBoss = bId
                lowestMap = bMap
            end
        end
    end

    if not lowestBoss and #selectedList > 0 then
        local bId = resolveMainBossId(selectedList[1])
        return bId, checkMainBossCooldown(bId, diff), getMainBossMapId(bId)
    end

    return lowestBoss, (lowestCd == math.huge and 0 or lowestCd), lowestMap
end

-- Tự động click chọn thẻ độ khó trong Panel.Left.Frame (Normal, Gold, Rainbow, Astral, Paradox, Origin)
local function selectGameBossDifficulty(diffName)
    local bossGui = getActiveBossScreenGui()
    if not bossGui or not diffName then return false end

    local diffRaw = resolveDifficulty(diffName) -- "Normal", "Gold", "Rainbow", etc.
    local diffKey = diffRaw:lower():gsub("%s+", "")

    local bossOverlay = bossGui:FindFirstChild("BossOverlay")
    local root = bossOverlay and bossOverlay:FindFirstChild("Root")
    local panel = root and root:FindFirstChild("Panel")
    local left = panel and panel:FindFirstChild("Left")
    local leftFrame = left and left:FindFirstChild("Frame")

    if leftFrame then
        for _, btn in ipairs(leftFrame:GetChildren()) do
            if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                local bName = btn.Name:lower():gsub("%s+", "")
                if bName == diffKey or (diffKey == "normal" and bName == "normal")
                    or (diffKey == "gold" and (bName == "gold" or bName == "calamity"))
                    or (diffKey == "rainbow" and (bName == "rainbow" or bName == "umbral"))
                    or (bName:find(diffKey)) then
                    pcall(function()
                        if firesignal then
                            firesignal(btn.MouseButton1Click)
                            firesignal(btn.Activated)
                        end
                    end)
                    task.wait(0.08)
                    return true
                end
            end
        end
    end

    return false
end

local function clickGuiElement(btn)
    if not btn then return false end
    local actualBtn = btn
    if not actualBtn:IsA("GuiButton") then
        actualBtn = btn:FindFirstAncestorWhichIsA("GuiButton") or (btn.Parent and btn.Parent:FindFirstChildWhichIsA("GuiButton")) or btn
    end

    local clicked = false

    -- 1. firesignal (Kích hoạt trực tiếp sự kiện Click/Activated của nút)
    if firesignal then
        pcall(function() firesignal(actualBtn.MouseButton1Click) end)
        pcall(function() firesignal(actualBtn.Activated) end)
        if actualBtn ~= btn then
            pcall(function() firesignal(btn.MouseButton1Click) end)
            pcall(function() firesignal(btn.Activated) end)
        end
        clicked = true
    end

    -- 2. getconnections (Kích hoạt toàn bộ listener gắn vào nút)
    if getconnections then
        pcall(function()
            if actualBtn.MouseButton1Click then
                for _, conn in ipairs(getconnections(actualBtn.MouseButton1Click)) do
                    pcall(function() conn:Fire() end)
                    clicked = true
                end
            end
            if actualBtn.Activated then
                for _, conn in ipairs(getconnections(actualBtn.Activated)) do
                    pcall(function() conn:Fire() end)
                    clicked = true
                end
            end
        end)
    end

    -- 3. VirtualInputManager (Click vật lý chuẩn xác 1 lần duy nhất có bù trừ Topbar Inset)
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local targetObj = (actualBtn.AbsolutePosition and actualBtn.AbsoluteSize) and actualBtn or btn
        if vim and targetObj.AbsolutePosition and targetObj.AbsoluteSize then
            local centerX = targetObj.AbsolutePosition.X + (targetObj.AbsoluteSize.X / 2)
            local centerY = targetObj.AbsolutePosition.Y + (targetObj.AbsoluteSize.Y / 2)
            
            local gs = game:GetService("GuiService")
            local inset = gs and gs:GetGuiInset() or Vector2.new(0, 0)
            local x1 = centerX + inset.X
            local y1 = centerY + inset.Y
            if x1 > 0 and y1 > 0 then
                vim:SendMouseButtonEvent(x1, y1, 0, true, game, 0)
                task.wait(0.04)
                vim:SendMouseButtonEvent(x1, y1, 0, false, game, 0)
                clicked = true
            end
        end
    end)

    return clicked
end

local function autoClickFightLoop(maxRetries, diffName)
    maxRetries = maxRetries or 8
    if diffName then
        pcall(function() selectGameBossDifficulty(diffName) end)
    end
    for attempt = 1, maxRetries do
        local btn = findFightButton()
        if btn then
            safeLog(string.format("[SuiSuiHUB] Đã phát hiện nút FIGHT (Lần %d) -> Đang kích hoạt click!", attempt))
            clickGuiElement(btn)
            task.wait(0.25)
            local stillThere = findFightButton()
            if not stillThere then
                safeLog("[SuiSuiHUB] Nút FIGHT đã được click thành công, trận đấu đã bắt đầu!")
                return true
            end
        else
            task.wait(0.2)
        end
    end
    return false
end

local clickGameFightButton = autoClickFightLoop

local function getPromptCFrame(prompt)
    if not prompt then return nil end
    local pObj = prompt.Parent
    if not pObj then return nil end

    if pObj:IsA("BasePart") then
        return pObj.CFrame
    elseif pObj:IsA("Attachment") then
        return pObj.WorldCFrame
    elseif pObj:IsA("Model") then
        return pObj:GetPivot()
    end

    local ancestorPart = prompt:FindFirstAncestorWhichIsA("BasePart")
    if ancestorPart then return ancestorPart.CFrame end

    local ancestorModel = prompt:FindFirstAncestorWhichIsA("Model")
    if ancestorModel then return ancestorModel:GetPivot() end

    return nil
end

local function findBossPromptAndCFrame(bossId)
    local target = (bossId or ""):lower():gsub("%s+", "")
    if target == "" then return nil, nil end

    -- 1. Trả về từ Cache siêu tốc nếu đã tìm thấy
    local cached = mainBossModelCache[target]
    if cached and cached.prompt and cached.prompt.Parent then
        local cf = getPromptCFrame(cached.prompt)
        if cf then return cached.prompt, cf end
    end

    local keywords = { target }
    if target == "queen" then
        keywords = { "queen", "shadowmonarch", "shadow", "monarch", "sjw" }
    elseif target == "gojo" then
        keywords = { "gojo", "limitless", "sorcerer" }
    elseif target == "kurumi" then
        keywords = { "kurumi", "clockmaiden", "devil" }
    elseif target == "castleboss" then
        keywords = { "castleboss", "castle", "endless" }
    end

    local function checkPromptMatch(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") then return nil, nil end
        local objTxt = (prompt.ObjectText or ""):lower():gsub("%s+", "")
        local actTxt = (prompt.ActionText or ""):lower():gsub("%s+", "")
        local pName = (prompt.Parent and prompt.Parent.Name or ""):lower():gsub("%s+", "")
        local aModel = prompt:FindFirstAncestorWhichIsA("Model")
        local mName = aModel and aModel.Name:lower():gsub("%s+", "") or ""

        for _, kw in ipairs(keywords) do
            if objTxt:find(kw) or actTxt:find(kw) or pName:find(kw) or mName:find(kw) then
                local cf = getPromptCFrame(prompt)
                if cf then
                    mainBossModelCache[target] = { prompt = prompt, cframe = cf }
                    return prompt, cf
                end
            end
        end
        return nil, nil
    end

    -- 2. Quét nhanh tất cả ProximityPrompt trong Workspace (Chính xác 100%, 0.001s)
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local p, cf = checkPromptMatch(desc)
            if p and cf then return p, cf end
        end
    end

    return nil, nil
end

local findMainBossModel = function(bossId)
    local p, cf = findBossPromptAndCFrame(bossId)
    if p then return p.Parent, p end
    return nil, nil
end

local function teleportToMainBoss(bossId)
    local prompt, cf = nil, nil
    -- Thử quét tìm ProximityPrompt tối đa 6 lần (mỗi lần cách 0.4s để chờ map nạp)
    for attempt = 1, 6 do
        prompt, cf = findBossPromptAndCFrame(bossId)
        if prompt and cf then break end
        task.wait(0.4)
    end

    if prompt and cf then
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Đứng an toàn ngay trên bề mặt của Prompt (nâng lên 2.5 studs, không offset lùi sau vách đá)
            local safeTarget = cf.Position + Vector3.new(0, 2.5, 0)
            hrp.CFrame = CFrame.new(safeTarget)
            Notification("Trùm Cuối", "Đã tới gần " .. tostring(bossId) .. " & Tự động bấm E!", 2)
            task.wait(0.2)

            -- Bấm E tự động (Kích hoạt ProximityPrompt để mở Menu Boss)
            pcall(function()
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                else
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration + 0.05)
                    prompt:InputHoldEnd()
                end
            end)
            return true, prompt
        end
    end

    return false, nil
end

local function closeActiveBossGui()
    pcall(function()
        local bossGui = getActiveBossScreenGui()
        if bossGui then
            local bossOverlay = bossGui:FindFirstChild("BossOverlay")
            local root = bossOverlay and bossOverlay:FindFirstChild("Root")
            local slantHeader = root and root:FindFirstChild("SlantHeader")
            local closeBtn = slantHeader and (slantHeader:FindFirstChild("Close") or slantHeader:FindFirstChildWhichIsA("GuiButton"))
            if closeBtn then
                clickGuiElement(closeBtn)
            end
            if bossOverlay then
                bossOverlay.Visible = false
            end
        end
    end)
end

local function executeBossVictory(bossId, diff)
    if not bossId then return false end
    diff = resolveDifficulty(diff)
    
    if not getCooldownRemote then
        getCooldownRemote = eventRemotes and eventRemotes:FindFirstChild("GetBossCooldown") or ReplicatedStorage:FindFirstChild("GetBossCooldown", true)
    end
    if not reportVictoryRemote then
        reportVictoryRemote = eventRemotes and eventRemotes:FindFirstChild("ReportBossVictory") or ReplicatedStorage:FindFirstChild("ReportBossVictory", true)
    end

    -- Danh sách ID gửi server (Bao gồm cả Alias dự phòng nếu game dùng tên hiển thị)
    local targetIds = { bossId }
    if bossId == "kurumi" then
        table.insert(targetIds, "clockmaiden")
    elseif bossId == "clockmaiden" then
        table.insert(targetIds, "kurumi")
    elseif bossId == "queen" then
        table.insert(targetIds, "shadowmonarch")
    end

    -- 1. Nếu có bảng Boss đang mở khớp với Boss hiện tại: Bấm FIGHT hỗ trợ
    pcall(function()
        local bossGui = getActiveBossScreenGui()
        if bossGui then
            selectGameBossDifficulty(diff)
            task.wait(0.08)
            local fightBtn = findFightButton()
            if fightBtn then
                clickGuiElement(fightBtn)
                task.wait(0.2)
            end
        end
    end)

    -- 2. Bước 1 & 2 & 3 SimpleSpy: Khởi tạo phiên đấu hợp lệ với Server
    if getCooldownRemote then
        for _, id in ipairs(targetIds) do
            pcall(function()
                getCooldownRemote:InvokeServer(id, "Normal")
                if diff ~= "Normal" then
                    getCooldownRemote:InvokeServer(id, diff)
                end
            end)
        end
    end
    task.wait(0.2)

    -- 3. Bước 4 SimpleSpy: Báo cáo bắt đầu trận đấu
    local reportOk = false
    if reportVictoryRemote then
        for _, id in ipairs(targetIds) do
            local ok = pcall(function()
                reportVictoryRemote:FireServer(id, diff)
            end)
            if ok then reportOk = true end
        end
    end

    -- 4. Bù trừ độ trễ mạng (Ping dj: ~324ms): Chờ 0.65s để Server tính toán xong phần thưởng
    task.wait(0.65)

    -- 5. Bước 5 SimpleSpy: Nhận quà thưởng chiến thắng
    if reportVictoryRemote then
        for _, id in ipairs(targetIds) do
            pcall(function()
                reportVictoryRemote:FireServer(id, diff)
            end)
        end
    end
    task.wait(0.25)

    -- 6. Tự động đóng bảng chiến thắng / nhận quà & Đóng menu Boss
    autoDismissBossDefeated()
    closeActiveBossGui()

    -- 7. Ghi nhận mốc thời gian vừa đánh xong để kích hoạt bộ đếm Cooldown 150s (2m30s)
    lastDefeatedBossTime[bossId] = os.time()
    safeLog(string.format("[SuiSuiHUB] Đã đấm Trùm Cuối & Nhận quà thành công: %s [%s] | Kích hoạt Cooldown 150s", tostring(bossId), tostring(diff)))
    return reportOk
end

-- Chu trình hoàn chỉnh khi đấm Mini Boss (Bao gồm BuildMiniBossBattle + ReportBossVictory)
local function executeMiniBossBattle(bossId)
    if not bossId then return false end
    
    if not buildMiniBossRemote then
        buildMiniBossRemote = eventRemotes and eventRemotes:FindFirstChild("BuildMiniBossBattle") or ReplicatedStorage:FindFirstChild("BuildMiniBossBattle", true)
    end
    if not reportVictoryRemote then
        reportVictoryRemote = eventRemotes and eventRemotes:FindFirstChild("ReportBossVictory") or ReplicatedStorage:FindFirstChild("ReportBossVictory", true)
    end

    -- 1. Khởi tạo trận Mini Boss trên Server (Chạy ngầm task.spawn để chống server làm treo / đơ luồng nếu Boss chưa hồi sinh)
    if buildMiniBossRemote then
        task.spawn(function()
            pcall(function()
                buildMiniBossRemote:InvokeServer(bossId, false)
            end)
        end)
    end

    -- 2. Báo cáo chiến thắng nhận phần thưởng trực tiếp (RemoteEvent FireServer không bao giờ bị nghẽn)
    local reportOk = false
    if reportVictoryRemote then
        reportOk = pcall(function()
            reportVictoryRemote:FireServer(bossId, "Normal")
        end)
    end

    safeLog(string.format("[SuiSuiHUB] Đã đấm Mini Boss: %s | Fire: %s", tostring(bossId), tostring(reportOk)))
    return true
end

local function teleportToWorld(mapId)
    if not worldsTeleportRemote then
        worldsTeleportRemote = ReplicatedStorage:FindFirstChild("WorldsTeleportRequest", true)
            or (eventRemotes and eventRemotes:FindFirstChild("WorldsTeleportRequest"))
            or ReplicatedStorage:FindFirstChild("WorldsTeleportRequest")
    end
    if worldsTeleportRemote and mapId then
        currentLoadedMapId = mapId
        table.clear(mainBossModelCache)
        table.clear(miniBossModelCache)
        worldsTeleportRemote:FireServer(mapId)
        safeLog(string.format("[SuiSuiHUB] Đã gửi lệnh Teleport tới Map: %s", tostring(mapId)))
        Notification("Teleport", "Đang tele tới Map: " .. tostring(mapId), 2)
    else
        safeWarn(string.format("[SuiSuiHUB] Không tìm thấy Remote WorldsTeleportRequest để tele tới Map %s!", tostring(mapId)))
    end
end

-- Tiện ích: Quay Spin
local function spinWheel(amount)
    amount = tonumber(amount) or 11
    if not wheelRemote then
        wheelRemote = ReplicatedStorage:FindFirstChild("WheelRemote", true)
    end
    if wheelRemote then
        local ok, res = pcall(function()
            return wheelRemote:InvokeServer("spin", amount)
        end)
        safeLog(string.format("[SuiSuiHUB] Quay Spin (%d lượt): Thành công = %s", amount, tostring(ok)))
        return ok, res
    end
    return false, "WheelRemote not found"
end

-- Tiện ích: Nhận / Cập nhật Quests
local function fetchQuests()
    if not getQuestsRemote then
        getQuestsRemote = ReplicatedStorage:FindFirstChild("GetQuests", true)
    end
    if getQuestsRemote then
        local ok, res = pcall(function()
            return getQuestsRemote:InvokeServer()
        end)
        safeLog(string.format("[SuiSuiHUB] Nhận / Cập nhật Quests: Thành công = %s", tostring(ok)))
        return ok, res
    end
    return false, "GetQuests not found"
end

-- Tiện ích: Dịch chuyển tới NPC
local function teleportToNpc(npcId)
    npcId = npcId or "trait system npc"
    if not worldsTeleportRemote then
        worldsTeleportRemote = ReplicatedStorage:FindFirstChild("WorldsTeleportRequest", true)
    end
    if worldsTeleportRemote then
        worldsTeleportRemote:FireServer(npcId)
        Notification("Teleport NPC", "Đang dịch chuyển tới: " .. tostring(npcId), 2)
        safeLog("[SuiSuiHUB] Teleport tới NPC: " .. tostring(npcId))
        return true
    end
    return false
end

-- Tiện ích: Dịch chuyển tới NPC Siege (axi)
-- ========================================================================
-- CÁC HÀM XỬ LÝ RIFTGATE (ENTER, BATTLE, VICTORY, LEAVE)
-- ========================================================================
local function findRiftGate()
    -- 1. Tìm model có tên riftgate1 hoặc chứa riftgate
    for _, child in ipairs(workspace:GetChildren()) do
        local n = child.Name:lower()
        if n:find("riftgate") or n:find("rift_gate") then
            local prompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
            return child, prompt
        end
    end
    -- 2. Quét ProximityPrompt toàn map
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local txt = ((desc.ObjectText or "") .. " " .. (desc.ActionText or "")):lower()
            if txt:find("rift") or txt:find("enter rift") then
                return desc.Parent, desc
            end
        end
    end
    return nil, nil
end

local function teleportToRiftGate()
    local gateModel, prompt = findRiftGate()
    local targetPart = gateModel and (gateModel:IsA("BasePart") and gateModel or gateModel:FindFirstChildWhichIsA("BasePart"))
    if not targetPart and prompt and prompt.Parent then
        targetPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
    end
    
    if targetPart and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = localPlayer.Character.HumanoidRootPart
        local safePos = targetPart.Position + Vector3.new(0, 3, 4)
        hrp.CFrame = CFrame.new(safePos, targetPart.Position)
        Notification("Teleport", "Đã dịch chuyển tới trước cổng RiftGATE!", 2)
        safeLog("[SuiSuiHUB] Teleport tới RiftGATE: " .. targetPart:GetFullName())
        return true
    end
    Notification("Teleport", "Không tìm thấy cổng RiftGATE trên map hiện tại!", 3)
    return false
end

local function executeRiftGateCycle()
    safeLog("[SuiSuiHUB] Bắt đầu chu trình tự động đấm RiftGATE...")
    
    -- 1. Kích hoạt vào cổng (Enter Request / ProximityPrompt)
    local gateModel, prompt = findRiftGate()
    if prompt and fireproximityprompt then
        pcall(function() fireproximityprompt(prompt) end)
    end
    if riftGateEnterRemote then
        pcall(function() riftGateEnterRemote:FireServer() end)
    end
    task.wait(0.3)
    
    -- 2. Khởi tạo trận đấu (BuildRiftGateBattle + StartFight)
    if buildRiftBattleRemote then
        pcall(function() buildRiftBattleRemote:InvokeServer(true) end)
    end
    if riftStartFightRemote then
        pcall(function() riftStartFightRemote:FireServer() end)
    end
    task.wait(0.5)
    
    -- 3. Báo cáo chiến thắng & Nhận quà (ReportVictory + Reward)
    local victoryOk = false
    if reportRiftVictoryRemote then
        victoryOk = pcall(function() reportRiftVictoryRemote:FireServer() end)
        pcall(function() reportRiftVictoryRemote:FireServer(true) end)
    end
    if riftRewardRemote then
        pcall(function() riftRewardRemote:FireServer() end)
    end
    task.wait(0.4)
    
    -- 4. Tự động đóng bảng chiến thắng & nhận quà
    autoDismissBossDefeated()
    
    -- 5. Rời khỏi cổng (Leave) để hoàn tất chu trình an toàn
    if riftGateLeaveRemote then
        pcall(function() riftGateLeaveRemote:FireServer() end)
    end
    
    safeLog(string.format("[SuiSuiHUB] Đã đấm RiftGATE xong! Kết quả: %s", tostring(victoryOk)))
    Notification("RiftGATE", "Đã tự động đấm RiftGATE & nhận quà thành công!", 4)
    return victoryOk
end

local function teleportToSiegeNpc()
    if not worldsTeleportRemote then
        worldsTeleportRemote = ReplicatedStorage:FindFirstChild("WorldsTeleportRequest", true)
    end
    if worldsTeleportRemote then
        worldsTeleportRemote:FireServer("axi")
        Notification("Teleport SIEGE", "Đang dịch chuyển tới NPC Siege (axi)!", 2)
        safeLog("[SuiSuiHUB] Teleport tới NPC Siege (axi)")
        return true
    end
    return false
end

-- Chu trình thực hiện Farm Stage trong SIEGE (StartDungeonStage + Damage + ClaimDungeonReward)
local function executeSiegeStage(stageNum)
    stageNum = tonumber(stageNum) or 1
    
    local startDungeonRemote = eventRemotes and eventRemotes:FindFirstChild("StartDungeonStage") or ReplicatedStorage:FindFirstChild("StartDungeonStage", true)
    local claimRewardRemote = eventRemotes and eventRemotes:FindFirstChild("ClaimDungeonReward") or ReplicatedStorage:FindFirstChild("ClaimDungeonReward", true)
    local battleDamageRemote = eventRemotes and (eventRemotes:FindFirstChild("ReportBattleDamage") or ReplicatedStorage:FindFirstChild("ReportBattleDamage", true))
    
    -- 1. Khởi tạo & nạp thông tin phiên Siege (Chạy ngầm task.spawn không block luồng)
    task.spawn(function()
        pcall(function()
            local getCd = eventRemotes and eventRemotes:FindFirstChild("GetDungeonCooldown") or ReplicatedStorage:FindFirstChild("GetDungeonCooldown", true)
            if getCd then getCd:InvokeServer() end
            local getProg = eventRemotes and eventRemotes:FindFirstChild("GetDungeonProgress") or ReplicatedStorage:FindFirstChild("GetDungeonProgress", true)
            if getProg then getProg:InvokeServer() end
            local getRot = eventRemotes and eventRemotes:FindFirstChild("GetDungeonRotation") or ReplicatedStorage:FindFirstChild("GetDungeonRotation", true)
            if getRot then getRot:InvokeServer() end
            local getPack = eventRemotes and eventRemotes:FindFirstChild("GetPackPunched") or ReplicatedStorage:FindFirstChild("GetPackPunched", true)
            if getPack then getPack:InvokeServer() end
            local getDecks = eventRemotes and eventRemotes:FindFirstChild("GetActiveDecks") or ReplicatedStorage:FindFirstChild("GetActiveDecks", true)
            if getDecks then getDecks:InvokeServer() end
            local getParty = eventRemotes and eventRemotes:FindFirstChild("GetParty") or ReplicatedStorage:FindFirstChild("GetParty", true)
            if getParty then getParty:InvokeServer(16) end
        end)
    end)

    -- 2. Bắt đầu Stage qua StartDungeonStage (args: { stageNum, [3] = false })
    local startOk = false
    if startDungeonRemote then
        startOk = pcall(function()
            local args = { stageNum, [3] = false }
            return startDungeonRemote:InvokeServer(unpack(args))
        end)
        safeLog(string.format("[SIEGE] StartDungeonStage(%d): %s", stageNum, tostring(startOk)))
    end

    -- 3. Speed & Battle Checks (Chạy ngầm)
    task.spawn(function()
        pcall(function()
            local speedPass = eventRemotes and eventRemotes:FindFirstChild("HasSpeedPass") or ReplicatedStorage:FindFirstChild("HasSpeedPass", true)
            if speedPass then speedPass:InvokeServer() end
            local battleSpd = eventRemotes and eventRemotes:FindFirstChild("GetBattleSpeed") or ReplicatedStorage:FindFirstChild("GetBattleSpeed", true)
            if battleSpd then battleSpd:InvokeServer() end
        end)
    end)

    -- 4. Báo cáo sát thương trận chiến (ReportBattleDamage)
    if battleDamageRemote then
        task.spawn(function()
            pcall(function()
                for i = 1, 3 do
                    if battleDamageRemote:IsA("RemoteEvent") then
                        battleDamageRemote:FireServer(stageNum)
                    else
                        battleDamageRemote:InvokeServer(stageNum)
                    end
                    task.wait(0.05)
                end
            end)
        end)
    end

    -- Chờ một nhịp 0.25s để server xử lý kết quả trận đánh
    task.wait(0.25)

    -- 5. Nhận thưởng Stage (ClaimDungeonReward)
    local claimOk = false
    if claimRewardRemote then
        claimOk = pcall(function()
            local args = { stageNum }
            return claimRewardRemote:InvokeServer(unpack(args))
        end)
        safeLog(string.format("[SIEGE] ClaimDungeonReward(%d): %s", stageNum, tostring(claimOk)))
    end

    -- 6. Tự động đóng bảng chiến thắng nếu xuất hiện
    task.wait(0.1)
    autoDismissBossDefeated()

    return claimOk
end

-- Caching Player Controls để tránh gọi require(PlayerModule) liên tục gây tụt FPS
local cachedPlayerControls = nil
pcall(function()
    local pm = localPlayer:WaitForChild("PlayerScripts", 3):FindFirstChild("PlayerModule")
    if pm then
        cachedPlayerControls = require(pm):GetControls()
    end
end)

local function restorePlayerControls()
    pcall(function()
        if cachedPlayerControls and cachedPlayerControls.Enable and not cachedPlayerControls:IsEnabled() then
            cachedPlayerControls:Enable()
        end
        local char = localPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.WalkSpeed <= 0 then
                hum.WalkSpeed = 16
            end
            hum.PlatformStand = false
        end
    end)
end

local function clickContinueButton(btn)
    pcall(function()
        if firesignal then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
        else
            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
            for _, c in ipairs(getconnections(btn.Activated)) do c:Fire() end
        end
    end)
    restorePlayerControls()
end

-- Tự động bấm CONTINUE theo cơ chế Event-driven O(1) (Chỉ kích hoạt khi có nút xuất hiện, 0% CPU rảnh rỗi)
pcall(function()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then
        pg.DescendantAdded:Connect(function(child)
            if not child:IsA("GuiButton") then return end
            local name = (child.Name or ""):lower():gsub("%s+", "")
            local txt = child:IsA("TextButton") and (child.Text or ""):lower():gsub("%s+", "") or ""
            if txt == "continue" or name:find("continue") or txt:find("continue") or txt == "skip>>" or name == "skip" then
                task.wait(0.08)
                clickContinueButton(child)
            end
        end)
    end
end)

local function autoDismissBossDefeated()
    pcall(function()
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if not pg then return end

        -- 1. Xử lý RarityCutsceneGui (Skip cutscene)
        local cutsceneGui = pg:FindFirstChild("RarityCutsceneGui")
        if cutsceneGui and cutsceneGui.Enabled then
            local frame = cutsceneGui:FindFirstChild("Frame")
            if frame then
                local skipBtn = frame:FindFirstChildWhichIsA("TextButton") or frame:FindFirstChild("TextButton")
                if skipBtn and skipBtn.Visible then
                    clickContinueButton(skipBtn)
                end
            end
        end

        -- 2. Xử lý KleinQuestGui (Dialogue skip)
        local kleinGui = pg:FindFirstChild("KleinQuestGui")
        if kleinGui and kleinGui.Enabled then
            local dialogue = kleinGui:FindFirstChild("Dialogue")
            if dialogue and dialogue.Visible then
                local skipBtn = dialogue:FindFirstChild("Skip") or dialogue:FindFirstChild("Hit")
                if skipBtn then clickContinueButton(skipBtn) end
            end
        end

        -- 3. Xử lý BattleGui2 / RankedGui / ScreenGui kết thúc trận đấu
        local candidateGuis = {
            pg:FindFirstChild("BattleGui2"),
            pg:FindFirstChild("RankedGui"),
            pg:FindFirstChild("ScreenGui")
        }
        for _, gui in ipairs(candidateGuis) do
            if gui and gui.Enabled then
                for _, desc in ipairs(gui:GetChildren()) do
                    if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and desc.Visible then
                        local txt = desc:IsA("TextButton") and (desc.Text or ""):lower():gsub("%s+", "") or ""
                        local name = (desc.Name or ""):lower():gsub("%s+", "")
                        if txt == "continue" or txt == "skip" or txt == "claim" or name:find("continue") or name:find("claim") or name == "skip" then
                            clickContinueButton(desc)
                            break
                        end
                    elseif desc:IsA("Frame") and desc.Visible then
                        for _, sub in ipairs(desc:GetChildren()) do
                            if (sub:IsA("TextButton") or sub:IsA("ImageButton")) and sub.Visible then
                                local txt = sub:IsA("TextButton") and (sub.Text or ""):lower():gsub("%s+", "") or ""
                                local name = (sub.Name or ""):lower():gsub("%s+", "")
                                if txt == "continue" or txt == "skip" or txt == "claim" or name:find("continue") or name:find("claim") or name == "skip" then
                                    clickContinueButton(sub)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    restorePlayerControls()
end

-- Safeguard: Hệ thống chống rơi Void & rơi tự do (Bảo vệ nhân vật khi Farm)
task.spawn(function()
    while true do
        pcall(function()
            local char = localPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < -80 then
                hrp.Velocity = Vector3.zero
                local spawnObj = workspace:FindFirstChild("SpawnLocation", true)
                if spawnObj and spawnObj:IsA("BasePart") then
                    hrp.CFrame = spawnObj.CFrame + Vector3.new(0, 4, 0)
                else
                    hrp.CFrame = CFrame.new(0, 50, 0)
                end
                safeLog("[SuiSuiHUB] Đã kích hoạt bảo vệ Anti-Void: Kéo nhân vật về khu vực an toàn!")
            end
        end)
        task.wait(0.5)
    end
end)

-- I. Vòng lặp Săn Boss Thường VÔ HẠN (Độ ưu tiên 3: Nhường lượt cho RiftGate và Boss Chính)
task.spawn(function()
    safeLog("[SuiSuiHUB] Vòng lặp Auto Mini Boss VÔ HẠN đã kích hoạt thành công!")
    while true do
        local loopOk, loopErr = pcall(function()
            if _G.AutoMiniBoss and _G.SelectedMiniBosses and #_G.SelectedMiniBosses > 0 then
                for _, bossId in ipairs(_G.SelectedMiniBosses) do
                    if not _G.AutoMiniBoss then break end
                    
                    -- ĐỘ ƯU TIÊN: Nhường lượt tuyệt đối cho RiftGate (Ưu tiên 1) và Boss Chính (Ưu tiên 2)
                    while _G.AutoMiniBoss and (shouldYieldToRiftGate() or shouldYieldToMainBoss()) do
                        task.wait(0.2)
                    end
                    if not _G.AutoMiniBoss then break end

                    -- Đánh Mini Boss (Đánh dấu busy để các tác vụ ưu tiên cao chờ 0.05s kết thúc gói tin)
                    isMiniBossBusy = true
                    executeMiniBossBattle(bossId)
                    task.wait(0.1)
                    autoDismissBossDefeated()
                    isMiniBossBusy = false

                    -- Nghỉ giữa các lượt đấm
                    local delay = tonumber(_G.BossDelay) or 0.5
                    task.wait(math.max(delay, 0.2))
                end
            end
        end)
        
        if not loopOk then
            isMiniBossBusy = false
            safeWarn("[SuiSuiHUB] Lỗi vòng lặp Mini Boss (tự động phục hồi): " .. tostring(loopErr))
        end
        
        task.wait(0.3)
    end
end)

-- J. Vòng lặp Săn Boss Chính (Trùm Cuối) VÔ HẠN (Tự Động Đấm Mọi Boss - Kế Thừa Thành Công Của Gojo)
task.spawn(function()
    safeLog("[SuiSuiHUB] Vòng lặp Auto Boss Chính VÔ HẠN đã kích hoạt!")
    while true do
        local loopOk, loopErr = pcall(function()
            if _G.AutoMainBoss and _G.SelectedMainBosses and #_G.SelectedMainBosses > 0 then
                local diff = _G.SelectedMainDifficulty or "Normal"
                
                for _, bTitle in ipairs(_G.SelectedMainBosses) do
                    if not _G.AutoMainBoss then break end
                    
                    -- ĐỘ ƯU TIÊN 1: Nếu RiftGATE đang mở hoặc đang đánh -> Nhường quyền tuyệt đối cho RiftGATE!
                    while _G.AutoMainBoss and shouldYieldToRiftGate() do
                        task.wait(0.2)
                    end
                    if not _G.AutoMainBoss then break end
                    
                    local bossId = resolveMainBossId(bTitle)
                    
                    -- 1. Kiểm tra Cooldown trực tiếp từ Server
                    local cd = checkMainBossCooldown(bossId, diff)
                    if cd <= 0 then
                        -- Chờ gói tin Mini Boss nếu đang gửi dở
                        while isMiniBossBusy do
                            task.wait(0.05)
                        end
                        
                        isMainBossFighting = true
                        safeLog(string.format("[SuiSuiHUB] Đang tự động đấm Trùm Cuối: %s [%s]...", tostring(bossId), tostring(diff)))
                        
                        -- Kích hoạt ProximityPrompt từ xa nếu Boss có trong map (TUYỆT ĐỐI KHÔNG di chuyển nhân vật để chống rơi xuống void / chết)
                        pcall(function()
                            local prompt = findBossPromptAndCFrame(bossId)
                            if prompt and fireproximityprompt then
                                fireproximityprompt(prompt)
                                task.wait(0.1)
                            end
                        end)
                        
                        -- Đấm boss & nhận quà trọn gói qua chuỗi Remote chuẩn xác (Giống hệt cách Gojo vừa thành công!)
                        executeBossVictory(bossId, diff)
                        
                        isMainBossFighting = false
                        
                        local delayTime = tonumber(_G.BossDelay) or 0.5
                        task.wait(math.max(delayTime, 0.3))
                    end
                end
            end
        end)
        
        if not loopOk then
            isMainBossFighting = false
            safeWarn("[SuiSuiHUB] Lỗi vòng lặp Boss Chính: " .. tostring(loopErr))
        end
        
        task.wait(1.0)
    end
end)

-- N. Vòng lặp RiftGATE: Quản lý đếm ngược 15 phút (xx:00, xx:15, xx:30, xx:45) & Tự động tham gia
local RiftStatusLabel
local RiftTimerLabel

task.spawn(function()
    safeLog("[SuiSuiHUB] Vòng lặp RiftGATE (Chu kỳ 15 phút: 00, 15, 30, 45) đã kích hoạt!")
    local lastNotifiedSlot = nil
    local lastFarmSlot = nil
    
    while true do
        pcall(function()
            local t = os.date("*t")
            local min = t.min
            local sec = t.sec
            
            local slotIndex = math.floor(min / 15)
            local slotStart = slotIndex * 15
            local elapsedInSlot = (min - slotStart) * 60 + sec
            
            -- Cổng mở trong 3 phút đầu mỗi đợt (hoặc theo trạng thái game)
            local isOpen = (elapsedInSlot < 180)
            
            local nextSlot = (slotIndex + 1) * 15
            local remTotal = (nextSlot - min) * 60 - sec
            local remM = math.floor(remTotal / 60)
            local remS = remTotal % 60
            local targetM = nextSlot % 60
            
            -- Cập nhật TextLabel trên UI nếu Tab đang mở
            if RiftStatusLabel and RiftStatusLabel.Set then
                if isOpen then
                    local openLeft = 180 - elapsedInSlot
                    RiftStatusLabel:Set(string.format("Trạng Thái: [ĐANG MỞ CỔNG - CÒN %02d:%02d]", math.floor(openLeft / 60), openLeft % 60))
                else
                    RiftStatusLabel:Set("Trạng Thái: [ĐANG CHỜ MỞ CỔNG]")
                end
            end
            
            if RiftTimerLabel and RiftTimerLabel.Set then
                RiftTimerLabel:Set(string.format("Đợt Kế Tiếp: xx:%02d | Còn Lại: %02d:%02d", targetM, remM, remS))
            end
            
            -- Cập nhật cờ Pending để các boss dưới tạm dừng nhường lượt cho RiftGate
            if isOpen and _G.AutoRiftGate and lastFarmSlot ~= slotIndex then
                isRiftGatePending = true
            else
                if not isRiftGateFighting then
                    isRiftGatePending = false
                end
            end
            
            -- Xử lý sự kiện khi cổng vừa bắt đầu mở
            if isOpen and lastNotifiedSlot ~= slotIndex then
                lastNotifiedSlot = slotIndex
                safeLog(string.format("[SuiSuiHUB] Cổng RiftGATE đã mở (Mốc xx:%02d)!", slotStart))
                
                if _G.RiftNotify then
                    Notification("RiftGATE ĐÃ MỞ!", string.format("Cổng RiftGATE mốc xx:%02d đang mở! Mau tham gia!", slotStart), 6)
                end
            elseif not isOpen then
                if lastNotifiedSlot == slotIndex then
                    lastNotifiedSlot = nil
                end
            end
            
            -- ĐỘ ƯU TIÊN 1 (RiftGATE): Tự động chiếm lượt và đấm RiftGATE trọn gói
            if isOpen and _G.AutoRiftGate and lastFarmSlot ~= slotIndex then
                lastFarmSlot = slotIndex
                isRiftGatePending = true
                task.spawn(function()
                    -- Chờ tối đa 0.3s cho gói tin Mini Boss / Boss Chính đang gửi dở kết thúc
                    local waitCount = 0
                    while (isMainBossFighting or isMiniBossBusy) and waitCount < 10 do
                        task.wait(0.05)
                        waitCount = waitCount + 1
                    end
                    
                    isRiftGateFighting = true
                    safeLog("[SuiSuiHUB] [ƯU TIÊN 1] Kích hoạt farm RiftGATE trước Boss Chính & Mini!")
                    executeRiftGateCycle()
                    isRiftGateFighting = false
                    isRiftGatePending = false
                end)
            end
        end)
        
        task.wait(1.0)
    end
end)


-- ========================================================================
-- 6. KHỞI TẠO GIAO DIỆN (UI INITIALIZATION QUA INVENTORY.LUA)
-- ========================================================================
local Window = library:CreateWindow("SuiSuiHUB | Card Origins")
local uiFullyLoaded = false

-- ========================================================================
-- TAB 1: SĂN BOSS (AUTO BOSS & MAP)
-- ========================================================================
local TabBoss = Window:CreateTab("Săn Boss")
local SecBossLeft = TabBoss:CreateSector("1. Boss Thường (Mini Boss)", "left")
local SecBossRight = TabBoss:CreateSector("2. Boss Chính (Shadow Realm)", "right")

local MiniBossDropdownItem
local MainBossDropdownItem

-- Cột Trái: Boss Thường
SecBossLeft:AddDropdown("Chọn Map Hiện Tại", MapOptions, _G.SelectedMap, false, function(v)
    _G.SelectedMap = v
    if not uiFullyLoaded then return end -- Không đè danh sách đã nạp từ config khi khởi tạo UI
    local cfg = GAME_WORLDS[v]
    if cfg then
        if cfg.miniBosses and #cfg.miniBosses > 0 then
            local bossList = {}
            for _, b in ipairs(cfg.miniBosses) do
                table.insert(bossList, b.id)
            end
            _G.SelectedMiniBosses = bossList
            if MiniBossDropdownItem and MiniBossDropdownItem.Set then
                MiniBossDropdownItem:Set(bossList)
            end
        end
        if cfg.mainBoss and MainBossDropdownItem and MainBossDropdownItem.Set then
            local title = string.format("%s (%s)", cfg.mainBoss.name, cfg.mainBoss.id)
            _G.SelectedMainBosses = { title }
            MainBossDropdownItem:Set({ title })
        end
    end
    saveConfig()
end)

SecBossLeft:AddButton("Teleport Vào Map", function()
    local cfg = GAME_WORLDS[_G.SelectedMap]
    if cfg and cfg.mapId then
        teleportToWorld(cfg.mapId)
    end
end)

MiniBossDropdownItem = SecBossLeft:AddDropdown("Chọn Boss Thường (Chọn Nhiều)", ALL_MINI_BOSS_LIST, _G.SelectedMiniBosses, true, function(selected)
    if typeof(selected) == "table" then
        _G.SelectedMiniBosses = selected
    elseif typeof(selected) == "string" then
        _G.SelectedMiniBosses = { selected }
    end
    if uiFullyLoaded then
        saveConfig()
    end
    safeLog("[SuiSuiHUB] Đã chọn danh sách Mini Boss: " .. table.concat(_G.SelectedMiniBosses or {}, ", "))
end)

SecBossLeft:AddButton("Chọn Toàn Bộ Mini Boss Trong Map", function()
    local allList = {}
    local cfg = GAME_WORLDS[_G.SelectedMap]
    if cfg and cfg.miniBosses then
        for _, b in ipairs(cfg.miniBosses) do table.insert(allList, b.id) end
    end
    if #allList > 0 then
        _G.SelectedMiniBosses = allList
        if MiniBossDropdownItem and MiniBossDropdownItem.Set then
            MiniBossDropdownItem:Set(allList)
        end
        saveConfig()
        Notification("Mini Boss", string.format("Đã chọn %d Boss trong map hiện tại!", #allList), 3)
    end
end)

SecBossLeft:AddButton("Chọn Toàn Bộ 6 Mini Boss (Toàn Game)", function()
    _G.SelectedMiniBosses = ALL_MINI_BOSS_LIST
    if MiniBossDropdownItem and MiniBossDropdownItem.Set then
        MiniBossDropdownItem:Set(ALL_MINI_BOSS_LIST)
    end
    saveConfig()
    Notification("Mini Boss", "Đã chọn toàn bộ 6 Mini Boss trong game!", 3)
end)

SecBossLeft:AddButton("Bay Tới Gần Boss Thường", function()
    local target = _G.SelectedMiniBosses and _G.SelectedMiniBosses[1] or "chahaein"
    teleportToMiniBoss(target)
end)

SecBossLeft:AddToggle("Auto Đấm Boss Thường (Xoay Vòng)", _G.AutoMiniBoss, function(v)
    _G.AutoMiniBoss = v
    if uiFullyLoaded then saveConfig() end
    Notification("Boss Thường", v and "Đã BẬT Auto đấm toàn bộ Boss thường đã chọn!" or "Đã TẮT!", 2)
end)

-- Cột Phải: Boss Chính (Shadow Realm)
_G.SelectedMainBosses = _G.SelectedMainBosses or { "The Shadow Monarch (queen)" }

MainBossDropdownItem = SecBossRight:AddDropdown("Chọn Trùm Cuối (Chọn Nhiều)", ALL_MAIN_BOSS_LIST, _G.SelectedMainBosses, true, function(selected)
    if typeof(selected) == "table" then
        _G.SelectedMainBosses = selected
    elseif typeof(selected) == "string" then
        _G.SelectedMainBosses = { selected }
    end
    if uiFullyLoaded then
        saveConfig()
    end
    safeLog("[SuiSuiHUB] Đã chọn danh sách Trùm Cuối: " .. table.concat(_G.SelectedMainBosses or {}, ", "))
end)

SecBossRight:AddButton("Chọn Toàn Bộ Trùm Cuối (Toàn Game)", function()
    _G.SelectedMainBosses = ALL_MAIN_BOSS_LIST
    if MainBossDropdownItem and MainBossDropdownItem.Set then
        MainBossDropdownItem:Set(ALL_MAIN_BOSS_LIST)
    end
    saveConfig()
    Notification("Trùm Cuối", "Đã chọn toàn bộ 4 Trùm Cuối trong game!", 3)
end)

local mainBossDifficulties = {
    "01: NORMAL (Normal)",
    "02: CALAMITY (Gold)",
    "03: UMBRAL (Rainbow)",
    "04: ASTRAL",
    "05: PARADOX",
    "06: ORIGIN",
    "Gold",
    "Rainbow",
    "Normal"
}

SecBossRight:AddDropdown("Độ Khó Boss Chính", mainBossDifficulties, _G.SelectedMainDifficulty, false, function(v)
    _G.SelectedMainDifficulty = v
    if uiFullyLoaded then saveConfig() end
end)

SecBossRight:AddToggle("Auto Đấm Boss Chính (Xoay Vòng)", _G.AutoMainBoss, function(v)
    _G.AutoMainBoss = v
    if uiFullyLoaded then saveConfig() end
    Notification("Boss Chính", v and "Đã BẬT Auto đấm toàn bộ Trùm Cuối đã chọn!" or "Đã TẮT!", 2)
end)

local PRIORITY_OPTIONS = {
    "RiftGate > Boss Chính > Boss Mini (Mặc Định)",
    "Boss Chính > RiftGate > Boss Mini",
    "Tự Do (Không Chờ Nhau)"
}

SecBossRight:AddDropdown("Độ Ưu Tiên Farm", PRIORITY_OPTIONS, _G.PriorityMode, false, function(v)
    _G.PriorityMode = v
    if uiFullyLoaded then saveConfig() end
    Notification("Độ Ưu Tiên", "Đã đặt thứ tự ưu tiên: " .. tostring(v), 2)
    safeLog("[SuiSuiHUB] Đã chọn chế độ ưu tiên: " .. tostring(v))
end)

-- ========================================================================
-- TAB 2: RiftGATE (CHU KỲ 15 PHÚT: 00, 15, 30, 45)
-- ========================================================================
local TabRift = Window:CreateTab("RiftGATE")
local SecRiftLeft = TabRift:CreateSector("1. Đếm Ngược & Trạng Thái Cổng", "left")
local SecRiftRight = TabRift:CreateSector("2. Tự Động & Tiện Ích RiftGATE", "right")

RiftStatusLabel = SecRiftLeft:AddLabel("Trạng Thái: ĐANG ĐỒNG BỘ GIỜ...", true)
RiftTimerLabel = SecRiftLeft:AddLabel("Đợt Kế Tiếp: xx:-- | Còn Lại: --:--")
local RiftNextListLabel = SecRiftLeft:AddLabel("Các Mốc Giờ: xx:00 | xx:15 | xx:30 | xx:45")

SecRiftLeft:AddToggle("Báo Chuông Khi Cổng Mở (Notify)", _G.RiftNotify, function(v)
    _G.RiftNotify = v
    if uiFullyLoaded then saveConfig() end
    Notification("RiftGATE", v and "Đã BẬT chuông báo khi cổng mở!" or "Đã TẮT chuông báo!", 2)
end)

SecRiftLeft:AddToggle("Tự Động Săn RiftGATE (Auto Join)", _G.AutoRiftGate, function(v)
    _G.AutoRiftGate = v
    if uiFullyLoaded then saveConfig() end
    Notification("RiftGATE", v and "Đã BẬT Auto tham gia RiftGATE khi cổng mở!" or "Đã TẮT Auto RiftGATE!", 2)
end)

-- Cột Phải: Tiện ích & Thao tác thủ công
SecRiftRight:AddButton("Đánh Thử 1 Trận RiftGATE (Ngay Lập Tức)", function()
    task.spawn(function()
        Notification("RiftGATE", "Đang thử chạy chu trình đấm RiftGATE...", 2)
        local ok = executeRiftGateCycle()
        Notification("RiftGATE", "Kết quả: " .. tostring(ok), 3)
    end)
end)

SecRiftRight:AddButton("Teleport Tới Cổng Rift (Bay Tới Cổng)", function()
    teleportToRiftGate()
end)

SecRiftRight:AddButton("Vào Cổng Thủ Công (RiftGateEnterRequest)", function()
    if riftGateEnterRemote then
        riftGateEnterRemote:FireServer()
        Notification("RiftGATE", "Đã gửi lệnh RiftGateEnterRequest!", 2)
    end
end)

SecRiftRight:AddButton("Rời Khỏi Cổng (RiftGateLeave)", function()
    if riftGateLeaveRemote then
        riftGateLeaveRemote:FireServer()
        Notification("RiftGATE", "Đã gửi lệnh RiftGateLeave!", 2)
    end
end)

SecRiftRight:AddButton("Quét Cổng & Prompt Rift Hiện Tại", function()
    local gateModel, prompt = findRiftGate()
    if gateModel then
        local pTxt = prompt and string.format("Prompt: %s [%s] (Enabled: %s)", prompt.ObjectText, prompt.ActionText, tostring(prompt.Enabled)) or "Không có Prompt"
        Notification("RiftGATE", string.format("Tìm thấy: %s | %s", gateModel:GetFullName(), pTxt), 5)
    else
        Notification("RiftGATE", "Không thấy cổng RiftGATE nào trong map hiện tại!", 3)
    end
end)

SecRiftRight:AddButton("Kích Hoạt (Bấm E) Mọi Cổng Trong Map", function()
    local triggered = 0
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local pName = (desc.ObjectText or "") .. " " .. (desc.ActionText or "") .. " " .. (desc.Parent and desc.Parent.Name or "")
            if pName:lower():find("rift") or pName:lower():find("gate") or pName:lower():find("portal") or pName:lower():find("raid") then
                if fireproximityprompt then
                    fireproximityprompt(desc)
                    triggered = triggered + 1
                end
            end
        end
    end
    Notification("RiftGATE", string.format("Đã kích hoạt %d cổng Rift/Gate!", triggered), 3)
end)

SecRiftRight:AddButton("Mở Bảng RaidBossUI (Nếu Có)", function()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    local raidGui = pg and pg:FindFirstChild("RaidBossUI")
    if raidGui then
        raidGui.Enabled = true
        Notification("RiftGATE", "Đã bật hiển thị RaidBossUI!", 2)
    else
        Notification("RiftGATE", "Chưa tìm thấy RaidBossUI trong PlayerGui!", 3)
    end
end)

-- ========================================================================
-- TAB 3: TIỆN ÍCH (SPIN, QUESTS, TELEPORT NPC)
-- ========================================================================
-- TAB 3: CÀI ĐẶT (SETTINGS)
-- ========================================================================
local TabSettings = Window:CreateTab("Cài Đặt")
local SecSetLeft = TabSettings:CreateSector("Tối Ưu Treo Máy", "left")
local SecSetRight = TabSettings:CreateSector("Hệ Thống & Tiện Ích", "right")

SecSetLeft:AddToggle("Chống Văng (Anti-AFK)", _G.AntiAFK, function(v)
    _G.AntiAFK = v
end)

SecSetLeft:AddToggle("Màn Hình Trắng Giảm CPU (WhiteScreen)", _G.WhiteScreen, function(v)
    _G.WhiteScreen = v
    RunService:Set3dRenderingEnabled(not v)
    Notification("Màn Hình", v and "Đã BẬT màn hình trắng (Siêu nhẹ CPU/GPU)!" or "Đã TẮT màn hình trắng!", 2)
end)

SecSetLeft:AddToggle("Giảm Lag Đồ Họa (FPS Boost)", _G.FPSBoost, function(v)
    _G.FPSBoost = v
    if v then
        pcall(function()
            settings().Rendering.QualityLevel = 1
            for _, item in ipairs(workspace:GetDescendants()) do
                if item:IsA("BasePart") and not item.Parent:FindFirstChild("Humanoid") then
                    item.Material = Enum.Material.SmoothPlastic
                elseif item:IsA("Decal") or item:IsA("Texture") then
                    item.Transparency = 1
                elseif item:IsA("ParticleEmitter") or item:IsA("Trail") then
                    item.Enabled = false
                end
            end
        end)
        Notification("Tối Ưu", "Đã kích hoạt chế độ siêu mượt!", 2)
    end
end)

_G.WalkSpeedEnabled = false
_G.WalkSpeedValue = 16

SecSetLeft:AddToggle("Bật Chỉnh Tốc Độ Di Chuyển", false, function(v)
    _G.WalkSpeedEnabled = v
    pcall(function()
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            local hum = localPlayer.Character:FindFirstChild("Humanoid")
            hum.WalkSpeed = v and (_G.WalkSpeedValue or 16) or 16
        end
    end)
end)

SecSetLeft:AddSlider("Tốc Độ (WalkSpeed)", 16, 16, 200, 1, function(v)
    if typeof(v) == "number" and v == v and v > 0 then
        _G.WalkSpeedValue = math.floor(v)
        if _G.WalkSpeedEnabled then
            pcall(function()
                if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
                    localPlayer.Character.Humanoid.WalkSpeed = _G.WalkSpeedValue
                end
            end)
        end
    end
end)

SecSetRight:AddButton("Vào Lại Server (Rejoin)", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
end)

SecSetRight:AddButton("Đổi Server (Server Hop)", function()
    local success, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and res and res.data then
        for _, server in ipairs(res.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, localPlayer)
                break
            end
        end
    else
        Notification("Server Hop", "Không thể lấy danh sách Server!", 3)
    end
end)

SecSetRight:AddButton("Khởi Chạy GUI Remote Hunter", function()
    local hunterLoaded = false
    pcall(function()
        loadstring(game:HttpGet("http://127.0.0.1:8000/Card%20Origins/RemoteHunter.lua"))()
        hunterLoaded = true
    end)
    if not hunterLoaded and isfile and readfile and isfile("Card Origins/RemoteHunter.lua") then
        pcall(function()
            loadstring(readfile("Card Origins/RemoteHunter.lua"))()
            hunterLoaded = true
        end)
    end
    if hunterLoaded then
        Notification("Remote Hunter", "Đã mở giao diện Remote Hunter trên màn hình!", 3)
    else
        Notification("Remote Hunter", "Không thể tải RemoteHunter.lua! Hãy kiểm tra server port 8000.", 4)
    end
end)

SecSetRight:AddButton("Lưu Cấu Hình (Save Config)", function()
    saveConfig()
    Notification("Cấu Hình", "Đã lưu cài đặt CardOrigins thành công!", 2)
end)

SecSetRight:AddButton("Tải Cấu Hình (Load Config)", function()
    loadConfig()
    Notification("Cấu Hình", "Đã nạp cài đặt đã lưu thành công!", 2)
end)

uiFullyLoaded = true
saveConfig()

Notification("SuiSuiHUB", "Khởi tạo Card Origins thành công!", 4)

