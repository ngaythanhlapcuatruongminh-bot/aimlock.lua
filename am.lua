-- CẤU HÌNH MÀU SẮC
local Settings = {
    EnemyColor = Color3.fromRGB(255, 0, 0), -- Màu Đỏ (Địch)
    TeamColor = Color3.fromRGB(0, 255, 0),  -- Màu Xanh Lá (Đồng đội)
    BoxThickness = 2,                       -- Độ dày viền hộp
    Transparency = 0.5                      -- Độ trong suốt (0 là rõ nhất, 1 là tàng hình)
}

-- DỊCH VỤ
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- HÀM KIỂM TRA ĐỒNG ĐỘI
local function IsTeammate(player)
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    return false -- Nếu game không chia team thì coi như là địch
end

-- HÀM TẠO ESP CHO 1 NGƯỜI
local function CreateESP(player)
    -- Hàm con: Tạo hộp khi nhân vật xuất hiện
    local function CharacterAdded(character)
        -- Đợi 1 chút để nhân vật load xong hoàn toàn (Tránh lỗi mất ESP)
        local rootPart = character:WaitForChild("HumanoidRootPart", 10)
        if not rootPart then return end

        -- Xóa ESP cũ nếu bị lỗi kẹt
        if character:FindFirstChild("BoxESP") then character.BoxESP:Destroy() end

        -- 1. Tạo Khung Chứa (BillboardGui)
        local espBox = Instance.new("BillboardGui")
        espBox.Name = "BoxESP"
        espBox.Adornee = rootPart
        espBox.Size = UDim2.new(4.5, 0, 6, 0) -- Kích thước hộp (4.5 x 6 studs)
        espBox.AlwaysOnTop = true
        espBox.Parent = character

        -- 2. Tạo Viền Hộp (Frame + UIStroke)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1 -- Chỉ lấy viền, không lấy nền
        frame.Parent = espBox

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = Settings.BoxThickness
        stroke.Parent = frame

        -- 3. Hàm cập nhật màu
        local function UpdateColor()
            if player == LocalPlayer then 
                espBox:Destroy() -- Không hiện cho bản thân
                return 
            end

            if IsTeammate(player) then
                stroke.Color = Settings.TeamColor
            else
                stroke.Color = Settings.EnemyColor
            end
        end

        -- Chạy cập nhật màu ngay lập tức
        UpdateColor()

        -- Tự đổi màu nếu người chơi đổi team giữa trận
        player:GetPropertyChangedSignal("Team"):Connect(UpdateColor)
        LocalPlayer:GetPropertyChangedSignal("Team"):Connect(UpdateColor)
    end

    -- KẾT NỐI SỰ KIỆN
    if player.Character then
        CharacterAdded(player.Character)
    end
    -- Khi chết và hồi sinh, ESP sẽ tự tạo lại
    player.CharacterAdded:Connect(CharacterAdded)
end

-- KHỞI CHẠY
-- 1. Quét toàn bộ người chơi hiện tại
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- 2. Đón người chơi mới vào server
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)
