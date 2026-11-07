--[[
    ========================================================================
    SuiSuiHUB | Anime Eyes Master
    PlaceId: 97617452700163
    Tác giả: dj & VANTA
    Phiên bản: 19.3 (Anti-Void Fall & Safe Streaming World Engine)
    ========================================================================
    Quy chuẩn vận hành theo yêu cầu của dj:
      1. Chỉ nhận Cúp tại đúng Stage đích đã chọn (Target Stage):
         - Ở các Stage trước đích (Stage 1, 2... < Target): Diệt sạch quái và tiến thẳng qua Cổng sang ải tiếp theo, TUYỆT ĐỐI KHÔNG chạm vào bất kỳ bệ cúp nào.
         - Khi đạt đúng Stage đích (hoặc vượt qua): Diệt sạch quái, tiến lên BỆ VÀNG duy nhất (Cúp thường Free, KHÔNG chạm vào Bệ Tím x3 nạp tiền).
      2. Nhận cúp xong tự động Reset ván đấu về Stage 1:
         - Khi nhận cúp tại Stage đích, ván đấu kết thúc và nhân vật tự động quay về Stage 1 để lặp lại chu trình farm cúp mới.
      3. Đứng giữa Stage bao quát quái & boss:
         - Tự động định vị trọng tâm đàn quái và tâm sàn đấu, xả đòn M1 + chiêu E (Shinra Tensei) & R (Chibaku Tensei) với tốc độ CPS cao (25-30 hit/s).
    ========================================================================
]]

repeat task.wait(0.2) until game:IsLoaded()

_G.SuiSuiGameName = "Anime Eyes"
local currentSessionId = os.clock() + math.random()
_G.AnimeEyes_SessionId = currentSessionId
local function isSessionActive()
    return _G.AnimeEyes_SessionId == currentSessionId
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local StatsService = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
repeat task.wait(0.2) until localPlayer

-- ========================================================================
-- 1. DỌN DẸP GIAO DIỆN CŨ (PREVENT DUPLICATE / GHOST WINDOWS)
-- ========================================================================
pcall(function()
    local containers = {}
    if gethui then pcall(function() table.insert(containers, gethui()) end) end
    pcall(function() table.insert(containers, game:GetService("CoreGui")) end)
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then table.insert(containers, pg) end

    for _, c in ipairs(containers) do
        for _, gui in ipairs(c:GetChildren()) do
            if gui.Name:find("Anime Eyes") or gui.Name:find("SuiSuiHUB") then
                pcall(function() gui:Destroy() end)
            end
        end
    end
end)

-- ========================================================================
-- 2. HỆ THỐNG LOG & THÔNG BÁO
-- ========================================================================
local function safeLog(...)
    if _G.DisableConsoleLogs then return end
    pcall(function(...) print(...) end, ...)
end

local function Notification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or "SuiSuiHUB"),
            Text = tostring(text or ""),
            Duration = tonumber(duration) or 3
        })
    end)
    safeLog(string.format("[SuiSuiHUB] %s: %s", tostring(title or ""), tostring(text or "")))
end

-- Helper cập nhật Text cho nhãn UI (Hỗ trợ cả label:Set và label.Main.Text)
local function updateLabel(labelObj, text)
    if not labelObj then return end
    pcall(function()
        if labelObj.Set then
            labelObj:Set(text)
        end
        if labelObj.Main and labelObj.Main:IsA("TextLabel") then
            labelObj.Main.Text = text
        end
    end)
end

-- ========================================================================
-- 3. TẢI THƯ VIỆN GIAO DIỆN (inventory.lua)
-- ========================================================================
local library = nil
local function loadLibrary()
    -- 1. Ưu tiên Localhost / LAN (Hỗ trợ cả PC và giả lập MuMu/LDPlayer/BlueStacks)
    for _, host in ipairs({"http://127.0.0.1:8000", "http://192.168.2.203:8000", "http://10.0.2.2:8000", "http://172.18.144.1:8000"}) do
        if not library then
            pcall(function()
                local code = game:HttpGet(host .. "/inventory.lua?t=" .. tostring(os.time()))
                if code and #code > 100 then
                    library = loadstring(code)()
                end
            end)
        end
    end
    -- 2. Nếu không có localhost, đọc file cục bộ nếu có executor hỗ trợ
    if not library and isfile and readfile and isfile("inventory.lua") then
        pcall(function()
            library = loadstring(readfile("inventory.lua"))()
        end)
    end
    -- 3. Fallback về GitHub Production
    if not library then
        pcall(function()
            library = loadstring(game:HttpGet("https://raw.githubusercontent.com/suisuimommy-code/SuiSuiHUB/main/inventory.lua"))()
        end)
    end
    return library
end

library = loadLibrary()
if not library then
    Notification("Lỗi Thư Viện", "Không thể nạp inventory.lua!", 5)
    safeLog("[SuiSuiHUB] Không thể nạp inventory.lua!")
    return
end

-- ========================================================================
-- 4. TRẠNG THÁI TOÀN CỤC (GLOBAL STATE)
-- ========================================================================
-- Tab 1: Chiến Đấu (Stage, World & Timeout Engine)
-- Ngắt triệt để mọi vòng lặp ngầm (ghost loops) từ phiên chạy cũ trong bộ nhớ
_G.AnimeEyes_AutoStage = false
_G.AnimeEyes_AutoBoss = false
_G.SuiSui_AutoStage = (_G.SuiSui_AutoStage ~= nil) and _G.SuiSui_AutoStage or false
_G.SuiSui_AutoBoss = (_G.SuiSui_AutoBoss ~= nil) and _G.SuiSui_AutoBoss or false
_G.AnimeEyes_CenterStage = _G.AnimeEyes_CenterStage ~= nil and _G.AnimeEyes_CenterStage or true
_G.AnimeEyes_TargetStage = math.clamp(tonumber(_G.AnimeEyes_TargetStage) or 5, 1, 15)
_G.AnimeEyes_SelectedWorld = tonumber(_G.AnimeEyes_SelectedWorld) or 1
_G.AnimeEyes_StageTimeout = tonumber(_G.AnimeEyes_StageTimeout) or 20
_G.AnimeEyes_BossFightDuration = tonumber(_G.AnimeEyes_BossFightDuration) or 10
_G.AnimeEyes_StageCPS = _G.AnimeEyes_StageCPS or 25
_G.AnimeEyes_StageDelay = _G.AnimeEyes_StageDelay or 1.0
_G.AnimeEyes_InBossFight = false
_G.AnimeEyes_BossHoverHeight = _G.AnimeEyes_BossHoverHeight or 26
_G.AnimeEyes_AutoDodge = _G.AnimeEyes_AutoDodge ~= nil and _G.AnimeEyes_AutoDodge or true
_G.AnimeEyes_DodgeSpeed = tonumber(_G.AnimeEyes_DodgeSpeed) or 3
_G.AnimeEyes_DodgeRadius = math.clamp(tonumber(_G.AnimeEyes_DodgeRadius) or 10, 6, 14)

-- Tab 2: Tự Động Farm & Trùng Sinh
_G.AnimeEyes_AutoClick = _G.AnimeEyes_AutoClick or false
_G.AnimeEyes_TargetCPS = _G.AnimeEyes_TargetCPS or 25
_G.AnimeEyes_BypassCooldown = _G.AnimeEyes_BypassCooldown ~= nil and _G.AnimeEyes_BypassCooldown or true
_G.AnimeEyes_AutoSkills = _G.AnimeEyes_AutoSkills or false
_G.AnimeEyes_KeepFreeOn = _G.AnimeEyes_KeepFreeOn ~= nil and _G.AnimeEyes_KeepFreeOn or true
_G.AnimeEyes_AutoClaims = _G.AnimeEyes_AutoClaims or false
_G.AnimeEyes_AutoRebirth = _G.AnimeEyes_AutoRebirth or false
_G.AnimeEyes_RebirthDelay = _G.AnimeEyes_RebirthDelay or 1.5

-- Tab 3: Mở Trứng
_G.AnimeEyes_AutoHatch = _G.AnimeEyes_AutoHatch or false
_G.AnimeEyes_SelectedEgg = _G.AnimeEyes_SelectedEgg or "Starter Egg"
_G.SuiSui_HatchAmount = tonumber(_G.SuiSui_HatchAmount) or 3
_G.AnimeEyes_HatchAmount = _G.SuiSui_HatchAmount
_G.AnimeEyes_AutoEquipBestPet = _G.AnimeEyes_AutoEquipBestPet or false

-- Tab 4: Cửa Hàng
_G.AnimeEyes_AutoUnlockEyes = _G.AnimeEyes_AutoUnlockEyes or false
_G.AnimeEyes_AutoEquipBestEye = _G.AnimeEyes_AutoEquipBestEye or false
_G.AnimeEyes_AutoRollAuras = _G.AnimeEyes_AutoRollAuras or false
_G.AnimeEyes_AutoEquipBestAura = _G.AnimeEyes_AutoEquipBestAura or false
_G.AnimeEyes_AutoBossShop = _G.AnimeEyes_AutoBossShop or false
_G.AnimeEyes_AutoClaims = _G.AnimeEyes_AutoClaims or false

-- Tab 5: Cài Đặt
_G.AntiAFK = _G.AntiAFK ~= nil and _G.AntiAFK or true
_G.WhiteScreen = _G.WhiteScreen or false
_G.FPSBoost = _G.FPSBoost or false
_G.WalkSpeedEnabled = _G.WalkSpeedEnabled ~= nil and _G.WalkSpeedEnabled or true
_G.WalkSpeedValue = _G.WalkSpeedValue or 70
_G.DisableConsoleLogs = _G.DisableConsoleLogs or false
_G.AnimeEyes_AutoSaveConfig = _G.AnimeEyes_AutoSaveConfig or false

-- ========================================================================
-- 4.5. NẠP NGAY LẬP TỨC CẤU HÌNH TỪ DISK TRƯỚC KHI KHỞI TẠO GIAO DIỆN (PRE-UI LOAD)
-- ========================================================================
local function loadSettingsFromDisk()
    local paths = { "!SuiSuiHUB/Anime Eyes/settings.json", "AnimeEyes_settings.json" }
    for _, p in ipairs(paths) do
        local ok, raw = pcall(function()
            if readfile then return readfile(p) end
            return nil
        end)
        if ok and raw and #raw > 2 then
            local decOk, data = pcall(function()
                return HttpService:JSONDecode(raw)
            end)
            if decOk and typeof(data) == "table" then
                for k, v in pairs(data) do
                    if k == "AnimeEyes_AutoStage" then
                        _G.SuiSui_AutoStage = (v == true)
                        _G.AnimeEyes_AutoStage = false
                    elseif k == "AnimeEyes_AutoBoss" then
                        _G.SuiSui_AutoBoss = (v == true)
                        _G.AnimeEyes_AutoBoss = false
                    elseif k == "AnimeEyes_HatchAmount" then
                        -- Bỏ qua key cũ mặc định 1 trứng; dùng SuiSui_HatchAmount (mặc định 3 - HATCH x3)
                    elseif k == "SuiSui_HatchAmount" then
                        _G.SuiSui_HatchAmount = (tonumber(v) == 1) and 1 or 3
                        _G.AnimeEyes_HatchAmount = _G.SuiSui_HatchAmount
                    else
                        _G[k] = v
                    end
                end
                if safeLog then
                    safeLog(string.format("[SuiSuiHUB] Đã nạp thành công cấu hình đã lưu từ %s!", p))
                end
                return true
            end
        end
    end
    return false
end
pcall(loadSettingsFromDisk)

local queueAutoSave
do
    local saveDebounce = nil
    queueAutoSave = function()
        if saveDebounce then return end
        saveDebounce = task.delay(0.3, function()
            saveDebounce = nil
            if autoSaveSettings then
                autoSaveSettings(false)
            end
        end)
    end
end

-- Bảng đăng ký lưu trữ đối tượng UI để đồng bộ 100% hai chiều
local uiRegistry = {
    toggles = {},
    sliders = {},
    dropdowns = {}
}

-- Dữ liệu hiển thị trực tiếp Stage & Cúp
local currentStageData = {
    stageNum = 1,
    stageName = "Đang quét...",
    recommendedChakra = "Chưa rõ",
    yellowTrophies = "+0",
    purpleTrophies = "+0",
    yellowPad = nil,
    purplePad = nil,
    gatePart = nil,
    stageCenter = nil,
    enemiesCount = 0,
    combatState = "Đang chờ lệnh..."
}

-- Forward Declarations (Tối ưu số lượng biến local cấp cao nhất dưới ngưỡng 200 của Luau)
local startStageLoop, teleportToWorld, teleportToStageOne
local startNativeClickLoop, triggerRebirthOnce, toggleWhiteScreen, applyFPSBoost
local unlockNextEyeAction, equipBestEyeAction, rollAuraAction
local updateEggTabForWorld, getSelectedCupEggData, scanLiveWorldCupEggs
local LabelCurrentWorldEgg, LabelEggCost, DropdownEgg
local autoSaveSettings, autoLoadSettings
local buyBossShopAction, claimAllFreeRewards, redeemAllKnownCodes, openGameMenu
local findAndClickJoinBoss, isKyubiJoinButton, getKyubiTimerStatus, dumpKyubiBossNow, dismissRobuxModals
local isInsideKyubiArena, isPlayerNearArenaExitPortal, getKyubiBossTarget, executeBossVictoryExit, restorePlayerMovementControls
local LabelWorldBossStatus, LabelWorldBossPhase, bossRemote, bossDropRemote, bossShopRemote, bossHunterState
local LabelCurrentEye, LabelNextEye, LabelEyeProgress, LabelCurrentAura, LabelOwnedAurasCount

-- ========================================================================
-- 5. KHỞI TẠO NGAY GIAO DIỆN CHÍNH THỨC (INSTANT UI CREATION AT TOP)
-- ========================================================================
local Window = library:CreateWindow("SuiSuiHUB | Anime Eyes Master")
Notification("SuiSuiHUB", "Giao diện đã mở thành công! (Bấm Menu trên Topbar hoặc phím Insert)", 4)

-- ------------------------------------------------------------------------
-- TAB 1: CHIẾN ĐẤU (WORLD SELECTOR, STAGE & COMBAT TIMEOUT ENGINE)
-- ------------------------------------------------------------------------
local TabStage = Window:CreateTab("Chiến Đấu")
local SecStageLeft = TabStage:CreateSector("1. Vượt Ải Stage & Thời Gian", "left")
local SecStageRight = TabStage:CreateSector("2. Chọn World, Stage Nhận Cúp & Boss", "right")

local WORLD_LIST = {
    "World 1: Shinobi Lands",
    "World 2: Celestial Realm",
    "World 3: Blood Moon",
    "World 4: Frozen Abyss",
    "World 5: Cosmic Void",
    "World 6: Soul Society",
    "World 7: Hueco Mundo",
    "World 8: Spirit World",
    "World 9: Dragon Realm"
}
local WORLD_NAMES = WORLD_LIST

local WORLD_ORIGINS = {
    Vector3.new(0, 0, 0),
    Vector3.new(3000, 0, 0),
    Vector3.new(6000, 0, 0),
    Vector3.new(9000, 0, 0),
    Vector3.new(12000, 0, 0),
    Vector3.new(15000, 0, 0),
    Vector3.new(18000, 0, 0),
    Vector3.new(21000, 0, 0),
    Vector3.new(24000, 0, 0)
}

-- Hàm tự động phát hiện World theo tọa độ thực tế của nhân vật
local function detectPhysicalWorld()
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local posX = root.Position.X
        local bestW = 1
        local minDiff = 1e9
        for i, orig in ipairs(WORLD_ORIGINS) do
            local diff = math.abs(posX - orig.X)
            if diff < minDiff then
                minDiff = diff
                bestW = i
            end
        end
        return bestW, WORLD_ORIGINS[bestW]
    end
    local w = math.clamp(tonumber(_G.AnimeEyes_SelectedWorld) or 1, 1, 9)
    return w, WORLD_ORIGINS[w]
end

-- Hàm lấy World farm (usePhysical = true sẽ dò theo vị trí đứng thực tế)
local function getFarmWorld(usePhysical)
    if usePhysical then
        return detectPhysicalWorld()
    end
    if _G.AnimeEyes_SelectedWorld then
        local w = math.clamp(tonumber(_G.AnimeEyes_SelectedWorld) or 1, 1, 9)
        return w, WORLD_ORIGINS[w] or Vector3.new((w - 1) * 3000, 0, 0)
    end
    return detectPhysicalWorld()
end

-- Tự động gán World ban đầu theo vị trí nhân vật đang đứng
if not _G.AnimeEyes_SelectedWorld or _G.AnimeEyes_SelectedWorld == 1 then
    local pW = detectPhysicalWorld()
    if pW and pW > 1 then
        _G.AnimeEyes_SelectedWorld = pW
    end
end

-- Khởi tạo Remotes sớm cho toàn bộ UI và Logic
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local function getRemote(name)
    if not remotes then remotes = ReplicatedStorage:FindFirstChild("Remotes") end
    if remotes then
        return remotes:FindFirstChild(name) or remotes:FindFirstChild(name:lower())
    end
    return nil
end

local trainRemote = getRemote("Train")
local castRemote = getRemote("Cast")
local equipRemote = getRemote("Equip")
local unlockEyeRemote = getRemote("UnlockEye")
bossRemote = getRemote("Boss")
bossDropRemote = getRemote("BossDrop")
bossShopRemote = getRemote("BossShop")
local padRemote = getRemote("Pad")
local teleportRemote = getRemote("Teleport")
local rebirthRemote = getRemote("Rebirth")
local autoRebirthRemote = getRemote("AutoRebirth")
local autoOpRemote = getRemote("AutoOp")
local openEggRemote = getRemote("OpenEgg") or getRemote("Hatch") or getRemote("Egg")
local petActionRemote = getRemote("PetAction") or getRemote("Pet") or getRemote("Pets")
local equipAuraRemote = getRemote("EquipAura") or getRemote("Aura")
local arcadeStartRemote = getRemote("ArcadeStart")
local arcadeFinishRemote = getRemote("ArcadeFinish")
local claimQuestRemote = getRemote("ClaimQuest")
local claimDailyRemote = getRemote("ClaimDaily")
local claimGroupRemote = getRemote("ClaimGroup")
local claimRewardRemote = getRemote("ClaimReward")
local exitBonusRemote = getRemote("ExitBonus")
local welcomeBackRemote = getRemote("WelcomeBack")
local redeemCodeRemote = getRemote("RedeemCode")

-- Labels thông số thời gian thực
local LabelStageTitle = SecStageLeft:AddLabel("Ải: Đang quét...")
local LabelStageTimer = SecStageLeft:AddLabel("Thời gian đánh ải: 0.0s / 20s")
local LabelEnemyLive  = SecStageLeft:AddLabel("Quái còn sống: 0 con")
local LabelStageState = SecStageLeft:AddLabel("Trạng thái: Đang chờ lệnh...")

uiRegistry.toggles["AnimeEyes_AutoStage"] = SecStageLeft:AddToggle("Bật Auto Đi Stage Đến Đích", _G.SuiSui_AutoStage, function(v)
    _G.SuiSui_AutoStage = (v == true)
    _G.AnimeEyes_AutoStage = false
    if queueAutoSave then queueAutoSave() end
    if v then
        currentStageData.combatState = "Đang khởi động Auto Stage..."
        updateLabel(LabelStageState, "Trạng thái: Đang khởi động Auto Stage...")
        if startStageLoop then
            startStageLoop()
        end
        Notification("Auto Stage", string.format("ĐÃ BẬT Auto đi Stage đến đích (Stage %d)!", tonumber(_G.AnimeEyes_TargetStage) or 5), 3)
    else
        if restorePlayerMovementControls then restorePlayerMovementControls() end
        currentStageData.combatState = "Đã dừng Auto Đi Stage."
        updateLabel(LabelStageState, "Trạng thái: Đã dừng Auto Đi Stage.")
        Notification("Auto Stage", "Đã TẮT Auto Đi Stage!", 2)
    end
end)

SecStageLeft:AddToggle("Luôn Đứng Giữa Sàn (Bao Quát Quái & Boss)", _G.AnimeEyes_CenterStage, function(v)
    _G.AnimeEyes_CenterStage = v
    Notification("Vị Trí Sàn", v and "ĐÃ BẬT Đứng giữa sàn đấu bao quát!" or "Đã TẮT đứng giữa sàn!", 2)
end)

SecStageLeft:AddSlider("Giới Hạn Thời Gian Đánh Ải (Giây)", 5, _G.AnimeEyes_StageTimeout, 60, 1, function(v)
    _G.AnimeEyes_StageTimeout = tonumber(v) or 20
end)

SecStageLeft:AddSlider("Tốc Độ Đánh Auto Stage (CPS)", 5, _G.AnimeEyes_StageCPS, 50, 1, function(v)
    _G.AnimeEyes_StageCPS = tonumber(v) or 25
end)

SecStageLeft:AddSlider("Delay Sau Khi Qua Cổng (Giây)", 0.5, _G.AnimeEyes_StageDelay, 3.0, 0.1, function(v)
    _G.AnimeEyes_StageDelay = tonumber(v) or 1.0
end)

-- Sector 2: Chọn World & Stage Nhận Cúp
local defaultWorldName = WORLD_LIST[_G.AnimeEyes_SelectedWorld] or WORLD_LIST[1]
SecStageRight:AddDropdown("Chọn World Muốn Farm (World 1 - 9)", WORLD_LIST, defaultWorldName, false, function(v)
    local wNum = tonumber(tostring(v):match("World%s*(%d+)")) or 1
    _G.AnimeEyes_SelectedWorld = wNum
    if teleportToWorld then
        teleportToWorld(wNum)
    end
    if updateEggTabForWorld then
        updateEggTabForWorld(wNum)
    end
end)

SecStageRight:AddButton("Dịch Chuyển Đến World Này Ngay", function()
    if teleportToWorld then
        teleportToWorld(_G.AnimeEyes_SelectedWorld or 1)
    end
end)

uiRegistry.sliders["AnimeEyes_TargetStage"] = SecStageRight:AddSlider("Chọn Stage Đích Để Nhận Cúp (1 - 15)", 1, _G.AnimeEyes_TargetStage, 15, 1, function(v)
    _G.AnimeEyes_TargetStage = math.clamp(tonumber(v) or 5, 1, 15)
    if queueAutoSave then queueAutoSave() end
    Notification("Stage Đích", string.format("Sẽ đi đến Stage %d -> Nhận Cúp Vàng -> Reset ván!", _G.AnimeEyes_TargetStage), 3)
end)

SecStageRight:AddLabel("Lưu ý: Chỉ nhận Cúp Vàng (Free) tại Stage đích.")
SecStageRight:AddLabel("Bỏ qua Bệ Tím x3 (Nạp tiền). Nhận xong sẽ tự Reset ván!")

LabelWorldBossStatus = SecStageRight:AddLabel("Kyubi: Đang theo dõi...")
LabelWorldBossPhase = SecStageRight:AddLabel("Tiến trình: Đang chờ sự kiện")

uiRegistry.toggles["AnimeEyes_AutoBoss"] = SecStageRight:AddToggle("Tự Động Săn Kyubi / Boss Thế Giới", _G.SuiSui_AutoBoss, function(v)
    _G.SuiSui_AutoBoss = (v == true)
    _G.AnimeEyes_AutoBoss = false
    if not v and restorePlayerMovementControls then
        restorePlayerMovementControls()
    end
    if queueAutoSave then queueAutoSave() end
    Notification("World Boss", v and "ĐÃ BẬT Tự động săn Boss Thế Giới (Ưu tiên số 1)!" or "Đã TẮT săn Boss!", 2)
end)

SecStageRight:AddSlider("Độ Cao Bay Trên Đầu Boss (Studs)", 10, _G.AnimeEyes_BossHoverHeight or 26, 40, 1, function(v)
    _G.AnimeEyes_BossHoverHeight = tonumber(v) or 26
    if queueAutoSave then queueAutoSave() end
end)

uiRegistry.toggles["AnimeEyes_AutoDodge"] = SecStageRight:AddToggle("Bật Auto Dodge (Tự Động Né Đòn Boss)", _G.AnimeEyes_AutoDodge ~= nil and _G.AnimeEyes_AutoDodge or true, function(v)
    _G.AnimeEyes_AutoDodge = v
    if queueAutoSave then queueAutoSave() end
    Notification("Auto Dodge", v and "ĐÃ BẬT Tự Động Né Chiêu 3D Khi Đánh Boss!" or "Đã TẮT Auto Dodge!", 2)
end)

uiRegistry.sliders["AnimeEyes_DodgeSpeed"] = SecStageRight:AddSlider("Tốc Độ Né Xoay Vòng (Dodge Speed)", 1, _G.AnimeEyes_DodgeSpeed or 3, 10, 1, function(v)
    _G.AnimeEyes_DodgeSpeed = tonumber(v) or 3
    if queueAutoSave then queueAutoSave() end
end)

uiRegistry.sliders["AnimeEyes_DodgeRadius"] = SecStageRight:AddSlider("Bán Kính Quỹ Đạo Né (Radius)", 6, math.clamp(tonumber(_G.AnimeEyes_DodgeRadius) or 10, 6, 14), 16, 1, function(v)
    _G.AnimeEyes_DodgeRadius = math.clamp(tonumber(v) or 10, 6, 14)
    if queueAutoSave then queueAutoSave() end
end)

SecStageRight:AddButton("Tham Gia Boss / Nhận Quà Boss Ngay", function()
    pcall(function()
        if findAndClickJoinBoss then findAndClickJoinBoss() end
        if bossRemote then bossRemote:FireServer(true) end
        if bossDropRemote then bossDropRemote:FireServer() end
    end)
    Notification("Boss", "Đã gửi lệnh tham gia Boss & nhận quà!", 2)
end)

SecStageRight:AddButton("Rời Khỏi Map Boss (Về Hub Spawn)", function()
    task.spawn(function()
        if executeBossVictoryExit then
            executeBossVictoryExit("Bấm nút Rời Khỏi Map Boss thủ công")
        end
    end)
end)

SecStageRight:AddButton(">>> DUMP QUÁ TRÌNH & GIAO DIỆN BOSS KYUBI <<<", function()
    if dumpKyubiBossNow then
        dumpKyubiBossNow()
    else
        Notification("Boss Dump", "Hệ thống đang chuẩn bị bộ Dump...", 2)
    end
end)

-- ------------------------------------------------------------------------
-- TAB 2: TỰ ĐỘNG FARM (FARM CHAKRA & TRÙNG SINH TÍCH HỢP)
-- ------------------------------------------------------------------------
do
local TabFarm = Window:CreateTab("Tự Động Farm")
local SecClick = TabFarm:CreateSector("1. Đòn Đánh Chakra Native", "left")
local SecRebirth = TabFarm:CreateSector("2. Trùng Sinh (Auto Rebirth)", "left")
local SecFarmSkills = TabFarm:CreateSector("3. Kỹ Năng & Trạng Thái", "right")

-- Hiển thị Ping
local PingLabel = SecFarmSkills:AddLabel("Ping: Đang đo...")
task.spawn(function()
    while isSessionActive() do
        pcall(function()
            local ping = 50
            local net = StatsService:FindFirstChild("Network") and StatsService.Network:FindFirstChild("ServerStatsItem")
            local p = net and net:FindFirstChild("Data Ping")
            if p then ping = math.floor(p:GetValue()) end
            if PingLabel and PingLabel.Set then
                PingLabel:Set(string.format("Ping: %d ms (Mượt)", ping))
            end
        end)
        task.wait(1.5)
    end
end)

uiRegistry.toggles["AnimeEyes_AutoClick"] = SecClick:AddToggle("Bật Auto Click Native (Chuẩn Game)", _G.AnimeEyes_AutoClick, function(v)
    _G.AnimeEyes_AutoClick = v
    if queueAutoSave then queueAutoSave() end
    if v and startNativeClickLoop then
        startNativeClickLoop()
        Notification("Auto Click", "ĐÃ BẬT Auto Click Native!", 2)
    else
        Notification("Auto Click", "Đã TẮT Auto Click!", 2)
    end
end)

SecClick:AddSlider("Tốc Độ Click (CPS)", 5, _G.AnimeEyes_TargetCPS, 50, 1, function(v)
    _G.AnimeEyes_TargetCPS = tonumber(v) or 25
end)

SecClick:AddToggle("Bỏ Giới Hạn Cooldown Đòn Đánh", _G.AnimeEyes_BypassCooldown, function(v)
    _G.AnimeEyes_BypassCooldown = v
end)

-- Trùng Sinh (Auto Rebirth) đưa vào chung Tab Farm
uiRegistry.toggles["AnimeEyes_AutoRebirth"] = SecRebirth:AddToggle("Bật Tự Động Trùng Sinh (Auto Rebirth)", _G.AnimeEyes_AutoRebirth, function(v)
    _G.AnimeEyes_AutoRebirth = v
    if queueAutoSave then queueAutoSave() end
    Notification("Auto Rebirth", v and "ĐÃ BẬT Tự Động Trùng Sinh!" or "Đã TẮT Trùng Sinh!", 2)
end)

SecRebirth:AddSlider("Khoảng Cách Giữa Các Lần (Giây)", 0.5, _G.AnimeEyes_RebirthDelay, 5.0, 0.5, function(v)
    _G.AnimeEyes_RebirthDelay = tonumber(v) or 1.5
end)

SecRebirth:AddButton("Trùng Sinh Ngay Lập Tức (1 Lần)", function()
    if triggerRebirthOnce then triggerRebirthOnce() end
    Notification("Rebirth", "Đã gửi lệnh Trùng Sinh!", 2)
end)

uiRegistry.toggles["AnimeEyes_AutoSkills"] = SecFarmSkills:AddToggle("Tự Tung Chiêu E & R (Shinra & Chibaku)", _G.AnimeEyes_AutoSkills, function(v)
    _G.AnimeEyes_AutoSkills = v
    if queueAutoSave then queueAutoSave() end
end)

SecFarmSkills:AddToggle("Duy Trì 'FREE Auto Clicker' Của Game", _G.AnimeEyes_KeepFreeOn, function(v)
    _G.AnimeEyes_KeepFreeOn = v
end)

SecFarmSkills:AddToggle("Tự Nhận Thưởng Quests / Daily / Group", _G.AnimeEyes_AutoClaims, function(v)
    _G.AnimeEyes_AutoClaims = v
end)
end

-- ------------------------------------------------------------------------
-- TAB 3: MỞ TRỨNG (EGGS & PETS - CHỈ HIỆN TRỨNG CÚP THEO TỪNG WORLD)
-- ------------------------------------------------------------------------
local MASTER_CUP_EGGS = {
    [1] = { worldName = "World 1: Shinobi Lands", eggs = { { id = "normal", name = "Normal Egg", cost = "10 Cúp", offset = Vector3.new(60, 1, 30) }, { id = "shinobi", name = "Shinobi Egg", cost = "400 Cúp", offset = Vector3.new(84, 1, 30) } } },
    [2] = { worldName = "World 2: Celestial Realm", eggs = { { id = "leaf", name = "Leaf Egg", cost = "15K Cúp", offset = Vector3.new(60, 1, 30) }, { id = "sand", name = "Sand Egg", cost = "500K Cúp", offset = Vector3.new(84, 1, 30) } } },
    [3] = { worldName = "World 3: Blood Moon", eggs = { { id = "sound", name = "Sound Egg", cost = "20M Cúp", offset = Vector3.new(60, 1, 30) }, { id = "mist", name = "Mist Egg", cost = "750M Cúp", offset = Vector3.new(84, 1, 30) } } },
    [4] = { worldName = "World 4: Frozen Abyss", eggs = { { id = "cloud", name = "Cloud Egg", cost = "30B Cúp", offset = Vector3.new(60, 1, 30) }, { id = "waterfall", name = "Waterfall Egg", cost = "1T Cúp", offset = Vector3.new(84, 1, 30) } } },
    [5] = { worldName = "World 5: Cosmic Void", eggs = { { id = "rain", name = "Rain Egg", cost = "45T Cúp", offset = Vector3.new(60, 1, 30) }, { id = "star", name = "Star Egg", cost = "1.5Qa Cúp", offset = Vector3.new(84, 1, 30) } } },
    [6] = { worldName = "World 6: Soul Society", eggs = { { id = "soul", name = "Soul Egg", cost = "60Qa Cúp", offset = Vector3.new(60, 1, 30) }, { id = "reaper", name = "Reaper Egg", cost = "2Qi Cúp", offset = Vector3.new(84, 1, 30) } } },
    [7] = { worldName = "World 7: Hueco Mundo", eggs = { { id = "hollow", name = "Hollow Egg", cost = "80Qi Cúp", offset = Vector3.new(60, 1, 30) }, { id = "arrancar", name = "Arrancar Egg", cost = "3Sx Cúp", offset = Vector3.new(84, 1, 30) } } },
    [8] = { worldName = "World 8: Spirit World", eggs = { { id = "spirit", name = "Spirit Egg", cost = "120Sx Cúp", offset = Vector3.new(60, 1, 30) }, { id = "ghost", name = "Ghost Egg", cost = "5Sp Cúp", offset = Vector3.new(84, 1, 30) } } },
    [9] = { worldName = "World 9: Dragon Realm", eggs = { { id = "dragon", name = "Dragon Egg", cost = "200Sp Cúp", offset = Vector3.new(60, 1, 30) }, { id = "celestial_dragon", name = "Celestial Dragon Egg", cost = "8Oc Cúp", offset = Vector3.new(84, 1, 30) } } }
}

-- Quét trực tiếp các biển hiệu Trứng Cúp thực tế trên bản đồ (Đọc chính xác Tên và Giá Cúp từ BillboardGui)
scanLiveWorldCupEggs = function(worldNum)
    local w = math.clamp(tonumber(worldNum) or 1, 1, 9)
    local wData = MASTER_CUP_EGGS[w] or MASTER_CUP_EGGS[1]
    local orig = (WORLD_ORIGINS and WORLD_ORIGINS[w]) or Vector3.new((w - 1) * 3000, 0, 0)

    pcall(function()
        local stand1X = orig.X + 60
        local stand2X = orig.X + 84

        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("BillboardGui") or desc:IsA("SurfaceGui") then
                local adornee = desc.Adornee or desc.Parent
                local aPos = (adornee and adornee:IsA("BasePart")) and adornee.Position or nil
                if not aPos and desc.Parent and desc.Parent:IsA("BasePart") then
                    aPos = desc.Parent.Position
                end

                if aPos and math.abs(aPos.Z - 30) <= 25 then
                    local dist1 = math.abs(aPos.X - stand1X)
                    local dist2 = math.abs(aPos.X - stand2X)

                    local eggIdx = nil
                    if dist1 <= 14 then eggIdx = 1
                    elseif dist2 <= 14 then eggIdx = 2 end

                    if eggIdx and wData.eggs[eggIdx] then
                        for _, tl in ipairs(desc:GetDescendants()) do
                            if tl:IsA("TextLabel") and tl.Text and #tl.Text > 0 then
                                local t = tl.Text:upper()
                                -- Nhận diện Tên Trứng (bỏ qua Robux)
                                if t:find("EGG") and not t:find("") and not t:find("ROBUX") and not t:find("BUY") then
                                    wData.eggs[eggIdx].name = tl.Text
                                -- Nhận diện Giá Mua Cúp
                                elseif not t:find("") and not t:find("ROBUX") and not t:find("R$") and not t:find("SKIP") then
                                    if t:match("%d") and not t:find("CHAKRA") and not t:find("STAGE") and not t:find("REACH") then
                                        wData.eggs[eggIdx].cost = tl.Text .. " Cúp"
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    return wData
end

do
local TabEggs = Window:CreateTab("Mở Trứng")
local SecEggsLeft = TabEggs:CreateSector("1. Tự Động Mở Trứng (Auto Hatch)", "left")
local SecEggsRight = TabEggs:CreateSector("2. Quản Lý Thú Cưng (Pets)", "right")

local curInitWorld = math.clamp(tonumber(_G.AnimeEyes_SelectedWorld) or 1, 1, 9)
local initWorldData = (MASTER_CUP_EGGS and MASTER_CUP_EGGS[curInitWorld]) or (MASTER_CUP_EGGS and MASTER_CUP_EGGS[1])
local initFirstEgg = (initWorldData and initWorldData.eggs and initWorldData.eggs[1]) or { name = "Normal Egg", cost = "10 Cúp" }

LabelCurrentWorldEgg = SecEggsLeft:AddLabel("Bản Đồ: " .. (WORLD_NAMES and WORLD_NAMES[curInitWorld] or ("World " .. curInitWorld)))
LabelEggCost = SecEggsLeft:AddLabel("Giá Mua: " .. tostring(initFirstEgg.cost or "10 Cúp"))

local function getEggDisplayList(w)
    local wData = (MASTER_CUP_EGGS and MASTER_CUP_EGGS[w]) or (MASTER_CUP_EGGS and MASTER_CUP_EGGS[1])
    local list = {}
    if wData and wData.eggs then
        for _, egg in ipairs(wData.eggs) do
            table.insert(list, string.format("%s (%s)", tostring(egg.name), tostring(egg.cost)))
        end
    end
    if #list == 0 then
        table.insert(list, "Normal Egg (10 Cúp)")
    end
    return list
end

local initialEggList = getEggDisplayList(curInitWorld)
local initialDefault = initialEggList[1] or "Normal Egg (10 Cúp)"
_G.AnimeEyes_SelectedEgg = tostring(initFirstEgg.name or "Normal Egg")

DropdownEgg = SecEggsLeft:AddDropdown("Chọn Trứng Mở Bằng Cúp", initialEggList, initialDefault, false, function(v)
    local str = tostring(v)
    local rawName = str:match("^(.-)%s*%(") or str
    rawName = rawName:gsub("^%s*(.-)%s*$", "%1")
    _G.AnimeEyes_SelectedEgg = rawName

    local costStr = str:match("%((.-)%)") or "Cúp"
    if LabelEggCost then
        updateLabel(LabelEggCost, "Giá Mua: " .. costStr)
    end
    Notification("Chọn Trứng", "Đã chọn: " .. rawName .. " (" .. costStr .. ")", 2)
end)

-- Hàm cập nhật toàn bộ Tab Mở Trứng theo World đang chọn (Chỉ hiện Trứng Cúp của World đó)
updateEggTabForWorld = function(worldNum)
    worldNum = math.clamp(tonumber(worldNum) or 1, 1, 9)
    local wData = scanLiveWorldCupEggs(worldNum)

    if LabelCurrentWorldEgg then
        updateLabel(LabelCurrentWorldEgg, "Bản Đồ: " .. (WORLD_NAMES[worldNum] or ("World " .. worldNum)))
    end

    local newEggItems = {}
    for _, egg in ipairs(wData.eggs) do
        table.insert(newEggItems, string.format("%s (%s)", tostring(egg.name), tostring(egg.cost)))
    end
    if #newEggItems == 0 then
        table.insert(newEggItems, "Normal Egg (10 Cúp)")
    end

    if DropdownEgg then
        pcall(function()
            if DropdownEgg.Refresh then
                DropdownEgg:Refresh(newEggItems)
            else
                local currentItems = {}
                for _, item in ipairs(DropdownEgg.items or {}) do
                    table.insert(currentItems, item)
                end
                for _, item in ipairs(currentItems) do
                    DropdownEgg:Remove(item)
                end
                for _, item in ipairs(newEggItems) do
                    DropdownEgg:Add(item)
                end
                if #newEggItems > 0 then
                    DropdownEgg:Set(newEggItems[1])
                end
            end

            if newEggItems[1] then
                local rawName = newEggItems[1]:match("^(.-)%s*%(") or newEggItems[1]
                _G.AnimeEyes_SelectedEgg = rawName:gsub("^%s*(.-)%s*$", "%1")
                if LabelEggCost then
                    local costStr = newEggItems[1]:match("%((.-)%)") or "Cúp"
                    updateLabel(LabelEggCost, "Giá Mua: " .. costStr)
                end
            end
        end)
    end
end

-- Lấy thông tin tọa độ bệ trứng Cúp đang chọn trong World
getSelectedCupEggData = function(targetWorld)
    local w = math.clamp(tonumber(targetWorld) or 1, 1, 9)
    local wData = MASTER_CUP_EGGS[w] or MASTER_CUP_EGGS[1]
    local selectedName = tostring(_G.AnimeEyes_SelectedEgg or ""):lower()
    for _, egg in ipairs(wData.eggs) do
        if egg.name:lower():find(selectedName) or selectedName:find(egg.name:lower()) then
            return egg
        end
    end
    return wData.eggs[1]
end

SecEggsLeft:AddButton("Dịch Chuyển Đến Bệ Trứng Này Ngay", function()
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targetWorld, worldOrigin = getFarmWorld()
    local eggData = getSelectedCupEggData(targetWorld)
    local standPos = worldOrigin + eggData.offset + Vector3.new(0, 1.2, 0)

    root.CFrame = CFrame.new(standPos)
    root.Velocity = Vector3.zero
    Notification("Bệ Trứng", string.format("Đã đến bệ %s tại Hub World %d!", eggData.name, targetWorld), 2)
end)

local HATCH_AMOUNTS = { "HATCH x3 (Mở 3 Trứng)", "HATCH x1 (Mở 1 Trứng)" }
local defaultHatchLabel = (tonumber(_G.SuiSui_HatchAmount) == 1) and "HATCH x1 (Mở 1 Trứng)" or "HATCH x3 (Mở 3 Trứng)"
uiRegistry.dropdowns["SuiSui_HatchAmount"] = SecEggsLeft:AddDropdown("Số Lượng Mở Mỗi Lần", HATCH_AMOUNTS, defaultHatchLabel, false, function(v)
    local str = tostring(v)
    if str:find("1") then
        _G.SuiSui_HatchAmount = 1
    else
        _G.SuiSui_HatchAmount = 3
    end
    _G.AnimeEyes_HatchAmount = _G.SuiSui_HatchAmount
    if queueAutoSave then queueAutoSave() end
end)

uiRegistry.toggles["AnimeEyes_AutoHatch"] = SecEggsLeft:AddToggle("Bật Tự Động Mở Trứng (Auto Hatch)", _G.AnimeEyes_AutoHatch, function(v)
    _G.AnimeEyes_AutoHatch = v
    if queueAutoSave then queueAutoSave() end
    Notification("Auto Hatch", v and "ĐÃ BẬT Tự Động Mở Trứng (Bằng Cúp)!" or "Đã TẮT mở trứng!", 2)
end)

SecEggsLeft:AddButton("Quét / Làm Mới Trứng Map Này", function()
    local targetWorld = getFarmWorld(true)
    _G.AnimeEyes_SelectedWorld = targetWorld
    if updateEggTabForWorld then
        updateEggTabForWorld(targetWorld)
    end
    Notification("Trứng Map", string.format("Đã quét & nạp trứng Cúp cho %s!", WORLD_NAMES[targetWorld] or ("World " .. targetWorld)), 3)
end)

SecEggsRight:AddToggle("Tự Động Trang Bị Pet Tốt Nhất", _G.AnimeEyes_AutoEquipBestPet, function(v)
    _G.AnimeEyes_AutoEquipBestPet = v
    Notification("Pets", v and "ĐÃ BẬT Tự động trang bị Pet mạnh nhất!" or "Đã TẮT!", 2)
end)

SecEggsRight:AddButton("Trang Bị Pet Mạnh Nhất Ngay", function()
    pcall(function()
        if petActionRemote then
            if petActionRemote:IsA("RemoteFunction") then
                petActionRemote:InvokeServer("EquipBest")
            else
                petActionRemote:FireServer("EquipBest")
            end
        end
    end)
    Notification("Pets", "Đã gửi lệnh trang bị Pet mạnh nhất!", 2)
end)

SecEggsRight:AddButton("Mở Kho Thú Cưng (Pets Menu)", function()
    if openGameMenu then openGameMenu("Pets") end
end)

-- ------------------------------------------------------------------------
-- TAB 4: CỬA HÀNG (MY EYES, AURAS & QUÀ TẶNG MIỄN PHÍ)
-- ------------------------------------------------------------------------
local TabShop = Window:CreateTab("Cửa Hàng")
local SecEyes = TabShop:CreateSector("1. My Eyes (Mở Khóa & Trang Bị Mắt)", "left")
local SecAuras = TabShop:CreateSector("2. Auras (Hào Quang Chiến Đấu)", "right")
local SecClaims = TabShop:CreateSector("3. Quà Tặng & Giftcode Miễn Phí", "left")

-- 1. SECTOR MY EYES
LabelCurrentEye = SecEyes:AddLabel("Mắt Đang Dùng: Đang quét...")
LabelNextEye = SecEyes:AddLabel("Mắt Kế Tiếp: Đang quét...")
LabelEyeProgress = SecEyes:AddLabel("Tiến độ: Đang quét...")

uiRegistry.toggles["AnimeEyes_AutoUnlockEyes"] = SecEyes:AddToggle("Tự Động Mua Mắt Khi Đủ Cúp", _G.AnimeEyes_AutoUnlockEyes, function(v)
    _G.AnimeEyes_AutoUnlockEyes = v
    if queueAutoSave then queueAutoSave() end
    Notification("My Eyes", v and "ĐÃ BẬT Tự động mở khóa Mắt từ thấp lên cao tại chỗ!" or "Đã TẮT Tự động mở khóa Mắt!", 2)
end)

SecEyes:AddToggle("Tự Động Trang Bị Mắt Xịn Nhất", _G.AnimeEyes_AutoEquipBestEye, function(v)
    _G.AnimeEyes_AutoEquipBestEye = v
    Notification("My Eyes", v and "ĐÃ BẬT Tự động trang bị Mắt mạnh nhất!" or "Đã TẮT!", 2)
    if v and equipBestEyeAction then equipBestEyeAction() end
end)

SecEyes:AddButton("Mở Menu My Eyes Của Game", function()
    if not fromAuto and openGameMenu then openGameMenu("Eyes") end
end)

-- 2. SECTOR AURAS
LabelCurrentAura = SecAuras:AddLabel("Aura Đang Dùng: Đang quét...")
LabelOwnedAurasCount = SecAuras:AddLabel("Đã Sở Hữu: 0 Auras")

uiRegistry.toggles["AnimeEyes_AutoRollAuras"] = SecAuras:AddToggle("Tự Động Quay / Mua Aura Game", _G.AnimeEyes_AutoRollAuras, function(v)
    _G.AnimeEyes_AutoRollAuras = v
    if queueAutoSave then queueAutoSave() end
    Notification("Auras", v and "ĐÃ BẬT Tự động quay Aura!" or "Đã TẮT!", 2)
end)

SecAuras:AddToggle("Tự Động Trang Bị Aura Xịn Nhất", _G.AnimeEyes_AutoEquipBestAura, function(v)
    _G.AnimeEyes_AutoEquipBestAura = v
    Notification("Auras", v and "ĐÃ BẬT Tự động trang bị Aura mới nhất!" or "Đã TẮT!", 2)
end)

SecAuras:AddButton("Mở Menu Auras Của Game", function()
    if openGameMenu then openGameMenu("Aura") end
end)

-- 3. SECTOR REWARDS & CLAIMS
SecClaims:AddToggle("Tự Động Nhận Toàn Bộ Quà Miễn Phí", _G.AnimeEyes_AutoClaims, function(v)
    _G.AnimeEyes_AutoClaims = v
    Notification("Nhận Quà", v and "ĐÃ BẬT Tự động nhận Daily, Group, Quests, Online!" or "Đã TẮT!", 2)
end)

SecClaims:AddButton("Tự Động Nhập Toàn Bộ Giftcode", function()
    if redeemAllKnownCodes then redeemAllKnownCodes() end
end)

-- ------------------------------------------------------------------------
-- TAB 5: CÀI ĐẶT (PERFORMANCE & CONFIG)
-- ------------------------------------------------------------------------
local TabSettings = Window:CreateTab("Cài Đặt")
local SecTreoMay = TabSettings:CreateSector("1. Tối Ưu Treo Máy (Performance)", "left")
local SecNhanVat = TabSettings:CreateSector("2. Tùy Biến Nhân Vật (Character)", "right")
local SecConfig = TabSettings:CreateSector("3. Quản Lý Cấu Hình (!SuiSuiHUB)", "left")

SecTreoMay:AddToggle("Anti-AFK (Chống Văng Game)", _G.AntiAFK, function(v)
    _G.AntiAFK = v
    Notification("Anti-AFK", v and "ĐÃ BẬT Anti-AFK!" or "Đã TẮT!", 2)
end)

SecTreoMay:AddToggle("Màn Hình Trắng (WhiteScreen)", _G.WhiteScreen, function(v)
    _G.WhiteScreen = v
    if toggleWhiteScreen then toggleWhiteScreen(v) end
    Notification("WhiteScreen", v and "ĐÃ BẬT Màn Hình Trắng!" or "Đã TẮT!", 2)
end)

SecTreoMay:AddButton("Kích Hoạt FPS Boost", function()
    if applyFPSBoost then applyFPSBoost() end
    Notification("FPS Boost", "Đã tối ưu đồ họa để tối đa hóa FPS!", 3)
end)

SecTreoMay:AddToggle("Tắt Log F9 Console", _G.DisableConsoleLogs, function(v)
    _G.DisableConsoleLogs = v
end)

SecNhanVat:AddToggle("Bật Tăng Tốc Độ Chạy (WalkSpeed)", _G.WalkSpeedEnabled, function(v)
    _G.WalkSpeedEnabled = v
    if not v and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

SecNhanVat:AddSlider("Tốc Độ Chạy (WalkSpeed)", 16, _G.WalkSpeedValue, 120, 2, function(v)
    _G.WalkSpeedValue = tonumber(v) or 70
end)

SecConfig:AddLabel("Chế độ: Tự Động Lưu 100% (Auto-Save)")
SecConfig:AddLabel("Mọi thay đổi cài đặt sẽ tự động lưu vào máy")

SecConfig:AddButton("Lưu Cấu Hình Thủ Công (Save)", function()
    if autoSaveSettings then autoSaveSettings(true) end
end)

SecConfig:AddButton("Nạp Lại Cấu Hình Thủ Công (Load)", function()
    if autoLoadSettings then autoLoadSettings(true) end
end)
end

-- ========================================================================
-- 6. KẾT NỐI REMOTES VÀ CLIENT MODULES (SAFE & NON-BLOCKING)
-- ========================================================================
-- (Các remotes đã được khởi tạo sớm tại phần đầu file để phục vụ UI và Boss Hunter)

local InputModule = nil
local AutoClickModule = nil
local EnemiesModule = nil
local StateModule = nil
local cooldownTable = nil

task.spawn(function()
    pcall(function()
        local ps = localPlayer:FindFirstChild("PlayerScripts") or localPlayer:WaitForChild("PlayerScripts", 2)
        local clientFolder = ps and (ps:FindFirstChild("Client") or ps:WaitForChild("Client", 2))
        if clientFolder then
            local inputScript = clientFolder:FindFirstChild("Input")
            if inputScript then
                InputModule = require(inputScript)
                if debug and debug.getupvalues and InputModule.cooldown then
                    local uvs = debug.getupvalues(InputModule.cooldown)
                    if uvs and typeof(uvs[1]) == "table" then
                        cooldownTable = uvs[1]
                    end
                end
            end

            local autoClickScript = clientFolder:FindFirstChild("AutoClick")
            if autoClickScript then
                AutoClickModule = require(autoClickScript)
            end

            local enemiesScript = clientFolder:FindFirstChild("Enemies")
            if enemiesScript then
                EnemiesModule = require(enemiesScript)
            end

            local stateScript = clientFolder:FindFirstChild("State")
            if stateScript then
                StateModule = require(stateScript)
            end
        end
    end)
end)

-- ========================================================================
-- 7. HỆ THỐNG ĐỊNH VỊ NATIVE WORLD & STAGE (CHUẨN XÁC 100% THEO GAME ENGINE)
-- ========================================================================
local STAGE_LENGTH = 90
local HUB_MIN_Z = -30
local FLOOR_Y = 3.0
local WorldConfig, GatesModule = nil, nil

pcall(function()
    local rsShared = ReplicatedStorage:FindFirstChild("Shared")
    if rsShared and rsShared:FindFirstChild("Config") and rsShared.Config:FindFirstChild("World") then
        WorldConfig = require(rsShared.Config.World)
    end
    local ps = localPlayer:FindFirstChild("PlayerScripts")
    local clientFolder = ps and ps:FindFirstChild("Client")
    if clientFolder and clientFolder:FindFirstChild("Gates") then
        GatesModule = require(clientFolder.Gates)
    end
end)

local getPlayerPhysicalWorld = detectPhysicalWorld
local getCurrentWorld = getFarmWorld

restorePlayerMovementControls = function()
    pcall(function()
        local char = localPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")

        if root then
            root.Anchored = false
            for _, child in ipairs(root:GetChildren()) do
                if child:IsA("BodyMover") or child.Name == "SuiSui_HoverVelocity" then
                    child:Destroy()
                end
            end
        end

        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == "SuiSui_SafeFloor" then obj:Destroy() end
        end

        if hum then
            hum.PlatformStand, hum.Sit, hum.AutoRotate = false, false, true
            if hum.WalkSpeed <= 0 then hum.WalkSpeed = (_G.WalkSpeedEnabled and tonumber(_G.WalkSpeedValue)) or 16 end
            if hum.UseJumpPower and hum.JumpPower <= 0 then hum.JumpPower = 50 end
        end

        local ps = localPlayer:FindFirstChild("PlayerScripts")
        local pm = ps and ps:FindFirstChild("PlayerModule")
        if pm then
            local ok, mod = pcall(require, pm)
            if ok and mod and mod.GetControls then
                local controls = mod:GetControls()
                if controls and controls.Enable then controls:Enable() end
            end
        end

        local cam = workspace.CurrentCamera
        if cam and hum then
            if cam.CameraType == Enum.CameraType.Scriptable then cam.CameraType = Enum.CameraType.Custom end
            if not cam.CameraSubject then cam.CameraSubject = hum end
        end
    end)
end

local function ensureStreamingSafeTeleport(targetCFrame)
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local targetPos = targetCFrame.Position
    local tempPlatform = Instance.new("Part")
    tempPlatform.Name = "SuiSui_SafeFloor"
    tempPlatform.Size = Vector3.new(40, 3, 40)
    tempPlatform.Position = targetPos - Vector3.new(0, 2.5, 0)
    tempPlatform.Anchored, tempPlatform.CanCollide, tempPlatform.Transparency = true, true, 1
    tempPlatform.Parent = workspace

    root.Anchored = false
    root.CFrame = targetCFrame
    root.Velocity = Vector3.zero

    if localPlayer.RequestStreamAroundAsync then
        task.spawn(function() pcall(localPlayer.RequestStreamAroundAsync, localPlayer, targetPos) end)
    end
    task.delay(0.8, function()
        pcall(function()
            if tempPlatform and tempPlatform.Parent then tempPlatform:Destroy() end
            restorePlayerMovementControls()
        end)
    end)
    task.wait(0.45)
    restorePlayerMovementControls()
end

teleportToWorld = function(worldId)
    local wId = math.clamp(tonumber(worldId) or 1, 1, 9)
    _G.AnimeEyes_SelectedWorld = wId
    pcall(function()
        restorePlayerMovementControls()
        if teleportRemote then teleportRemote:FireServer(wId) end
        local char = localPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local orig = (WorldConfig and WorldConfig.origin and WorldConfig.origin(wId)) or WORLD_ORIGINS[wId] or Vector3.new(0, 0, 0)
            local groundY = (wId == 3) and 18.5 or (FLOOR_Y + 1.0)
            ensureStreamingSafeTeleport(CFrame.new(orig + Vector3.new(0, groundY, 46)))
        end
    end)
    Notification("Chuyển World", string.format("Đã về Hub %s!", WORLD_NAMES[wId] or ("World " .. wId)), 3)
    if updateEggTabForWorld then updateEggTabForWorld(wId) end
end

local function getStageCenter(stageNum)
    local _, worldOrigin = getCurrentWorld()
    stageNum = math.clamp(tonumber(stageNum) or 1, 1, 15)
    if WorldConfig and WorldConfig.spawnCentre then
        local localPos = WorldConfig.spawnCentre(stageNum)
        return worldOrigin + Vector3.new(localPos.X, FLOOR_Y, localPos.Z)
    end
    return worldOrigin + Vector3.new(0, FLOOR_Y, -75 - (stageNum - 1) * STAGE_LENGTH)
end

local function getYellowPadPos(stageNum)
    local _, worldOrigin = getCurrentWorld()
    stageNum = math.clamp(tonumber(stageNum) or 1, 1, 15)
    if WorldConfig and WorldConfig.padPosition then
        local localPos = WorldConfig.padPosition(stageNum, "gold")
        return worldOrigin + Vector3.new(localPos.X, 4.4, localPos.Z)
    end
    return worldOrigin + Vector3.new(20, 4.4, -111 - (stageNum - 1) * STAGE_LENGTH)
end

local function getStageAtZ(zCoord)
    local _, worldOrigin = getCurrentWorld()
    local localZ = zCoord - worldOrigin.Z
    if localZ > HUB_MIN_Z then return 0 end
    if WorldConfig and WorldConfig.stageAt then
        local s = WorldConfig.stageAt(localZ)
        if s and s > 0 then return math.clamp(s, 1, 15) end
    end
    return math.clamp(math.floor((HUB_MIN_Z - localZ) / STAGE_LENGTH) + 1, 1, 15)
end

local function getStageEnemies(stageNum)
    local enemies = {}
    if stageNum < 1 then return enemies end
    local center = getStageCenter(stageNum)

    if EnemiesModule and EnemiesModule.list then
        pcall(function()
            local list = EnemiesModule.list()
            if typeof(list) == "table" then
                for _, e in ipairs(list) do
                    if e and e.pos and (e.pos - center).Magnitude < 60 then
                        table.insert(enemies, e)
                    end
                end
            end
        end)
    end

    if #enemies == 0 then
        pcall(function()
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    local part = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                    if hum and hum.Health > 0 and part then
                        local dist = (part.Position - center).Magnitude
                        if dist < 60 then
                            table.insert(enemies, { id = obj.Name, pos = part.Position, dist = dist, model = obj })
                        end
                    end
                end
            end
        end)
    end
    return enemies
end

local function isStageBarrierOpen(_, stageNum)
    local ok, res = pcall(function()
        local targetWorld = getFarmWorld()
        for _, mapName in ipairs({"Map" .. targetWorld, "World" .. targetWorld, "World_" .. targetWorld}) do
            local m = workspace:FindFirstChild(mapName)
            local st = m and m:FindFirstChild("Stages") and m.Stages:FindFirstChild("Stage" .. stageNum)
            local b = st and st:FindFirstChild("Barrier", true)
            if b and b:IsA("BasePart") then
                if not b.CanCollide then return true end
                local sign = b:FindFirstChild("Sign")
                if sign and sign:FindFirstChild("Left") and sign.Left:IsA("TextLabel") and sign.Left.Text:upper():find("CLEARED") then
                    return true
                end
            end
        end
        return false
    end)
    return ok and res or false
end

local function isCurrentStageCleared(stageNum, elapsedInStage, hadEnemies)
    if stageNum < 1 or elapsedInStage < 0.35 then return false end
    if hadEnemies and #getStageEnemies(stageNum) == 0 then return true end
    if isStageBarrierOpen(getFarmWorld(), stageNum) then return true end
    if not hadEnemies and elapsedInStage >= 1.5 and #getStageEnemies(stageNum) == 0 then return true end
    return false
end

task.spawn(function()
    while isSessionActive() do
        pcall(function()
            local char = localPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local targetWorld = getFarmWorld()
            local curStage = root and getStageAtZ(root.Position.Z) or 0
            local target = math.clamp(tonumber(_G.AnimeEyes_TargetStage) or 5, 1, 15)
            local enemies = (curStage > 0) and getStageEnemies(curStage) or {}
            local stageText = (curStage == 0) and string.format("World %d | Hub (Spawn)", targetWorld) or string.format("World %d | Stage %d", targetWorld, curStage)
            updateLabel(LabelStageTitle, string.format("Ải: %s (Đích: Stage %d)", stageText, target))
            updateLabel(LabelEnemyLive, string.format("Quái còn sống: %d con", #enemies))
            updateLabel(LabelStageState, "Trạng thái: " .. tostring(currentStageData.combatState or "Đang chờ lệnh..."))
        end)
        task.wait(0.3)
    end
end)

-- (Đã tắt vòng lặp đóng bảng ngầm để không tự đóng Menu/Chức năng game người chơi đang mở)

-- ========================================================================
-- 9. LOGIC CHIẾN ĐẤU VƯỢT ẢI & NHẬN CÚP NATIVE (CLEAN & ROCK SOLID)
-- ========================================================================
local function isBossPriorityActive()
    if (isInsideKyubiArena and isInsideKyubiArena()) or (isPlayerNearArenaExitPortal and isPlayerNearArenaExitPortal(220)) then
        return true
    end
    if not _G.SuiSui_AutoBoss then return false end
    if _G.AnimeEyes_InBossFight or (bossHunterState and bossHunterState ~= "IDLE") then
        return true
    end
    if getKyubiTimerStatus then
        local bossTimerStatus, bossSecsLeft, _, _, _, _, bossHasJoinBtn = getKyubiTimerStatus()
        if bossHasJoinBtn or (bossTimerStatus == "waiting" and bossSecsLeft <= 15) or (bossTimerStatus == "active") then
            return true
        end
    end
    return false
end

local stageLoopEpoch = 0
startStageLoop = function()
    stageLoopEpoch = stageLoopEpoch + 1
    local currentEpoch = stageLoopEpoch

    task.spawn(function()
        local currentStageStartTime = os.clock()
        local lastStageIndex, stageHadEnemies = nil, false

        while isSessionActive() and _G.SuiSui_AutoStage and stageLoopEpoch == currentEpoch do
            local stepSuccess, err = pcall(function()
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum or hum.Health <= 0 then task.wait(0.5); return end

                if isBossPriorityActive() then
                    currentStageData.combatState = "Tạm dừng Đi Stage -> Đang ưu tiên Săn Boss Kyubi!"
                    if LabelStageState then updateLabel(LabelStageState, "Trạng thái: Tạm dừng -> Đang ưu tiên Săn Boss Kyubi!") end
                    task.wait(0.4)
                    return
                end

                restorePlayerMovementControls()

                local targetWorld, worldOrigin = getFarmWorld()
                if getPlayerPhysicalWorld() ~= targetWorld then
                    if isBossPriorityActive() then return end
                    currentStageData.combatState = string.format("Đang chuyển sang World %d...", targetWorld)
                    pcall(function() if teleportRemote then teleportRemote:FireServer(targetWorld) end end)
                    root.CFrame = CFrame.new(worldOrigin + Vector3.new(0, FLOOR_Y + 1, 46))
                    root.Velocity = Vector3.zero
                    task.wait(0.5)
                    if isBossPriorityActive() then return end
                    root.CFrame = CFrame.new(worldOrigin + Vector3.new(0, FLOOR_Y + 1, -15))
                    task.wait(0.2)
                    if isBossPriorityActive() then return end
                    root.CFrame = CFrame.new(worldOrigin + Vector3.new(0, FLOOR_Y + 1, -38))
                    task.wait(0.2)
                    if isBossPriorityActive() then return end
                    root.CFrame = CFrame.new(getStageCenter(1))
                    root.Velocity = Vector3.zero
                    lastStageIndex, stageHadEnemies, currentStageStartTime = 1, false, os.clock()
                    task.wait(0.8)
                    return
                end

                local curStage = getStageAtZ(root.Position.Z)
                local targetStage = math.clamp(tonumber(_G.AnimeEyes_TargetStage) or 5, 1, 15)
                local timeout = tonumber(_G.AnimeEyes_StageTimeout) or 20

                if curStage == 0 then
                    if isBossPriorityActive() then return end
                    currentStageData.combatState = "Đang ở Hub -> Tiến vào Stage 1..."
                    root.CFrame = CFrame.new(worldOrigin + Vector3.new(0, FLOOR_Y + 1, -15)); root.Velocity = Vector3.zero; task.wait(0.2)
                    if isBossPriorityActive() then return end
                    root.CFrame = CFrame.new(worldOrigin + Vector3.new(0, FLOOR_Y + 1, -38)); root.Velocity = Vector3.zero; task.wait(0.2)
                    if isBossPriorityActive() then return end
                    root.CFrame = CFrame.new(getStageCenter(1)); root.Velocity = Vector3.zero
                    lastStageIndex, stageHadEnemies, currentStageStartTime = 1, false, os.clock()
                    task.wait(0.6)
                    return
                end

                if curStage ~= lastStageIndex then
                    lastStageIndex, stageHadEnemies, currentStageStartTime = curStage, false, os.clock()
                end

                local elapsed = os.clock() - currentStageStartTime
                local isTimeExpired = (elapsed >= timeout)
                local stageCenter = getStageCenter(curStage)
                local stageEnemies = getStageEnemies(curStage)
                if #stageEnemies > 0 then stageHadEnemies = true end

                local stageCleared = isCurrentStageCleared(curStage, elapsed, stageHadEnemies)
                if LabelStageTimer then
                    updateLabel(LabelStageTimer, string.format("Thời gian đánh ải: %.1fs / %.0fs", math.min(elapsed, timeout), timeout))
                end

                if not stageCleared and not isTimeExpired then
                    currentStageData.combatState = string.format("Stage %d/%d: Đang diệt %d quái (%.1fs/%.0fs)...", curStage, targetStage, #stageEnemies, elapsed, timeout)
                    local isPlayerMoving = (hum.MoveDirection and hum.MoveDirection.Magnitude > 0.05)

                    if _G.AnimeEyes_CenterStage and not isPlayerMoving then
                        if (root.Position - stageCenter).Magnitude > 8 or math.abs(root.Position.Y - FLOOR_Y) > 4.0 then
                            root.CFrame = CFrame.new(stageCenter)
                            root.Velocity = Vector3.zero
                        end
                    end

                    local targetPos, targetId = stageCenter, nil
                    if #stageEnemies > 0 then
                        targetPos, targetId = stageEnemies[1].pos, stageEnemies[1].id
                        if not isPlayerMoving then
                            pcall(function()
                                local lookAt = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
                                if (lookAt - root.Position).Magnitude > 0.5 then root.CFrame = CFrame.new(root.Position, lookAt) end
                            end)
                        end
                    end

                    pcall(function()
                        if cooldownTable and _G.AnimeEyes_BypassCooldown then cooldownTable.attack = 0 end
                        if InputModule and InputModule.autoClick then InputModule.autoClick()
                        elseif trainRemote then trainRemote:FireServer() end
                        if castRemote then castRemote:FireServer("attack", targetPos, targetId) end
                    end)

                    if _G.AnimeEyes_AutoSkills then
                        pcall(function()
                            if cooldownTable and _G.AnimeEyes_BypassCooldown then cooldownTable.E, cooldownTable.R = 0, 0 end
                            if castRemote then
                                castRemote:FireServer("E", targetPos, targetId)
                                castRemote:FireServer("R", targetPos, targetId)
                            end
                        end)
                    end

                    if _G.SuiSui_AutoBoss and bossDropRemote then pcall(function() bossDropRemote:FireServer() end) end
                    local cps = tonumber(_G.AnimeEyes_StageCPS) or 25
                    task.wait(math.clamp(1 / cps, 0.02, 0.1))
                else
                    if isBossPriorityActive() then return end
                    if curStage >= targetStage then
                        currentStageData.combatState = string.format("ĐẠT ĐÍCH STAGE %d! Đang bước lên Bệ Vàng nhận Cúp...", curStage)
                        root.CFrame = CFrame.new(getYellowPadPos(curStage))
                        root.Velocity = Vector3.zero
                        pcall(function() if padRemote then padRemote:FireServer(curStage, "gold") end end)
                        task.wait(0.8)

                        currentStageData.combatState = string.format("Đã nhận Cúp Vàng! Về Hub Spawn World %d chuẩn bị ván mới...", targetWorld)
                        root.CFrame = CFrame.new(worldOrigin + Vector3.new(0, FLOOR_Y + 1, 46))
                        root.Velocity = Vector3.zero
                        lastStageIndex, stageHadEnemies, currentStageStartTime = 0, false, os.clock()
                        task.wait(1.0)
                    else
                        local nextStage = math.clamp(curStage + 1, 1, 15)
                        currentStageData.combatState = string.format("Vượt Stage %d! Tiến vào sàn đấu Stage %d...", curStage, nextStage)
                        local barrierZ = HUB_MIN_Z - (curStage * STAGE_LENGTH)
                        root.CFrame = CFrame.new(worldOrigin + Vector3.new(0, FLOOR_Y + 1, barrierZ + 5)); root.Velocity = Vector3.zero; task.wait(0.12)
                        root.CFrame = CFrame.new(worldOrigin + Vector3.new(0, FLOOR_Y + 1, barrierZ - 5)); root.Velocity = Vector3.zero; task.wait(0.12)
                        root.CFrame = CFrame.new(getStageCenter(nextStage)); root.Velocity = Vector3.zero
                        lastStageIndex, stageHadEnemies, currentStageStartTime = nextStage, false, os.clock()
                        task.wait(math.clamp(tonumber(_G.AnimeEyes_StageDelay) or 0.5, 0.3, 2.0))
                    end
                end
            end)
            if not stepSuccess then
                safeLog("[SuiSuiHUB Stage Error]:", tostring(err))
                task.wait(0.5)
            end
        end
        currentStageData.combatState = "Đã dừng Auto Đi Stage."
    end)
end

if _G.SuiSui_AutoStage and startStageLoop then
    task.spawn(function() task.wait(0.5); startStageLoop() end)
end

-- ========================================================================
-- 9.5. HỆ THỐNG SĂN BOSS THẾ GIỚI KYUBI (ƯU TIÊN SỐ 1, AUTO DODGE 3D & CỔNG EXIT)
-- ========================================================================
local isGuiActuallyVisible, triggerGuiButton
do
_G.AnimeEyes_KyubiActiveOnScreen = false
bossHunterState = "IDLE"
local joinAttemptTime = 0
local lastLobbyPortalStepTime = 0
local notInFightSince = 0
local lastValidBossPos = nil
local arenaCenterPos = nil
local hadLiveBossInFight = false
local bossMissingSince = 0

localPlayer.CharacterAdded:Connect(function()
    if isSessionActive() and _G.SuiSui_AutoBoss and (bossHunterState == "FIGHTING" or bossHunterState == "JOINING" or _G.AnimeEyes_InBossFight) then
        task.spawn(function()
            task.wait(0.4)
            if not isSessionActive() or not _G.SuiSui_AutoBoss then return end
            safeLog("[Kyubi Boss] Phát hiện nhân vật hồi sinh -> Lập tức bấm JOIN lại đấu trường Boss!")
            if findAndClickJoinBoss then findAndClickJoinBoss() end
        end)
    end
end)

isGuiActuallyVisible = function(guiObj)
    if not guiObj or not guiObj:IsA("GuiObject") or not guiObj.Visible then return false end
    local cur = guiObj.Parent
    while cur and not cur:IsA("ScreenGui") do
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        cur = cur.Parent
    end
    return not (cur and cur:IsA("ScreenGui") and not cur.Enabled)
end

-- Định vị chính xác Nút / Text LEAVE bên phải thanh máu Boss Kyubi (Main.HUD.Top.KuramaBar.KuramaSide)
local function findBossLeaveButton()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end

    local kuramaBar = pg:FindFirstChild("Main") and pg.Main:FindFirstChild("HUD")
        and pg.Main.HUD:FindFirstChild("Top") and pg.Main.HUD.Top:FindFirstChild("KuramaBar")
    if kuramaBar and isGuiActuallyVisible(kuramaBar) then
        for _, desc in ipairs(kuramaBar:GetDescendants()) do
            if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and isGuiActuallyVisible(desc) then
                if (desc.Text or ""):upper():find("LEAVE") then
                    local side = kuramaBar:FindFirstChild("KuramaSide")
                    if side and isGuiActuallyVisible(side) then return side end
                    return (desc.Parent and desc.Parent ~= kuramaBar and desc.Parent:IsA("GuiObject")) and desc.Parent or desc
                end
            end
        end
    end

    for _, desc in ipairs(pg:GetDescendants()) do
        if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and isGuiActuallyVisible(desc) then
            local txt = (desc:IsA("TextButton") and desc.Text or ""):upper()
            for _, child in ipairs(desc:GetDescendants()) do
                if child:IsA("TextLabel") and child.Text and #child.Text > 0 then
                    txt = txt .. " " .. child.Text:upper()
                end
            end
            txt = txt:gsub("^%s*(.-)%s*$", "%1")
            local bn = desc.Name:lower()
            if not txt:find("JOIN") and not txt:find("SKIP") and (txt == "LEAVE" or txt:find("LEAVE") or bn == "leave") then
                return desc
            end
        elseif desc:IsA("TextLabel") and isGuiActuallyVisible(desc) then
            local t = (desc.Text or ""):upper():gsub("^%s*(.-)%s*$", "%1")
            if t == "LEAVE" or t == "LEAVE FIGHT" then
                return (desc.Parent and desc.Parent:IsA("GuiObject")) and desc.Parent or desc
            end
        end
    end
    return nil
end

-- Tìm chính xác Cổng Vàng 3D "EXIT / BACK TO LOBBY" bên trong Đấu Trường Boss Kyubi
-- Trả về: vortexPart (BasePart cổng chạm), portalFloorPos (Vector3 tâm cổng dưới mặt sàn), touchParts (danh sách BasePart của cổng), signPos (Vector3 chữ EXIT)
local function findArenaExitPortal(maxDist)
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local signPart, signModel = nil, nil
    local bestDist = maxDist or 260

    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Text then
            local t = desc.Text:upper()
            if t:find("BACK TO LOBBY") or (t == "EXIT" and not desc:FindFirstAncestor("Stages")) then
                local bGui = desc:FindFirstAncestorWhichIsA("BillboardGui") or desc:FindFirstAncestorWhichIsA("SurfaceGui")
                local part = nil
                if bGui then
                    if bGui.Adornee then
                        if bGui.Adornee:IsA("BasePart") then part = bGui.Adornee
                        elseif bGui.Adornee:IsA("Attachment") and bGui.Adornee.Parent and bGui.Adornee.Parent:IsA("BasePart") then part = bGui.Adornee.Parent
                        elseif bGui.Adornee:IsA("Model") then part = bGui.Adornee.PrimaryPart or bGui.Adornee:FindFirstChildWhichIsA("BasePart", true) end
                    end
                    if not part and bGui.Parent then
                        if bGui.Parent:IsA("BasePart") then part = bGui.Parent
                        elseif bGui.Parent:IsA("Attachment") and bGui.Parent.Parent and bGui.Parent.Parent:IsA("BasePart") then part = bGui.Parent.Parent end
                    end
                end
                if not part then part = desc:FindFirstAncestorWhichIsA("BasePart") end
                local mdl = desc:FindFirstAncestorWhichIsA("Model")
                if not part and mdl then part = mdl.PrimaryPart or mdl:FindFirstChildWhichIsA("BasePart", true) end

                if part and part:IsA("BasePart") then
                    if not root then
                        signPart, signModel = part, mdl
                        break
                    end
                    local d = (part.Position - root.Position).Magnitude
                    if d < bestDist then
                        bestDist, signPart, signModel = d, part, mdl
                    end
                end
            end
        end
    end

    if not signPart then return nil, nil, nil, nil end

    local signPos = signPart.Position
    local touchParts = {}
    local seenParts = {}
    local vortexPart = signPart

    local function addCandidatePart(p)
        if not p or not p:IsA("BasePart") or seenParts[p] then return end
        if char and p:IsDescendantOf(char) then return end
        local dXZ = Vector2.new(p.Position.X - signPos.X, p.Position.Z - signPos.Z).Magnitude
        local dY = math.abs(p.Position.Y - signPos.Y)
        if dXZ <= 16 and dY <= 18 then
            seenParts[p] = true
            table.insert(touchParts, p)
            local hasTouch = (p:FindFirstChildOfClass("TouchTransmitter") ~= nil) or (p:FindFirstChild("TouchInterest") ~= nil)
            local hasFX = (p:FindFirstChildOfClass("ParticleEmitter") ~= nil) or (p:FindFirstChildOfClass("Beam") ~= nil)
            local vHasTouch = (vortexPart:FindFirstChildOfClass("TouchTransmitter") ~= nil) or (vortexPart:FindFirstChild("TouchInterest") ~= nil)
            if hasTouch and not vHasTouch then
                vortexPart = p
            elseif not vHasTouch and hasFX then
                vortexPart = p
            elseif not vHasTouch and p.Size.Magnitude < 30 and p.Position.Y < vortexPart.Position.Y and p.Position.Y >= (signPos.Y - 12) then
                vortexPart = p
            end
        end
    end

    addCandidatePart(signPart)
    if signModel then
        for _, d in ipairs(signModel:GetDescendants()) do addCandidatePart(d) end
    end
    if signPart.Parent then
        for _, d in ipairs(signPart.Parent:GetDescendants()) do addCandidatePart(d) end
    end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("TouchTransmitter") and d.Parent and d.Parent:IsA("BasePart") then
            addCandidatePart(d.Parent)
        end
    end

    -- Dò mặt sàn ngay dưới chân chữ EXIT / BACK TO LOBBY để lấy đúng vị trí tâm cổng vàng dưới đất
    local floorY = nil
    pcall(function()
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local ignore = {}
        if char then table.insert(ignore, char) end
        for _, tp in ipairs(touchParts) do
            if tp.Size.Magnitude < 25 then table.insert(ignore, tp) end
        end
        rp.FilterDescendantsInstances = ignore
        local hit = workspace:Raycast(Vector3.new(signPos.X, signPos.Y + 4, signPos.Z), Vector3.new(0, -30, 0), rp)
        if hit and hit.Position then floorY = hit.Position.Y end
    end)

    local portalFloorPos
    if vortexPart ~= signPart and vortexPart.Position.Y <= signPos.Y - 1.5 then
        portalFloorPos = vortexPart.Position
    elseif floorY then
        portalFloorPos = Vector3.new(signPos.X, floorY + 3.0, signPos.Z)
    else
        portalFloorPos = Vector3.new(signPos.X, signPos.Y - 4.5, signPos.Z)
    end

    return vortexPart, portalFloorPos, touchParts, signPos
end

isPlayerNearArenaExitPortal = function(maxRadius)
    local vp = findArenaExitPortal(maxRadius or 220)
    return vp ~= nil
end

-- Đọc trực tiếp thanh trạng thái chính thức Main.HUD.Top.KuramaBar.Back.Name
local function getKuramaBarMainText()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    local kb = pg and pg:FindFirstChild("Main") and pg.Main:FindFirstChild("HUD")
        and pg.Main.HUD:FindFirstChild("Top") and pg.Main.HUD.Top:FindFirstChild("KuramaBar")
    if kb and isGuiActuallyVisible(kb) then
        local back = kb:FindFirstChild("Back")
        local nameLbl = back and back:FindFirstChild("Name")
        if nameLbl and nameLbl:IsA("TextLabel") and isGuiActuallyVisible(nameLbl) then
            return (nameLbl.Text or ""):upper()
        end
    end
    return ""
end

-- Quét Cổng Vào Boss thực tế tại Hub/Sảnh ("KYUBI BOSS FIGHT")
local function findLobbyBossEntryPortal()
    local targetWorld, worldOrigin = getFarmWorld(true)
    local groundY = (targetWorld == 3) and 18.5 or (FLOOR_Y + 1.0)
    local foundSignPos = nil
    local fallbackSignPos = nil
    local nextFightText = ""

    pcall(function()
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text then
                local t = desc.Text:upper()
                if t:find("KYUBI BOSS FIGHT") then
                    local gui = desc:FindFirstAncestorWhichIsA("BillboardGui") or desc:FindFirstAncestorWhichIsA("SurfaceGui")
                    local adornee = gui and (gui.Adornee or gui.Parent)
                    local pPos = nil
                    if adornee and adornee:IsA("BasePart") then pPos = adornee.Position
                    elseif adornee and adornee:IsA("Model") then pPos = adornee:GetPivot().Position end

                    if pPos then
                        local subTxt = ""
                        if gui then
                            for _, sub in ipairs(gui:GetDescendants()) do
                                if sub:IsA("TextLabel") and sub ~= desc and sub.Text and #sub.Text > 0 then
                                    subTxt = subTxt .. " " .. sub.Text:upper()
                                end
                            end
                        end
                        if math.abs(pPos.X - worldOrigin.X) < 600 then
                            foundSignPos = pPos
                            nextFightText = subTxt
                            break
                        elseif not fallbackSignPos then
                            fallbackSignPos = pPos
                            nextFightText = subTxt
                        end
                    end
                end
            end
        end
    end)

    local signPos = foundSignPos or fallbackSignPos
    if not signPos then
        return nil, {}, "", false
    end

    local portalCenterXZ = Vector3.new(signPos.X, groundY, signPos.Z)

    -- Bắn tia Raycast xuống mặt sàn ngay dưới biển hiệu "KYUBI BOSS FIGHT" để lấy đúng cao độ mặt đất cổng Boss
    local rayOrigin = Vector3.new(signPos.X, signPos.Y - 2, signPos.Z)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    if localPlayer.Character then rayParams.FilterDescendantsInstances = { localPlayer.Character } end
    local rayHit = workspace:Raycast(rayOrigin, Vector3.new(0, -45, 0), rayParams)
    if rayHit and rayHit.Position then
        portalCenterXZ = rayHit.Position + Vector3.new(0, 2.5, 0)
    end

    -- Thu thập toàn bộ các BasePart của cánh cổng không gian Boss tại Hub để chạm vật lý & firetouchinterest
    local portalParts = {}
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "Terrain" then
                if not (localPlayer.Character and obj:IsDescendantOf(localPlayer.Character)) then
                    local dx = obj.Position.X - portalCenterXZ.X
                    local dz = obj.Position.Z - portalCenterXZ.Z
                    local dy = math.abs(obj.Position.Y - portalCenterXZ.Y)
                    if (dx * dx + dz * dz) <= (16 * 16) and dy <= 22 and obj.Size.Magnitude < 45 then
                        table.insert(portalParts, obj)
                    end
                end
            end
        end
    end)

    return portalCenterXZ, portalParts, nextFightText, true
end

-- Xử lý màn hình KNOCKED OUT! (Ảnh 3): Bấm nút Đỏ "No (BACK TO LOBBY)" để về sảnh miễn phí rồi lập tức JOIN lại!
local function checkAndHandleKnockedOut()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    local knockedOutFound = false
    for _, desc in ipairs(pg:GetDescendants()) do
        if desc:IsA("TextLabel") and isGuiActuallyVisible(desc) then
            local t = (desc.Text or ""):upper()
            if t:find("KNOCKED OUT") then
                knockedOutFound = true
                local container = desc.Parent
                while container and not container:IsA("ScreenGui") do
                    for _, btn in ipairs(container:GetDescendants()) do
                        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and isGuiActuallyVisible(btn) then
                            local btxt = (btn:IsA("TextButton") and btn.Text or ""):upper()
                            for _, c in ipairs(btn:GetDescendants()) do
                                if c:IsA("TextLabel") and c.Text then btxt = btxt .. " " .. c.Text:upper() end
                            end
                            -- Chỉ bấm nút "NO" (Back to Lobby), TUYỆT ĐỐI KHÔNG bấm "REVIVE NOW" tốn 9 Robux
                            if (btxt:find("NO") and not btxt:find("NOW")) or btn.Name:lower() == "no" then
                                triggerGuiButton(btn)
                                return true
                            end
                        end
                    end
                    container = container.Parent
                end
                break
            end
        end
    end
    return knockedOutFound
end

isInsideKyubiArena = function()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return false, 100, false, false, false end

    local barText = getKuramaBarMainText()
    local isPortalHome = barText:find("PORTAL HOME") ~= nil
    local hasLeaveBtn = (findBossLeaveButton() ~= nil)
    local bossHpPercent, hasBossPercent, hasKyubiLists = 100, false, false

    if isPortalHome then
        bossHpPercent, hasBossPercent = 0, true
    elseif barText:find("KYUBI") and not barText:find("IN ") and not barText:find("IS HERE") then
        local pct = barText:match("(%d+)%%")
        if pct then
            bossHpPercent, hasBossPercent = tonumber(pct), true
        end
    end

    if not hasBossPercent then
        for _, desc in ipairs(pg:GetDescendants()) do
            if desc:IsA("TextLabel") and isGuiActuallyVisible(desc) then
                local t = desc.Text:upper()
                if t:find("PORTAL HOME") then
                    isPortalHome, bossHpPercent, hasBossPercent = true, 0, true
                    break
                elseif t:find("KYUBI") and not t:find("IN ") and not t:find("IS HERE") and not t:find("IN 0:") and not t:find("IN 1:") and not t:find("IN 2:") and not t:find("IN 3:") then
                    local pct = t:match("(%d+)%%")
                    if pct then
                        bossHpPercent, hasBossPercent = tonumber(pct), true
                        break
                    end
                end
            end
        end
    end

    local kyubiLists = pg:FindFirstChild("KyubiLists")
    local bar = kyubiLists and kyubiLists:FindFirstChild("Bar")
    if bar then
        local dmgBar, dropBar = bar:FindFirstChild("KyubiDamage"), bar:FindFirstChild("KyubiDrops")
        if (dmgBar and isGuiActuallyVisible(dmgBar)) or (dropBar and isGuiActuallyVisible(dropBar)) then
            hasKyubiLists = true
        end
    end

    local hasEnragedTag = false
    local kb = pg:FindFirstChild("Main") and pg.Main:FindFirstChild("HUD")
        and pg.Main.HUD:FindFirstChild("Top") and pg.Main.HUD.Top:FindFirstChild("KuramaBar")
    if kb and isGuiActuallyVisible(kb) then
        local tagLbl = kb:FindFirstChild("Tag")
        if tagLbl and tagLbl:IsA("TextLabel") and isGuiActuallyVisible(tagLbl) then
            local tagTxt = (tagLbl.Text or ""):upper()
            if tagTxt:find("ENRAGED") then
                hasEnragedTag = true
            end
        end
    end

    local inFight = (hasLeaveBtn or hasBossPercent or hasKyubiLists or isPortalHome or hasEnragedTag)
    return inFight, bossHpPercent, hasLeaveBtn, hasBossPercent, isPortalHome
end

-- CHỈ lấy tọa độ Boss Kyubi thực sự trong Đấu Trường Boss (TUYỆT ĐỐI KHÔNG lấy nhầm quái Stage thường!)
getKyubiBossTarget = function()
    if EnemiesModule and EnemiesModule.list then
        local ok, list = pcall(EnemiesModule.list)
        if ok and typeof(list) == "table" and #list > 0 then
            for _, item in ipairs(list) do
                local idStr = tostring(item.id or item.name or ""):lower()
                if (item.boss or idStr:find("kyubi") or idStr:find("kurama") or idStr:find("boss")) and item.pos and item.pos.Y > -100 then
                    lastValidBossPos = item.pos
                    if not arenaCenterPos then arenaCenterPos = item.pos end
                    return item.pos, item.id or "Kyubi", true
                end
            end
        end
    end

    local _, portalFloorPos, _, signPos = findArenaExitPortal(260)
    local refPos = arenaCenterPos or lastValidBossPos or portalFloorPos or signPos
    local myEnemies = workspace:FindFirstChild("MyEnemies")
    if myEnemies then
        for _, m in ipairs(myEnemies:GetChildren()) do
            local r = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart or m:FindFirstChild("root") or m:FindFirstChild("Torso") or m:FindFirstChildOfClass("BasePart")
            if r and r.Position.Y > -100 then
                local mName = m.Name:lower()
                local isNamedBoss = mName:find("kyubi") or mName:find("kurama") or mName:find("boss") or (m:GetAttribute("Boss") == true)
                local isNearArena = refPos and ((r.Position - refPos).Magnitude <= 85) or false
                if isNamedBoss or isNearArena then
                    lastValidBossPos = r.Position
                    if not arenaCenterPos then arenaCenterPos = r.Position end
                    return r.Position, m.Name, true
                end
            end
        end
    end
    return lastValidBossPos, "Kyubi", false
end

-- Quét vùng đỏ AoE / đòn đánh Boss để né trong phạm vi an toàn của Đấu Trường
local function getBossDangerDodgeOffset(rootPos, bossPos)
    local dodgeVec = Vector3.zero
    local dangerFound = false
    local bossShielded = false

    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "Terrain" then
                local dist = (obj.Position - bossPos).Magnitude
                if dist < 55 then
                    local n = obj.Name:lower()
                    local c = obj.Color
                    local isRedZone = (c.R > 0.65 and c.G < 0.35 and c.B < 0.35)
                    local isDangerName = n:find("telegraph") or n:find("indicator") or n:find("danger") or n:find("aoe") or n:find("warning") or n:find("hitbox") or n:find("attack") or n:find("slam") or n:find("meteor") or n:find("fireball") or n:find("laser") or n:find("beam")
                    if (isRedZone or isDangerName) and obj.Transparency < 0.95 and obj.Size.Magnitude < 80 then
                        local toPlayer = Vector3.new(rootPos.X - obj.Position.X, 0, rootPos.Z - obj.Position.Z)
                        local radius = math.max(obj.Size.X, obj.Size.Z) * 0.55 + 6
                        if toPlayer.Magnitude < radius then
                            dangerFound = true
                            local pushDir = toPlayer.Magnitude > 0.1 and toPlayer.Unit or Vector3.new(1, 0, 0)
                            dodgeVec = dodgeVec + pushDir * (radius - toPlayer.Magnitude + 8)
                        end
                    end
                    if n:find("shield") or n:find("reflect") or n:find("barrier") or n:find("immune") then
                        if dist < 20 and obj.Transparency < 0.9 then bossShielded = true end
                    end
                elseif obj:IsA("Highlight") and obj.Enabled and obj.Parent and obj.Parent:IsA("Model") then
                    local p = obj.Parent.PrimaryPart or obj.Parent:FindFirstChild("HumanoidRootPart")
                    if p and (p.Position - bossPos).Magnitude < 25 then
                        local fc = obj.FillColor
                        if fc.B > 0.7 and fc.R < 0.3 then bossShielded = true end
                    end
                end
            end
        end
    end)

    return dodgeVec, dangerFound, bossShielded
end

-- Giữ tọa độ (X, Z) của nhân vật luôn nằm gọn bên trong tường Đấu Trường Boss (không bao giờ văng ra ngoài tường đen)
local function clampInsideBossArena(pos, fallbackCenter)
    local center = arenaCenterPos or fallbackCenter or pos
    if not arenaCenterPos and fallbackCenter then
        arenaCenterPos = fallbackCenter
        center = arenaCenterPos
    end
    if not center then return pos end

    local offsetXZ = Vector2.new(pos.X - center.X, pos.Z - center.Z)
    local maxSafeRadius = 13.5
    if offsetXZ.Magnitude > maxSafeRadius then
        local clampedXZ = offsetXZ.Unit * maxSafeRadius
        return Vector3.new(center.X + clampedXZ.X, pos.Y, center.Z + clampedXZ.Y)
    end
    return pos
end

triggerGuiButton = function(btn)
    if not btn then return false end
    local clicked = false
    local targets = { btn }
    if btn.Parent and btn.Parent:IsA("GuiObject") and btn.Parent.AbsoluteSize.X < 450 and btn.Parent.AbsoluteSize.Y < 180 then
        table.insert(targets, btn.Parent)
    end
    for _, desc in ipairs(btn:GetDescendants()) do
        if desc:IsA("GuiButton") or desc:IsA("TextLabel") or desc:IsA("Frame") then table.insert(targets, desc) end
    end

    local btnCenter = Vector2.new(0, 0)
    pcall(function()
        if btn.AbsolutePosition and btn.AbsoluteSize then
            btnCenter = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
        end
    end)

    for _, t in ipairs(targets) do
        pcall(function()
            if replicatesignal and t:IsA("GuiButton") then
                pcall(replicatesignal, t.Activated)
                pcall(replicatesignal, t.MouseButton1Click)
                clicked = true
            end
            if firesignal then
                for _, ev in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up"}) do
                    if t[ev] then pcall(firesignal, t[ev]); clicked = true end
                end
            end
            if getconnections then
                for _, ev in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up"}) do
                    local sig = t[ev]
                    if sig then
                        for _, conn in ipairs(getconnections(sig) or {}) do
                            if conn.Fire then pcall(conn.Fire, conn); clicked = true end
                            if conn.Function then pcall(conn.Function); clicked = true end
                        end
                    end
                end
                for _, ev in ipairs({"InputBegan", "InputEnded"}) do
                    local sig = t[ev]
                    if sig then
                        local uState = (ev == "InputBegan") and Enum.UserInputState.Begin or Enum.UserInputState.End
                        local posVec = Vector3.new(btnCenter.X, btnCenter.Y, 0)
                        local mockMouse = {
                            UserInputType = Enum.UserInputType.MouseButton1,
                            UserInputState = uState,
                            Position = posVec,
                            Delta = Vector3.zero,
                            KeyCode = Enum.KeyCode.Unknown
                        }
                        local mockTouch = {
                            UserInputType = Enum.UserInputType.Touch,
                            UserInputState = uState,
                            Position = posVec,
                            Delta = Vector3.zero,
                            KeyCode = Enum.KeyCode.Unknown
                        }
                        for _, conn in ipairs(getconnections(sig) or {}) do
                            if conn.Fire then
                                pcall(conn.Fire, conn, mockMouse, false)
                                pcall(conn.Fire, conn, mockTouch, false)
                                clicked = true
                            end
                            if conn.Function then
                                pcall(conn.Function, mockMouse, false)
                                pcall(conn.Function, mockTouch, false)
                                clicked = true
                            end
                        end
                    end
                end
            end
        end)
    end

    -- Luôn gửi kèm click VirtualInputManager vào đúng tâm nút (nếu nút không bị che bởi cửa sổ SuiSuiHUB)
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local guiService = game:GetService("GuiService")
        local inset = guiService and guiService:GetGuiInset() or Vector2.new(0, 36)
        if vim and btn.AbsolutePosition and btn.AbsoluteSize and btn.AbsoluteSize.X > 0 and btn.AbsoluteSize.Y > 0 then
            local center = btn.AbsolutePosition + btn.AbsoluteSize / 2
            if Window and Window.Frame and Window.Frame.Visible then
                local wp, ws = Window.Frame.AbsolutePosition, Window.Frame.AbsoluteSize
                if center.X >= wp.X and center.X <= (wp.X + ws.X) and center.Y >= wp.Y and center.Y <= (wp.Y + ws.Y) then
                    return
                end
            end
            local clickX = center.X + (inset.X or 0)
            local clickY = (center.Y < 0) and math.max(center.Y + inset.Y, 18) or (center.Y + inset.Y)
            vim:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
            task.wait(0.03)
            vim:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
            clicked = true
        end
    end)
    return clicked
end

isKyubiJoinButton = function(btn)
    if not btn or not (btn:IsA("TextButton") or btn:IsA("ImageButton")) or not isGuiActuallyVisible(btn) then return false end
    if btn.AbsoluteSize and (btn.AbsoluteSize.X <= 5 or btn.AbsoluteSize.Y <= 5) then return false end

    local bName = btn.Name:lower()
    local txt = (btn:IsA("TextButton") and btn.Text:upper() or "")
    for _, c in ipairs(btn:GetDescendants()) do
        if c:IsA("TextLabel") and c.Text and #c.Text > 0 then txt = txt .. " " .. c.Text:upper() end
    end
    txt = txt:gsub("^%s*(.-)%s*$", "%1")

    if txt:find("LEAVE") or bName:find("leave") or bName:find("group") or txt:find("GROUP") or bName:find("member") or txt:find("MEMBER") or txt:find("BANDO") or bName:find("community") then
        return false
    end
    local cp = btn.Parent
    while cp and not cp:IsA("ScreenGui") do
        local pn = cp.Name:lower()
        if pn == "community" or pn == "store" or pn == "shop" then return false end
        cp = cp.Parent
    end
    if bName:find("skip") or txt:find("SKIP") or bName:find("robux") or txt:find("29") or txt:find("R$") or txt:find("") or bName:find("chest") or txt:find("CHEST") or bName:find("claim") or txt:find("CLAIM") or bName:find("reward") or txt:find("REWARD") or bName:find("daily") or txt:find("DAILY") or bName:find("code") or txt:find("CODE") or bName:find("like") or txt:find("LIKE") then
        return false
    end
    if not (txt == "JOIN" or txt:find("JOIN") or bName == "join" or bName:find("join")) then return false end

    local cur = btn.Parent
    while cur and not cur:IsA("ScreenGui") do
        local cn = cur.Name:lower()
        if cn:find("kyubi") or cn:find("worldboss") or cn:find("kurama") or cn:find("nine") or cn:find("boss") or cn:find("fight") then return true end
        for _, desc in ipairs(cur:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text then
                local dt = desc.Text:upper()
                if dt:find("KYUBI") or dt:find("THE FIGHT") or dt:find("READY") then return true end
            end
        end
        cur = cur.Parent
    end
    return _G.AnimeEyes_KyubiActiveOnScreen == true
end

local function readRawKyubiBarTimer()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    local bestStatus, bestSecondsLeft, hasJoinButton = "unknown", 9999, false
    if not pg then return bestStatus, bestSecondsLeft, hasJoinButton end

    pcall(function()
        -- 1. Ưu tiên tuyệt đối đọc từ thanh KuramaBar.Back.Name chính thức trên đỉnh màn hình
        local barText = getKuramaBarMainText()
        if barText ~= "" then
            if barText:find("PORTAL HOME") then
                bestStatus, bestSecondsLeft = "portal_home", 0
            elseif barText:find("IS HERE") or barText:find("HERE") or barText:find("FIGHT") or barText:find("SPAWN") or barText:find("READY") then
                -- Ảnh 1: "KYUBI IS HERE!" -> Boss đang có sẵn trên map!
                bestStatus, bestSecondsLeft, hasJoinButton = "active", 0, true
            else
                local m, s = barText:match("KYUBI%s*IN%s*(%d+)%s*:%s*(%d+)")
                if m and s then
                    bestStatus, bestSecondsLeft = "waiting", tonumber(m) * 60 + tonumber(s)
                    if bestSecondsLeft <= 15 then hasJoinButton = true end
                else
                    local sOnly = barText:match("KYUBI%s*IN%s*(%d+)")
                    if sOnly then
                        bestStatus, bestSecondsLeft = "waiting", tonumber(sOnly)
                        if bestSecondsLeft <= 15 then hasJoinButton = true end
                    elseif barText:find("%%") then
                        local pct = tonumber(barText:match("(%d+)%%"))
                        if pct and pct <= 0 then
                            bestStatus, bestSecondsLeft = "portal_home", 0
                        else
                            bestStatus, bestSecondsLeft = "active", 0
                        end
                    end
                end
            end
        end

        -- 2. Kiểm tra nút JOIN xanh lá trên KuramaBar.KuramaSide hoặc KuramaCall (Ảnh 1)
        local kuramaCall = pg:FindFirstChild("Main") and pg.Main:FindFirstChild("HUD") and pg.Main.HUD:FindFirstChild("Overlay") and pg.Main.HUD.Overlay:FindFirstChild("KuramaCall")
        if kuramaCall and isGuiActuallyVisible(kuramaCall) then
            for _, c in ipairs(kuramaCall:GetDescendants()) do
                if (c:IsA("TextLabel") or c:IsA("TextButton")) and c.Text and c.Text:upper():find("JOIN") and isGuiActuallyVisible(c) then
                    hasJoinButton = true
                    break
                end
            end
        end
        local kuramaBar = pg:FindFirstChild("Main") and pg.Main:FindFirstChild("HUD") and pg.Main.HUD:FindFirstChild("Top") and pg.Main.HUD.Top:FindFirstChild("KuramaBar")
        if kuramaBar and isGuiActuallyVisible(kuramaBar) then
            local side = kuramaBar:FindFirstChild("KuramaSide") or kuramaBar:FindFirstChild("Join")
            if side and isGuiActuallyVisible(side) then
                local sideTxt = (side:IsA("TextLabel") or side:IsA("TextButton")) and (side.Text or ""):upper() or ""
                for _, c in ipairs(side:GetDescendants()) do
                    if (c:IsA("TextLabel") or c:IsA("TextButton")) and c.Text then
                        sideTxt = sideTxt .. " " .. c.Text:upper()
                    end
                end
                if sideTxt:find("JOIN") and not sideTxt:find("LEAVE") then
                    hasJoinButton = true
                    if bestStatus == "unknown" then
                        bestStatus, bestSecondsLeft = "active", 0
                    end
                end
            end
        end
    end)

    return bestStatus, bestSecondsLeft, hasJoinButton
end

-- Vào khu vực Boss an toàn (Không bao giờ kéo ngược nhân vật từ sàn Boss ra ngoài Map/Stage!)
local joinStepCounter = 0
findAndClickJoinBoss = function()
    -- 1. Nếu ĐÃ ở trong Đấu Trường Boss thì giữ nguyên tuyệt đối, KHÔNG dịch chuyển ra ngoài!
    local inArenaNow = isInsideKyubiArena()
    local _, _, hasLiveBoss = getKyubiBossTarget()
    if inArenaNow or hasLiveBoss or isPlayerNearArenaExitPortal(220) then
        return true
    end

    local clickedCount = 0
    local pg = localPlayer:FindFirstChild("PlayerGui")

    -- Chỉ vào Boss khi Boss thực sự đang có trên map / mở cổng (TUYỆT ĐỐI KHÔNG vào khi đang đếm ngược > 15s)
    local rawStatus, rawSecs, hasJoinBtn = readRawKyubiBarTimer()
    if rawStatus == "portal_home" or (rawStatus == "waiting" and rawSecs > 15 and not hasJoinBtn) then
        return false
    end

    -- 2. Khắc phục lỗi "Finish your wave first!":
    -- Nếu nhân vật đang đứng giữa ải Stage (Z < -30), phải Reset về Hub Spawn (Z = 46) trước khi bấm JOIN!
    pcall(function()
        local char = localPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root and getStageAtZ(root.Position.Z) >= 1 then
            restorePlayerMovementControls()
            local curWorld, worldOrigin = detectPhysicalWorld()
            local groundY = (curWorld == 3) and 18.5 or (FLOOR_Y + 1.0)
            if teleportRemote then
                pcall(function() teleportRemote:FireServer(curWorld) end)
            end
            root.Anchored = false
            root.CFrame = CFrame.new(worldOrigin + Vector3.new(0, groundY, 46))
            root.Velocity = Vector3.zero
            task.wait(0.28)
        end
    end)

    -- 3. Ưu tiên Cách 1: Gửi Remote Boss & Bấm nút JOIN xanh lá trên KuramaBar / KuramaCall (Đứng yên đợi Server tele vào Boss)
    pcall(function()
        if bossRemote then
            bossRemote:FireServer(true)
            bossRemote:FireServer("join")
            bossRemote:FireServer(1)
            bossRemote:FireServer()
        end
    end)

    if pg then
        pcall(function()
            local kuramaCall = pg:FindFirstChild("Main") and pg.Main:FindFirstChild("HUD") and pg.Main.HUD:FindFirstChild("Overlay") and pg.Main.HUD.Overlay:FindFirstChild("KuramaCall")
            if kuramaCall and isGuiActuallyVisible(kuramaCall) then
                local joinBtn = kuramaCall:FindFirstChild("Join") or kuramaCall:FindFirstChildWhichIsA("TextButton") or kuramaCall:FindFirstChildWhichIsA("ImageButton")
                if joinBtn and triggerGuiButton(joinBtn) then clickedCount = clickedCount + 1 end
            end

            local kuramaBar = pg:FindFirstChild("Main") and pg.Main:FindFirstChild("HUD") and pg.Main.HUD:FindFirstChild("Top") and pg.Main.HUD.Top:FindFirstChild("KuramaBar")
            if kuramaBar and isGuiActuallyVisible(kuramaBar) then
                local sideJoin = kuramaBar:FindFirstChild("KuramaSide") or kuramaBar:FindFirstChild("Join")
                if sideJoin and isGuiActuallyVisible(sideJoin) then
                    local sideTxt = (sideJoin:IsA("TextLabel") or sideJoin:IsA("TextButton")) and (sideJoin.Text or ""):upper() or ""
                    for _, c in ipairs(sideJoin:GetDescendants()) do
                        if (c:IsA("TextLabel") or c:IsA("TextButton")) and c.Text then sideTxt = sideTxt .. " " .. c.Text:upper() end
                    end
                    if sideTxt:find("JOIN") and not sideTxt:find("LEAVE") and not sideTxt:find("SKIP") then
                        if triggerGuiButton(sideJoin) then clickedCount = clickedCount + 1 end
                    end
                end
            end
        end)
    end

    if pg and clickedCount == 0 then
        pcall(function()
            for _, btn in ipairs(pg:GetDescendants()) do
                if isKyubiJoinButton(btn) and triggerGuiButton(btn) then
                    clickedCount = clickedCount + 1
                end
            end
        end)
    end

    -- Đợi 0.35s để Server dịch chuyển nhân vật vào Đấu Trường Boss sau khi bấm JOIN
    task.wait(0.35)
    local inArenaAfterClick = isInsideKyubiArena()
    local _, _, hasLiveAfterClick = getKyubiBossTarget()
    if inArenaAfterClick or hasLiveAfterClick or isPlayerNearArenaExitPortal(220) then
        return true
    end

    -- 4. Cách 2 (Dự phòng khi không có nút JOIN hoặc sau 1.8s bấm JOIN chưa vào):
    -- Chỉ bước qua cổng vật lý "KYUBI BOSS FIGHT" tại Hub nếu thực sự tìm thấy cổng trên Map và chưa vào trong sàn Boss
    local elapsedSinceJoinStart = (joinAttemptTime > 0) and (os.clock() - joinAttemptTime) or 99
    if (clickedCount == 0 or elapsedSinceJoinStart >= 1.8) and (os.clock() - lastLobbyPortalStepTime) >= 1.2 then
        pcall(function()
            local portalPos, portalParts, nextFightText, hasRealPortal = findLobbyBossEntryPortal()
            if not hasRealPortal or not portalPos then return end

            local nfMin, nfSec = nextFightText:match("NEXT%s*FIGHT%s*(%d+)%s*:%s*(%d+)")
            local nfTotal = (nfMin and nfSec) and (tonumber(nfMin) * 60 + tonumber(nfSec)) or 0
            local bossIsOnMap = (rawStatus == "active") or hasJoinBtn or (rawStatus == "waiting" and rawSecs <= 15) or (nfTotal > 0 and nfTotal <= 15)

            if bossIsOnMap and not isInsideKyubiArena() and not isPlayerNearArenaExitPortal(220) then
                lastLobbyPortalStepTime = os.clock()
                restorePlayerMovementControls()
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if root then
                    joinStepCounter = (joinStepCounter % 3) + 1
                    local sweepZ = (joinStepCounter - 2) * 2.0
                    local stepPos = portalPos + Vector3.new(0, 0.5, sweepZ)
                    root.Anchored = false
                    root.CFrame = CFrame.new(stepPos)
                    root.Velocity = Vector3.zero
                    if hum then
                        hum:MoveTo(portalPos + Vector3.new(0, 0, -sweepZ))
                    end
                    if firetouchinterest then
                        for _, pp in ipairs(portalParts or {}) do
                            pcall(firetouchinterest, root, pp, 0)
                            pcall(firetouchinterest, root, pp, 1)
                        end
                    end
                    clickedCount = clickedCount + 1
                end
            end
        end)
    end

    return clickedCount > 0
end

getKyubiTimerStatus = function()
    local inFight, _, _, hasBossPct = isInsideKyubiArena()
    local bestStatus, bestSecondsLeft, hasJoinButton = readRawKyubiBarTimer()
    if inFight and (hasBossPct or bestStatus ~= "waiting") then
        _G.AnimeEyes_KyubiActiveOnScreen = true
        return "active", 0, true, nil, nil, nil, false
    end
    if bestStatus == "waiting" and bestSecondsLeft > 15 then
        hasJoinButton = false
        _G.AnimeEyes_KyubiActiveOnScreen = false
    elseif (bestSecondsLeft <= 15 and bestStatus == "waiting") or bestStatus == "active" or hasJoinButton then
        _G.AnimeEyes_KyubiActiveOnScreen = true
    elseif bestSecondsLeft > 60 then
        _G.AnimeEyes_KyubiActiveOnScreen = false
    end
    return bestStatus, bestSecondsLeft, inFight, nil, nil, nil, hasJoinButton
end

-- HÀM KẾT THÚC BOSS: Đứng giữa sàn hút hết quà -> Đi thẳng vào Cổng Vàng "EXIT / BACK TO LOBBY" để Server tự tele về World
executeBossVictoryExit = function(reason)
    bossHunterState = "REWARDING"
    safeLog(string.format("[Kyubi Boss] Kết thúc Boss (%s) -> Hút quà & đi vào cổng EXIT / BACK TO LOBBY...", tostring(reason)))
    if LabelWorldBossPhase then updateLabel(LabelWorldBossPhase, "Tiến trình: Boss đã chết! Đang chờ hút quà & đi vào cổng EXIT...") end
    Notification("Kyubi Boss", "Đã hạ gục Boss! Đang đi vào cổng EXIT để về World...", 3)

    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- Bước 1: Hạ xuống mặt sàn ngay tâm Đấu Trường (0.8s) để quà Boss tự động hút hết vào người (không bị rơi ra ngoài tường)
    local safeCenter = arenaCenterPos or lastValidBossPos
    for _ = 1, 4 do
        pcall(function()
            if bossDropRemote then bossDropRemote:FireServer() end
            char = localPlayer.Character
            root = char and char:FindFirstChild("HumanoidRootPart")
            if root and safeCenter then
                local collectY = (safeCenter.Y >= -15 and safeCenter.Y <= 40) and (safeCenter.Y + 3.0) or root.Position.Y
                root.CFrame = CFrame.new(Vector3.new(safeCenter.X, collectY, safeCenter.Z))
                root.Velocity = Vector3.zero
            end
        end)
        task.wait(0.2)
    end

    -- Bước 2: Gỡ khóa bay (HoverVelocity) để nhân vật đi bộ/chạm vật lý trực tiếp vào Cổng Vàng "EXIT / BACK TO LOBBY"
    restorePlayerMovementControls()
    local returnWorld = _G.AnimeEyes_WorldBeforeBoss or _G.AnimeEyes_SelectedWorld or 1

    if LabelWorldBossPhase then
        updateLabel(LabelWorldBossPhase, "Tiến trình: Đang đi vào cánh cổng EXIT / BACK TO LOBBY...")
    end

    for step = 1, 14 do
        local vortexPart, portalFloorPos, touchParts, signPos = findArenaExitPortal(260)
        local stillInGui, _, stillHasLeave = isInsideKyubiArena()

        -- Nếu không còn thấy cổng EXIT quanh 260 studs và đã thoát GUI Boss -> Server đã tele nhân vật về World thành công!
        if not vortexPart and not stillInGui and not stillHasLeave then
            safeLog("[Kyubi Boss] Cổng EXIT đã dịch chuyển nhân vật về World thành công!")
            break
        end

        pcall(function()
            char = localPlayer.Character
            root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if root and portalFloorPos then
                local sweepZ = ((step % 3) - 1) * 1.5
                local basePos = (step % 2 == 0 and vortexPart) and vortexPart.Position or portalFloorPos
                local targetPortalPos = basePos + Vector3.new(0, 0.5, sweepZ)
                root.Anchored = false
                root.CFrame = CFrame.new(targetPortalPos)
                root.Velocity = Vector3.zero
                if hum then
                    hum:MoveTo(portalFloorPos + Vector3.new(0, 0, -sweepZ))
                end

                if firetouchinterest then
                    if vortexPart then
                        pcall(firetouchinterest, root, vortexPart, 0)
                        pcall(firetouchinterest, root, vortexPart, 1)
                    end
                    for _, tp in ipairs(touchParts or {}) do
                        pcall(firetouchinterest, root, tp, 0)
                        pcall(firetouchinterest, root, tp, 1)
                    end
                end
            end

            local leaveBtn = findBossLeaveButton()
            if leaveBtn then triggerGuiButton(leaveBtn) end
        end)

        task.wait(0.22)
    end

    task.wait(0.35)
    restorePlayerMovementControls()

    -- Bước 3: Kiểm tra sau khi đi qua cổng EXIT. Nếu cổng đã đưa về đúng World thì giữ nguyên, chỉ tele nếu lệch World hoặc kẹt
    local stillNearExit = isPlayerNearArenaExitPortal(220)
    local currentPhysicalW = detectPhysicalWorld()
    if stillNearExit or currentPhysicalW ~= returnWorld then
        if teleportToWorld then
            pcall(teleportToWorld, returnWorld)
        end
    end

    restorePlayerMovementControls()
    hadLiveBossInFight, bossMissingSince, lastValidBossPos, arenaCenterPos = false, 0, nil, nil
    bossHunterState, _G.AnimeEyes_InBossFight, _G.AnimeEyes_KyubiActiveOnScreen = "IDLE", false, false

    if LabelWorldBossPhase then
        local msg = _G.SuiSui_AutoStage and string.format("Tiến trình: Đã qua cổng EXIT về World %d -> Tiếp tục đi Stage", returnWorld)
            or string.format("Tiến trình: Hoàn tất săn Boss! Đã qua cổng EXIT về World %d", returnWorld)
        updateLabel(LabelWorldBossPhase, msg)
    end
    Notification("Kyubi Boss", string.format("Đã đi qua cổng EXIT và trở về World %d!", returnWorld), 3)
    task.wait(0.8)
end

dumpKyubiBossNow = function()
    local lines = {}
    local function dlog(fmt, ...) table.insert(lines, string.format("[%s] " .. fmt, os.date("%H:%M:%S"), ...)) end
    local inFight, pct, hasLeave, hasBossPct = isInsideKyubiArena()
    local vp, pFloor, tParts, sPos = findArenaExitPortal(300)
    local lobbyPos, lobbyParts, lobbyTxt = findLobbyBossEntryPortal()
    dlog("SuiSuiHUB BOSS DUMP | PlaceId: %s | inFight: %s | HP: %s%% | hasLeave: %s | hasBossPct: %s | state: %s",
        tostring(game.PlaceId), tostring(inFight), tostring(pct), tostring(hasLeave), tostring(hasBossPct), tostring(bossHunterState))
    dlog("ExitPortal: part=%s | floorPos=%s | signPos=%s | touchParts=%d",
        tostring(vp and vp:GetFullName() or "nil"), tostring(pFloor), tostring(sPos), tParts and #tParts or 0)
    dlog("LobbyEntryPortal: pos=%s | parts=%d | text='%s'",
        tostring(lobbyPos), lobbyParts and #lobbyParts or 0, tostring(lobbyTxt))

    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, desc in ipairs(pg:GetDescendants()) do
            local n = desc.Name:lower()
            local txt = (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Text or ""
            local tu = txt:upper()
            if n:find("kyubi") or n:find("boss") or n:find("kurama") or tu:find("KYUBI") or tu:find("JOIN") or tu:find("LEAVE") then
                dlog(" * %s [%s] | Vis: %s | Text: '%s'", desc:GetFullName(), desc.ClassName, tostring(desc:IsA("GuiObject") and desc.Visible), txt)
            end
        end
    end
    local bPos, bName, hasLive = getKyubiBossTarget()
    dlog("Target Boss: %s | Name: %s | hasLive: %s", tostring(bPos), tostring(bName), tostring(hasLive))
    local fullTxt = table.concat(lines, "\n")
    if writefile then pcall(function() writefile("!SuiSuiHUB/Anime Eyes/boss_dump.txt", fullTxt); writefile("boss_dump.txt", fullTxt) end) end
    if setclipboard then pcall(setclipboard, fullTxt) end
    Notification("Boss Dump", string.format("Đã lưu thông tin Boss vào boss_dump.txt (%d dòng)!", #lines), 4)
end

task.spawn(function()
    while isSessionActive() do
        pcall(function()
            -- Khóa cứng biến cũ = false để vô hiệu hóa 100% mọi vòng lặp cũ từ lần chạy trước
            _G.AnimeEyes_AutoBoss = false
            _G.AnimeEyes_AutoStage = false

            -- Đồng bộ trực tiếp trạng thái ô tích tím (CheckedFrame.Visible) trên UI
            local toggleBossUI = uiRegistry and uiRegistry.toggles and uiRegistry.toggles["AnimeEyes_AutoBoss"]
            if toggleBossUI then
                if toggleBossUI.CheckedFrame then
                    _G.SuiSui_AutoBoss = (toggleBossUI.CheckedFrame.Visible == true)
                elseif toggleBossUI.value ~= nil then
                    _G.SuiSui_AutoBoss = (toggleBossUI.value == true)
                end
            end
            local toggleStageUI = uiRegistry and uiRegistry.toggles and uiRegistry.toggles["AnimeEyes_AutoStage"]
            if toggleStageUI and toggleStageUI.CheckedFrame then
                local uiStageOn = (toggleStageUI.CheckedFrame.Visible == true)
                if uiStageOn ~= _G.SuiSui_AutoStage then
                    _G.SuiSui_AutoStage = uiStageOn
                    if uiStageOn and startStageLoop then startStageLoop() end
                end
            end

            if not _G.SuiSui_AutoBoss then
                if bossHunterState ~= "IDLE" or _G.AnimeEyes_InBossFight then restorePlayerMovementControls() end
                bossHunterState, _G.AnimeEyes_InBossFight, hadLiveBossInFight, bossMissingSince, notInFightSince = "IDLE", false, false, 0, 0
                if LabelWorldBossStatus then updateLabel(LabelWorldBossStatus, "Kyubi: Đang TẮT tự động săn") end
                if LabelWorldBossPhase then updateLabel(LabelWorldBossPhase, "Tiến trình: Đã tắt") end
                task.wait(0.6)
                return
            end

            local inFight, bossHpPercent, hasLeaveBtn, hasBossPercent, isPortalHome = isInsideKyubiArena()
            local nearExitPortal = isPlayerNearArenaExitPortal(220)
            local rawBarStatus, rawBarSecondsLeft, rawHasJoinBtn = readRawKyubiBarTimer()
            local bossPos, bossId, hasLiveBoss = getKyubiBossTarget()

            -- Nếu bị Boss đánh hạ (KNOCKED OUT! - Ảnh 3): Bấm nút Đỏ "No" về Lobby rồi lập tức JOIN lại trận!
            if checkAndHandleKnockedOut() then
                bossHunterState, joinAttemptTime, notInFightSince = "JOINING", os.clock(), 0
                _G.AnimeEyes_InBossFight, _G.AnimeEyes_KyubiActiveOnScreen = true, true
                if LabelWorldBossPhase then updateLabel(LabelWorldBossPhase, "Tiến trình: Bị hạ gục (KNOCKED OUT) -> Bấm No & đang vào lại Boss...") end
                task.wait(0.5)
                findAndClickJoinBoss()
                return
            end

            -- Nếu vẫn đang đứng gần Boss sống (<= 160 studs) hoặc cạnh cổng EXIT và chưa hết trận thì luôn coi là đang trong trận
            local charNow = localPlayer.Character
            local rootNow = charNow and charNow:FindFirstChild("HumanoidRootPart")
            local nearLiveBoss = (hasLiveBoss and bossPos and rootNow and (rootNow.Position - bossPos).Magnitude <= 160) or false
            if (nearExitPortal or nearLiveBoss) and hasLiveBoss and not isPortalHome and rawBarStatus ~= "portal_home" then
                inFight = true
            end

            -- CHỈ kiểm tra Boss chết (bossDefeated) khi nhân vật ĐANG ở trong trận Boss hoặc cạnh cổng EXIT
            -- (TUYỆT ĐỐI KHÔNG đọc KuramaCard vì KuramaCard luôn để Visible = true ở ngoài sảnh sau trận trước!)
            local bossDefeated, defeatReason = false, ""
            if inFight or bossHunterState == "FIGHTING" or nearExitPortal then
                if isPortalHome or rawBarStatus == "portal_home" then
                    bossDefeated, defeatReason = true, "Thanh trạng thái hiện PORTAL HOME (Boss 0% HP)"
                elseif hasBossPercent and bossHpPercent <= 0 then
                    bossDefeated, defeatReason = true, "Máu Boss về 0%"
                elseif rawBarStatus == "waiting" and rawBarSecondsLeft > 15 then
                    bossDefeated, defeatReason = true, string.format("Boss đã xong (KYUBI IN %ds) -> Đi vào cổng EXIT", rawBarSecondsLeft)
                elseif (inFight or bossHunterState == "FIGHTING") and hadLiveBossInFight and not hasLiveBoss then
                    if bossMissingSince == 0 then bossMissingSince = os.clock()
                    elseif (os.clock() - bossMissingSince) >= 0.8 then bossDefeated, defeatReason = true, "Model Boss đã biến mất -> Đi vào cổng EXIT" end
                end
            end

            if bossDefeated then
                executeBossVictoryExit(defeatReason)
                return
            end

            if inFight then
                bossHunterState, _G.AnimeEyes_InBossFight, notInFightSince = "FIGHTING", true, 0
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum or hum.Health <= 0 then task.wait(0.3); return end

                if hasLiveBoss then hadLiveBossInFight, bossMissingSince = true, 0 end
                if LabelWorldBossStatus then updateLabel(LabelWorldBossStatus, string.format("Kyubi: ĐANG GIAO TRANH! (Máu: %d%%)", bossHpPercent)) end

                if not bossPos then
                    if LabelWorldBossPhase then updateLabel(LabelWorldBossPhase, "Tiến trình: Đang kiểm tra trạng thái Boss...") end
                    root.Velocity = Vector3.zero
                    task.wait(0.1)
                    return
                end

                local bv = root:FindFirstChild("SuiSui_HoverVelocity")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "SuiSui_HoverVelocity"
                    bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
                    bv.Velocity = Vector3.zero
                    bv.Parent = root
                end

                local hoverH = tonumber(_G.AnimeEyes_BossHoverHeight) or 26
                local targetBaseY = (bossPos.Y >= -10 and bossPos.Y <= 25) and bossPos.Y or (FLOOR_Y + 1.0)
                local isDodgeEnabled = (_G.AnimeEyes_AutoDodge ~= nil and _G.AnimeEyes_AutoDodge or true)
                local targetPos3D
                local holdFireForShield = false

                if hasLiveBoss and isDodgeEnabled then
                    local dodgeVec, dangerFound, bossShielded = getBossDangerDodgeOffset(root.Position, bossPos)
                    holdFireForShield = bossShielded
                    local hpPercent = (hum.Health / (hum.MaxHealth > 0 and hum.MaxHealth or 100)) * 100

                    if hpPercent < 65 or bossShielded then
                        local safeCenter = arenaCenterPos or bossPos
                        targetPos3D = Vector3.new(safeCenter.X, targetBaseY + 36, safeCenter.Z)
                        if LabelWorldBossPhase then
                            updateLabel(LabelWorldBossPhase, bossShielded
                                and "Tiến trình: [DODGE] Boss bật Khiên -> Bay cao ngừng bắn tránh phản đòn!"
                                or string.format("Tiến trình: [DODGE KHẨN CẤP] Máu %d%% -> Bay cao giữa sàn hồi phục...", math.floor(hpPercent)))
                        end
                    else
                        local dSpeed = tonumber(_G.AnimeEyes_DodgeSpeed) or 3
                        local dRadius = math.clamp(tonumber(_G.AnimeEyes_DodgeRadius) or 10, 6, 13)
                        local now = os.clock()
                        local angle = (now * dSpeed) % (2 * math.pi)
                        local rawOrbit = Vector3.new(
                            bossPos.X + math.cos(angle) * dRadius + dodgeVec.X,
                            targetBaseY + hoverH + math.sin(now * 5.0) * 3.5 + (dangerFound and 8 or 0),
                            bossPos.Z + math.sin(angle) * dRadius + dodgeVec.Z
                        )
                        targetPos3D = clampInsideBossArena(rawOrbit, bossPos)
                        if LabelWorldBossPhase then
                            updateLabel(LabelWorldBossPhase, dangerFound
                                and "Tiến trình: [DODGE AoE] Phát hiện vùng đỏ chiêu Boss -> Đang né trong sàn!"
                                or "Tiến trình: Đang bay né chiêu 3D trong Đấu Trường (Auto Dodge ON)...")
                        end
                    end
                else
                    local rawStatic = Vector3.new(bossPos.X, targetBaseY + hoverH, bossPos.Z + 6)
                    targetPos3D = clampInsideBossArena(rawStatic, bossPos)
                    if LabelWorldBossPhase then updateLabel(LabelWorldBossPhase, "Tiến trình: Đang bay trên đầu Boss tiêu diệt an toàn...") end
                end

                root.CFrame = CFrame.new(targetPos3D, Vector3.new(bossPos.X, targetBaseY + 4, bossPos.Z))
                root.Velocity = Vector3.zero
                if bv then bv.Velocity = Vector3.zero end

                if not holdFireForShield then
                    pcall(function()
                        if cooldownTable and _G.AnimeEyes_BypassCooldown then
                            cooldownTable.attack, cooldownTable.E, cooldownTable.R = 0, 0, 0
                        end
                        if InputModule and InputModule.autoClick then InputModule.autoClick()
                        elseif trainRemote then trainRemote:FireServer() end
                        if InputModule and InputModule.press then InputModule.press("E"); InputModule.press("R") end
                        if castRemote then
                            castRemote:FireServer("attack", bossPos, bossId)
                            castRemote:FireServer("E", bossPos, bossId)
                            castRemote:FireServer("R", bossPos, bossId)
                        end
                        if bossDropRemote then bossDropRemote:FireServer() end
                    end)
                end

                local cps = tonumber(_G.AnimeEyes_StageCPS) or 25
                task.wait(math.clamp(1 / cps, 0.02, 0.05))
                return
            end

            if bossHunterState == "FIGHTING" and not inFight then
                -- Chống nhiễu GUI 1-2 nhịp khi Boss chuyển trạng thái ENRAGED!: Phải thực sự rời sàn > 1.5s mới bấm JOIN lại
                if notInFightSince == 0 then
                    notInFightSince = os.clock()
                end
                if (os.clock() - notInFightSince) < 1.5 then
                    task.wait(0.2)
                    return
                end
                notInFightSince = 0
                bossHunterState, joinAttemptTime = "JOINING", os.clock()
                _G.AnimeEyes_InBossFight, _G.AnimeEyes_KyubiActiveOnScreen = true, true
                if LabelWorldBossPhase then updateLabel(LabelWorldBossPhase, "Tiến trình: Nhân vật đã hồi sinh -> Đang bấm JOIN vào lại Boss...") end
                Notification("Kyubi Boss", "Nhân vật đã hồi sinh! Đang vào lại khu vực Boss Kyubi...", 2)
                findAndClickJoinBoss()
                task.wait(0.6)
                return
            end

            if bossHunterState == "JOINING" then
                -- Nếu trong lúc đang chờ Join mà thanh báo chuyển sang chờ hồi lâu (> 15s) thì dừng Join ngay
                if rawBarStatus == "waiting" and rawBarSecondsLeft > 15 and not rawHasJoinBtn then
                    bossHunterState, _G.AnimeEyes_InBossFight, _G.AnimeEyes_KyubiActiveOnScreen = "IDLE", false, false
                    restorePlayerMovementControls()
                    return
                end
                _G.AnimeEyes_InBossFight, _G.AnimeEyes_KyubiActiveOnScreen = true, true
                local elapsed = os.clock() - joinAttemptTime
                if elapsed > 45 then
                    bossHunterState, _G.AnimeEyes_InBossFight, _G.AnimeEyes_KyubiActiveOnScreen = "IDLE", false, false
                    if LabelWorldBossPhase then updateLabel(LabelWorldBossPhase, "Tiến trình: Hết thời gian chờ Join -> Tiếp tục Farm") end
                    return
                end
                if LabelWorldBossStatus then updateLabel(LabelWorldBossStatus, "Kyubi: ĐÃ XUẤT HIỆN! (Đang vào khu vực Boss)") end
                if LabelWorldBossPhase then updateLabel(LabelWorldBossPhase, string.format("Tiến trình: Đang bấm JOIN & đi qua cổng Boss tại Hub (%ds / 45s)...", math.floor(elapsed))) end
                findAndClickJoinBoss()
                task.wait(0.45)
                return
            end

            bossHunterState, _G.AnimeEyes_InBossFight = "IDLE", false
            restorePlayerMovementControls()

            local charRescue = localPlayer.Character
            local rootRescue = charRescue and charRescue:FindFirstChild("HumanoidRootPart")
            if rootRescue and not inFight and not nearExitPortal and rootRescue.Position.Y < -35 then
                local targetWorld, worldOrigin = getFarmWorld()
                local groundY = (targetWorld == 3) and 18.5 or (FLOOR_Y + 1.0)
                rootRescue.CFrame = CFrame.new(worldOrigin + Vector3.new(0, groundY, 46))
                rootRescue.Velocity = Vector3.zero
            end

            local status, secondsLeft, _, _, _, _, hasJoinButton = getKyubiTimerStatus()
            local isCooldown = (status == "waiting" and secondsLeft > 15 and not hasJoinButton)
            if isCooldown then
                bossHunterState, _G.AnimeEyes_InBossFight, _G.AnimeEyes_KyubiActiveOnScreen, hasJoinButton = "IDLE", false, false, false
            end

            if LabelWorldBossStatus then
                if isCooldown and secondsLeft < 9999 then
                    updateLabel(LabelWorldBossStatus, string.format("Kyubi: Xuất hiện sau %02d:%02d", math.floor(secondsLeft / 60), secondsLeft % 60))
                elseif hasJoinButton or status == "active" or (status == "waiting" and secondsLeft <= 15) then
                    updateLabel(LabelWorldBossStatus, "Kyubi: Sẵn sàng tham chiến! (Đang vào cổng Boss)")
                else
                    updateLabel(LabelWorldBossStatus, "Kyubi: Đang theo dõi...")
                end
            end

            if LabelWorldBossPhase and bossHunterState == "IDLE" then
                if _G.SuiSui_AutoStage then
                    updateLabel(LabelWorldBossPhase, (isCooldown and secondsLeft < 9999)
                        and string.format("Tiến trình: Đang nhường quyền Auto Stage (Boss hồi: %02d:%02d)", math.floor(secondsLeft / 60), secondsLeft % 60)
                        or "Tiến trình: Đang nhường quyền cho Auto Stage")
                else
                    updateLabel(LabelWorldBossPhase, (isCooldown and secondsLeft < 9999)
                        and string.format("Tiến trình: Boss đang hồi (%02d:%02d) - Nghỉ tại Hub", math.floor(secondsLeft / 60), secondsLeft % 60)
                        or "Tiến trình: Đang chờ sự kiện Boss")
                end
            end

            if not isCooldown and (hasJoinButton or (status == "waiting" and secondsLeft <= 15) or status == "active") then
                _G.AnimeEyes_WorldBeforeBoss = detectPhysicalWorld() or _G.AnimeEyes_SelectedWorld or 1
                bossHunterState, joinAttemptTime = "JOINING", os.clock()
                _G.AnimeEyes_InBossFight, _G.AnimeEyes_KyubiActiveOnScreen = true, true
                if LabelWorldBossPhase then updateLabel(LabelWorldBossPhase, "Tiến trình: [Ưu Tiên Số 1] Tạm dừng Stage -> Đang qua cổng Boss...") end
                Notification("Kyubi Boss", "Boss đã xuất hiện trên Map! Đang bấm JOIN & đi qua cổng Boss!", 3)
                findAndClickJoinBoss()
                task.wait(0.45)
            end
        end)
        task.wait(0.45)
    end
end)

end

-- ========================================================================
-- 10. LOGIC FARM CHAKRA, TRÙNG SINH & MỞ TRỨNG CÚP (TAB 2 & TAB 3 ENGINE)
-- ========================================================================
local isNativeClickRunning = false
startNativeClickLoop = function()
    if isNativeClickRunning then return end
    isNativeClickRunning = true
    task.spawn(function()
        while _G.AnimeEyes_AutoClick do
            if _G.AnimeEyes_BypassCooldown and cooldownTable then cooldownTable.attack = 0 end
            pcall(function()
                if InputModule and InputModule.autoClick then InputModule.autoClick()
                elseif trainRemote then trainRemote:FireServer() end
            end)
            task.wait(math.clamp(1 / (tonumber(_G.AnimeEyes_TargetCPS) or 25), 0.02, 0.2))
        end
        isNativeClickRunning = false
    end)
end

task.spawn(function()
    while isSessionActive() do
        if _G.AnimeEyes_AutoSkills and InputModule and InputModule.press then
            pcall(function()
                if _G.AnimeEyes_BypassCooldown and cooldownTable then cooldownTable.E, cooldownTable.R = 0, 0 end
                InputModule.press("E"); task.wait(0.1); InputModule.press("R")
            end)
        end
        task.wait(1.0)
    end
end)

task.spawn(function()
    while isSessionActive() do
        if _G.AnimeEyes_KeepFreeOn and AutoClickModule then
            pcall(function()
                if AutoClickModule.freeOn and not AutoClickModule.freeOn() and AutoClickModule.toggleFree then
                    AutoClickModule.toggleFree()
                end
            end)
        end
        task.wait(3.0)
    end
end)

triggerRebirthOnce = function()
    pcall(function()
        if rebirthRemote then
            if rebirthRemote:IsA("RemoteFunction") then rebirthRemote:InvokeServer() else rebirthRemote:FireServer() end
        end
    end)
end

task.spawn(function()
    while isSessionActive() do
        if _G.AnimeEyes_AutoRebirth then triggerRebirthOnce() end
        task.wait(tonumber(_G.AnimeEyes_RebirthDelay) or 1.5)
    end
end)

do
local function isEggGuiVisible(obj)
    if not obj or not obj:IsA("GuiObject") then return false end
    if obj.AbsoluteSize.X <= 4 or obj.AbsoluteSize.Y <= 4 then return false end
    local curr = obj
    while curr do
        if curr:IsA("GuiObject") and not curr.Visible then return false end
        if curr:IsA("LayerCollector") then
            if not curr.Enabled then return false end
            break
        end
        curr = curr.Parent
    end
    return true
end

local function clickEggPopupHatchButton(preferredCount)
    local clickedAny = false
    pcall(function()
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if not pg then return end

        local wantX3 = (tonumber(preferredCount) or 3) >= 3
        local x3Buttons = {}
        local x1Buttons = {}
        local seenContainers = {}

        for _, desc in ipairs(pg:GetDescendants()) do
            if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and isEggGuiVisible(desc) then
                local rawTxt = tostring(desc.Text or ""):upper():gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
                if #rawTxt > 0 and not rawTxt:find("DELETE") and not rawTxt:find("ROBUX") and not rawTxt:find("") then
                    local isX3 = (rawTxt == "HATCH X3" or rawTxt:find("HATCH%s*X%s*3") ~= nil)
                    local isX1 = (rawTxt == "HATCH X1" or rawTxt:find("HATCH%s*X%s*1") ~= nil)
                    if isX3 or isX1 then
                        local btnContainer = nil
                        if desc:IsA("GuiButton") then
                            btnContainer = desc
                        elseif desc.Parent and desc.Parent:IsA("GuiButton") then
                            btnContainer = desc.Parent
                        elseif desc.Parent and desc.Parent.Parent and desc.Parent.Parent:IsA("GuiButton") then
                            btnContainer = desc.Parent.Parent
                        elseif desc.Parent then
                            btnContainer = desc.Parent:FindFirstChildWhichIsA("GuiButton") or desc.Parent
                        else
                            btnContainer = desc
                        end

                        if btnContainer and not seenContainers[btnContainer] then
                            seenContainers[btnContainer] = true
                            if isX3 then
                                table.insert(x3Buttons, btnContainer)
                            else
                                table.insert(x1Buttons, btnContainer)
                            end
                        end
                    end
                end
            end
        end

        local targetList = wantX3 and (#x3Buttons > 0 and x3Buttons or x1Buttons) or (#x1Buttons > 0 and x1Buttons or x3Buttons)
        for _, btn in ipairs(targetList) do
            if triggerGuiButton(btn) then
                clickedAny = true
            end
        end
    end)
    return clickedAny
end

local lastEquipBestTick = 0
task.spawn(function()
    while isSessionActive() do
        if _G.AnimeEyes_AutoHatch and not (_G.SuiSui_AutoBoss and _G.AnimeEyes_InBossFight) then
            pcall(function()
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum or hum.Health <= 0 then task.wait(0.5); return end

                local targetWorld, worldOrigin = getFarmWorld()
                local eggData = getSelectedCupEggData and getSelectedCupEggData(targetWorld)
                if not eggData then return end

                local count = tonumber(_G.SuiSui_HatchAmount) or tonumber(_G.AnimeEyes_HatchAmount) or 3
                local standPos = worldOrigin + eggData.offset + Vector3.new(0, 1.2, 0)
                if (root.Position - standPos).Magnitude > 5.5 then
                    root.CFrame = CFrame.new(standPos)
                    root.Velocity = Vector3.zero
                    task.wait(0.25)
                end

                -- 1. Ưu tiên bấm trực tiếp nút HATCH x3 (hoặc HATCH x1) trên bảng trứng đang mở (Void Egg, v.v.)
                local clickedPopup = clickEggPopupHatchButton(count)

                -- 2. Gửi kèm Remote dự phòng không chặn luồng nếu bảng trứng chưa kịp hiện
                if not clickedPopup and petActionRemote then
                    task.spawn(function()
                        pcall(function()
                            if petActionRemote:IsA("RemoteFunction") then
                                petActionRemote:InvokeServer("hatch", eggData.id or eggData.name, count)
                                petActionRemote:InvokeServer("Hatch", eggData.name, count)
                            else
                                petActionRemote:FireServer("hatch", eggData.id or eggData.name, count)
                                petActionRemote:FireServer("Hatch", eggData.name, count)
                            end
                        end)
                    end)
                end

                -- 3. Tự động trang bị Pet mạnh nhất (mỗi 2.5s để không làm nghẽn tốc độ bấm HATCH x3)
                if _G.AnimeEyes_AutoEquipBestPet and petActionRemote and (os.clock() - lastEquipBestTick >= 2.5) then
                    lastEquipBestTick = os.clock()
                    task.spawn(function()
                        pcall(function()
                            if petActionRemote:IsA("RemoteFunction") then petActionRemote:InvokeServer("EquipBest")
                            else petActionRemote:FireServer("EquipBest") end
                        end)
                    end)
                end
            end)
        end
        task.wait(0.3)
    end
end)
end

-- ========================================================================
-- 13. HỆ THỐNG CỬA HÀNG HOÀN CHỈNH (MY EYES, AURAS, BOSS SHOP & REWARDS)
-- ========================================================================
do
local function formatNumber(n)
    n = tonumber(n) or 0
    if n >= 1e18 then return string.format("%.2fQi", n / 1e18) end
    if n >= 1e15 then return string.format("%.2fQa", n / 1e15) end
    if n >= 1e12 then return string.format("%.2fT", n / 1e12) end
    if n >= 1e9 then return string.format("%.2fB", n / 1e9) end
    if n >= 1e6 then return string.format("%.2fM", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fK", n / 1e3) end
    return tostring(math.floor(n))
end

local MASTER_EYES_CHAIN
do
local function E(id, name, wins, mult, world, padIndex) return { id = id, name = name, wins = wins, mult = mult, world = world, padIndex = padIndex } end
MASTER_EYES_CHAIN = {
    E("sharingan", "Sharingan", 0, 1, 1, 1), E("mangekyo", "Mangekyo Sharingan", 10, 2, 1, 2), E("geass", "Geass", 50, 3, 1, 3), E("eternal_mangekyo", "Eternal Mangekyo Sharingan", 300, 4, 1, 4),
    E("rinnegan", "Rinnegan", 2000, 7, 1, 5), E("jogan", "Jogan", 15000, 10, 1, 6), E("tenseigan", "Tenseigan", 100000, 14, 1, 7), E("rinne_sharingan", "Rinne Sharingan", 500000, 32, 1, 8),
    E("senrigan", "Senrigan", 2000000, 75, 1, 9), E("shion", "Shion\'s Dojutsu", 6000000, 170, 1, 10), E("six_eyes", "Six Eyes", 15000000, 400, 1, 11), E("kokugan", "Kokugan", 40000000, 900, 1, 12),
    E("all_seeing", "All-Seeing Eyes of God", 100000000, 2100, 1, 13), E("shin_ketsuryugan", "Shin Ketsuryugan", 0, 1, 1, 14), E("beast_gaze", "Beast Gaze", 790000000.0, 3900.0, 2, 1), E("violet_halo", "Violet Halo", 3400000000.0, 16000.0, 2, 2),
    E("venom_tomoe", "Venom Tomoe", 14000000000.0, 66000.0, 2, 3), E("lotus_eye", "Lotus Eye", 59000000000.0, 270000.0, 2, 4), E("phantom_pinwheel", "Phantom Pinwheel", 240000000000.0, 1100000.0, 2, 5), E("amethyst_star", "Amethyst Star", 960000000000.0, 4500000.0, 2, 6),
    E("grave_rinne", "Grave Rinne", 14000000000000.0, 19000000.0, 2, 7), E("jade_seal", "Jade Seal", 54000000000000.0, 76000000.0, 2, 8), E("solar_lotus", "Solar Lotus", 210000000000000.0, 310000000.0, 2, 9), E("crimson_spiral", "Crimson Spiral", 820000000000000.0, 1300000000.0, 2, 10),
    E("sage_rings", "Sage Rings", 3200000000000000.0, 5200000000.0, 2, 11), E("oracle_eye", "Oracle Eye", 1.2e+16, 21000000000.0, 2, 12), E("celestial_gaze", "Celestial Gaze", 4.7e+16, 88000000000.0, 2, 13), E("blossom_orbit", "Blossom Orbit", 3.9e+17, 260000000000.0, 3, 1),
    E("thorn_blossom", "Thorn Blossom", 1.7e+18, 1100000000000.0, 3, 2), E("crimson_bloom", "Crimson Bloom", 7.1e+18, 4300000000000.0, 3, 3), E("nightshade_pinwheel", "Nightshade Pinwheel", 2.8e+19, 17000000000000.0, 3, 4), E("iron_mandala", "Iron Mandala", 1.2e+20, 70000000000000.0, 3, 5),
    E("void_compass", "Void Compass", 4.6e+20, 290000000000000.0, 3, 6), E("blood_trident", "Blood Trident", 1.8e+21, 1100000000000000.0, 3, 7), E("moon_rinne", "Moon Rinne", 7.1e+21, 4700000000000000.0, 3, 8), E("rift_crescent", "Rift Crescent", 2.8e+22, 1.8e+16, 3, 9),
    E("scarlet_whirl", "Scarlet Whirl", 1.1e+23, 7.7e+16, 3, 10), E("eclipse_spiral", "Eclipse Spiral", 4.2e+23, 3.1e+17, 3, 11), E("inferno_star", "Inferno Star", 1.6e+24, 1.2e+18, 3, 12), E("thorn_halo", "Thorn Halo", 6.1e+24, 5.1e+18, 3, 13),
    E("arcane_sigil", "Arcane Sigil", 2.4e+25, 2.1e+19, 3, 14), E("tide_tomoe", "Tide Tomoe", 2e+26, 4.7e+19, 4, 1), E("frost_thorn", "Frost Thorn", 8.5e+26, 2e+20, 4, 2), E("glacier_star", "Glacier Star", 3.6e+27, 7.7e+20, 4, 3),
    E("frozen_rinne", "Frozen Rinne", 1.4e+28, 3.1e+21, 4, 4), E("abyss_spindle", "Abyss Spindle", 5.8e+28, 1.3e+22, 4, 5), E("starsea_rinne", "Starsea Rinne", 2.3e+29, 5.1e+22, 4, 6), E("azure_flame", "Azure Flame", 9.2e+29, 2.1e+23, 4, 7),
    E("polar_dial", "Polar Dial", 3.55e+30, 8.3e+23, 4, 8), E("blizzard_wheel", "Blizzard Wheel", 1.4e+31, 3.4e+24, 4, 9), E("dark_maelstrom", "Dark Maelstrom", 5.5e+31, 1.4e+25, 4, 10), E("ember_trinity", "Ember Trinity", 2.1e+32, 5.6e+25, 4, 11),
    E("glacier_sharingan", "Glacier Sharingan", 8.4e+32, 1.1e+26, 4, 12), E("kurobyougan", "Kurobyougan", 3.4e+33, 2.2e+26, 4, 13), E("yumegan", "Yumegan", 1.35e+34, 4.5e+26, 4, 14), E("astral_bloom", "Astral Bloom", 1e+35, 1.2e+26, 5, 1),
    E("crimson_vortex", "Crimson Vortex", 4.2e+35, 4.8e+26, 5, 2), E("corona_gear", "Corona Gear", 1.8e+36, 1.9e+27, 5, 3), E("mangekyou_byakugan", "Mangekyou Byakugan", 6.9e+36, 7.7e+27, 5, 4), E("crimson_comet", "Crimson Comet", 2.9e+37, 3.1e+28, 5, 5),
    E("pulsar_tomoe", "Pulsar Tomoe", 1.14e+38, 1.2e+29, 5, 6), E("mangekyou_jigokugan", "Mangekyou Jigokugan", 4.6e+38, 4.9e+29, 5, 7), E("astral_sigil", "Astral Sigil", 1.8e+39, 2e+30, 5, 8), E("red_giant", "Red Giant", 7e+39, 7.9e+30, 5, 9),
    E("void_gaze", "Void Gaze", 2.75e+40, 3.1e+31, 5, 10), E("nova_trinity", "Nova Trinity", 1.05e+41, 1.3e+32, 5, 11), E("dark_star", "Dark Star", 4e+41, 5e+32, 5, 12), E("nebula_rinne", "Nebula Rinne", 1.54e+42, 2e+33, 5, 13),
    E("chikaragan", "Chikaragan", 5.9e+42, 8e+33, 5, 14), E("raging_current", "Raging Current", 7.5e+43, 1.3e+35, 6, 1), E("hell_butterfly", "Hell Butterfly", 3.15e+44, 8.32e+35, 6, 2), E("raiko_gaze", "Raiko Gaze", 1.35e+45, 5.38e+36, 6, 3),
    E("kido_seal", "Kido Seal", 5.17e+45, 3.4e+37, 6, 4), E("shinso_edge", "Shinso Edge", 2.18e+46, 2.16e+38, 6, 5), E("shirayuki", "Shirayuki", 8.55e+46, 1.36e+39, 6, 6), E("quincy_cross", "Quincy Cross", 3.45e+47, 8.89e+39, 6, 7),
    E("sanrei_lattice", "Sanrei Lattice", 1.35e+48, 5.64e+40, 6, 8), E("kyoka_suigetsu", "Kyoka Suigetsu", 5.25e+48, 3.65e+41, 6, 9), E("black_coffin", "Black Coffin", 2.06e+49, 2.34e+42, 6, 10), E("senbonzakura", "Senbonzakura", 7.87e+49, 1.54e+43, 6, 11),
    E("hyorinmaru", "Hyorinmaru", 3e+50, 9.5e+43, 6, 12), E("ryujin_jakka", "Ryujin Jakka", 1.15e+51, 6.19e+44, 6, 13), E("getsuga_tensho", "Getsuga Tensho", 4.42e+51, 3.92e+45, 6, 14), E("gamuza", "Gamuza", 7e+52, 7.88e+45, 7, 1),
    E("resurreccion", "Resurreccion", 2.94e+53, 5.04e+46, 7, 2), E("gran_rey_cero", "Gran Rey Cero", 1.26e+54, 3.23e+47, 7, 3), E("cero_inferno", "Cero Inferno", 4.83e+54, 2.06e+48, 7, 4), E("tatarforas", "Tatarforas", 2.03e+55, 1.31e+49, 7, 5),
    E("los_lobos", "Los Lobos", 7.98e+55, 8.26e+49, 7, 6), E("pantera", "Pantera", 3.22e+56, 5.36e+50, 7, 7), E("compulsory", "The Compulsory", 1.26e+57, 3.44e+51, 7, 8), E("murcielago", "Murcielago", 4.9e+57, 2.22e+52, 7, 9),
    E("inner_hollow", "Inner Hollow", 1.92e+58, 1.42e+53, 7, 10), E("vasto_lorde", "Vasto Lorde", 7.35e+58, 9.15e+53, 7, 11), E("hogyoku", "Hogyoku", 2.8e+59, 5.78e+54, 7, 12), E("hakka_no_togame", "Hakka no Togame", 0, 1, 1, 15),
    E("soul_king", "Soul King", 1.08e+60, 3.74e+55, 7, 13), E("almighty", "The Almighty", 4.13e+60, 2.37e+56, 7, 14), E("briar_maiden", "Briar Maiden", 8.75e+61, 4.77e+56, 8, 1), E("four_leaf", "Four-Leaf Grimoire", 3.67e+62, 3.05e+57, 8, 2),
    E("sea_dragon", "Sea Dragon", 1.57e+63, 1.95e+58, 8, 3), E("leo_rugiens", "Leo Rugiens", 6.04e+63, 1.25e+59, 8, 4), E("blood_curse", "Blood Curse", 2.54e+64, 7.98e+59, 8, 5), E("spirit_storm", "Spirit Storm", 9.98e+64, 5e+60, 8, 6),
    E("sealing_magic", "Sealing Magic", 4.03e+65, 3.24e+61, 8, 7), E("chronostasis", "Chronostasis", 1.57e+66, 2.07e+62, 8, 8), E("dimension_slash", "Dimension Slash", 6.12e+66, 1.34e+63, 8, 9), E("light_magic", "Light Magic", 2.41e+67, 8.58e+63, 8, 10),
    E("devil_eye", "Devil Eye", 9.19e+67, 5.54e+64, 8, 11), E("world_tree", "World Tree", 3.5e+68, 3.5e+65, 8, 12), E("black_asta", "Black Asta", 1.35e+69, 2.26e+66, 8, 13), E("gravity_king", "Gravity King", 5.16e+69, 1.44e+67, 8, 14),
    E("prism_eye", "Prism Eye", 0.0, 120000000000.0, 2, 14), E("six_paths_sage", "Six Paths Sage", 0, 1, 1, 16), E("exploding_blood", "Exploding Blood", 1.09e+71, 2.89e+67, 9, 1), E("lower_moon", "Lower Moon", 4.59e+71, 1.85e+68, 9, 2),
    E("blood_sickle", "Blood Sickle", 1.96e+72, 1.18e+69, 9, 3), E("black_thunder", "Black Thunder", 7.55e+72, 7.56e+69, 9, 4), E("thousand_needles", "Thousand Needles", 3.18e+73, 4.83e+70, 9, 5), E("zohakuten", "Zohakuten", 1.25e+74, 3.03e+71, 9, 6),
    E("dead_calm", "Dead Calm", 5.04e+74, 1.96e+72, 9, 7), E("biwa_castle", "Biwa Castle", 1.96e+75, 1.25e+73, 9, 8), E("destructive_death", "Destructive Death", 7.65e+75, 8.11e+73, 9, 9), E("cryo_lotus", "Cryo Lotus", 3.01e+76, 5.19e+74, 9, 10),
    E("demon_seal", "Demon Seal", 1.15e+77, 3.35e+75, 9, 11), E("moon_breathing", "Moon Breathing", 4.38e+77, 2.12e+76, 9, 12), E("sun_breathing", "Sun Breathing", 1.69e+78, 1.37e+77, 9, 13), E("demon_king", "Demon King", 6.45e+78, 8.71e+77, 9, 14),
}
end

local function getEyesChain() return MASTER_EYES_CHAIN end

local function getPlayerOwnedEyes()
    local raw = localPlayer:GetAttribute("Eyes")
    if not raw or raw == "" then return { sharingan = 1 } end
    local ok, res = pcall(function() return HttpService:JSONDecode(raw) end)
    return (ok and typeof(res) == "table") and res or { sharingan = 1 }
end

local function getNextLockedEye()
    local owned = getPlayerOwnedEyes()
    for _, eye in ipairs(MASTER_EYES_CHAIN) do
        if eye and eye.id and not owned[eye.id] then
            return eye, eye.world or 1, eye.padIndex or 1
        end
    end
    return nil, 1, 1
end

local function getBestOwnedEye()
    local owned = getPlayerOwnedEyes()
    local best = nil
    for _, eye in ipairs(MASTER_EYES_CHAIN) do
        if eye and eye.id and owned[eye.id] then best = eye end
    end
    return best or MASTER_EYES_CHAIN[1]
end

dismissRobuxModals = function()
    -- Không dùng triggerGuiButton hay đóng Frame tự động để tránh tự tắt chức năng/menu của game
end

openGameMenu = function(menuName)
    local opened = false
    pcall(function()
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        local target = tostring(menuName or ""):lower()

        for _, frame in ipairs(pg:GetDescendants()) do
            if frame:IsA("Frame") then
                local fName = frame.Name:lower()
                local hasTitle = false
                for _, child in ipairs(frame:GetChildren()) do
                    if child:IsA("TextLabel") and child.Visible then
                        local ct = child.Text:lower()
                        if ((target == "eyes" or target == "eye") and ct:find("my eyes")) or ((target == "aura" or target == "auras") and ct:find("aura")) then
                            hasTitle = true; break
                        end
                    end
                end
                if hasTitle or ((target == "eyes" or target == "eye") and (fName == "myeyes" or fName == "eyesframe" or fName == "eyes")) then
                    frame.Visible = true; opened = true; return
                end
            end
        end

        for _, btn in ipairs(pg:GetDescendants()) do
            if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                local bName = btn.Name:lower()
                local txt = (btn:IsA("TextButton") and btn.Text:lower() or "")
                local l = btn:FindFirstChildOfClass("TextLabel")
                if l and l.Text then txt = txt .. " " .. l.Text:lower() end
                txt = txt:gsub("^%s*(.-)%s*$", "%1")
                local isForbidden = bName:find("robux") or txt:find("") or txt:find("buy") or bName:find("deal") or txt:find("deal") or bName:find("egg") or txt:find("egg") or bName:find("special") or txt:find("special") or bName:find("pack") or bName:find("pass")
                if not isForbidden then
                    local isMatch = ((target == "eyes" or target == "eye" or target == "my eyes") and (txt == "eyes" or txt == "my eyes" or bName == "eyes" or bName == "myeyes" or bName == "eyesbtn"))
                        or ((target == "aura" or target == "auras") and (txt == "auras" or txt == "aura" or bName == "auras" or bName == "aurabtn"))
                    if isMatch and not bName:find("unlock") and not bName:find("equip") and txt ~= "x" then
                        if triggerGuiButton(btn) then opened = true; return end
                    end
                end
            end
        end
    end)
    return opened
end

local isUnlockingEye = false
unlockNextEyeAction = function(fromAuto)
    if isUnlockingEye then return false end
    local nextEye = getNextLockedEye()
    if not nextEye then
        if not fromAuto then Notification("My Eyes", "Bạn đã mở khóa toàn bộ Mắt trong game!", 3) end
        return false
    end
    local totalWins, requiredWins = localPlayer:GetAttribute("TotalWins") or 0, nextEye.wins or 0
    if totalWins < requiredWins then
        if not fromAuto then
            Notification("My Eyes", string.format("Chưa đủ Cúp mua [%s]! Cần: %s (Hiện có: %s)", nextEye.name, formatNumber(requiredWins), formatNumber(totalWins)), 3)
        end
        return false
    end

    isUnlockingEye = true
    local ok = pcall(function()
        dismissRobuxModals()
        if not fromAuto and openGameMenu then openGameMenu("Eyes") end
        task.wait(0.2)
        pcall(function()
            local pg = localPlayer:FindFirstChild("PlayerGui")
            if not pg then return end
            local targetName = nextEye.name:lower()
            for _, desc in ipairs(pg:GetDescendants()) do
                if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and desc.Visible then
                    local txt = (desc:IsA("TextButton") and desc.Text:upper() or "")
                    local l = desc:FindFirstChildOfClass("TextLabel")
                    if l and l.Text then txt = txt .. " " .. l.Text:upper() end
                    if txt:find("UNLOCK") and not txt:find("BUY") and not txt:find("") and not txt:find("ROBUX") then
                        local p, matchEye = desc.Parent, false
                        while p and not p:IsA("ScreenGui") do
                            for _, c in ipairs(p:GetChildren()) do
                                if c:IsA("TextLabel") and c.Text:lower():find(targetName) then matchEye = true; break end
                            end
                            if matchEye then break end
                            p = p.Parent
                        end
                        if matchEye then triggerGuiButton(desc); break end
                    end
                end
            end
        end)

        if unlockEyeRemote then
            for _, arg in ipairs({ nextEye.id, true, 1 }) do
                unlockEyeRemote:FireServer(nextEye.id, arg ~= nextEye.id and arg or nil)
                task.wait(0.08)
            end
            unlockEyeRemote:FireServer()
        end
        task.wait(0.35)
        if equipRemote then
            equipRemote:FireServer(nextEye.id)
            equipRemote:FireServer("eye", nextEye.id)
            equipRemote:FireServer("Eye", nextEye.id)
        end
        dismissRobuxModals()
        Notification("My Eyes", string.format("ĐÃ MUA VÀ TRANG BỊ: %s (x%s Chakra)!", nextEye.name, formatNumber(nextEye.mult)), 4)
    end)
    isUnlockingEye = false
    return ok
end

equipBestEyeAction = function()
    local best = getBestOwnedEye()
    if not best then return end
    if tostring(localPlayer:GetAttribute("Eye") or ""):lower() == best.id:lower() then return end
    pcall(function()
        if equipRemote then
            equipRemote:FireServer(best.id)
            equipRemote:FireServer("eye", best.id)
            equipRemote:FireServer("Eye", best.id)
        end
    end)
end

local function getPlayerOwnedAuras()
    local raw = localPlayer:GetAttribute("OwnedAuras")
    if not raw or raw == "" then return {} end
    local ok, res = pcall(function() return HttpService:JSONDecode(raw) end)
    if ok and typeof(res) == "table" then
        local list = {}
        for k, v in pairs(res) do
            if v == true or v == 1 or typeof(v) == "table" or typeof(v) == "number" then table.insert(list, tostring(k)) end
        end
        return list
    end
    return {}
end

local function equipAuraByName(auraName)
    if not auraName or auraName == "" or not equipAuraRemote then return end
    pcall(function()
        if equipAuraRemote:IsA("RemoteFunction") then equipAuraRemote:InvokeServer(auraName)
        else equipAuraRemote:FireServer(auraName) end
    end)
end

rollAuraAction = function()
    pcall(function()
        if arcadeStartRemote and arcadeStartRemote:IsA("RemoteFunction") then arcadeStartRemote:InvokeServer() end
        if arcadeFinishRemote and arcadeFinishRemote:IsA("RemoteFunction") then arcadeFinishRemote:InvokeServer() end
    end)
    Notification("Auras", "Đã gửi lệnh quay Aura!", 2)
end

buyBossShopAction = function()
    pcall(function()
        if bossShopRemote and bossShopRemote:IsA("RemoteFunction") then
            bossShopRemote:InvokeServer(); bossShopRemote:InvokeServer("BuyAll"); bossShopRemote:InvokeServer(1)
        end
    end)
    Notification("Boss Shop", "Đã gửi lệnh mua đồ Boss Shop!", 2)
end

claimAllFreeRewards = function()
    pcall(function() if claimDailyRemote and claimDailyRemote:IsA("RemoteFunction") then claimDailyRemote:InvokeServer() end end)
    pcall(function() if claimGroupRemote and claimGroupRemote:IsA("RemoteFunction") then claimGroupRemote:InvokeServer() end end)
    pcall(function() if claimRewardRemote and claimRewardRemote:IsA("RemoteFunction") then for i = 1, 12 do claimRewardRemote:InvokeServer(i) end end end)
    pcall(function() if claimQuestRemote and claimQuestRemote:IsA("RemoteFunction") then for i = 1, 10 do claimQuestRemote:InvokeServer(i) end end end)
    pcall(function()
        if exitBonusRemote and exitBonusRemote:IsA("RemoteFunction") then exitBonusRemote:InvokeServer() end
        if welcomeBackRemote and welcomeBackRemote:IsA("RemoteFunction") then welcomeBackRemote:InvokeServer() end
    end)
    Notification("Nhận Quà", "Đã tự động nhận tất cả phần thưởng miễn phí!", 3)
end

redeemAllKnownCodes = function()
    local codeList = { "RELEASE", "ANIME", "EYES", "CHAKRA", "UPDATE1", "UPDATE2", "KYUBI", "BOSS", "LIKE", "WINS", "FREE", "SHARINGAN", "NARUTO" }
    if not redeemCodeRemote then Notification("Giftcode", "Không tìm thấy Remote RedeemCode!", 2); return end
    task.spawn(function()
        for _, code in ipairs(codeList) do
            pcall(function()
                if redeemCodeRemote:IsA("RemoteFunction") then redeemCodeRemote:InvokeServer(code)
                else redeemCodeRemote:FireServer(code) end
            end)
            task.wait(0.2)
        end
        Notification("Giftcode", "Đã tự động nhập toàn bộ mã Giftcode!", 3)
    end)
end

task.spawn(function()
    while isSessionActive() do
        pcall(function()
            if LabelCurrentEye then
                local equippedId = tostring(localPlayer:GetAttribute("Eye") or "sharingan")
                local curEyeName, curMult = equippedId, 1
                for _, e in ipairs(MASTER_EYES_CHAIN) do
                    if e and e.id and e.id:lower() == equippedId:lower() then
                        curEyeName, curMult = e.name or e.id, e.mult or 1; break
                    end
                end
                updateLabel(LabelCurrentEye, string.format("Mắt Đang Dùng: %s (x%s Chakra)", curEyeName, tostring(curMult)))
            end
            if LabelNextEye and LabelEyeProgress then
                local nextEye = getNextLockedEye()
                if nextEye then
                    local totalWins, cost = localPlayer:GetAttribute("TotalWins") or 0, nextEye.wins or 0
                    local pct = cost > 0 and math.clamp(math.floor((totalWins / cost) * 100), 0, 100) or 100
                    updateLabel(LabelNextEye, string.format("Mắt Kế Tiếp: %s (x%s Chakra) [Bệ %d World %d]", nextEye.name, formatNumber(nextEye.mult), nextEye.padIndex or 1, nextEye.world or 1))
                    updateLabel(LabelEyeProgress, string.format("Cúp: %s / %s (%d%%) - Bắt buộc mua tuần tự", formatNumber(totalWins), formatNumber(cost), pct))
                else
                    updateLabel(LabelNextEye, "Mắt Kế Tiếp: Đã mở khóa hết tất cả Mắt!")
                    updateLabel(LabelEyeProgress, "Tiến độ: 100% Hoàn thành!")
                end
            end
            if LabelCurrentAura then
                local equippedAura = tostring(localPlayer:GetAttribute("Aura") or "Chưa trang bị")
                updateLabel(LabelCurrentAura, "Aura Đang Dùng: " .. (equippedAura ~= "" and equippedAura or "Chưa trang bị"))
            end
            if LabelOwnedAurasCount then
                updateLabel(LabelOwnedAurasCount, string.format("Đã sở hữu: %d Auras", #getPlayerOwnedAuras()))
            end
        end)
        task.wait(1.0)
    end
end)

task.spawn(function()
    while isSessionActive() do
        if _G.AnimeEyes_AutoUnlockEyes then pcall(unlockNextEyeAction, true) end
        if _G.AnimeEyes_AutoEquipBestEye then pcall(equipBestEyeAction) end
        if _G.AnimeEyes_AutoEquipBestAura then
            pcall(function()
                local auras = getPlayerOwnedAuras()
                if #auras > 0 then equipAuraByName(auras[#auras]) end
            end)
        end
        if _G.AnimeEyes_AutoRollAuras then pcall(rollAuraAction) end
        if _G.AnimeEyes_AutoBossShop then pcall(buyBossShopAction) end
        if _G.AnimeEyes_AutoClaims then pcall(claimAllFreeRewards) end
        task.wait(2.5)
    end
end)

end

-- ========================================================================
-- 14. TIỆN ÍCH TỐI ƯU TREO MÁY (ANTI-AFK & FPS BOOST & WALKSPEED)
-- ========================================================================
pcall(function()
    localPlayer.Idled:Connect(function()
        if _G.AntiAFK then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(0.2)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    end)
end)

toggleWhiteScreen = function(enable)
    local containers = {}
    if gethui then pcall(function() table.insert(containers, gethui()) end) end
    pcall(function() table.insert(containers, game:GetService("CoreGui")) end)
    local targetParent = containers[1] or game:GetService("CoreGui")

    local existing = targetParent:FindFirstChild("SuiSuiWhiteScreen")
    if enable then
        if not existing then
            local sg = Instance.new("ScreenGui")
            sg.Name = "SuiSuiWhiteScreen"
            sg.DisplayOrder = 999
            sg.IgnoreGuiInset = true
            local f = Instance.new("Frame", sg)
            f.Size = UDim2.fromScale(1, 1)
            f.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
            f.BorderSizePixel = 0
            local txt = Instance.new("TextLabel", f)
            txt.Size = UDim2.fromScale(1, 1)
            txt.BackgroundTransparency = 1
            txt.Text = "[SuiSuiHUB] Màn Hình Trắng Đang Bật\nBấm Tắt trong Hub để xem lại game!"
            txt.TextColor3 = Color3.fromRGB(40, 40, 40)
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 22
            sg.Parent = targetParent
        end
    else
        if existing then existing:Destroy() end
    end
end

applyFPSBoost = function()
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.Brightness = 1

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("BasePart") and not obj:IsA("Terrain") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            end
        end
    end)
end

-- Vòng lặp duy trì WalkSpeed
task.spawn(function()
    while isSessionActive() do
        if _G.WalkSpeedEnabled and localPlayer.Character then
            pcall(function()
                local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= _G.WalkSpeedValue then
                    hum.WalkSpeed = _G.WalkSpeedValue
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ========================================================================
-- 15. HỆ THỐNG TỰ ĐỘNG LƯU & NẠP CẤU HÌNH (AUTO-SAVE / AUTO-LOAD DUAL-LAYER)
-- ========================================================================
do
local CONFIG_KEYS = {
    "AnimeEyes_AutoStage", "AnimeEyes_TargetStage", "AnimeEyes_SelectedWorld",
    "AnimeEyes_StageTimeout", "AnimeEyes_StageCPS", "AnimeEyes_StageDelay",
    "AnimeEyes_CenterStage", "AnimeEyes_AutoBoss", "AnimeEyes_BossHoverHeight",
    "AnimeEyes_AutoDodge", "AnimeEyes_DodgeSpeed", "AnimeEyes_DodgeRadius",
    "AnimeEyes_AutoClick", "AnimeEyes_TargetCPS", "AnimeEyes_BypassCooldown",
    "AnimeEyes_AutoSkills", "AnimeEyes_KeepFreeOn", "AnimeEyes_AutoRebirth",
    "AnimeEyes_RebirthDelay", "AnimeEyes_AutoHatch", "AnimeEyes_SelectedEgg",
    "SuiSui_HatchAmount", "AnimeEyes_AutoEquipBestPet", "AnimeEyes_AutoUnlockEyes",
    "AnimeEyes_AutoEquipBestEye", "AnimeEyes_AutoRollAuras", "AnimeEyes_AutoEquipBestAura",
    "AnimeEyes_AutoClaims", "WalkSpeedEnabled", "WalkSpeedValue",
    "AntiAFK", "WhiteScreen", "DisableConsoleLogs"
}

local isSavingConfig = false
autoSaveSettings = function(manual)
    if isSavingConfig then return end
    isSavingConfig = true
    pcall(function()
        if not writefile then
            if manual then Notification("Cấu Hình", "Executor không hỗ trợ writefile!", 3) end
            return
        end
        local stateTable = {}
        for _, k in ipairs(CONFIG_KEYS) do
            if k == "AnimeEyes_AutoStage" then
                stateTable[k] = (_G.SuiSui_AutoStage == true)
            elseif k == "AnimeEyes_AutoBoss" then
                stateTable[k] = (_G.SuiSui_AutoBoss == true)
            else
                stateTable[k] = _G[k]
            end
        end
        local jsonStr = HttpService:JSONEncode(stateTable)
        pcall(function()
            if isfolder and makefolder then
                if not isfolder("!SuiSuiHUB") then makefolder("!SuiSuiHUB") end
                if not isfolder("!SuiSuiHUB/Anime Eyes") then makefolder("!SuiSuiHUB/Anime Eyes") end
            end
            writefile("!SuiSuiHUB/Anime Eyes/settings.json", jsonStr)
        end)
        pcall(function() writefile("AnimeEyes_settings.json", jsonStr) end)
        if manual then Notification("Cấu Hình", "Đã lưu cài đặt tự động vào máy!", 3) end
    end)
    isSavingConfig = false
end

autoLoadSettings = function(manual)
    pcall(function()
        local loaded = loadSettingsFromDisk()
        if loaded and uiRegistry then
            for _, group in pairs({ uiRegistry.toggles, uiRegistry.sliders }) do
                if group then
                    for flag, elem in pairs(group) do
                        local val = _G[flag]
                        if flag == "AnimeEyes_AutoStage" then val = _G.SuiSui_AutoStage
                        elseif flag == "AnimeEyes_AutoBoss" then val = _G.SuiSui_AutoBoss end
                        if val ~= nil and elem and elem.Set then
                            pcall(function() elem:Set(val) end)
                        end
                    end
                end
            end
        end
        if manual then Notification("Cấu Hình", "Đã nạp lại toàn bộ cài đặt từ file lưu!", 3) end
    end)
end

local function computeConfigHash()
    local parts = {}
    for _, k in ipairs(CONFIG_KEYS) do
        if k == "AnimeEyes_AutoStage" then
            table.insert(parts, tostring(_G.SuiSui_AutoStage))
        elseif k == "AnimeEyes_AutoBoss" then
            table.insert(parts, tostring(_G.SuiSui_AutoBoss))
        else
            table.insert(parts, tostring(_G[k]))
        end
    end
    return table.concat(parts, "_")
end

task.spawn(function()
    local lastSavedStateHash = computeConfigHash()
    while isSessionActive() do
        task.wait(3.0)
        pcall(function()
            local curHash = computeConfigHash()
            if curHash ~= lastSavedStateHash then
                lastSavedStateHash = curHash
                autoSaveSettings(false)
            end
        end)
    end
end)

pcall(function()
    game:BindToClose(function() autoSaveSettings(false) end)
end)

Notification("SuiSuiHUB", "Anime Eyes v19.5: Đã bật Tự Động Lưu Cấu Hình & Tối Ưu Hóa!", 4)
end
