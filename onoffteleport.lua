local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer



-- --- CÀI ĐẶT ---

local Settings = {

AutoTP = false,

TPDelay = 0.2 -- Cập nhật vị trí mỗi 0.2 giây (tránh giật lag hoặc văng game)

}



-- --- 1. TẠO GIAO DIỆN (GUI) ---

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "ModMenuV2"

if pcall(function() ScreenGui.Parent = game.CoreGui end) then

ScreenGui.Parent = game.CoreGui

else

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

end



local MainFrame = Instance.new("Frame")

MainFrame.Parent = ScreenGui

MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)

MainFrame.Size = UDim2.new(0, 200, 0, 180)

MainFrame.Active = true

MainFrame.Draggable = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)



local Title = Instance.new("TextLabel")

Title.Parent = MainFrame

Title.Size = UDim2.new(1, 0, 0, 30)

Title.BackgroundTransparency = 1

Title.Text = "MOD MENU V2"

Title.TextColor3 = Color3.fromRGB(255, 100, 100)

Title.Font = Enum.Font.GothamBold

Title.TextSize = 16



local UIListLayout = Instance.new("UIListLayout")

UIListLayout.Parent = MainFrame

UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

UIListLayout.Padding = UDim.new(0, 10)

UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center



-- --- 2. CÁC NÚT TƯƠNG TÁC ---



-- Nút Auto Teleport

local ToggleTPBtn = Instance.new("TextButton")

ToggleTPBtn.Parent = MainFrame

ToggleTPBtn.Size = UDim2.new(0.9, 0, 0, 35)

ToggleTPBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

ToggleTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

ToggleTPBtn.Font = Enum.Font.GothamBold

ToggleTPBtn.TextSize = 14

ToggleTPBtn.Text = "AUTO TP: OFF"

Instance.new("UICorner", ToggleTPBtn)



-- Khung nhập tốc độ (Speed Input)

local SpeedInput = Instance.new("TextBox")

SpeedInput.Parent = MainFrame

SpeedInput.Size = UDim2.new(0.9, 0, 0, 30)

SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)

SpeedInput.Font = Enum.Font.Gotham

SpeedInput.TextSize = 14

SpeedInput.PlaceholderText = "Nhập tốc độ (VD: 50, 100)..."

SpeedInput.Text = ""

Instance.new("UICorner", SpeedInput)



-- Nút Áp dụng Tốc độ

local ApplySpeedBtn = Instance.new("TextButton")

ApplySpeedBtn.Parent = MainFrame

ApplySpeedBtn.Size = UDim2.new(0.9, 0, 0, 35)

ApplySpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)

ApplySpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

ApplySpeedBtn.Font = Enum.Font.GothamBold

ApplySpeedBtn.TextSize = 14

ApplySpeedBtn.Text = "ÁP DỤNG TỐC ĐỘ"

Instance.new("UICorner", ApplySpeedBtn)



-- --- 3. LOGIC XỬ LÝ ---



-- Logic thay đổi tốc độ

ApplySpeedBtn.MouseButton1Click:Connect(function()

local char = LocalPlayer.Character

if char and char:FindFirstChild("Humanoid") then

local newSpeed = tonumber(SpeedInput.Text)

if newSpeed then

char.Humanoid.WalkSpeed = newSpeed

ApplySpeedBtn.Text = "ĐÃ ĐỔI: " .. newSpeed

task.wait(1)

ApplySpeedBtn.Text = "ÁP DỤNG TỐC ĐỘ"

else

ApplySpeedBtn.Text = "LỖI: HÃY NHẬP SỐ!"

task.wait(1)

ApplySpeedBtn.Text = "ÁP DỤNG TỐC ĐỘ"

end

end

end)



-- Hàm tìm người gần nhất

local function GetNearestEnemy()

local myChar = LocalPlayer.Character

if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

local myPos = myChar.HumanoidRootPart.Position



local closestDist = math.huge

local targetChar = nil



for _, p in pairs(Players:GetPlayers()) do

if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then

local hum = p.Character:FindFirstChild("Humanoid")

if hum and hum.Health > 0 then

local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude

if dist < closestDist then

closestDist = dist

targetChar = p.Character

end

end

end

end

return targetChar

end



-- Vòng lặp Auto Teleport (Chạy ngầm)

task.spawn(function()

while true do

if Settings.AutoTP then

local target = GetNearestEnemy()

local myChar = LocalPlayer.Character


if target and myChar and myChar:FindFirstChild("HumanoidRootPart") then

local targetRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso")

if targetRoot then

-- Teleport bám theo sau lưng

myChar:PivotTo(targetRoot.CFrame * CFrame.new(0, 0, 3))


-- Reset vận tốc để không bị văng

if myChar.HumanoidRootPart:FindFirstChild("Velocity") then

myChar.HumanoidRootPart.Velocity = Vector3.new(0,0,0)

end

end

end

end

-- Nghỉ một khoảng nhỏ để server không đá văng vì spam lệnh

task.wait(Settings.TPDelay)

end

end)



-- Nút Bật/Tắt Auto TP

ToggleTPBtn.MouseButton1Click:Connect(function()

Settings.AutoTP = not Settings.AutoTP

if Settings.AutoTP then

ToggleTPBtn.Text = "AUTO TP: ON"

ToggleTPBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)

else

ToggleTPBtn.Text = "AUTO TP: OFF"

ToggleTPBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

end

end)
