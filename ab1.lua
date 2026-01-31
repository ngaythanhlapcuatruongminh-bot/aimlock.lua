-- CẤU HÌNH --
local Settings = {
    EnemyColor = Color3.fromRGB(255, 0, 0), -- Địch: Đỏ
    TeamColor = Color3.fromRGB(0, 255, 0),  -- Đồng đội: Xanh Lá
    BoxThickness = 2,
    Transparency = 0.5
}

-- DỊCH VỤ --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- HÀM KIỂM TRA ĐỘI (ĐÃ SỬA) --
local function IsTeammate(player)
    -- Kiểm tra 1: So sánh đối tượng Team
    if player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then
            return true
        end
    end
    
    -- Kiểm tra 2: So sánh Màu Team (Quan trọng cho nhiều game)
    if player.TeamColor == LocalPlayer.TeamColor then
        return true
    end

    return false
end

-- HÀM TẠO ESP --
local function CreateESP(player)
    local function CharacterAdded(character)
        local rootPart = character:WaitForChild("HumanoidRootPart", 10)
        if not rootPart then return end

        if character:FindFirstChild("BoxESP") then character.BoxESP:Destroy() end

        -- Tạo khung
        local espBox = Instance.new("BillboardGui")
        espBox.Name = "BoxESP"
        espBox.Adornee = rootPart
        espBox.Size = UDim2.new(4.5, 0, 6, 0)
        espBox.AlwaysOnTop = true
        espBox.Parent = character

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = espBox

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = Settings.BoxThickness
        stroke.Parent = frame

        -- Hàm cập nhật màu riêng biệt cho từng người
        local function UpdateSpecificColor()
            if player == LocalPlayer then 
                espBox:Destroy()
                return 
            end

            if IsTeammate(player) then
                stroke.Color = Settings.TeamColor
            else
                stroke.Color = Settings.EnemyColor
            end
        end

        -- Chạy ngay lập tức
        UpdateSpecificColor()

        -- Tự động cập nhật nếu màu team thay đổi
        player:GetPropertyChangedSignal("TeamColor"):Connect(UpdateSpecificColor)
        player:GetPropertyChangedSignal("Team"):Connect(UpdateSpecificColor)
        
        -- Lưu hàm cập nhật vào frame để dùng sau (xem phần Loop bên dưới)
        frame:SetAttribute("IsESP", true)
    end

    if player.Character then CharacterAdded(player.Character) end
    player.CharacterAdded:Connect(CharacterAdded)
end

-- KHỞI CHẠY --
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESP(player) end
end

Players.PlayerAdded:Connect(CreateESP)

-- VÒNG LẶP KIỂM TRA MÀU (FIX LỖI KHÔNG ĐỔI MÀU) --
-- Đôi khi sự kiện đổi team không kích hoạt, vòng lặp này sẽ ép màu phải đúng mỗi 1 giây
task.spawn(function()
    while task.wait(1) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("BoxESP") then
                local stroke = player.Character.BoxESP.Frame.UIStroke
                if IsTeammate(player) then
                    stroke.Color = Settings.TeamColor
                else
                    stroke.Color = Settings.EnemyColor
                end
            end
        end
    end
end)
