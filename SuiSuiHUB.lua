--[[
    ========================================================================
    SuiSuiHUB | 1 SCRIPT CHO ALL GAME (Universal Loader + All-Game Hub)
    Tác giả: dj & VANTA
    Phiên bản: 4.0 (Auto-Detect Game + Universal All-Game Suite + Game Dumper)
    ========================================================================
    1 Lệnh Duy Nhất Chạy Cho Mọi Game:
      - Localhost Test:
        loadstring(game:HttpGet("http://127.0.0.1:8000/SuiSuiHUB.lua?t=" .. tick()))()
      - GitHub Production:
        loadstring(game:HttpGet("https://raw.githubusercontent.com/suisuimommy-code/SuiSuiHUB/main/SuiSuiHUB.lua?t=" .. tick()))()
    ========================================================================
]]

repeat task.wait(0.2) until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")

local localPlayer = Players.LocalPlayer
repeat task.wait(0.2) until localPlayer

local placeId = game.PlaceId
local gameId = game.GameId

local LOCAL_HOST = "http://127.0.0.1:8000"
local GITHUB_HOST = "https://raw.githubusercontent.com/suisuimommy-code/SuiSuiHUB/main"

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or "SuiSuiHUB"),
            Text = tostring(text or ""),
            Duration = tonumber(duration or 4)
        })
    end)
    print(string.format("[SuiSuiHUB] %s: %s", tostring(title or ""), tostring(text or "")))
end

-- ========================================================================
-- 1. CƠ SỞ DỮ LIỆU GAME CHUYÊN BIỆT (AUTO-DETECTION ENGINE)
-- ========================================================================
local GameDatabase = {
    ["Anime Eyes"] = {
        PlaceIds = { 97617452700163 },
        UniverseIds = {},
        Paths = { "Anime Eyes/AnimeEyes.lua" },
        SignatureCheck = function()
            local rem = ReplicatedStorage:FindFirstChild("Remotes")
            if rem and (rem:FindFirstChild("UnlockEye") or rem:FindFirstChild("BossDrop")) then
                return true
            end
            return false
        end
    },
    ["Anime Dimensions"] = {
        PlaceIds = { 6938803436, 6990129309, 6990133340, 6990131029, 7338881230, 7274690025 },
        UniverseIds = {},
        Paths = { "anime dimesion/ADS.lua", "Anime dimesion/ADS.lua" },
        SignatureCheck = function()
            return false
        end
    },
    ["Card Origins"] = {
        PlaceIds = { 78312396550517 },
        UniverseIds = {},
        Paths = { "Card Origins/CardOrigins.lua" },
        SignatureCheck = function()
            return false
        end
    }
}

local function fetchRemoteFile(relativePath)
    local cacheBuster = "?t=" .. tostring(os.time())
    local cleanPath = relativePath:gsub(" ", "%%20")
    local content = nil

    -- 1. Ưu tiên Localhost (Port 8000)
    pcall(function()
        local res = game:HttpGet(string.format("%s/%s%s", LOCAL_HOST, cleanPath, cacheBuster))
        if res and #res > 100 then content = res end
    end)

    -- 2. Đọc file nội bộ nếu có trong workspace executor
    if not content and isfile and readfile then
        pcall(function()
            if isfile(relativePath) then
                local res = readfile(relativePath)
                if res and #res > 100 then content = res end
            end
        end)
    end

    -- 3. Fallback về GitHub Production
    if not content then
        pcall(function()
            local res = game:HttpGet(string.format("%s/%s%s", GITHUB_HOST, cleanPath, cacheBuster))
            if res and #res > 100 then content = res end
        end)
    end

    return content
end

local function loadGameScript(gameName, config)
    Notify("SuiSuiHUB", string.format("Phát hiện game: %s\nĐang nạp Script chuyên biệt...", gameName), 3)
    for _, path in ipairs(config.Paths or {}) do
        local code = fetchRemoteFile(path)
        if code then
            local fn, err = loadstring(code)
            if fn then
                Notify("SuiSuiHUB", string.format("Đã kích hoạt [%s] thành công!", gameName), 4)
                task.spawn(fn)
                return true
            else
                warn("[SuiSuiHUB] Lỗi biên dịch " .. path .. ": " .. tostring(err))
            end
        end
    end
    Notify("SuiSuiHUB", "Không tải được bản chuyên biệt, đang mở bản Universal All-Game...", 4)
    return false
end

-- Quét nhận diện game hiện tại
local matchedName, matchedConfig = nil, nil
for name, cfg in pairs(GameDatabase) do
    for _, pid in ipairs(cfg.PlaceIds or {}) do
        if pid == placeId then matchedName, matchedConfig = name, cfg; break end
    end
    if not matchedName then
        for _, uid in ipairs(cfg.UniverseIds or {}) do
            if uid == gameId then matchedName, matchedConfig = name, cfg; break end
        end
    end
    if not matchedName and cfg.SignatureCheck then
        local ok, sig = pcall(cfg.SignatureCheck)
        if ok and sig then matchedName, matchedConfig = name, cfg; break end
    end
    if matchedName then break end
end

if matchedName and matchedConfig then
    if loadGameScript(matchedName, matchedConfig) then
        return
    end
end

-- ========================================================================
-- 2. CHẾ ĐỘ UNIVERSAL ALL-GAME HUB (CHẠY ĐƯỢC TRÊN MỌI GAME ROBLOX)
-- ========================================================================
local libCode = fetchRemoteFile("inventory.lua")
if not libCode then
    Notify("SuiSuiHUB", "Không thể tải thư viện giao diện inventory.lua!", 5)
    return
end

local library = loadstring(libCode)()
if not library then return end

local gameTitle = "Unknown Game"
pcall(function()
    local info = MarketplaceService:GetProductInfo(placeId)
    if info and info.Name then gameTitle = info.Name end
end)

local univSession = os.clock() + math.random()
_G.SuiSui_UniversalSession = univSession
local function isUnivActive()
    return _G.SuiSui_UniversalSession == univSession
end

_G.Univ_AutoClick = false
_G.Univ_ClickCPS = 20
_G.Univ_AutoCollect = false
_G.Univ_CollectRadius = 50
_G.Univ_AutoPrompt = false
_G.Univ_AutoFireRemotes = false
_G.Univ_WalkSpeedOn = false
_G.Univ_WalkSpeed = 60
_G.Univ_JumpPowerOn = false
_G.Univ_JumpPower = 100
_G.Univ_InfJump = false
_G.Univ_Noclip = false
_G.Univ_AntiAFK = true

local Window = library:CreateWindow(string.format("SuiSuiHUB | All-Game Universal (%s)", gameTitle:sub(1, 24)))
Notify("SuiSuiHUB All-Game", string.format("Đã mở chế độ Universal cho:\n%s (PlaceId: %d)", gameTitle, placeId), 4)

-- TAB 1: FARM & TIỆN ÍCH ĐA NĂNG MỌI GAME
local TabUniversal = Window:CreateTab("All-Game Farm")
local SecCombat = TabUniversal:CreateSector("1. Auto Click & Thu Thập Đa Năng", "left")
local SecMove = TabUniversal:CreateSector("2. Di Chuyển & Nhân Vật (Mọi Game)", "right")

SecCombat:AddLabel("Game: " .. gameTitle)
SecCombat:AddLabel("PlaceId: " .. tostring(placeId) .. " | GameId: " .. tostring(gameId))

SecCombat:AddToggle("Bật Auto Click Đa Năng (VirtualUser + Tool)", _G.Univ_AutoClick, function(v)
    _G.Univ_AutoClick = v
    Notify("Auto Click", v and "ĐÃ BẬT Auto Click Đa Năng!" or "Đã TẮT Auto Click!", 2)
end)

SecCombat:AddSlider("Tốc Độ Click (CPS)", 1, _G.Univ_ClickCPS, 50, 1, function(v)
    _G.Univ_ClickCPS = tonumber(v) or 20
end)

SecCombat:AddToggle("Tự Động Hút Vật Phẩm / Quà (TouchInterest)", _G.Univ_AutoCollect, function(v)
    _G.Univ_AutoCollect = v
    Notify("Auto Collect", v and "ĐÃ BẬT Tự động chạm nhận vật phẩm quanh người!" or "Đã TẮT!", 2)
end)

SecCombat:AddSlider("Bán Kính Quét Vật Phẩm (Studs)", 15, _G.Univ_CollectRadius, 250, 5, function(v)
    _G.Univ_CollectRadius = tonumber(v) or 50
end)

SecCombat:AddToggle("Tự Động Bấm Nút Tương Tác (ProximityPrompt)", _G.Univ_AutoPrompt, function(v)
    _G.Univ_AutoPrompt = v
    Notify("Auto Interact", v and "ĐÃ BẬT Tự động kích hoạt ProximityPrompt & ClickDetector!" or "Đã TẮT!", 2)
end)

SecMove:AddToggle("Bật Tăng Tốc Độ Chạy (WalkSpeed)", _G.Univ_WalkSpeedOn, function(v)
    _G.Univ_WalkSpeedOn = v
    if not v and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

SecMove:AddSlider("Tốc Độ Chạy (WalkSpeed)", 16, _G.Univ_WalkSpeed, 200, 2, function(v)
    _G.Univ_WalkSpeed = tonumber(v) or 60
end)

SecMove:AddToggle("Bật Tăng Lực Nhảy (JumpPower)", _G.Univ_JumpPowerOn, function(v)
    _G.Univ_JumpPowerOn = v
    if not v and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = 50 end
    end
end)

SecMove:AddSlider("Độ Cao Nhảy (JumpPower)", 50, _G.Univ_JumpPower, 300, 5, function(v)
    _G.Univ_JumpPower = tonumber(v) or 100
end)

SecMove:AddToggle("Nhảy Trên Không Vô Hạn (Infinite Jump)", _G.Univ_InfJump, function(v)
    _G.Univ_InfJump = v
end)

SecMove:AddToggle("Đi Xuyên Tường (Noclip)", _G.Univ_Noclip, function(v)
    _G.Univ_Noclip = v
end)

-- TAB 2: QUÉT DỮ LIỆU GAME MỚI & NẠP SCRIPT THỦ CÔNG
local TabInspector = Window:CreateTab("Dump & Chọn Game")
local SecDumper = TabInspector:CreateSector("1. Quét Toàn Bộ Cấu Trúc Game Mới", "left")
local SecForceLoad = TabInspector:CreateSector("2. Ép Chạy Script Cụ Thể", "right")

SecDumper:AddLabel("Dùng để lấy toàn bộ Remotes, Map, GUI của game bất kỳ")

SecDumper:AddButton("Sao Chép PlaceId & Tên Game Vào Clipboard", function()
    if setclipboard then
        pcall(setclipboard, string.format("Game: %s | PlaceId: %d | GameId: %d", gameTitle, placeId, gameId))
        Notify("Clipboard", "Đã chép PlaceId: " .. tostring(placeId), 3)
    end
end)

SecDumper:AddButton(">>> DUMP TOÀN BỘ GAME NÀY RA FILE <<<", function()
    Notify("Game Dumper", "Đang quét ReplicatedStorage, Workspace, PlayerGui...", 3)
    task.spawn(function()
        local out = {}
        local function addLine(fmt, ...)
            table.insert(out, string.format(fmt, ...))
        end

        addLine("==================================================================")
        addLine("SUISUIHUB UNIVERSAL GAME DUMP")
        addLine("Game Name : %s", tostring(gameTitle))
        addLine("PlaceId   : %s | GameId: %s", tostring(placeId), tostring(gameId))
        addLine("Timestamp : %s", os.date("%Y-%m-%d %H:%M:%S"))
        addLine("==================================================================")

        addLine("\n[1] REPLICATED STORAGE (REMOTES & MODULES):")
        pcall(function()
            for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
                if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("BindableEvent") or d:IsA("ModuleScript") then
                    addLine("  * [%s] %s", d.ClassName, d:GetFullName())
                end
            end
        end)

        addLine("\n[2] WORKSPACE TOP-LEVEL & INTERACTABLES:")
        pcall(function()
            for _, c in ipairs(workspace:GetChildren()) do
                addLine("  * [%s] %s (%d children)", c.ClassName, c.Name, #c:GetChildren())
            end
            for _, d in ipairs(workspace:GetDescendants()) do
                if d:IsA("ProximityPrompt") or d:IsA("ClickDetector") or (d:IsA("TextLabel") and d.Text and #d.Text > 0) then
                    local extra = d:IsA("TextLabel") and ("Text='" .. d.Text:gsub("\n", " ") .. "'") or ("Action='" .. tostring(d:IsA("ProximityPrompt") and d.ActionText or "") .. "'")
                    addLine("  + [%s] %s | %s", d.ClassName, d:GetFullName(), extra)
                end
            end
        end)

        addLine("\n[3] PLAYER GUI (BUTTONS & TEXT LABELS):")
        pcall(function()
            local pg = localPlayer:FindFirstChild("PlayerGui")
            if pg then
                for _, d in ipairs(pg:GetDescendants()) do
                    if d:IsA("TextButton") or d:IsA("ImageButton") or (d:IsA("TextLabel") and d.Text and #d.Text > 0) then
                        local txt = (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text:gsub("\n", " ") or ""
                        addLine("  * [%s] %s | Vis=%s | Text='%s'", d.ClassName, d:GetFullName(), tostring(d:IsA("GuiObject") and d.Visible), txt)
                    end
                end
            end
        end)

        local fullDump = table.concat(out, "\n")
        local fileName = string.format("dump_%d.txt", placeId)
        if writefile then
            pcall(function()
                if isfolder and makefolder and not isfolder("!SuiSuiHUB") then
                    makefolder("!SuiSuiHUB")
                end
                writefile("!SuiSuiHUB/" .. fileName, fullDump)
                writefile("dump_demo.txt", fullDump)
            end)
        end
        if setclipboard then
            pcall(setclipboard, fullDump)
        end
        Notify("Game Dumper", string.format("Đã lưu %d dòng vào !SuiSuiHUB/%s & Clipboard!", #out, fileName), 5)
    end)
end)

for gName, gCfg in pairs(GameDatabase) do
    SecForceLoad:AddButton("Mở Script: " .. gName, function()
        loadGameScript(gName, gCfg)
    end)
end

-- TAB 3: TREO MÁY & TỐI ƯU FPS
local TabSettings = Window:CreateTab("Treo Máy")
local SecPerf = TabSettings:CreateSector("Tối Ưu Treo Máy 24/7", "left")

SecPerf:AddToggle("Anti-AFK (Chống Văng Game 20 Phút)", _G.Univ_AntiAFK, function(v)
    _G.Univ_AntiAFK = v
end)

SecPerf:AddButton("Kích Hoạt FPS Boost (Giảm Lag)", function()
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("BasePart") and not obj:IsA("Terrain") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            end
        end
    end)
    Notify("FPS Boost", "Đã tối ưu đồ họa tăng FPS!", 3)
end)

-- VÒNG LẶP ĐA NĂNG (UNIVERSAL ENGINE LOOPS)
pcall(function()
    localPlayer.Idled:Connect(function()
        if isUnivActive() and _G.Univ_AntiAFK then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(0.2)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    end)
end)

UserInputService.JumpRequest:Connect(function()
    if isUnivActive() and _G.Univ_InfJump and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Stepped:Connect(function()
    if not isUnivActive() then return end
    local char = localPlayer.Character
    if not char then return end
    if _G.Univ_Noclip then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end
end)

task.spawn(function()
    while isUnivActive() do
        if _G.Univ_AutoClick then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
                local char = localPlayer.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end)
            task.wait(math.clamp(1 / (_G.Univ_ClickCPS or 20), 0.02, 0.5))
        else
            task.wait(0.3)
        end
    end
end)

task.spawn(function()
    while isUnivActive() do
        pcall(function()
            local char = localPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                if _G.Univ_WalkSpeedOn then hum.WalkSpeed = _G.Univ_WalkSpeed end
                if _G.Univ_JumpPowerOn then
                    hum.UseJumpPower = true
                    hum.JumpPower = _G.Univ_JumpPower
                end
            end
            if root and (_G.Univ_AutoCollect or _G.Univ_AutoPrompt) then
                local rad = tonumber(_G.Univ_CollectRadius) or 50
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if _G.Univ_AutoCollect and firetouchinterest and obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
                        local part = obj.Parent
                        if not (char and part:IsDescendantOf(char)) and (part.Position - root.Position).Magnitude <= rad then
                            pcall(firetouchinterest, root, part, 0)
                            pcall(firetouchinterest, root, part, 1)
                        end
                    elseif _G.Univ_AutoPrompt and fireproximityprompt and obj:IsA("ProximityPrompt") and obj.Enabled then
                        local pPart = obj.Parent and (obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart"))
                        if pPart and (pPart.Position - root.Position).Magnitude <= rad then
                            pcall(fireproximityprompt, obj)
                        end
                    elseif _G.Univ_AutoPrompt and fireclickdetector and obj:IsA("ClickDetector") then
                        local cPart = obj.Parent and (obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart"))
                        if cPart and (cPart.Position - root.Position).Magnitude <= rad then
                            pcall(fireclickdetector, obj)
                        end
                    end
                end
            end
        end)
        task.wait(0.4)
    end
end)
