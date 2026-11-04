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
-- 1. LOAD SHARED UI LIBRARY (inventory.lua)
-- ========================================================================
local library
local function loadLibrary()
    -- 1. Ưu tiên file local server qua start_local_test.bat (Port 8000)
    pcall(function()
        library = loadstring(game:HttpGet("http://127.0.0.1:8000/inventory.lua"))()
    end)
    -- 2. Đọc file trực tiếp từ workspace nếu executor hỗ trợ readfile
    if not library and isfile and readfile and isfile("inventory.lua") then
        pcall(function()
            library = loadstring(readfile("inventory.lua"))()
        end)
    end
    -- 3. Load từ GitHub repository chính thức
    if not library then
        pcall(function()
            library = loadstring(game:HttpGet("https://raw.githubusercontent.com/suisuimommy-code/SuiSuiHUB/main/inventory.lua"))()
        end)
    end
    -- 4. Backup link dự phòng
    if not library then
        pcall(function()
            library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FZ8nj2VdyKq/inventory/main/ADS%20inventory.lua"))()
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
local function findMiniBossModel(bossId)
    local target = (bossId or ""):lower():gsub("%s+", "")
    -- 1. Tìm qua ProximityPrompt
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local objTxt = (prompt.ObjectText or ""):lower():gsub("%s+", "")
            local pModel = prompt:FindFirstAncestorOfClass("Model")
            local mName = pModel and pModel.Name:lower():gsub("%s+", "") or ""
            
            if (target == "guildmaster" and (objTxt:find("guild") or mName:find("guild")))
                or (target == "chahaein" and (objTxt:find("dancer") or objTxt:find("chahaein") or mName:find("dancer") or mName:find("chahaein")))
                or (objTxt ~= "" and objTxt:find(target))
                or (mName ~= "" and mName:find(target)) then
                return pModel
            end
        end
    end
    -- 2. Tìm qua Model name & Attributes
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local attrId = obj:GetAttribute("MiniBossId") or obj:GetAttribute("BossId")
            if attrId and tostring(attrId):lower():gsub("%s+", "") == target then
                return obj
            end
            local objName = obj.Name:lower():gsub("%s+", "")
            if (target == "guildmaster" and objName:find("guild"))
                or (target == "chahaein" and (objName:find("dancer") or objName:find("chahaein")))
                or (objName:find(target)) then
                return obj
            end
        end
    end
    return nil
end

-- Tự động quét tất cả Mini Boss thực tế đang có trong Workspace trên Map hiện tại (Quét Model & ProximityPrompt)
local function scanCurrentMapMiniBosses()
    local detected = {}
    local seen = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
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
        elseif obj:IsA("ProximityPrompt") then
            local action = (obj.ActionText or ""):lower()
            local objTxt = (obj.ObjectText or ""):lower():gsub("%s+", "")
            if action:find("fight") or action:find("boss") or objTxt:find("boss") then
                local attr = obj:GetAttribute("BossId") or obj:GetAttribute("MiniBossId")
                local candidate = attr and tostring(attr) or (objTxt ~= "" and objTxt or nil)
                if candidate and not seen[candidate] then
                    seen[candidate] = true
                    table.insert(detected, candidate)
                end
                local pModel = obj:FindFirstAncestorOfClass("Model")
                if pModel then
                    local mAttr = pModel:GetAttribute("MiniBossId") or pModel:GetAttribute("BossId")
                    local mName = mAttr and tostring(mAttr) or pModel.Name:lower():gsub("%s+", "")
                    if mName and not seen[mName] then
                        seen[mName] = true
                        table.insert(detected, mName)
                    end
                end
            end
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

local function checkMainBossCooldown(bossId, diff)
    diff = resolveDifficulty(diff)
    if getCooldownRemote then
        local ok, cd = pcall(function()
            return getCooldownRemote:InvokeServer(bossId, diff)
        end)
        if ok and typeof(cd) == "number" then
            return cd
        end
    end
    return 0
end
local checkBossCooldown = checkMainBossCooldown

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

local function selectGameBossDifficulty(diffName)
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg or not diffName then return false end
    local cleanTarget = resolveDifficulty(diffName):lower():gsub("%s+", "")
    for _, desc in ipairs(pg:GetDescendants()) do
        if not isSuiSuiHubElement(desc) and (desc:IsA("TextLabel") or desc:IsA("TextButton")) then
            local txt = (desc.Text or ""):gsub("<[^>]->", ""):lower():gsub("%s+", "")
            if txt == cleanTarget or (txt:find(cleanTarget, 1, true) and not txt:find("ready")) then
                local btn = desc:IsA("GuiButton") and desc or desc:FindFirstAncestorWhichIsA("GuiButton") or desc.Parent
                if btn then
                    pcall(function()
                        if firesignal then
                            firesignal(btn.MouseButton1Click)
                            firesignal(btn.Activated)
                        end
                    end)
                    task.wait(0.12)
                    return true
                end
            end
        end
    end
    return false
end

local function findFightButton()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end

    -- 1. Quét tìm TextLabel hoặc TextButton có Text là "FIGHT" (Bỏ qua rich text, khoảng trắng)
    for _, desc in ipairs(pg:GetDescendants()) do
        if not isSuiSuiHubElement(desc) then
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                local rawText = desc.Text or ""
                local txt = rawText:gsub("<[^>]->", ""):lower():gsub("%s+", "")
                if txt == "fight" or txt:find("^fight") or txt:find("fight$") then
                    if desc:IsA("GuiButton") then
                        return desc
                    end
                    local btn = desc:FindFirstAncestorWhichIsA("GuiButton")
                    if btn then return btn end
                    if desc.Parent and desc.Parent:FindFirstChildWhichIsA("GuiButton") then
                        return desc.Parent:FindFirstChildWhichIsA("GuiButton")
                    end
                    return desc
                end
            end
        end
    end

    -- 2. Quét tìm object có Name chứa "fight"
    for _, desc in ipairs(pg:GetDescendants()) do
        if not isSuiSuiHubElement(desc) then
            local name = (desc.Name or ""):lower():gsub("%s+", "")
            if name == "fight" or name == "fightbutton" or name == "btnfight" or name:find("fight") then
                if desc:IsA("GuiButton") then
                    return desc
                end
                local btn = desc:FindFirstAncestorWhichIsA("GuiButton")
                if btn then return btn end
                return desc
            end
        end
    end

    return nil
end

local function clickGuiElement(btn)
    if not btn then return false end
    local actualBtn = btn
    if not actualBtn:IsA("GuiButton") then
        actualBtn = btn:FindFirstAncestorWhichIsA("GuiButton") or (btn.Parent and btn.Parent:FindFirstChildWhichIsA("GuiButton")) or btn
    end

    local clicked = false

    -- 1. firesignal
    if firesignal then
        pcall(function() firesignal(actualBtn.MouseButton1Down) end)
        pcall(function() firesignal(actualBtn.MouseButton1Click) end)
        pcall(function() firesignal(actualBtn.Activated) end)
        pcall(function() firesignal(actualBtn.MouseButton1Up) end)
        if actualBtn ~= btn then
            pcall(function() firesignal(btn.MouseButton1Click) end)
            pcall(function() firesignal(btn.Activated) end)
        end
        clicked = true
    end

    -- 2. getconnections
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

    -- 3. VirtualInputManager (Click vật lý tới tâm nút)
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local targetObj = (actualBtn.AbsolutePosition and actualBtn.AbsoluteSize) and actualBtn or btn
        if vim and targetObj.AbsolutePosition and targetObj.AbsoluteSize then
            local x = targetObj.AbsolutePosition.X + (targetObj.AbsoluteSize.X / 2)
            local y = targetObj.AbsolutePosition.Y + (targetObj.AbsoluteSize.Y / 2)
            if x > 0 and y > 0 then
                vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
                task.wait(0.04)
                vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
                clicked = true
            end
        end
    end)

    -- 4. VirtualUser fallback
    pcall(function()
        local vu = game:GetService("VirtualUser")
        local targetObj = (actualBtn.AbsolutePosition and actualBtn.AbsoluteSize) and actualBtn or btn
        if vu and targetObj.AbsolutePosition and targetObj.AbsoluteSize then
            local x = targetObj.AbsolutePosition.X + (targetObj.AbsoluteSize.X / 2)
            local y = targetObj.AbsolutePosition.Y + (targetObj.AbsoluteSize.Y / 2)
            if x > 0 and y > 0 then
                vu:Button1Down(Vector2.new(x, y))
                task.wait(0.04)
                vu:Button1Up(Vector2.new(x, y))
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
local function findMainBossModel(bossId)
    local target = (bossId or ""):lower():gsub("%s+", "")
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

    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local objTxt = (prompt.ObjectText or ""):lower():gsub("%s+", "")
            local pModel = prompt:FindFirstAncestorOfClass("Model")
            local mName = pModel and pModel.Name:lower():gsub("%s+", "") or ""

            for _, kw in ipairs(keywords) do
                if objTxt:find(kw) or mName:find(kw) then
                    return pModel, prompt
                end
            end
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local attrId = obj:GetAttribute("BossId") or obj:GetAttribute("MainBossId") or obj:GetAttribute("MiniBossId")
            local mName = obj.Name:lower():gsub("%s+", "")
            for _, kw in ipairs(keywords) do
                if (attrId and tostring(attrId):lower():gsub("%s+", ""):find(kw)) or mName:find(kw) then
                    return obj, obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                end
            end
        end
    end

    return nil, nil
end

local function teleportToMainBoss(bossId)
    local model, prompt = findMainBossModel(bossId)
    if model then
        local pivot = model:GetPivot()
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and pivot then
            hrp.CFrame = pivot * CFrame.new(0, 0, 5)
            Notification("Trùm Cuối", "Đã bay tới gần Trùm Cuối: " .. tostring(bossId), 2)
            if prompt then
                task.wait(0.2)
                pcall(function()
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        prompt:InputHoldBegin()
                        task.wait(prompt.HoldDuration + 0.05)
                        prompt:InputHoldEnd()
                    end
                end)
            end
            return true
        end
    end
    Notification("Trùm Cuối", "Không tìm thấy vị trí Trùm Cuối trong Map hiện tại!", 2)
    return false
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
    if not buildMiniBossRemote then
        buildMiniBossRemote = eventRemotes and eventRemotes:FindFirstChild("BuildMiniBossBattle") or ReplicatedStorage:FindFirstChild("BuildMiniBossBattle", true)
    end

    -- 1. Nếu bảng Boss đang mở, click nút FIGHT trực tiếp trên màn hình
    clickGameFightButton(4, diff)

    -- 2. Bước 1 & 2 theo SimpleSpy: Gọi GetBossCooldown đồng bộ để khởi tạo phiên đấu
    if getCooldownRemote then
        pcall(function()
            getCooldownRemote:InvokeServer(bossId, "Normal")
        end)
        if diff ~= "Normal" then
            pcall(function()
                getCooldownRemote:InvokeServer(bossId, diff)
            end)
        end
    end

    -- Thử kích hoạt BuildMiniBossBattle phòng trường hợp game dùng chung remote này
    if buildMiniBossRemote then
        pcall(function()
            buildMiniBossRemote:InvokeServer(bossId, false)
        end)
    end

    task.wait(0.12)

    -- 3. Bước 4 SimpleSpy: Bấm đánh với độ khó đã chọn (FireServer)
    local reportOk = false
    if reportVictoryRemote then
        reportOk = pcall(function()
            reportVictoryRemote:FireServer(bossId, diff)
        end)
    end

    task.wait(0.2)

    -- 4. Bước 5 SimpleSpy: Nhận quà thưởng chiến thắng
    if reportVictoryRemote then
        pcall(function()
            reportVictoryRemote:FireServer(bossId, diff)
        end)
    end

    safeLog(string.format("[SuiSuiHUB] Đã đấm Trùm Cuối: %s [%s] | Fire: %s", tostring(bossId), tostring(diff), tostring(reportOk)))
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
    end
    if worldsTeleportRemote and mapId then
        worldsTeleportRemote:FireServer(mapId)
        Notification("Teleport", "Đang tele tới Map: " .. tostring(mapId), 2)
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

-- Tự động bấm CONTINUE theo cơ chế Event-driven O(1) (Chỉ kích hoạt khi có bảng xuất hiện, 0% CPU rảnh rỗi)
pcall(function()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then
        pg.DescendantAdded:Connect(function(child)
            if child:IsA("TextButton") or child:IsA("ImageButton") then
                local name = (child.Name or ""):lower():gsub("%s+", "")
                local txt = child:IsA("TextButton") and (child.Text or ""):lower():gsub("%s+", "") or ""
                if txt == "continue" or name:find("continue") or txt:find("continue") then
                    task.wait(0.08)
                    clickContinueButton(child)
                end
            end
        end)
    end
end)

local function autoDismissBossDefeated()
    pcall(function()
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, btn in ipairs(gui:GetChildren()) do
                    if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                        local name = (btn.Name or ""):lower():gsub("%s+", "")
                        local txt = btn:IsA("TextButton") and (btn.Text or ""):lower():gsub("%s+", "") or ""
                        if txt == "continue" or name:find("continue") or txt:find("continue") then
                            clickContinueButton(btn)
                            return
                        end
                    end
                end
            end
        end
    end)
    restorePlayerControls()
end

-- I. Vòng lặp Săn Boss Thường VÔ HẠN (Tự động lặp lại liên tục, xoay vòng tuần tự)
task.spawn(function()
    safeLog("[SuiSuiHUB] Vòng lặp Auto Mini Boss VÔ HẠN đã kích hoạt thành công!")
    while true do
        local loopOk, loopErr = pcall(function()
            if _G.AutoMiniBoss and _G.SelectedMiniBosses and #_G.SelectedMiniBosses > 0 then
                for _, bossId in ipairs(_G.SelectedMiniBosses) do
                    if not _G.AutoMiniBoss then break end
                    
                    -- Đấm boss
                    executeMiniBossBattle(bossId)
                    
                    -- Đóng bảng thông báo chiến thắng
                    task.wait(0.1)
                    autoDismissBossDefeated()
                    
                    -- Nghỉ giữa các lượt đấm
                    local delay = tonumber(_G.BossDelay) or 0.5
                    task.wait(math.max(delay, 0.2))
                end
            end
        end)
        
        if not loopOk then
            safeWarn("[SuiSuiHUB] Lỗi vòng lặp Mini Boss (tự động phục hồi): " .. tostring(loopErr))
        end
        
        -- Luôn nghỉ 0.5s sau mỗi chu kỳ xoay vòng để bắt đầu vòng lặp tiếp theo
        task.wait(0.5)
    end
end)

local currentLoadedMapId = nil

-- J. Vòng lặp Săn Boss Chính (Trùm Cuối) VÔ HẠN (Thread độc lập, xoay vòng nhiều boss)
task.spawn(function()
    safeLog("[SuiSuiHUB] Vòng lặp Auto Boss Chính VÔ HẠN đã kích hoạt!")
    while true do
        local loopOk, loopErr = pcall(function()
            if _G.AutoMainBoss and _G.SelectedMainBosses and #_G.SelectedMainBosses > 0 then
                for _, bossTitleOrId in ipairs(_G.SelectedMainBosses) do
                    if not _G.AutoMainBoss then break end
                    
                    local bId = resolveMainBossId(bossTitleOrId)
                    local diff = _G.SelectedMainDifficulty or "Normal"
                    local mapId = getMainBossMapId(bId)
                    
                    -- 1. Quản lý chuyển Map thông minh & thời gian nạp map
                    if currentLoadedMapId ~= mapId then
                        safeLog(string.format("[SuiSuiHUB] Chuyển tới Map mới: %s -> Chờ 3.0s nạp map hoàn chỉnh...", tostring(mapId)))
                        teleportToWorld(mapId)
                        currentLoadedMapId = mapId
                        task.wait(3.0)
                    else
                        -- Đang ở cùng map từ trước, chỉ chờ 1.5s
                        task.wait(1.5)
                    end
                    if not _G.AutoMainBoss then break end
                    
                    -- 2. Teleport tới gần Boss Cuối và kích hoạt prompt (Bấm E)
                    teleportToMainBoss(bId)
                    task.wait(0.8)
                    if not _G.AutoMainBoss then break end

                    -- 3. Tự động chọn độ khó & click nút FIGHT trên màn hình game (Retry tối đa 8 lần)
                    autoClickFightLoop(8, diff)

                    -- 4. Đấm trùm cuối & nhận quà thưởng (kết hợp cả click UI FIGHT và chuỗi remote đồng bộ)
                    executeBossVictory(bId, diff)
                    
                    -- Đóng bảng thông báo chiến thắng
                    task.wait(0.15)
                    autoDismissBossDefeated()
                    
                    -- Nghỉ giữa các lượt đấm
                    local delayTime = tonumber(_G.BossDelay) or 0.5
                    task.wait(math.max(delayTime, 0.2))
                end
            end
        end)
        
        if not loopOk then
            safeWarn("[SuiSuiHUB] Lỗi vòng lặp Boss Chính (tự động phục hồi): " .. tostring(loopErr))
        end
        
        task.wait(0.5)
    end
end)

-- L. Vòng lặp Auto Quay Vòng Quay (Auto Spin Wheel)
task.spawn(function()
    while true do
        if _G.AutoSpinWheel then
            pcall(function()
                spinWheel(_G.SpinAmount or 11)
            end)
            local d = tonumber(_G.SpinDelay) or 1.0
            task.wait(math.max(d, 0.3))
        else
            task.wait(0.5)
        end
    end
end)

-- M. Vòng lặp Auto Nhận Quests
task.spawn(function()
    while true do
        if _G.AutoGetQuests then
            pcall(function()
                fetchQuests()
            end)
            local d = tonumber(_G.QuestDelay) or 10
            task.wait(math.max(d, 1))
        else
            task.wait(1)
        end
    end
end)

-- N. Vòng lặp Auto Farm SIEGE (Chạy tuần tự từ Stage 1 tới Stage Dừng)
task.spawn(function()
    safeLog("[SuiSuiHUB] Vòng lặp Auto SIEGE đã kích hoạt!")
    while true do
        local loopOk, loopErr = pcall(function()
            if _G.AutoSiege then
                local currentStage = tonumber(_G.SiegeCurrentStage) or 1
                local stopStage = tonumber(_G.SiegeStopStage) or 20
                if currentStage < 1 then currentStage = 1 end
                if stopStage < 1 then stopStage = 20 end

                safeLog(string.format("[SuiSuiHUB] Đang farm Siege: Stage %d / %d (Mục tiêu dừng: %d)...", currentStage, stopStage, stopStage))
                
                -- Thực thi farm stage
                executeSiegeStage(currentStage)

                -- Kiểm tra điều kiện dừng
                if currentStage >= stopStage then
                    safeLog(string.format("[SuiSuiHUB] Đã hoàn thành Stage %d (Đạt mục tiêu dừng %d) -> Tự động dừng Auto Siege!", currentStage, stopStage))
                    Notification("SIEGE Hoàn Thành", string.format("Đã hoàn tất Stage %d! Đạt mục tiêu dừng %d. Đã tự tắt Auto Siege.", currentStage, stopStage), 4)
                    _G.AutoSiege = false
                    _G.SiegeCurrentStage = 1
                    if SiegeToggleItem and SiegeToggleItem.Set then
                        SiegeToggleItem:Set(false)
                    end
                    saveConfig()
                else
                    _G.SiegeCurrentStage = currentStage + 1
                    safeLog(string.format("[SuiSuiHUB] Chuyển tiếp sang Stage %d...", _G.SiegeCurrentStage))
                end

                local delayTime = tonumber(_G.SiegeDelay) or 1.0
                task.wait(math.max(delayTime, 0.5))
            else
                task.wait(0.5)
            end
        end)

        if not loopOk then
            safeWarn("[SuiSuiHUB] Lỗi vòng lặp Siege (tự động phục hồi): " .. tostring(loopErr))
            task.wait(0.5)
        end
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

SecBossRight:AddSlider("Tốc Độ Đánh / Delay (Giây)", 0.2, _G.BossDelay, 2.0, 2, function(v)
    _G.BossDelay = v
    if uiFullyLoaded then saveConfig() end
end)

SecBossRight:AddButton("Bay Tới Map & Trùm Cuối (Mở Menu Boss)", function()
    task.spawn(function()
        local target = _G.SelectedMainBosses and _G.SelectedMainBosses[1] or "The Shadow Monarch (queen)"
        local bId = resolveMainBossId(target)
        local mapId = getMainBossMapId(bId)
        if currentLoadedMapId ~= mapId then
            safeLog(string.format("[SuiSuiHUB] Chuyển tới Map mới: %s -> Chờ 3.0s nạp map hoàn chỉnh...", tostring(mapId)))
            teleportToWorld(mapId)
            currentLoadedMapId = mapId
            task.wait(3.0)
        else
            task.wait(1.5)
        end
        teleportToMainBoss(bId)
    end)
end)

SecBossRight:AddButton("Đấm Thử Boss Chính 1 Lần", function()
    task.spawn(function()
        local target = _G.SelectedMainBosses and _G.SelectedMainBosses[1] or "The Shadow Monarch (queen)"
        local bId = resolveMainBossId(target)
        local diff = _G.SelectedMainDifficulty or "Normal"
        Notification("Boss Chính", string.format("Đang đấm thử %s [%s]...", bId, resolveDifficulty(diff)), 2)
        local ok = executeBossVictory(bId, diff)
        Notification("Boss Chính", string.format("Kết quả: %s", tostring(ok)), 3)
    end)
end)

SecBossRight:AddButton("Kiểm Tra Cooldown Trùm Cuối", function()
    task.spawn(function()
        local target = _G.SelectedMainBosses and _G.SelectedMainBosses[1] or "The Shadow Monarch (queen)"
        local bId = resolveMainBossId(target)
        local diff = _G.SelectedMainDifficulty or "Normal"
        local cd = checkMainBossCooldown(bId, diff)
        Notification("Cooldown Boss Chính", string.format("Boss %s [%s]: %s giây", bId, resolveDifficulty(diff), tostring(cd)), 3)
    end)
end)

SecBossRight:AddToggle("Auto Đấm Boss Chính (Xoay Vòng)", _G.AutoMainBoss, function(v)
    _G.AutoMainBoss = v
    if uiFullyLoaded then saveConfig() end
    Notification("Boss Chính", v and "Đã BẬT Auto đấm toàn bộ Trùm Cuối đã chọn!" or "Đã TẮT!", 2)
end)

-- ========================================================================
-- TAB 2: SIEGE (DUNGEON BATTLE & PROGRESS)
-- ========================================================================
local TabSiege = Window:CreateTab("SIEGE")
local SecSiegeLeft = TabSiege:CreateSector("1. Tự Động Farm SIEGE", "left")
local SecSiegeRight = TabSiege:CreateSector("2. Tiện Ích SIEGE & Teleport", "right")

local SiegeStopDropdownItem
local SiegeToggleItem

local ALL_SIEGE_STOP_STAGES = {}
for i = 1, 20 do
    table.insert(ALL_SIEGE_STOP_STAGES, string.format("Stage %02d", i))
end

local defaultStopStageStr = string.format("Stage %02d", tonumber(_G.SiegeStopStage) or 20)

SiegeStopDropdownItem = SecSiegeLeft:AddDropdown("Dừng Lại Tại Stage (Target Stop)", ALL_SIEGE_STOP_STAGES, defaultStopStageStr, false, function(v)
    local stageNum = tonumber(v:match("%d+")) or 20
    _G.SiegeStopStage = stageNum
    if uiFullyLoaded then saveConfig() end
    safeLog(string.format("[SuiSuiHUB] Đã đặt mục tiêu dừng Siege tại: Stage %02d", stageNum))
end)

SecSiegeLeft:AddSlider("Tốc Độ Farm / Delay (Giây)", 0.3, _G.SiegeDelay, 5.0, 1, function(v)
    _G.SiegeDelay = v
    if uiFullyLoaded then saveConfig() end
end)

SiegeToggleItem = SecSiegeLeft:AddToggle("Auto Farm SIEGE (1 -> Điểm Dừng)", _G.AutoSiege, function(v)
    _G.AutoSiege = v
    if uiFullyLoaded then saveConfig() end
    if v then
        Notification("SIEGE", string.format("Đã BẬT Auto Farm! Sẽ chạy tuần tự tới Stage %02d rồi dừng.", _G.SiegeStopStage or 20), 3)
    else
        Notification("SIEGE", "Đã TẮT Auto Farm SIEGE!", 2)
    end
end)

SecSiegeLeft:AddButton("Reset Về Bắt Đầu Từ Stage 1", function()
    _G.SiegeCurrentStage = 1
    Notification("SIEGE", "Đã reset tiến độ bắt đầu về Stage 01!", 2)
end)

-- Cột Phải: Tiện Ích SIEGE
SecSiegeRight:AddButton("Teleport Tới NPC Siege (axi)", function()
    teleportToSiegeNpc()
end)

SecSiegeRight:AddButton("Dừng Nhanh Tại Stage 05", function()
    _G.SiegeStopStage = 5
    if SiegeStopDropdownItem and SiegeStopDropdownItem.Set then
        SiegeStopDropdownItem:Set("Stage 05")
    end
    if uiFullyLoaded then saveConfig() end
    Notification("SIEGE", "Mục tiêu dừng: Stage 05", 2)
end)

SecSiegeRight:AddButton("Dừng Nhanh Tại Stage 10", function()
    _G.SiegeStopStage = 10
    if SiegeStopDropdownItem and SiegeStopDropdownItem.Set then
        SiegeStopDropdownItem:Set("Stage 10")
    end
    if uiFullyLoaded then saveConfig() end
    Notification("SIEGE", "Mục tiêu dừng: Stage 10", 2)
end)

SecSiegeRight:AddButton("Dừng Nhanh Tại Stage 20", function()
    _G.SiegeStopStage = 20
    if SiegeStopDropdownItem and SiegeStopDropdownItem.Set then
        SiegeStopDropdownItem:Set("Stage 20")
    end
    if uiFullyLoaded then saveConfig() end
    Notification("SIEGE", "Mục tiêu dừng: Stage 20", 2)
end)

SecSiegeRight:AddButton("Đánh Thử Stage 1 Lần (Thủ Công)", function()
    task.spawn(function()
        local stage = tonumber(_G.SiegeCurrentStage) or 1
        Notification("SIEGE", string.format("Đang đánh thử Stage %d...", stage), 2)
        local ok = executeSiegeStage(stage)
        Notification("SIEGE", string.format("Stage %d -> Kết quả: %s", stage, tostring(ok)), 3)
    end)
end)

SecSiegeRight:AddButton("Kiểm Tra Tiến Độ (GetDungeonProgress)", function()
    task.spawn(function()
        local remote = eventRemotes and eventRemotes:FindFirstChild("GetDungeonProgress") or ReplicatedStorage:FindFirstChild("GetDungeonProgress", true)
        if remote then
            local ok, res = pcall(function() return remote:InvokeServer() end)
            local str = ok and tostring(res) or "Lỗi"
            if typeof(res) == "table" then
                str = string.format("Stage: %s | P1: %s", tostring(res.Stage or res[1]), tostring(res[2]))
            end
            Notification("Tiến Độ Siege", "DungeonProgress: " .. str, 4)
        else
            Notification("Tiến Độ Siege", "Không tìm thấy Remote GetDungeonProgress!", 3)
        end
    end)
end)

SecSiegeRight:AddButton("Kiểm Tra Cooldown (GetDungeonCooldown)", function()
    task.spawn(function()
        local remote = eventRemotes and eventRemotes:FindFirstChild("GetDungeonCooldown") or ReplicatedStorage:FindFirstChild("GetDungeonCooldown", true)
        if remote then
            local ok, res = pcall(function() return remote:InvokeServer() end)
            Notification("Cooldown Siege", "GetDungeonCooldown: " .. tostring(res), 3)
        else
            Notification("Cooldown Siege", "Không tìm thấy Remote GetDungeonCooldown!", 3)
        end
    end)
end)

SecSiegeRight:AddButton("Nhận Thưởng Thủ Công (Claim Reward)", function()
    task.spawn(function()
        local remote = eventRemotes and eventRemotes:FindFirstChild("ClaimDungeonReward") or ReplicatedStorage:FindFirstChild("ClaimDungeonReward", true)
        if remote then
            local stage = tonumber(_G.SiegeCurrentStage) or 1
            local ok, res = pcall(function() return remote:InvokeServer(stage) end)
            Notification("Claim Siege", string.format("Claim Stage %d: %s", stage, tostring(ok)), 3)
        else
            Notification("Claim Siege", "Không tìm thấy Remote ClaimDungeonReward!", 3)
        end
    end)
end)

-- ========================================================================
-- TAB 3: TIỆN ÍCH (SPIN, QUESTS, TELEPORT NPC)
-- ========================================================================
local TabUtilities = Window:CreateTab("Tiện Ích")
local SecUtilLeft = TabUtilities:CreateSector("1. Vòng Quay (Spin) & Nhiệm Vụ", "left")
local SecUtilRight = TabUtilities:CreateSector("2. Dịch Chuyển NPC (Teleport)", "right")

-- 1. VÒNG QUAY (WHEEL REMOTE)
local spinOptions = { "11 Lượt / Lần", "1 Lượt / Lần" }
SecUtilLeft:AddDropdown("Số Lượt Quay Mỗi Lần", spinOptions, "11 Lượt / Lần", false, function(v)
    if v:find("11") then
        _G.SpinAmount = 11
    else
        _G.SpinAmount = 1
    end
end)

SecUtilLeft:AddSlider("Tốc Độ / Delay Quay (Giây)", 0.3, _G.SpinDelay, 5.0, 1, function(v)
    _G.SpinDelay = v
end)

SecUtilLeft:AddToggle("Auto Quay Vòng Quay (Spin)", _G.AutoSpinWheel, function(v)
    _G.AutoSpinWheel = v
    Notification("Vòng Quay", v and string.format("Đã BẬT Auto Quay (%d lượt/lần)!", _G.SpinAmount or 11) or "Đã TẮT!", 2)
end)

SecUtilLeft:AddButton("Quay Thử 1 Lần (11 Lượt)", function()
    task.spawn(function()
        local ok, res = spinWheel(_G.SpinAmount or 11)
        Notification("Vòng Quay", ok and string.format("Đã gửi lệnh quay %d lượt!", _G.SpinAmount or 11) or "Lỗi gửi lệnh quay!", 2)
    end)
end)

-- 2. NHẬN NHIỆM VỤ (GET QUESTS)
SecUtilLeft:AddToggle("Tự Động Nhận / Cập Nhật Quests", _G.AutoGetQuests, function(v)
    _G.AutoGetQuests = v
    Notification("Nhiệm Vụ", v and "Đã BẬT tự động nhận Quests!" or "Đã TẮT!", 2)
end)

SecUtilLeft:AddSlider("Chu Kỳ Nhận Quests (Giây)", 2, _G.QuestDelay, 60, 0, function(v)
    _G.QuestDelay = v
end)

SecUtilLeft:AddButton("Nhận / Cập Nhật Quests Ngay", function()
    task.spawn(function()
        local ok, res = fetchQuests()
        Notification("Nhiệm Vụ", ok and "Đã cập nhật Quests thành công!" or "Lỗi nhận Quests!", 2)
    end)
end)

-- 3. TELEPORT NPC
local npcDisplayMap = {
    ["NPC Trait System (Tẩy Trait)"] = "trait system npc",
}
local npcDisplayList = {
    "NPC Trait System (Tẩy Trait)"
}

SecUtilRight:AddButton("Teleport Tới NPC Trait System", function()
    teleportToNpc("trait system npc")
end)

SecUtilRight:AddDropdown("Danh Sách NPC", npcDisplayList, "NPC Trait System (Tẩy Trait)", false, function(v)
    _G.SelectedNpcTeleport = npcDisplayMap[v] or "trait system npc"
end)

SecUtilRight:AddButton("Dịch Chuyển Tới NPC Đã Chọn", function()
    teleportToNpc(_G.SelectedNpcTeleport or "trait system npc")
end)

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

