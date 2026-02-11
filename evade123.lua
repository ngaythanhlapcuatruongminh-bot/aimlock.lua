local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera



-- Cài đặt mặc định

local Settings = {

    FlyEnabled = false,

    FlySpeed = 50, -- Tốc độ mặc định

    ESPEnabled = false

}



-- --- 1. TẠO GUI ---

local ScreenGui = Instance.new("ScreenGui")

local Frame = Instance.new("Frame")

local UIListLayout = Instance.new("UIListLayout")



-- Tên GUI để tránh trùng lặp

ScreenGui.Name = "FlySpeedControl"

if pcall(function() game:GetService("CoreGui") end) then

    ScreenGui.Parent = game:GetService("CoreGui")

else

    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

end



-- Khung chính nhỏ gọn

Frame.Parent = ScreenGui

Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

Frame.Position = UDim2.new(0.1, 0, 0.3, 0)

Frame.Size = UDim2.new(0, 150, 0, 140) -- Kích thước nhỏ

Frame.Active = true

Frame.Draggable = true -- Có thể kéo thả

Frame.BorderSizePixel = 0



local Corner = Instance.new("UICorner")

Corner.CornerRadius = UDim.new(0, 8)

Corner.Parent = Frame



-- Layout xếp dọc

UIListLayout.Parent = Frame

UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

UIListLayout.Padding = UDim.new(0, 5)

UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center



-- Tiêu đề

local Title = Instance.new("TextLabel")

Title.Parent = Frame

Title.BackgroundTransparency = 1

Title.Size = UDim2.new(1, 0, 0, 25)

Title.Text = "FLY CONTROL"

Title.TextColor3 = Color3.fromRGB(255, 255, 255)

Title.Font = Enum.Font.GothamBold

Title.TextSize = 14



-- Nút Fly

local FlyBtn = Instance.new("TextButton")

FlyBtn.Parent = Frame

FlyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

FlyBtn.Size = UDim2.new(0.9, 0, 0, 30)

FlyBtn.Font = Enum.Font.SourceSansBold

FlyBtn.Text = "FLY: OFF"

FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

FlyBtn.TextSize = 14

local FlyCorner = Instance.new("UICorner")

FlyCorner.Parent = FlyBtn



-- Nút ESP

local ESPBtn = Instance.new("TextButton")

ESPBtn.Parent = Frame

ESPBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

ESPBtn.Size = UDim2.new(0.9, 0, 0, 30)

ESPBtn.Font = Enum.Font.SourceSansBold

ESPBtn.Text = "ESP: OFF"

ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

ESPBtn.TextSize = 14

local ESPCorner = Instance.new("UICorner")

ESPCorner.Parent = ESPBtn



-- Ô Nhập Tốc Độ

local SpeedInput = Instance.new("TextBox")

SpeedInput.Parent = Frame

SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

SpeedInput.Size = UDim2.new(0.9, 0, 0, 30)

SpeedInput.Font = Enum.Font.SourceSansBold

SpeedInput.Text = tostring(Settings.FlySpeed) -- Hiện số hiện tại

SpeedInput.TextColor3 = Color3.fromRGB(255, 215, 0) -- Màu vàng cho dễ nhìn

SpeedInput.PlaceholderText = "Nhập tốc độ..."

SpeedInput.TextSize = 14

local SpeedCorner = Instance.new("UICorner")

SpeedCorner.Parent = SpeedInput



-- --- 2. XỬ LÝ LOGIC ---



-- Cập nhật tốc độ ngay khi nhập

SpeedInput:GetPropertyChangedSignal("Text"):Connect(function()

    local num = tonumber(SpeedInput.Text)

    if num then

        Settings.FlySpeed = num -- Cập nhật biến tốc độ ngay lập tức

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

        hum.PlatformStand = true

        

        BodyGyro = Instance.new("BodyGyro", root)

        BodyGyro.P = 9e4

        BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)

        BodyGyro.CFrame = root.CFrame

        

        BodyVelocity = Instance.new("BodyVelocity", root)

        BodyVelocity.Velocity = Vector3.new(0, 0, 0)

        BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

    else

        hum.PlatformStand = false

        if BodyGyro then BodyGyro:Destroy() end

        if BodyVelocity then BodyVelocity:Destroy() end

    end

end



FlyBtn.MouseButton1Click:Connect(function()

    Settings.FlyEnabled = not Settings.FlyEnabled

    FlyBtn.Text = Settings.FlyEnabled and "FLY: ON" or "FLY: OFF"

    FlyBtn.BackgroundColor3 = Settings.FlyEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)

    toggleFly(Settings.FlyEnabled)

end)



-- Logic ESP

local ESPFolder = Instance.new("Folder", game.CoreGui)

local function updateESP()

    ESPFolder:ClearAllChildren()

    if not Settings.ESPEnabled then return end

    for _, v in pairs(Players:GetPlayers()) do

        if v ~= LocalPlayer and v.Character then

            local hl = Instance.new("Highlight")

            hl.Adornee = v.Character

            hl.FillColor = Color3.fromRGB(255, 0, 0)

            hl.OutlineColor = Color3.fromRGB(255, 255, 255)

            hl.Parent = ESPFolder

        end

    end

end



ESPBtn.MouseButton1Click:Connect(function()

    Settings.ESPEnabled = not Settings.ESPEnabled

    ESPBtn.Text = Settings.ESPEnabled and "ESP: ON" or "ESP: OFF"

    ESPBtn.BackgroundColor3 = Settings.ESPEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)

    updateESP()

end)



-- Vòng lặp chính (Quản lý di chuyển)

RunService.RenderStepped:Connect(function()

    if Settings.FlyEnabled and LocalPlayer.Character then

        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        

        -- Kiểm tra lại nếu BodyVelocity bị game xóa thì tạo lại

        if not root:FindFirstChild("BodyVelocity") then

            toggleFly(true)

        end



        if BodyGyro and BodyVelocity then

            BodyGyro.CFrame = Camera.CFrame

            

            local direction = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end

            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end

            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end

            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end

            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end

            

            -- QUAN TRỌNG: Nhân hướng di chuyển với tốc độ hiện tại trong ô nhập

            BodyVelocity.Velocity = direction * Settings.FlySpeed

        end

    end

end)

-- Reset khi chết

LocalPlayer.CharacterAdded:Connect(function()

    Settings.FlyEnabled = false

    FlyBtn.Text = "FLY: OFF"

    FlyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

end)
