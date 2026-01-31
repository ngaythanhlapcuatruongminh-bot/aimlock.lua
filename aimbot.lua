-- Dịch vụ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cài đặt chung
local Settings = {
    AimbotEnabled = false,
    AimbotSmoothness = 0.5,
    FOV = 150,
    TeamCheck = true,
    -- Cài đặt Bay
    FlyEnabled = false,
    FlySpeed = 50
}

-- --- 1. HỆ THỐNG GUI ---
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout") -- Tự động sắp xếp nút
local UICorner = Instance.new("UICorner")

-- Setup GUI
ScreenGui.Name = "SuperFPSGui"
ScreenGui.Parent = game.CoreGui

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 160, 0, 100) -- Kích thước chứa đủ 2 nút
MainFrame.Active = true
MainFrame.Draggable = true 

-- Bo tròn góc Frame
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Layout sắp xếp (Xếp chồng dọc)
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- >> NÚT 1: AIMBOT <<
local AimbotBtn = Instance.new("TextButton")
AimbotBtn.Parent = MainFrame
AimbotBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AimbotBtn.Size = UDim2.new(1, 0, 0.5, -3) -- Chiếm 50% chiều cao
AimbotBtn.Font = Enum.Font.SourceSansBold
AimbotBtn.Text = "AIMBOT: OFF"
AimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotBtn.TextSize = 18
AimbotBtn.LayoutOrder = 1
local AimCorner = Instance.new("UICorner")
AimCorner.Parent = AimbotBtn

-- >> NÚT 2: FLY <<
local FlyBtn = Instance.new("TextButton")
FlyBtn.Parent = MainFrame
FlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FlyBtn.Size = UDim2.new(1, 0, 0.5, -3) -- Chiếm 50% chiều cao
FlyBtn.Font = Enum.Font.SourceSansBold
FlyBtn.Text = "FLY: OFF"
FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBtn.TextSize = 18
FlyBtn.LayoutOrder = 2
local FlyCorner = Instance.new("UICorner")
FlyCorner.Parent = FlyBtn

-- --- LOGIC NÚT BẤM ---

-- Logic Aimbot
AimbotBtn.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    if Settings.AimbotEnabled then
        AimbotBtn.Text = "AIMBOT: ON"
        AimbotBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        AimbotBtn.Text = "AIMBOT: OFF"
        AimbotBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Logic Fly
local BodyGyro, BodyVelocity
local function toggleFly(state)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    if state then
        -- Bật bay
        hum.PlatformStand = true -- Tắt vật lý nhân vật
        
        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.P = 9e4
        BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BodyGyro.CFrame = root.CFrame
        BodyGyro.Parent = root
        
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVelocity.Parent = root
        
        FlyBtn.Text = "FLY: ON"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        -- Tắt bay
        hum.PlatformStand = false
        if BodyGyro then BodyGyro:Destroy() end
        if BodyVelocity then BodyVelocity:Destroy() end
        
        FlyBtn.Text = "FLY: OFF"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end

FlyBtn.MouseButton1Click:Connect(function()
    Settings.FlyEnabled = not Settings.FlyEnabled
    toggleFly(Settings.FlyEnabled)
end)

-- --- 2. HỆ THỐNG FLY (Xử lý di chuyển) ---
RunService.RenderStepped:Connect(function()
    if Settings.FlyEnabled and LocalPlayer.Character and BodyVelocity and BodyGyro then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            BodyGyro.CFrame = Camera.CFrame -- Xoay nhân vật theo Camera
            
            local direction = Vector3.new(0, 0, 0)
            
            -- Xử lý phím bấm
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0) -- Bay lên
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction = direction - Vector3.new(0, 1, 0) -- Bay xuống
            end
            
            -- Áp dụng tốc độ
            BodyVelocity.Velocity = direction * Settings.FlySpeed
        end
    end
end)

-- Reset Fly khi chết
LocalPlayer.CharacterAdded:Connect(function()
    Settings.FlyEnabled = false
    FlyBtn.Text = "FLY: OFF"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)

-- --- 3. HỆ THỐNG ESP (Như cũ) ---
local function createESP(player)
    local function applyHighlight(char)
        if not char:FindFirstChild("ESPHighlight") then
            local hl = Instance.new("Highlight")
            hl.Name = "ESPHighlight"
            hl.Adornee = char
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.Parent = char
        end
    end
    if player.Character then applyHighlight(player.Character) end
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart")
        applyHighlight(char)
    end)
end

for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then createESP(v) end
end
Players.PlayerAdded:Connect(createESP)

-- --- 4. HỆ THỐNG AIMBOT (Như cũ) ---
local function getClosestEnemy()
    local closestDistance = Settings.FOV
    local closestPlayer = nil
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 and target.Character:FindFirstChild("Head") then
            if Settings.TeamCheck and target.Team == LocalPlayer.Team then continue end
            local vector, onScreen = Camera:WorldToScreenPoint(target.Character.Head.Position)
            if onScreen then
                local mouseLocation = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(mouseLocation.X, mouseLocation.Y) - Vector2.new(vector.X, vector.Y)).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = target
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = getClosestEnemy()
            if target then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 - Settings.AimbotSmoothness)
            end
        end
    end
end)
