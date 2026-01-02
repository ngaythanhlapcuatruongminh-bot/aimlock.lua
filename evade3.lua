local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local isAutoReviveOn = false

-- 1. Dọn dẹp tất cả menu cũ bị lỗi
-- (Xóa hết mấy cái hộp đen xì đang chắn màn hình của bạn)
local oldGuis = {"EvadeTools_Direct", "EvadeTool_MobileFix", "EvadeTool_Simple", "Evade Config"}
for _, name in pairs(oldGuis) do
    if PlayerGui:FindFirstChild(name) then
        PlayerGui[name]:Destroy()
    end
end

-- 2. Tạo màn hình mới
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EvadeTools_Direct"
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = PlayerGui

-- === NÚT 1: TELEPORT (Màu Đỏ) ===
local TpButton = Instance.new("TextButton")
TpButton.Name = "TpButton"
TpButton.Parent = ScreenGui
TpButton.Position = UDim2.new(0.6, 0, 0.1, 0) -- Nằm góc trên bên phải (tránh nút Menu game)
TpButton.Size = UDim2.new(0, 160, 0, 50)
TpButton.Text = "✈️ TP ĐẾN NGƯỜI GỤC"
TpButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- Đỏ tươi
TpButton.TextColor3 = Color3.white
TpButton.Font = Enum.Font.GothamBold
TpButton.TextSize = 16
TpButton.BorderSizePixel = 2
TpButton.BorderColor3 = Color3.white

-- Bo tròn góc cho đẹp
local Corner1 = Instance.new("UICorner")
Corner1.CornerRadius = UDim.new(0, 12)
Corner1.Parent = TpButton

-- === NÚT 2: AUTO REVIVE (Màu Xám) ===
local ReviveToggle = Instance.new("TextButton")
ReviveToggle.Name = "ReviveButton"
ReviveToggle.Parent = ScreenGui
ReviveToggle.Position = UDim2.new(0.6, 0, 0.22, 0) -- Nằm ngay dưới nút TP
ReviveToggle.Size = UDim2.new(0, 160, 0, 40)
ReviveToggle.Text = "Auto Revive: TẮT ❌"
ReviveToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ReviveToggle.TextColor3 = Color3.white
ReviveToggle.Font = Enum.Font.GothamBold
ReviveToggle.TextSize = 14
ReviveToggle.BorderSizePixel = 2
ReviveToggle.BorderColor3 = Color3.white

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 12)
Corner2.Parent = ReviveToggle

-- === 3. XỬ LÝ LOGIC (GIỮ NGUYÊN) ===

-- Bật/Tắt Auto Revive
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

-- Xử lý Teleport
TpButton.MouseButton1Click:Connect(function()
    local found = false
    TpButton.Text = "Đang tìm..."
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        TpButton.Text = "Lỗi nhân vật!"
        wait(1)
        TpButton.Text = "✈️ TP ĐẾN NGƯỜI GỤC"
        return 
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local isDowned = player.Character:GetAttribute("Downed")
            
            if isDowned then
                -- Teleport
                local targetPos = player.Character.HumanoidRootPart.CFrame
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPos + Vector3.new(0, 4, 0)
                
                found = true
                TpButton.Text = "✅ Đã tới: " .. player.Name
                wait(1.5)
                break 
            end
        end
    end

    if not found then
        TpButton.Text = "⚠️ Không tìm thấy ai!"
        wait(1)
    end
    TpButton.Text = "✈️ TP ĐẾN NGƯỜI GỤC"
end)

-- Chạy ngầm Auto Revive
RunService.RenderStepped:Connect(function()
    if isAutoReviveOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local isDowned = player.Character:GetAttribute("Downed")
                if isDowned then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 15 then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    end
                end
            end
        end
    end
end)

print("Đã tải nút điều khiển trực tiếp!")
