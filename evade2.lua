local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local isAutoReviveOn = false

-- 1. Xóa giao diện cũ
if PlayerGui:FindFirstChild("EvadeTool_MobileFix") then
    PlayerGui.EvadeTool_MobileFix:Destroy()
end

-- 2. Tạo GUI Mới
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EvadeTool_MobileFix"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Quan trọng cho Mobile
ScreenGui.Parent = PlayerGui

-- Khung Chính (MainFrame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 130) -- Làm to hơn một chút
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

-- Tiêu đề (Title)
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "EVADE TOOLS (FIX)"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(255, 127, 0)
Title.TextColor3 = Color3.white
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.ZIndex = 2 -- Nổi lên trên

-- NÚT 1: TELEPORT (Sửa ZIndex)
local TpButton = Instance.new("TextButton")
TpButton.Name = "TpButton"
TpButton.Parent = MainFrame
TpButton.Position = UDim2.new(0.05, 0, 0.35, 0) -- Cách trên 35%
TpButton.Size = UDim2.new(0.9, 0, 0, 35)
TpButton.Text = "✈️ TP ĐẾN NGƯỜI GỤC"
TpButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
TpButton.TextColor3 = Color3.white
TpButton.Font = Enum.Font.SourceSansBold
TpButton.TextSize = 14
TpButton.ZIndex = 2 -- QUAN TRỌNG: Để nút nổi lên trên nền đen

-- NÚT 2: AUTO REVIVE (Sửa ZIndex)
local ReviveToggle = Instance.new("TextButton")
ReviveToggle.Name = "ReviveButton"
ReviveToggle.Parent = MainFrame
ReviveToggle.Position = UDim2.new(0.05, 0, 0.7, 0) -- Cách trên 70%
ReviveToggle.Size = UDim2.new(0.9, 0, 0, 30)
ReviveToggle.Text = "Auto Revive: TẮT ❌"
ReviveToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ReviveToggle.TextColor3 = Color3.white
ReviveToggle.Font = Enum.Font.SourceSansBold
ReviveToggle.TextSize = 14
ReviveToggle.ZIndex = 2 -- QUAN TRỌNG: Để nút nổi lên trên nền đen

-- 3. Logic Chức Năng (Giữ nguyên)
ReviveToggle.MouseButton1Click:Connect(function()
    isAutoReviveOn = not isAutoReviveOn
    if isAutoReviveOn then
        ReviveToggle.Text = "Auto Revive: BẬT ✅"
        ReviveToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        ReviveToggle.Text = "Auto Revive: TẮT ❌"
        ReviveToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
end)

TpButton.MouseButton1Click:Connect(function()
    local found = false
    TpButton.Text = "Đang quét..."
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local isDowned = player.Character:GetAttribute("Downed")
            if isDowned then
                local targetPos = player.Character.HumanoidRootPart.CFrame
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

print("Đã tải UI Fix Mobile!")
