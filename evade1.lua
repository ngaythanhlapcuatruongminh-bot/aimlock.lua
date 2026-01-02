local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Biến lưu trạng thái
local isAutoReviveOn = false

-- 1. Xóa giao diện cũ để không bị trùng
if PlayerGui:FindFirstChild("EvadeTool_Simple") then
    PlayerGui.EvadeTool_Simple:Destroy()
end

-- 2. Tạo Giao diện (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EvadeTool_Simple"
ScreenGui.ResetOnSpawn = false -- Chết không bị mất nút
ScreenGui.Parent = PlayerGui

-- Khung chứa (Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0) -- Vị trí bên trái màn hình
MainFrame.Size = UDim2.new(0, 180, 0, 110)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể kéo thả cửa sổ

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "EVADE TOOLS"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(255, 127, 0) -- Màu cam
Title.TextColor3 = Color3.white
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- NÚT 1: TELEPORT
local TpButton = Instance.new("TextButton")
TpButton.Parent = MainFrame
TpButton.Position = UDim2.new(0.05, 0, 0.35, 0)
TpButton.Size = UDim2.new(0.9, 0, 0, 30)
TpButton.Text = "✈️ TP ĐẾN NGƯỜI GỤC"
TpButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Màu đỏ
TpButton.TextColor3 = Color3.white
TpButton.Font = Enum.Font.SourceSansBold
TpButton.TextSize = 14

-- NÚT 2: AUTO REVIVE (TOGGLE)
local ReviveToggle = Instance.new("TextButton")
ReviveToggle.Parent = MainFrame
ReviveToggle.Position = UDim2.new(0.05, 0, 0.7, 0)
ReviveToggle.Size = UDim2.new(0.9, 0, 0, 25)
ReviveToggle.Text = "Auto Revive: TẮT ❌"
ReviveToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Màu xám
ReviveToggle.TextColor3 = Color3.white
ReviveToggle.Font = Enum.Font.SourceSansBold
ReviveToggle.TextSize = 14

-- 3. Xử lý chức năng

-- >> Chức năng Bật/Tắt Auto Revive
ReviveToggle.MouseButton1Click:Connect(function()
    isAutoReviveOn = not isAutoReviveOn
    if isAutoReviveOn then
        ReviveToggle.Text = "Auto Revive: BẬT ✅"
        ReviveToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Xanh lá
    else
        ReviveToggle.Text = "Auto Revive: TẮT ❌"
        ReviveToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Xám
    end
end)

-- >> Chức năng Teleport
TpButton.MouseButton1Click:Connect(function()
    local found = false
    TpButton.Text = "Đang quét..."
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Kiểm tra Attribute "Downed"
            local isDowned = player.Character:GetAttribute("Downed")
            
            if isDowned then
                local targetPos = player.Character.HumanoidRootPart.CFrame
                -- TP đến vị trí (nhích lên 3 đơn vị để không bị kẹt)
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPos + Vector3.new(0, 3, 0)
                
                found = true
                TpButton.Text = "Đã tới: " .. player.Name
                wait(1)
                break 
            end
        end
    end

    if not found then
        TpButton.Text = "Không ai bị gục!"
        wait(1)
    end
    TpButton.Text = "✈️ TP ĐẾN NGƯỜI GỤC"
end)

-- >> Vòng lặp chạy ngầm: Tự động bấm E khi bật Auto Revive
RunService.RenderStepped:Connect(function()
    if isAutoReviveOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local isDowned = player.Character:GetAttribute("Downed")
                
                if isDowned then
                    -- Tính khoảng cách
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    
                    -- Nếu khoảng cách nhỏ hơn 15 studs (gần đủ để cứu)
                    if dist < 15 then
                        -- Giả lập bấm phím E
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    end
                end
            end
        end
    end
end)

print("Đã tải Evade Tools: TP + Revive!")
