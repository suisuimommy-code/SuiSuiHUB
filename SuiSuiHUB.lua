--[[
    ========================================================================
    SuiSuiHUB | Universal Script Loader & Game Auto-Detector
    Tác giả: dj & VANTA
    Phiên bản: 3.0 (Universal Hub Architecture)
    ========================================================================
    Mô tả:
      - 1 Script duy nhất cho toàn bộ hệ thống SuiSuiHUB.
      - Tự động nhận diện Place ID / Universe ID khi người chơi vào bất kỳ game nào.
      - Tự động tải và kích hoạt đúng Script tương ứng của game đó.
      - Hỗ trợ nạp Localhost (port 8000) khi đang test dev, tự fallback về GitHub Production.
    ========================================================================
]]

repeat task.wait(0.2) until game:IsLoaded()

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
repeat task.wait(0.2) until localPlayer

local StarterGui = game:GetService("StarterGui")
local placeId = game.PlaceId
local gameId = game.GameId

-- Hàm gửi thông báo hệ thống
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or "SuiSuiHUB"),
            Text = tostring(text or ""),
            Duration = tonumber(duration or 5)
        })
    end)
    print(string.format("[SuiSuiHUB Loader] %s: %s", tostring(title or ""), tostring(text or "")))
end

-- ========================================================================
-- 1. BẢNG DỮ LIỆU CÁC GAME ĐƯỢC HỖ TRỢ (GAME DATABASE)
-- ========================================================================
local GameDatabase = {
    -- 1. Card Origins
    ["Card Origins"] = {
        PlaceIds = {
            78312396550517
        },
        UniverseIds = {},
        ScriptPath = "Card Origins/CardOrigins.lua",
        Description = "Auto Săn Boss, Tùy Chỉnh Độ Khó, Auto RiftGate 15p"
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
        ScriptPath = "anime dimesion/ADS.lua",
        Description = "Auto Farm Map, Auto Raid, Quản Lý Thẻ & Kỹ Năng"
    }
}

-- ========================================================================
-- 2. NHẬN DIỆN GAME HIỆN TẠI (GAME DETECTION ENGINE)
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
    if detectedGameName then break end
end

-- ========================================================================
-- 3. XỬ LÝ KHI GAME CHƯA ĐƯỢC HỖ TRỢ
-- ========================================================================
if not detectedGameConfig then
    Notify("SuiSuiHUB", string.format("Chưa hỗ trợ game này!\nPlace ID: %s", tostring(placeId)), 7)
    
    -- Tự động sao chép Place ID vào Clipboard cho dj dễ copy
    pcall(function()
        if setclipboard then
            setclipboard(tostring(placeId))
            Notify("Clipboard", "Đã tự động chép Place ID vào bộ nhớ tạm!", 3)
        end
    end)
    return
end

-- ========================================================================
-- 4. TẢI VÀ KHỞI CHẠY SCRIPT (SMART LOADER)
-- ========================================================================
Notify("SuiSuiHUB", string.format("Phát hiện game: %s\nĐang tải Script...", detectedGameName), 3)

local LOCAL_HOST = "http://127.0.0.1:8000"
local GITHUB_HOST = "https://raw.githubusercontent.com/suisuimommy-code/SuiSuiHUB/main"

local scriptContent = nil
local scriptSource = nil
local cacheBuster = "?t=" .. tostring(os.time())

-- 1. Ưu tiên thử nạp từ Local Test Server (port 8000)
local cleanPath = detectedGameConfig.ScriptPath:gsub(" ", "%%20")
pcall(function()
    local localUrl = string.format("%s/%s%s", LOCAL_HOST, cleanPath, cacheBuster)
    scriptContent = game:HttpGet(localUrl)
    if scriptContent and #scriptContent > 100 then
        scriptSource = "Localhost (Port 8000 Dev)"
    end
end)

-- 2. Nếu Localhost không mở, tự động nạp từ GitHub Production
if not scriptContent or #scriptContent < 100 then
    pcall(function()
        local githubUrl = string.format("%s/%s%s", GITHUB_HOST, cleanPath, cacheBuster)
        scriptContent = game:HttpGet(githubUrl)
        if scriptContent and #scriptContent > 100 then
            scriptSource = "GitHub Production (Main)"
        end
    end)
end

-- 3. Thực thi mã nguồn
if scriptContent and #scriptContent > 100 then
    local loadedFunc, parseError = loadstring(scriptContent)
    if loadedFunc then
        Notify("SuiSuiHUB", string.format("Khởi động thành công [%s]!\nNguồn: %s", detectedGameName, scriptSource or "Remote"), 4)
        task.spawn(loadedFunc)
    else
        Notify("Lỗi Cú Pháp", "Không thể biên dịch script:\n" .. tostring(parseError), 6)
        warn("[SuiSuiHUB Loader] Parse error:", parseError)
    end
else
    Notify("Lỗi Tải Script", "Không thể kết nối máy chủ để tải file " .. tostring(detectedGameConfig.ScriptPath), 6)
    warn("[SuiSuiHUB Loader] Failed to fetch script for:", detectedGameName)
end
