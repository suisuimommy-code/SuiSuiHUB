--[[
    ========================================================================
    SuiSuiHUB | Card Origins (Refactored & High-Performance Edition)
    PlaceId: 78312396550517 | Tối ưu hóa 3 Chức năng cốt lõi
    - Tab 1: Săn Boss (Trùm Cuối xoay vòng Bật -> Đánh -> Nhận -> Tắt, Mini Boss)
    - Tab 2: RiftGATE (Chu kỳ 15 phút :00, :15, :30, :45)
    - Tab 3: Cài Đặt (Anti-AFK, WhiteScreen, FPS Boost, Speed, Ẩn Menu Khởi Động)
    ========================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local function safeLog(...)
    if _G.DisableConsoleLogs then return end
    pcall(function(...) print(...) end, ...)
end

local function safeWarn(...)
    if _G.DisableConsoleLogs then return end
    pcall(function(...) warn(...) end, ...)
end

local function Notification(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title or "SuiSuiHUB"),
            Text = tostring(text or ""),
            Duration = tonumber(duration) or 3
        })
    end)
end

-- ========================================================================
-- 1. LOAD UI LIBRARY (inventory.lua)
-- ========================================================================
local library
local function loadLibrary()
    pcall(function()
        library = loadstring(game:HttpGet("https://raw.githubusercontent.com/suisuimommy-code/SuiSuiHUB/main/inventory.lua"))()
    end)
    if not library then
        pcall(function()
            library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FZ8nj2VdyKq/inventory/main/ADS%20inventory.lua"))()
        end)
    end
    if not library and isfile and readfile and isfile("inventory.lua") then
        pcall(function()
            library = loadstring(readfile("inventory.lua"))()
        end)
    end
    if not library then
        pcall(function()
            library = loadstring(game:HttpGet("http://127.0.0.1:8000/inventory.lua"))()
        end)
    end
    return library
end

library = loadLibrary()
if not library then
    safeWarn("[SuiSuiHUB] Không thể tải inventory.lua!")
    return
end

-- ========================================================================
-- 2. CẤU HÌNH REMOTES (CHÍNH XÁC THEO LOG F9 CAPTURED)
-- ========================================================================
local eventRemotes = ReplicatedStorage:WaitForChild("EventRemotes", 5)
local reportVictoryRemote = eventRemotes and eventRemotes:FindFirstChild("ReportBossVictory") or ReplicatedStorage:FindFirstChild("ReportBossVictory", true)
local getCooldownRemote = eventRemotes and eventRemotes:FindFirstChild("GetBossCooldown") or ReplicatedStorage:FindFirstChild("GetBossCooldown", true)
local buildMiniBossRemote = eventRemotes and eventRemotes:FindFirstChild("BuildMiniBossBattle") or ReplicatedStorage:FindFirstChild("BuildMiniBossBattle", true)
local worldsTeleportRemote = ReplicatedStorage:FindFirstChild("WorldsTeleportRequest", true)
local setAutoBossRemote = eventRemotes and eventRemotes:FindFirstChild("SetAutoBossFight") or ReplicatedStorage:FindFirstChild("SetAutoBossFight", true)
local endBattleRemote = eventRemotes and eventRemotes:FindFirstChild("EndBattle") or ReplicatedStorage:FindFirstChild("EndBattle", true)
local startBattleRemote = eventRemotes and eventRemotes:FindFirstChild("StartBattle") or ReplicatedStorage:FindFirstChild("StartBattle", true)
local reportBattleDmgRemote = eventRemotes and eventRemotes:FindFirstChild("ReportBattleDamage") or ReplicatedStorage:FindFirstChild("ReportBattleDamage", true)
local getBorderProgRemote = eventRemotes and eventRemotes:FindFirstChild("GetBossBorderProgress") or ReplicatedStorage:FindFirstChild("GetBossBorderProgress", true)
local getAutoBossRemote = eventRemotes and eventRemotes:FindFirstChild("GetAutoBossFight") or ReplicatedStorage:FindFirstChild("GetAutoBossFight", true)

-- RiftGATE Remotes
local riftGateEnterRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateEnterRequest") or ReplicatedStorage:FindFirstChild("RiftGateEnterRequest", true)
local buildRiftBattleRemote = eventRemotes and eventRemotes:FindFirstChild("BuildRiftGateBattle") or ReplicatedStorage:FindFirstChild("BuildRiftGateBattle", true)
local riftStartFightRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateStartFight") or ReplicatedStorage:FindFirstChild("RiftGateStartFight", true)
local reportRiftVictoryRemote = eventRemotes and eventRemotes:FindFirstChild("ReportRiftGateVictory") or ReplicatedStorage:FindFirstChild("ReportRiftGateVictory", true)
local riftRewardRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateReward") or ReplicatedStorage:FindFirstChild("RiftGateReward", true)
local riftGateLeaveRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateLeave") or ReplicatedStorage:FindFirstChild("RiftGateLeave", true)
local riftGateSpawnedRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateSpawned") or ReplicatedStorage:FindFirstChild("RiftGateSpawned", true)
local riftGateClosedRemote = eventRemotes and eventRemotes:FindFirstChild("RiftGateClosed") or ReplicatedStorage:FindFirstChild("RiftGateClosed", true)

local isServerRiftGateOpen = false
local hasFarmedCurrentRiftGate = false -- Đánh dấu đã farm xong đợt này (tránh lặp lại & tele vào lại)

if riftGateSpawnedRemote and riftGateSpawnedRemote.OnClientEvent then
    pcall(function()
        riftGateSpawnedRemote.OnClientEvent:Connect(function()
            isServerRiftGateOpen = true
            hasFarmedCurrentRiftGate = false -- Cổng mới mở: Sẵn sàng cho đợt farm mới
            safeLog("[SuiSuiHUB] Nhận tín hiệu Server: Cổng RiftGate vừa mở đợt mới!")
            Notification("RiftGATE", "CỔNG RIFTGATE VỪA MỞ TRÊN MAP!", 5)
        end)
    end)
end
if riftGateClosedRemote and riftGateClosedRemote.OnClientEvent then
    pcall(function()
        riftGateClosedRemote.OnClientEvent:Connect(function()
            isServerRiftGateOpen = false
            hasFarmedCurrentRiftGate = false -- Cổng đóng: Reset để đón đợt kế tiếp
            safeLog("[SuiSuiHUB] Nhận tín hiệu Server: Cổng RiftGate đã đóng!")
        end)
    end)
end

-- ========================================================================
-- 3. HỆ THỐNG DỮ LIỆU GAME (WORLDS, BOSSES, GUIS)
-- ========================================================================
local GAME_WORLDS = {
    ["World 02: DUNGEON (queen)"] = {
        mapId = "sjwmap",
        miniBosses = { { id = "chahaein", name = "Cha Hae-In" }, { id = "guildmaster", name = "Guild Master" } },
        mainBoss = { id = "queen", name = "The Shadow Monarch", gui = "WorldBossGui" }
    },
    ["World 04: LIMITLESS DOMAIN (gojo)"] = {
        mapId = "gojodomainv2",
        miniBosses = { { id = "sukuna", name = "Sukuna" }, { id = "yuta", name = "Yuta" } },
        mainBoss = { id = "gojo", name = "The Honored One", gui = "GojoBossGui" }
    },
    ["World 05: DEVIL HEART (kurumi)"] = {
        mapId = "kurumimapspawn",
        miniBosses = { { id = "yuno", name = "Yuno" }, { id = "swordempress", name = "Sword Empress" } },
        mainBoss = { id = "kurumi", name = "Clockmaiden", gui = "KurumiBossGui" }
    },
    ["World 06: THE MYSTERIOUS LIBRARY (klein)"] = {
        mapId = "library",
        miniBosses = {},
        mainBoss = nil
    }
}

local MapOptions = {
    "World 02: DUNGEON (queen)",
    "World 04: LIMITLESS DOMAIN (gojo)",
    "World 05: DEVIL HEART (kurumi)",
    "World 06: THE MYSTERIOUS LIBRARY (klein)"
}

local ALL_MINI_BOSS_LIST = {
    "chahaein", "guildmaster", "sukuna", "yuta", "yuno", "swordempress"
}

local ALL_MAIN_BOSS_LIST = {
    "The Shadow Monarch (queen)",
    "The Honored One (gojo)",
    "Clockmaiden (kurumi)"
}

local MAIN_BOSS_DIFFICULTIES = {
    "01: NORMAL (Normal)",
    "02: CALAMITY (Gold)",
    "03: UMBRAL (Rainbow)",
    "04: ASTRAL (Uni)",
    "05: PARADOX (Paradox)",
    "06: ORIGIN (Origin)"
}

local BOSS_MAP_MAPPING = {
    ["queen"] = "sjwmap",
    ["gojo"] = "gojodomainv2",
    ["kurumi"] = "kurumimapspawn"
}

local BOSS_GUI_NAME_MAP = {
    ["queen"] = "WorldBossGui",
    ["kurumi"] = "KurumiBossGui",
    ["gojo"] = "GojoBossGui",
    ["eydis"] = "EydisBossGui"
}

-- Trạng thái toàn cục
_G.SelectedMap = _G.SelectedMap or "World 02: DUNGEON (queen)"
_G.SelectedMiniBosses = _G.SelectedMiniBosses or { "chahaein", "guildmaster" }
_G.AutoMiniBoss = _G.AutoMiniBoss or false
_G.SelectedMainBosses = _G.SelectedMainBosses or { "The Shadow Monarch (queen)" }
_G.SelectedMainDifficulty = _G.SelectedMainDifficulty or "Normal"
_G.MainBossDifficulties = _G.MainBossDifficulties or {
    ["queen"] = "04: ASTRAL (Uni)",
    ["gojo"] = "02: CALAMITY (Gold)",
    ["kurumi"] = "03: UMBRAL (Rainbow)"
}
_G.AutoMainBoss = _G.AutoMainBoss or false
_G.PriorityMode = _G.PriorityMode or "RiftGate > Boss Chính > Boss Mini (Mặc Định)"
_G.BossDelay = _G.BossDelay or 0.5
_G.RiftNotify = _G.RiftNotify or true
_G.AutoRiftGate = _G.AutoRiftGate or false
_G.AntiAFK = _G.AntiAFK or true
_G.DisableConsoleLogs = _G.DisableConsoleLogs or false
_G.WhiteScreen = _G.WhiteScreen or false
_G.FPSBoost = _G.FPSBoost or false
_G.HideMenuOnStartup = _G.HideMenuOnStartup or false
_G.WalkSpeedEnabled = _G.WalkSpeedEnabled or false
_G.WalkSpeedValue = _G.WalkSpeedValue or 16

local isMiniBossBusy = false
local isMainBossFighting = false
local isRiftGateBusy = false
local lastDefeatedBossTime = {}

-- ========================================================================
-- 4. HỆ THỐNG LƯU / TẢI CẤU HÌNH (PERSISTENT CONFIG)
-- ========================================================================
local CONFIG_DIR = "!SuiSuiHUB/Card Origins"
local CONFIG_FILE_NAME = CONFIG_DIR .. "/config.json"

local function ensureConfigDir()
    pcall(function()
        if isfolder and makefolder then
            if not isfolder("!SuiSuiHUB") then makefolder("!SuiSuiHUB") end
            if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end
        end
    end)
end

local function saveConfig()
    pcall(function()
        if not writefile then return end
        ensureConfigDir()
        local cfg = {
            SelectedMap = _G.SelectedMap,
            SelectedMiniBosses = _G.SelectedMiniBosses,
            AutoMiniBoss = _G.AutoMiniBoss,
            SelectedMainBosses = _G.SelectedMainBosses,
            SelectedMainDifficulty = _G.SelectedMainDifficulty,
            MainBossDifficulties = _G.MainBossDifficulties,
            AutoMainBoss = _G.AutoMainBoss,
            PriorityMode = _G.PriorityMode,
            BossDelay = _G.BossDelay,
            RiftNotify = _G.RiftNotify,
            AutoRiftGate = _G.AutoRiftGate,
            AntiAFK = _G.AntiAFK,
            DisableConsoleLogs = _G.DisableConsoleLogs,
            WhiteScreen = _G.WhiteScreen,
            FPSBoost = _G.FPSBoost,
            HideMenuOnStartup = _G.HideMenuOnStartup,
            WalkSpeedEnabled = _G.WalkSpeedEnabled,
            WalkSpeedValue = _G.WalkSpeedValue
        }
        writefile(CONFIG_FILE_NAME, HttpService:JSONEncode(cfg))
    end)
end

local function loadConfig()
    pcall(function()
        if not isfile or not readfile then return end
        ensureConfigDir()
        -- Tự động migrate file cũ nếu có
        local targetFile = CONFIG_FILE_NAME
        if not isfile(targetFile) and isfile("SuiSuiHUB_CardOrigins_Config.json") then
            targetFile = "SuiSuiHUB_CardOrigins_Config.json"
        end
        if isfile(targetFile) then
            local data = HttpService:JSONDecode(readfile(targetFile))
            if data then
                if data.SelectedMap ~= nil then _G.SelectedMap = data.SelectedMap end
                if data.SelectedMiniBosses ~= nil then _G.SelectedMiniBosses = data.SelectedMiniBosses end
                if data.AutoMiniBoss ~= nil then _G.AutoMiniBoss = data.AutoMiniBoss end
                if data.SelectedMainBosses ~= nil then _G.SelectedMainBosses = data.SelectedMainBosses end
                if data.SelectedMainDifficulty ~= nil then _G.SelectedMainDifficulty = data.SelectedMainDifficulty end
                if data.MainBossDifficulties ~= nil then
                    _G.MainBossDifficulties = data.MainBossDifficulties
                end
                if data.AutoMainBoss ~= nil then _G.AutoMainBoss = data.AutoMainBoss end
                if data.PriorityMode ~= nil then _G.PriorityMode = data.PriorityMode end
                if data.BossDelay ~= nil then _G.BossDelay = data.BossDelay end
                if data.RiftNotify ~= nil then _G.RiftNotify = data.RiftNotify end
                if data.AutoRiftGate ~= nil then _G.AutoRiftGate = data.AutoRiftGate end
                if data.AntiAFK ~= nil then _G.AntiAFK = data.AntiAFK end
                if data.DisableConsoleLogs ~= nil then _G.DisableConsoleLogs = data.DisableConsoleLogs end
                if data.WhiteScreen ~= nil then _G.WhiteScreen = data.WhiteScreen end
                if data.FPSBoost ~= nil then _G.FPSBoost = data.FPSBoost end
                if data.HideMenuOnStartup ~= nil then _G.HideMenuOnStartup = data.HideMenuOnStartup end
                if data.WalkSpeedEnabled ~= nil then _G.WalkSpeedEnabled = data.WalkSpeedEnabled end
                if data.WalkSpeedValue ~= nil then _G.WalkSpeedValue = data.WalkSpeedValue end
            end
        end
    end)
end

loadConfig()

-- ========================================================================
-- 5. TIỆN ÍCH GUI, ĐIỀU KHIỂN & BẬT/TẮT IN-GAME AUTO FIGHT
-- ========================================================================

-- Click GUI element an toàn, siêu nhẹ, không gây lag frame
local function clickGuiElement(btn)
    if not btn then return false end
    local clicked = false
    if firesignal then
        pcall(function()
            if btn.MouseButton1Click then firesignal(btn.MouseButton1Click) end
            if btn.Activated then firesignal(btn.Activated) end
            clicked = true
        end)
    end
    if not clicked then
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            task.wait(0.02)
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
            clicked = true
        end)
    end
    return clicked
end

-- BẬT / TẮT In-Game Auto Fight (Chuẩn đối số (bossId, diffInternal) theo log dj cung cấp)
local function setInGameAutoBoss(bossId, enable, diffInternal)
    pcall(function()
        local rem = setAutoBossRemote or (eventRemotes and eventRemotes:FindFirstChild("SetAutoBossFight")) or ReplicatedStorage:FindFirstChild("SetAutoBossFight", true)
        if not rem then return end
        if enable and bossId then
            diffInternal = diffInternal or "Normal"
            -- Gửi trực tiếp đúng canonical bossId và độ khó nội bộ (VD: "queen", "Uni")
            rem:FireServer(bossId, diffInternal)
        else
            rem:FireServer("", nil)
        end
    end)
end

-- Teleport tới Map (Sử dụng FireServer chuẩn cho RemoteEvent WorldsTeleportRequest)
local function teleportToWorld(mapId)
    if not mapId then return false end
    if not worldsTeleportRemote then
        worldsTeleportRemote = ReplicatedStorage:FindFirstChild("WorldsTeleportRequest", true)
    end
    if worldsTeleportRemote then
        local ok = pcall(function()
            if worldsTeleportRemote:IsA("RemoteFunction") then
                worldsTeleportRemote:InvokeServer(mapId)
            else
                worldsTeleportRemote:FireServer(mapId)
            end
        end)
        return ok
    end
    return false
end

-- Định vị Map hiện tại
local function detectCurrentMapId()
    local name = (workspace.Name or ""):lower()
    for _, mapKey in ipairs({"sjwmap", "kurumimapspawn", "gojodomainv2", "namimap", "eydismap"}) do
        if name:find(mapKey) or workspace:FindFirstChild(mapKey) then
            return mapKey
        end
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        local n = obj.Name:lower()
        for _, mapKey in ipairs({"sjwmap", "kurumimapspawn", "gojodomainv2", "namimap", "eydismap"}) do
            if n:find(mapKey) then return mapKey end
        end
    end
    return ""
end

-- Phân giải tên trùm cuối & độ khó
local function resolveMainBossId(title)
    if not title then return "queen" end
    local lower = title:lower()
    if lower:find("shadow") or lower:find("queen") or lower:find("monarch") or lower:find("sjw") then
        return "queen"
    elseif lower:find("kurumi") or lower:find("clock") then
        return "kurumi"
    elseif lower:find("gojo") or lower:find("honored") or lower:find("limitless") then
        return "gojo"
    elseif lower:find("eydis") or lower:find("evolution") then
        return "eydis"
    elseif lower:find("nami") then
        return "nami"
    end
    return "queen"
end

local function resolveDifficultyInternal(diffStr)
    if not diffStr then return "Normal" end
    local s = diffStr:lower()
    if s:find("astral") or s:find("uni") or s:find("04") then
        return "Uni"
    elseif s:find("umbral") or s:find("rainbow") or s:find("03") then
        return "Rainbow"
    elseif s:find("calamity") or s:find("gold") or s:find("02") then
        return "Gold"
    elseif s:find("paradox") or s:find("05") then
        return "Paradox"
    elseif s:find("origin") or s:find("06") then
        return "Origin"
    elseif s:find("normal") or s:find("01") then
        return "Normal"
    end
    return diffStr
end

local function resolveDifficulty(diff)
    return resolveDifficultyInternal(diff)
end

-- Lấy giao diện của Trùm tương ứng (Chống xung đột GUI Gojo đè lên)
local function getActiveBossScreenGui(targetBossId)
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local targetGuiName = targetBossId and BOSS_GUI_NAME_MAP[targetBossId]
    if targetGuiName then
        local g = pg:FindFirstChild(targetGuiName)
        if g and g.Enabled then return g end
    end
    for _, gName in ipairs({"WorldBossGui", "KurumiBossGui", "GojoBossGui", "EydisBossGui"}) do
        local g = pg:FindFirstChild(gName)
        if g and g.Enabled then return g end
    end
    return nil
end

-- Đóng giao diện trùm
local function closeActiveBossGui(targetBossId)
    pcall(function()
        local bossGui = getActiveBossScreenGui(targetBossId)
        if bossGui then
            local bossOverlay = bossGui:FindFirstChild("BossOverlay")
            local root = bossOverlay and bossOverlay:FindFirstChild("Root")
            local slantHeader = root and root:FindFirstChild("SlantHeader")
            local closeBtn = slantHeader and (slantHeader:FindFirstChild("Close") or slantHeader:FindFirstChildWhichIsA("GuiButton"))
            if closeBtn then clickGuiElement(closeBtn) end
            if bossOverlay then bossOverlay.Visible = false end
        end
    end)
end

-- Tìm nút FIGHT của đúng Trùm
local function findFightButton(targetBossId)
    local bossGui = getActiveBossScreenGui(targetBossId)
    if not bossGui then return nil end
    for _, desc in ipairs(bossGui:GetDescendants()) do
        if desc:IsA("GuiButton") or desc:IsA("TextButton") or desc:IsA("ImageButton") then
            local n = (desc.Name or ""):lower()
            local t = desc:IsA("TextButton") and (desc.Text or ""):lower() or ""
            if n:find("fight") or t:find("fight") or n == "start" or t == "start" then
                if desc.Visible and desc.AbsoluteSize.X > 10 and desc.AbsoluteSize.Y > 10 then
                    return desc
                end
            end
        end
    end
    return nil
end

-- Chọn độ khó trên GUI Trùm (Hỗ trợ cả Tên hiển thị lẫn Tên nội bộ Uni/Rainbow/Gold/Normal)
local function selectGameBossDifficulty(diffName, targetBossId)
    local bossGui = getActiveBossScreenGui(targetBossId)
    if not bossGui then return false end
    local s = (diffName or "Normal"):lower()
    local keywords = {}
    if s:find("astral") or s:find("uni") or s:find("04") then
        keywords = {"astral", "uni", "4"}
    elseif s:find("umbral") or s:find("rainbow") or s:find("03") then
        keywords = {"umbral", "rainbow", "3"}
    elseif s:find("calamity") or s:find("gold") or s:find("02") then
        keywords = {"calamity", "gold", "2"}
    elseif s:find("paradox") or s:find("05") then
        keywords = {"paradox", "5"}
    elseif s:find("origin") or s:find("06") then
        keywords = {"origin", "6"}
    elseif s:find("normal") or s:find("01") then
        keywords = {"normal", "1"}
    else
        keywords = { s }
    end

    for _, desc in ipairs(bossGui:GetDescendants()) do
        if desc:IsA("GuiButton") or desc:IsA("TextButton") then
            local n = (desc.Name or ""):lower()
            local t = desc:IsA("TextButton") and (desc.Text or ""):lower() or ""
            for _, kw in ipairs(keywords) do
                if n:find(kw) or t:find(kw) then
                    clickGuiElement(desc)
                    return true
                end
            end
        end
    end
    return false
end

-- Bộ tự động đóng giao diện Đài Phun Nước (Fountain) và Shop bảo vệ màn hình 100%
local function autoDismissFountain()
    pcall(function()
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        for _, g in ipairs(pg:GetChildren()) do
            if g:IsA("ScreenGui") and g.Enabled then
                local gn = g.Name:lower()
                if gn:find("fountain") then
                    g.Enabled = false
                end
            end
        end
        local sg = pg:FindFirstChild("ScreenGui")
        if sg then
            for _, child in ipairs(sg:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible and child.Name:lower():find("fountain") then
                    child.Visible = false
                end
            end
        end
    end)
end

-- Tự động dọn dẹp Fountain ngầm liên tục
task.spawn(function()
    while true do
        autoDismissFountain()
        task.wait(0.5)
    end
end)

-- Kiểm tra Cooldown Trùm Cuối (Hỏi trực tiếp Server, không khóa cứng thời gian nội bộ)
local function checkMainBossCooldown(bossId, diff)
    if not bossId then return 0 end
    diff = resolveDifficultyInternal(diff)

    -- Query GetBossCooldown từ Server
    if getCooldownRemote then
        local ok, cd = pcall(function()
            return getCooldownRemote:InvokeServer(bossId, diff)
        end)
        if ok and typeof(cd) == "number" and cd > 0 then
            return cd
        end
    end
    return 0
end

-- Tự động dọn dẹp Popup kết thúc trận (Chỉ quét GUI đang bật, siêu nhẹ)
local function autoDismissBossDefeated()
    pcall(function()
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        for _, g in ipairs(pg:GetChildren()) do
            if g:IsA("ScreenGui") and g.Enabled then
                local gn = g.Name:lower()
                if gn:find("boss") or gn:find("reward") or gn:find("victory") or gn:find("defeat") or gn:find("win") or gn:find("result") then
                    for _, desc in ipairs(g:GetDescendants()) do
                        if desc:IsA("GuiButton") and desc.Visible then
                            local t = (desc:IsA("TextButton") and desc.Text or desc.Name):lower()
                            if t:find("continue") or t:find("claim") or t:find("ok") or t:find("close") or t:find("skip") then
                                clickGuiElement(desc)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Chu trình gửi gói tin chiến thắng & nhận thưởng (Đứng đâu cũng đánh được, an toàn 100%, không tele)
local function executeBossVictory(bossId, diff)
    if not bossId then return false end
    diff = resolveDifficulty(diff)

    -- Bấm nút FIGHT trên GUI nếu đang hiển thị
    local fightBtn = findFightButton(bossId)
    if fightBtn then
        clickGuiElement(fightBtn)
        task.wait(0.1)
    end

    -- Đồng bộ Cooldown / Progress
    pcall(function()
        if getCooldownRemote then getCooldownRemote:InvokeServer(bossId, "Normal") end
        if getBorderProgRemote then getBorderProgRemote:InvokeServer(bossId) end
    end)
    task.wait(0.05)

    -- Gọi Remote Build Battle chuyên biệt
    pcall(function()
        local target = (bossId or ""):lower():gsub("%s+", "")
        local candidates = {}
        if target:find("kurumi") then
            candidates = { "BuildKurumiBattle", "BuildClockmaidenBattle" }
        elseif target:find("gojo") then
            candidates = { "BuildGojoBattle", "BuildLimitlessBattle", "BuildDomainBattle" }
        elseif target:find("queen") then
            candidates = { "BuildQueenBattle", "BuildShadowMonarchBattle", "BuildSjwBattle", "BuildShadowBattle", "BuildWorldBossBattle", "BuildRaidBossBattle" }
        elseif target:find("eydis") or target:find("evolution") then
            candidates = { "BuildEydisBattle", "BuildEvolutionBattle" }
        end

        if eventRemotes then
            for _, cName in ipairs(candidates) do
                local rem = eventRemotes:FindFirstChild(cName) or ReplicatedStorage:FindFirstChild(cName, true)
                if rem and rem:IsA("RemoteFunction") then
                    pcall(function() rem:InvokeServer(diff, false) end)
                    pcall(function() rem:InvokeServer(diff, true) end)
                    break
                end
            end
        end
    end)
    task.wait(0.1)

    -- Bắt đầu trận đấu & Báo cáo sát thương (Tuyệt đối KHÔNG gọi EndBattle để không làm ngắt quãng Infinite Run của dj)
    if startBattleRemote then pcall(function() startBattleRemote:InvokeServer(true) end) end
    if reportBattleDmgRemote then pcall(function() reportBattleDmgRemote:FireServer(999999, "dealt") end) end
    task.wait(0.15)

    -- Báo cáo chiến thắng nhận quà
    local reportOk = false
    if reportVictoryRemote then
        local ok = pcall(function() reportVictoryRemote:FireServer(bossId, diff) end)
        if ok then reportOk = true end
        pcall(function() reportVictoryRemote:FireServer(bossId, diff) end)
    end

    task.wait(0.1)
    autoDismissBossDefeated()
    closeActiveBossGui(bossId)
    autoDismissFountain()
    safeLog(string.format("[SuiSuiHUB] Đã đấm Trùm Cuối & Nhận quà: %s [%s]", tostring(bossId), tostring(diff)))
    return reportOk
end

-- Thực thi đấm Trùm Cuối (MẶC ĐỊNH ĐỨNG ĐÂU CŨNG ĐÁNH ĐƯỢC - KHÔNG CẦN TELE TỚI MAP)
local function engageMainBossBattle(bossId, diffInternal, diffDisplayName)
    if not bossId then return false end
    diffInternal = resolveDifficultyInternal(diffInternal)

    -- Nếu GUI Boss đang hiển thị trên màn hình: chọn độ khó & bấm nút FIGHT
    local bossGui = getActiveBossScreenGui(bossId)
    if bossGui then
        selectGameBossDifficulty(diffDisplayName or diffInternal, bossId)
        task.wait(0.05)
        local fightBtn = findFightButton(bossId)
        if fightBtn then clickGuiElement(fightBtn) end
        task.wait(0.1)
    end

    -- Gửi chuỗi Remote đấm Boss & Nhận quà (Đứng bất kỳ đâu: Floor 18, Lobby, map bất kỳ đều đấm được)
    return executeBossVictory(bossId, diffInternal)
end

-- ========================================================================
-- 6. CORE LOGIC CHO MINI BOSS & RIFTGATE
-- ========================================================================

-- Tìm model Mini Boss
local function findMiniBossModel(bossId)
    if not bossId then return nil end
    local clean = bossId:lower():gsub("%s+", "")
    for _, folderName in ipairs({"NPCs", "Bosses", "Enemies", "Monsters", "Spawns"}) do
        local f = workspace:FindFirstChild(folderName)
        if f then
            for _, obj in ipairs(f:GetChildren()) do
                if obj:IsA("Model") and obj.Name:lower():gsub("%s+", ""):find(clean) then
                    return obj
                end
            end
        end
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name:lower():gsub("%s+", ""):find(clean) then
            return obj
        end
    end
    return nil
end

local function teleportToMiniBoss(bossId)
    local model = findMiniBossModel(bossId)
    if model then
        local targetCF = model:GetPivot()
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and targetCF then
            hrp.CFrame = targetCF + Vector3.new(0, 2, -3)
            return true
        end
    end
    return false
end

local function executeMiniBossBattle(bossId)
    if not bossId then return false end
    if not buildMiniBossRemote then
        buildMiniBossRemote = eventRemotes and eventRemotes:FindFirstChild("BuildMiniBossBattle") or ReplicatedStorage:FindFirstChild("BuildMiniBossBattle", true)
    end
    if not reportVictoryRemote then
        reportVictoryRemote = eventRemotes and eventRemotes:FindFirstChild("ReportBossVictory") or ReplicatedStorage:FindFirstChild("ReportBossVictory", true)
    end
    if buildMiniBossRemote then
        pcall(function() buildMiniBossRemote:InvokeServer(bossId) end)
    end
    task.wait(0.15)
    if reportVictoryRemote then
        pcall(function() reportVictoryRemote:FireServer(bossId, "Normal") end)
    end
    task.wait(0.1)
    autoDismissBossDefeated()
    return true
end

-- RiftGATE Logic
local cachedRiftGate = nil
local function findRiftGate()
    if cachedRiftGate and cachedRiftGate.Parent then
        local p = cachedRiftGate:FindFirstChildWhichIsA("ProximityPrompt", true)
        return cachedRiftGate, p
    end
    for _, folderName in ipairs({"Map", "Spawns", "Gates", "Events"}) do
        local f = workspace:FindFirstChild(folderName)
        if f then
            for _, obj in ipairs(f:GetChildren()) do
                if obj:IsA("Model") and (obj.Name:lower():find("rift") or obj.Name:lower():find("gate") or obj.Name:lower():find("portal")) then
                    local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    cachedRiftGate = obj
                    return obj, p
                end
            end
        end
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and (obj.Name:lower():find("rift") or obj.Name:lower():find("gate") or obj.Name:lower():find("portal")) then
            local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            cachedRiftGate = obj
            return obj, p
        end
    end
    return nil, nil
end

local function teleportToRiftGate()
    local gateModel = findRiftGate()
    if gateModel then
        local cf = gateModel:GetPivot()
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and cf then
            hrp.CFrame = cf + Vector3.new(0, 3, 0)
            return true
        end
    end
    return false
end

local function executeRiftGateCycle()
    isRiftGateBusy = true
    safeLog("[SuiSuiHUB] Đang tham gia RiftGATE từ xa (0s Teleport)...")
    Notification("RiftGATE", "Đang tự động đánh RiftGATE từ xa...", 2)

    -- Chạy ngầm 100% bằng Remote, TUYỆT ĐỐI KHÔNG di chuyển nhân vật để bảo toàn Infinite Run
    if riftGateEnterRemote then pcall(function() riftGateEnterRemote:FireServer() end) end
    task.wait(0.2)
    if buildRiftBattleRemote then pcall(function() buildRiftBattleRemote:InvokeServer(true) end) end
    if riftStartFightRemote then
        pcall(function()
            if riftStartFightRemote:IsA("RemoteEvent") then
                riftStartFightRemote:FireServer()
            else
                riftStartFightRemote:InvokeServer()
            end
        end)
    end
    if reportBattleDmgRemote then pcall(function() reportBattleDmgRemote:FireServer(999999, "dealt") end) end
    task.wait(0.25)

    -- Nhận quà chiến thắng
    if reportRiftVictoryRemote then pcall(function() reportRiftVictoryRemote:FireServer() end) end
    task.wait(0.2)
    if riftRewardRemote then pcall(function() riftRewardRemote:FireServer() end) end
    task.wait(0.2)

    -- Rời cổng RiftGATE
    if riftGateLeaveRemote then pcall(function() riftGateLeaveRemote:FireServer() end) end
    autoDismissBossDefeated()
    autoDismissFountain()

    -- Đánh dấu đã hoàn thành đợt này: KHÔNG lặp lại, giữ nguyên vị trí nhân vật
    hasFarmedCurrentRiftGate = true
    isRiftGateBusy = false
    safeLog("[SuiSuiHUB] Đã hoàn thành RiftGATE & nhận quà xong! Vị trí nhân vật được giữ nguyên 100%.")
    Notification("RiftGATE", "Đã nhận quà RiftGATE xong! Giữ nguyên vị trí.", 3)
    return true
end

-- Ưu tiên
local function shouldYieldToRiftGate()
    if not _G.AutoRiftGate then return false end
    if _G.PriorityMode:find("Không Chờ") then return false end
    -- Nếu đã farm xong đợt này rồi thì không cần nhường đường nữa, để Auto Boss tiếp tục chạy
    if hasFarmedCurrentRiftGate then return false end
    return isServerRiftGateOpen or isRiftGateBusy
end

local function shouldYieldToMainBoss()
    if not _G.AutoMainBoss then return false end
    if _G.PriorityMode:find("Không Chờ") then return false end
    return isMainBossFighting
end

-- ========================================================================
-- 7. VÒNG LẶP CHÍNH (LOOPS)
-- ========================================================================

-- Anti-AFK
task.spawn(function()
    localPlayer.Idled:Connect(function()
        if _G.AntiAFK then
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.05)
            vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end
    end)
end)

-- Anti-Void: Đã gỡ bỏ để không làm dịch chuyển vị trí người chơi ra Đài Phun Nước ở Lobby

-- Chuẩn hóa danh sách Boss được chọn (Hỗ trợ cả dạng mảng lẫn bảng từ điển Linoria)
local function getNormalizedSelectedBosses()
    local list = {}
    if typeof(_G.SelectedMainBosses) == "table" then
        for k, v in pairs(_G.SelectedMainBosses) do
            if typeof(k) == "number" and typeof(v) == "string" then
                table.insert(list, v)
            elseif typeof(k) == "string" and v == true then
                table.insert(list, k)
            elseif typeof(v) == "string" and v ~= "" then
                table.insert(list, v)
            end
        end
    elseif typeof(_G.SelectedMainBosses) == "string" and _G.SelectedMainBosses ~= "" then
        table.insert(list, _G.SelectedMainBosses)
    end
    if #list == 0 then
        list = { "The Shadow Monarch (queen)" }
    end
    return list
end

-- VÒNG LẶP AUTO BOSS CHÍNH (ĐỨNG ĐÂU CŨNG ĐÁNH ĐƯỢC - KHÔNG TELEPORT, KHÔNG THAY ĐỔI VỊ TRÍ)
task.spawn(function()
    safeLog("[SuiSuiHUB] Vòng lặp Auto Boss Chính (Đứng Đâu Cũng Đánh Được - Chạy Ngầm 100%) đã sẵn sàng!")
    while true do
        pcall(function()
            if _G.AutoMainBoss then
                local bossList = getNormalizedSelectedBosses()

                for _, bTitle in ipairs(bossList) do
                    if not _G.AutoMainBoss then break end
                    
                    local bossId = resolveMainBossId(bTitle)
                    local diffDisplay = (_G.MainBossDifficulties and _G.MainBossDifficulties[bossId]) or _G.SelectedMainDifficulty or "01: NORMAL (Normal)"
                    local diffInternal = resolveDifficultyInternal(diffDisplay)

                    safeLog(string.format("[SuiSuiHUB] Chu trình Trùm Cuối: BẬT Auto in-game -> Đánh %s [%s -> %s] -> Nhận quà -> TẮT Auto", tostring(bossId), tostring(diffDisplay), tostring(diffInternal)))

                    -- 1. BẬT In-Game Auto Fight cho trùm này
                    setInGameAutoBoss(bossId, true, diffInternal)
                    task.wait(0.15)

                    -- 2. Đánh trùm & nhận thưởng từ xa qua Remote (Không di chuyển nhân vật)
                    executeBossVictory(bossId, diffInternal)
                    task.wait(0.2)

                    -- 3. TẮT In-Game Auto Fight để xoay tua sang trùm khác
                    setInGameAutoBoss(bossId, false)
                    task.wait(0.1)

                    local delayTime = tonumber(_G.BossDelay) or 0.2
                    task.wait(math.max(delayTime, 0.1))
                end
            end
        end)
        task.wait(0.3)
    end
end)

-- VÒNG LẶP AUTO MINI BOSS
task.spawn(function()
    while true do
        pcall(function()
            if _G.AutoMiniBoss and _G.SelectedMiniBosses and #_G.SelectedMiniBosses > 0 then
                for _, bossId in ipairs(_G.SelectedMiniBosses) do
                    if not _G.AutoMiniBoss then break end
                    
                    while _G.AutoMiniBoss and (shouldYieldToRiftGate() or shouldYieldToMainBoss()) do
                        task.wait(0.2)
                    end
                    if not _G.AutoMiniBoss then break end

                    isMiniBossBusy = true
                    executeMiniBossBattle(bossId)
                    task.wait(0.1)
                    autoDismissBossDefeated()
                    isMiniBossBusy = false

                    local delay = tonumber(_G.BossDelay) or 0.5
                    task.wait(math.max(delay, 0.2))
                end
            end
        end)
        task.wait(0.3)
    end
end)

-- VÒNG LẶP ĐỒNG BỘ RIFTGATE (CHU KỲ 15 PHÚT)
local RiftStatusLabel, RiftTimerLabel
task.spawn(function()
    while true do
        pcall(function()
            local now = os.date("*t")
            local totalSec = (now.min * 60) + now.sec
            local secInCycle = totalSec % 900
            local secRemaining = 900 - secInCycle

            local isWindowOpen = isServerRiftGateOpen or (secInCycle >= 0 and secInCycle <= 120)

            if isWindowOpen then
                if hasFarmedCurrentRiftGate then
                    if RiftStatusLabel then RiftStatusLabel:Set("Trạng Thái: ĐÃ XONG ĐỢT NÀY (Đã về Lobby, Chờ đợt sau)") end
                    if RiftTimerLabel then RiftTimerLabel:Set(string.format("Đợt Kế Tiếp Sau: %02d:%02d", math.floor(secRemaining / 60), secRemaining % 60)) end
                else
                    if RiftStatusLabel then RiftStatusLabel:Set("Trạng Thái: CỔNG ĐANG MỞ (Chiến Đấu!)") end
                    if RiftTimerLabel then RiftTimerLabel:Set(string.format("Đang Mở! Còn Lại: %02d:%02d", math.floor((120 - (secInCycle % 120)) / 60), (120 - (secInCycle % 120)) % 60)) end

                    if _G.AutoRiftGate and not isRiftGateBusy then
                        executeRiftGateCycle()
                    end
                end
            else
                -- Cổng đang đóng: Reset cờ để sẵn sàng đón đợt mở cổng kế tiếp
                hasFarmedCurrentRiftGate = false
                if RiftStatusLabel then RiftStatusLabel:Set("Trạng Thái: Đang Đóng (Chờ Mở)") end
                if RiftTimerLabel then RiftTimerLabel:Set(string.format("Đợt Kế Tiếp Sau: %02d:%02d", math.floor(secRemaining / 60), secRemaining % 60)) end
            end
        end)
        task.wait(1.0)
    end
end)

-- ========================================================================
-- 8. KHỞI TẠO GIAO DIỆN (UI INITIALIZATION QUA INVENTORY.LUA)
-- ========================================================================
local Window = library:CreateWindow("SuiSuiHUB | Card Origins")
local uiFullyLoaded = false

-- Helper: Ẩn / Hiện toàn bộ giao diện SuiSuiHUB chuẩn xác
local function setMenuVisible(visible)
    pcall(function()
        if Window and Window.Frame then
            Window.Frame.Visible = visible
        end
        local containers = {}
        if gethui then pcall(function() table.insert(containers, gethui()) end) end
        pcall(function() table.insert(containers, game:GetService("CoreGui")) end)
        if localPlayer and localPlayer:FindFirstChild("PlayerGui") then
            table.insert(containers, localPlayer.PlayerGui)
        end
        for _, c in ipairs(containers) do
            for _, v in pairs(c:GetChildren()) do
                local m = v:FindFirstChild("main")
                if m then
                    m.Visible = visible
                end
            end
        end
    end)
end

-- ========================================================================
-- TAB 1: SĂN BOSS (AUTO BOSS & MAP)
-- ========================================================================
local TabBoss = Window:CreateTab("Săn Boss")
local SecBossLeft = TabBoss:CreateSector("1. Boss Thường (Mini Boss)", "left")
local SecBossRight = TabBoss:CreateSector("2. Boss Chính (Trùm Cuối)", "right")

local MiniBossDropdownItem
local MainBossDropdownItem

-- Cột Trái: Boss Thường
SecBossLeft:AddDropdown("Chọn Map Hiện Tại", MapOptions, _G.SelectedMap, false, function(v)
    _G.SelectedMap = v
    if not uiFullyLoaded then return end
    local cfg = GAME_WORLDS[v]
    if cfg then
        if cfg.miniBosses and #cfg.miniBosses > 0 then
            local bossList = {}
            for _, b in ipairs(cfg.miniBosses) do table.insert(bossList, b.id) end
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
    if cfg and cfg.mapId then teleportToWorld(cfg.mapId) end
end)

MiniBossDropdownItem = SecBossLeft:AddDropdown("Chọn Boss Thường (Chọn Nhiều)", ALL_MINI_BOSS_LIST, _G.SelectedMiniBosses, true, function(selected)
    if typeof(selected) == "table" then
        _G.SelectedMiniBosses = selected
    elseif typeof(selected) == "string" then
        _G.SelectedMiniBosses = { selected }
    end
    if uiFullyLoaded then saveConfig() end
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
        Notification("Mini Boss", string.format("Đã chọn %d Boss trong map!", #allList), 3)
    end
end)

SecBossLeft:AddButton("Chọn Toàn Bộ 6 Mini Boss (Toàn Game)", function()
    _G.SelectedMiniBosses = ALL_MINI_BOSS_LIST
    if MiniBossDropdownItem and MiniBossDropdownItem.Set then
        MiniBossDropdownItem:Set(ALL_MINI_BOSS_LIST)
    end
    saveConfig()
    Notification("Mini Boss", "Đã chọn toàn bộ 6 Mini Boss!", 3)
end)

SecBossLeft:AddButton("Bay Tới Gần Boss Thường", function()
    local target = _G.SelectedMiniBosses and _G.SelectedMiniBosses[1] or "chahaein"
    teleportToMiniBoss(target)
end)

SecBossLeft:AddToggle("Auto Đấm Boss Thường (Xoay Vòng)", _G.AutoMiniBoss, function(v)
    _G.AutoMiniBoss = v
    if uiFullyLoaded then saveConfig() end
    Notification("Boss Thường", v and "Đã BẬT Auto Mini Boss!" or "Đã TẮT!", 2)
end)

-- Cột Phải: Trùm Cuối
MainBossDropdownItem = SecBossRight:AddDropdown("Chọn Trùm Cuối (Chọn Nhiều)", ALL_MAIN_BOSS_LIST, _G.SelectedMainBosses, true, function(selected)
    if typeof(selected) == "table" then
        _G.SelectedMainBosses = selected
    elseif typeof(selected) == "string" then
        _G.SelectedMainBosses = { selected }
    end
    if uiFullyLoaded then saveConfig() end
end)

SecBossRight:AddButton("Chọn Toàn Bộ 3 Trùm Cuối (Toàn Game)", function()
    _G.SelectedMainBosses = ALL_MAIN_BOSS_LIST
    if MainBossDropdownItem and MainBossDropdownItem.Set then
        MainBossDropdownItem:Set(ALL_MAIN_BOSS_LIST)
    end
    saveConfig()
    Notification("Trùm Cuối", "Đã chọn toàn bộ 3 Trùm Cuối!", 3)
end)

SecBossRight:AddLabel("--- TÙY CHỈNH ĐỘ KHÓ TỪNG TRÙM CUỐI ---")

SecBossRight:AddDropdown("Độ Khó Queen (The Shadow Monarch - 02: DUNGEON)", MAIN_BOSS_DIFFICULTIES, _G.MainBossDifficulties["queen"] or "04: ASTRAL (Uni)", false, function(v)
    _G.MainBossDifficulties["queen"] = v
    if uiFullyLoaded then saveConfig() end
    Notification("Độ Khó Queen", "Đã đặt độ khó Queen: " .. tostring(v), 2)
end)

SecBossRight:AddDropdown("Độ Khó Gojo (The Honored One - 04: LIMITLESS DOMAIN)", MAIN_BOSS_DIFFICULTIES, _G.MainBossDifficulties["gojo"] or "02: CALAMITY (Gold)", false, function(v)
    _G.MainBossDifficulties["gojo"] = v
    if uiFullyLoaded then saveConfig() end
    Notification("Độ Khó Gojo", "Đã đặt độ khó Gojo: " .. tostring(v), 2)
end)

SecBossRight:AddDropdown("Độ Khó Kurumi (Clockmaiden - 05: DEVIL HEART)", MAIN_BOSS_DIFFICULTIES, _G.MainBossDifficulties["kurumi"] or "03: UMBRAL (Rainbow)", false, function(v)
    _G.MainBossDifficulties["kurumi"] = v
    if uiFullyLoaded then saveConfig() end
    Notification("Độ Khó Kurumi", "Đã đặt độ khó Kurumi: " .. tostring(v), 2)
end)

local PRIORITY_OPTIONS = {
    "RiftGate > Boss Chính > Boss Mini (Mặc Định)",
    "Boss Chính > RiftGate > Boss Mini",
    "Tự Do (Không Chờ Nhau)"
}

SecBossRight:AddDropdown("Độ Ưu Tiên Farm", PRIORITY_OPTIONS, _G.PriorityMode, false, function(v)
    _G.PriorityMode = v
    if uiFullyLoaded then saveConfig() end
end)

SecBossRight:AddSlider("Nghỉ Giữa Các Trận (Giây)", 0.2, 0.5, 5.0, 0.1, function(v)
    _G.BossDelay = tonumber(v) or 0.5
    if uiFullyLoaded then saveConfig() end
end)

SecBossRight:AddToggle("Auto Đấm Boss Chính (Xoay Vòng Bật/Tắt)", _G.AutoMainBoss, function(v)
    _G.AutoMainBoss = v
    if not v then
        setInGameAutoBoss(nil, false) -- Tắt ngay in-game auto fight của game khi tắt toggle
    end
    if uiFullyLoaded then saveConfig() end
    Notification("Boss Chính", v and "Đã BẬT Auto Trùm Cuối (Quy trình: Bật auto -> Đánh -> Tắt -> Chuyển Boss)!" or "Đã TẮT!", 3)
end)

-- ========================================================================
-- TAB 2: RiftGATE (CHU KỲ 15 PHÚT)
-- ========================================================================
local TabRift = Window:CreateTab("RiftGATE")
local SecRiftLeft = TabRift:CreateSector("1. Đếm Ngược & Trạng Thái Cổng", "left")
local SecRiftRight = TabRift:CreateSector("2. Tự Động & Tiện Ích RiftGATE", "right")

RiftStatusLabel = SecRiftLeft:AddLabel("Trạng Thái: ĐANG ĐỒNG BỘ GIỜ...", true)
RiftTimerLabel = SecRiftLeft:AddLabel("Đợt Kế Tiếp: xx:-- | Còn Lại: --:--")
SecRiftLeft:AddLabel("Các Mốc Giờ: xx:00 | xx:15 | xx:30 | xx:45")

SecRiftLeft:AddToggle("Báo Chuông Khi Cổng Mở", _G.RiftNotify, function(v)
    _G.RiftNotify = v
    if uiFullyLoaded then saveConfig() end
end)

SecRiftLeft:AddToggle("Tự Động Săn RiftGATE (Auto Join)", _G.AutoRiftGate, function(v)
    _G.AutoRiftGate = v
    if not v then
        hasFarmedCurrentRiftGate = false
    end
    if uiFullyLoaded then saveConfig() end
    Notification("RiftGATE", v and "Đã BẬT Auto tham gia RiftGATE khi cổng mở!" or "Đã TẮT Auto RiftGATE!", 2)
end)

SecRiftRight:AddButton("Đánh Thử 1 Trận RiftGATE", function()
    task.spawn(function()
        Notification("RiftGATE", "Đang thử chạy chu trình đấm RiftGATE...", 2)
        local ok = executeRiftGateCycle()
        Notification("RiftGATE", "Kết quả: " .. tostring(ok), 3)
    end)
end)

SecRiftRight:AddButton("Teleport Tới Cổng Rift", function()
    teleportToRiftGate()
end)

SecRiftRight:AddButton("Teleport Về Lobby (Sảnh)", function()
    teleportToWorld("lobby")
end)

SecRiftRight:AddButton("Vào Cổng Thủ Công (EnterRequest)", function()
    if riftGateEnterRemote then
        riftGateEnterRemote:FireServer()
        Notification("RiftGATE", "Đã gửi lệnh RiftGateEnterRequest!", 2)
    end
end)

SecRiftRight:AddButton("Rời Khỏi Cổng (LeaveRequest)", function()
    if riftGateLeaveRemote then
        riftGateLeaveRemote:FireServer()
        Notification("RiftGATE", "Đã gửi lệnh RiftGateLeave!", 2)
    end
end)

-- ========================================================================
-- TAB 3: CÀI ĐẶT (SETTINGS)
-- ========================================================================
local TabSettings = Window:CreateTab("Cài Đặt")
local SecSetLeft = TabSettings:CreateSector("Tối Ưu Treo Máy", "left")
local SecSetRight = TabSettings:CreateSector("Hệ Thống & Giao Diện", "right")

SecSetLeft:AddToggle("Chống Văng (Anti-AFK)", _G.AntiAFK, function(v)
    _G.AntiAFK = v
    if uiFullyLoaded then saveConfig() end
end)

SecSetLeft:AddToggle("Ẩn Nhật Ký Console (Tối Ưu FPS Khi Treo Máy)", _G.DisableConsoleLogs, function(v)
    _G.DisableConsoleLogs = v
    if uiFullyLoaded then saveConfig() end
    Notification("Nhật Ký Console", v and "Đã ẨN toàn bộ log Console (Tối ưu RAM/FPS treo máy qua đêm)!" or "Đã BẬT lại log Console!", 3)
end)

SecSetLeft:AddToggle("Màn Hình Trắng Giảm CPU (WhiteScreen)", _G.WhiteScreen, function(v)
    _G.WhiteScreen = v
    RunService:Set3dRenderingEnabled(not v)
    if uiFullyLoaded then saveConfig() end
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
    end
    if uiFullyLoaded then saveConfig() end
    Notification("Tối Ưu", v and "Đã kích hoạt FPS Boost!" or "Đã tắt FPS Boost!", 2)
end)

SecSetLeft:AddToggle("Bật Chỉnh Tốc Độ Di Chuyển", _G.WalkSpeedEnabled, function(v)
    _G.WalkSpeedEnabled = v
    pcall(function()
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.WalkSpeed = v and (_G.WalkSpeedValue or 16) or 16
        end
    end)
    if uiFullyLoaded then saveConfig() end
end)

SecSetLeft:AddSlider("Tốc Độ (WalkSpeed)", 16, 16, 200, 1, function(v)
    if typeof(v) == "number" and v > 0 then
        _G.WalkSpeedValue = math.floor(v)
        if _G.WalkSpeedEnabled then
            pcall(function()
                if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
                    localPlayer.Character.Humanoid.WalkSpeed = _G.WalkSpeedValue
                end
            end)
        end
        if uiFullyLoaded then saveConfig() end
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
    Notification("Remote Hunter", hunterLoaded and "Đã mở Remote Hunter!" or "Không thể tải RemoteHunter.lua!", 3)
end)

-- Toggle & Button Ẩn Menu
SecSetRight:AddToggle("Ẩn Menu Khi Khởi Động", _G.HideMenuOnStartup, function(v)
    _G.HideMenuOnStartup = v
    if uiFullyLoaded then saveConfig() end
    Notification("Cài Đặt", v and "Đã BẬT: Menu sẽ tự ẩn khi vừa chạy script (Bấm phím [Insert] để mở lại)!" or "Đã TẮT tính năng tự ẩn menu!", 3)
end)

SecSetRight:AddButton("Ẩn Menu Ngay (Phím Insert)", function()
    local isVis = false
    if Window and Window.Frame then
        isVis = Window.Frame.Visible
    end
    setMenuVisible(not isVis)
    Notification("Giao Diện", isVis and "Đã ẩn menu! Bấm phím [Insert] để mở lại." or "Đã hiện menu!", 2)
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

-- Tự động ẩn menu khi khởi động nếu đã được cài đặt
if _G.HideMenuOnStartup then
    task.spawn(function()
        task.wait(0.3)
        setMenuVisible(false)
        Notification("SuiSuiHUB", "Menu đã tự động ẩn khi khởi động! Bấm [Insert] để mở lại.", 3)
    end)
end

Notification("SuiSuiHUB", "Khởi tạo Card Origins thành công!", 4)
