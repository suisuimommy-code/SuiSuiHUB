--[[
    ========================================================================
    SuiSuiHUB | Universal Script Loader (1 Script Cho All Game)
    Tác giả: dj & VANTA
    Phiên bản: 4.1 (Pure Auto-Detector: Anime Eyes, Anime Dimensions, Card Origins)
    ========================================================================
    Mô tả:
      - 1 Script duy nhất tự động nhận diện game đang chơi và mở đúng bản
        SuiSuiHUB Master chính thức (như SuiSuiHUB | Anime Eyes Master).
      - Hỗ trợ đầy đủ cả PC (127.0.0.1:8000), Giả lập MuMu/Android (192.168.2.203:8000 / 10.0.2.2:8000)
        và GitHub Production.
    ========================================================================
]]

repeat task.wait(0.2) until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
repeat task.wait(0.2) until localPlayer

local placeId = game.PlaceId
local gameId = game.GameId

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or "SuiSuiHUB"),
            Text = tostring(text or ""),
            Duration = tonumber(duration or 4)
        })
    end)
    print(string.format("[SuiSuiHUB Loader] %s: %s", tostring(title or ""), tostring(text or "")))
end

-- ========================================================================
-- 1. DANH SÁCH GAME CHÍNH THỨC CỦA SUISUIHUB
-- ========================================================================
local GameDatabase = {
    -- 1. Anime Eyes (SuiSuiHUB | Anime Eyes Master)
    ["Anime Eyes"] = {
        PlaceIds = {
            97617452700163
        },
        UniverseIds = {},
        Paths = {
            "Anime Eyes/AnimeEyes.lua"
        },
        SignatureCheck = function()
            local rem = ReplicatedStorage:FindFirstChild("Remotes")
            if rem and (rem:FindFirstChild("UnlockEye") or rem:FindFirstChild("BossDrop") or rem:FindFirstChild("Pad")) then
                return true
            end
            return false
        end
    },

    -- 2. Anime Dimensions Simulator (ADS)
    ["Anime Dimensions"] = {
        PlaceIds = {
            6938803436,
            6990129309,
            6990133340,
            6990131029,
            7338881230,
            7274690025
        },
        UniverseIds = {},
        Paths = {
            "anime dimesion/ADS.lua",
            "Anime dimesion/ADS.lua"
        }
    },

    -- 3. Card Origins
    ["Card Origins"] = {
        PlaceIds = {
            78312396550517
        },
        UniverseIds = {},
        Paths = {
            "Card Origins/CardOrigins.lua"
        }
    }
}

-- ========================================================================
-- 2. NHẬN DIỆN GAME ĐANG CHƠI
-- ========================================================================
local detectedGameName = nil
local detectedGameConfig = nil

for name, config in pairs(GameDatabase) do
    if config.PlaceIds then
        for _, id in ipairs(config.PlaceIds) do
            if id == placeId then
                detectedGameName = name
                detectedGameConfig = config
                break
            end
        end
    end
    if not detectedGameName and config.UniverseIds then
        for _, id in ipairs(config.UniverseIds) do
            if id == gameId then
                detectedGameName = name
                detectedGameConfig = config
                break
            end
        end
    end
    if not detectedGameName and config.SignatureCheck then
        local ok, matched = pcall(config.SignatureCheck)
        if ok and matched then
            detectedGameName = name
            detectedGameConfig = config
            break
        end
    end
    if detectedGameName then break end
end

if not detectedGameConfig then
    Notify("SuiSuiHUB", string.format("Game này chưa có trong danh sách!\nPlaceId: %s", tostring(placeId)), 6)
    pcall(function()
        if setclipboard then
            setclipboard(tostring(placeId))
        end
    end)
    return
end

-- ========================================================================
-- 3. NẠP VÀ CHẠY ĐÚNG BẢN SUISUIHUB MASTER CỦA GAME ĐÓ
-- ========================================================================
local LOCAL_HOSTS = {
    "http://127.0.0.1:8000",
    "http://192.168.2.203:8000",
    "http://10.0.2.2:8000",
    "http://172.18.144.1:8000"
}
local GITHUB_HOST = "https://raw.githubusercontent.com/suisuimommy-code/SuiSuiHUB/main"
local cacheBuster = "?t=" .. tostring(os.time())

local scriptContent = nil
local scriptSource = nil

for _, rawPath in ipairs(detectedGameConfig.Paths or {}) do
    local cleanPath = rawPath:gsub(" ", "%%20")

    -- 1. Ưu tiên nạp từ Local Server (PC hoặc Giả lập MuMu/Android qua LAN)
    for _, host in ipairs(LOCAL_HOSTS) do
        if not scriptContent then
            pcall(function()
                local url = string.format("%s/%s%s", host, cleanPath, cacheBuster)
                local res = game:HttpGet(url)
                if res and #res > 100 and not res:find("404: Not Found") and not res:find("Error response") then
                    scriptContent = res
                    scriptSource = host
                end
            end)
        end
    end

    -- 2. Nếu có sẵn file trong thư mục workspace của executor
    if not scriptContent and isfile and readfile then
        pcall(function()
            if isfile(rawPath) then
                local res = readfile(rawPath)
                if res and #res > 100 then
                    scriptContent = res
                    scriptSource = "Local File"
                end
            end
        end)
    end

    -- 3. Fallback nạp từ GitHub Production
    if not scriptContent then
        pcall(function()
            local githubUrl = string.format("%s/%s%s", GITHUB_HOST, cleanPath, cacheBuster)
            local res = game:HttpGet(githubUrl)
            if res and #res > 100 and not res:find("404: Not Found") then
                scriptContent = res
                scriptSource = "GitHub Production"
            end
        end)
    end

    if scriptContent then break end
end

if scriptContent and #scriptContent > 100 then
    local loadedFunc, parseError = loadstring(scriptContent)
    if loadedFunc then
        Notify("SuiSuiHUB", string.format("Đang mở [%s] (%s)...", detectedGameName, tostring(scriptSource)), 3)
        task.spawn(loadedFunc)
    else
        Notify("Lỗi Biên Dịch", tostring(parseError), 6)
        warn("[SuiSuiHUB Loader] Parse error:", parseError)
    end
else
    Notify("Lỗi Tải Script", string.format("Không tải được [%s]!\nHãy bật Server Local hoặc Push file lên GitHub.", detectedGameName), 6)
end
