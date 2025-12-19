local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StatsService = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().AutoConfig = {
    UseAutoPrediction = true,   
    BasePrediction = 0.135,     
    AimPart = "HumanoidRootPart",
    TeamCheck = false,            
    Smoothness = true,          
    SmoothnessAmount = 0.15,
    ShakeFix = true,
    SyncThreshold = 0.95 
}

local CurrentTarget = nil
local CurrentPing = 0
local RealPrediction = getgenv().AutoConfig.BasePrediction
local LastPingUpdate = 0

local ScreenName = "ProTrackerUI_Final"
if CoreGui:FindFirstChild(ScreenName) then
    CoreGui[ScreenName]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenName
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0, 10, 0.5, -55) 
Frame.Size = UDim2.new(0, 210, 0, 110)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, -20, 0, 15)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "SYNC TRACKER v3"
Title.TextColor3 = Color3.fromRGB(255, 180, 50)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 10
Title.TextXAlignment = Enum.TextXAlignment.Left

local BountyValue = Instance.new("TextLabel", Frame)
BountyValue.Size = UDim2.new(1, -20, 0, 20)
BountyValue.Position = UDim2.new(0, 10, 0, 20)
BountyValue.BackgroundTransparency = 1
BountyValue.Text = "Wait..."
BountyValue.TextColor3 = Color3.fromRGB(80, 255, 80)
BountyValue.Font = Enum.Font.GothamBold
BountyValue.TextSize = 16
BountyValue.TextXAlignment = Enum.TextXAlignment.Left

local StatusLabel = Instance.new("TextLabel", Frame)
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -20, 0, 30) -- Chiều cao lớn hơn để xuống dòng
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Scanning..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.TextWrapped = true

local InfoLabel = Instance.new("TextLabel", Frame)
InfoLabel.Size = UDim2.new(1, -20, 0, 20)
InfoLabel.Position = UDim2.new(0, 10, 0, 85) 
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Ping: ... | Pred: ..."
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.Font = Enum.Font.Code
InfoLabel.TextSize = 10
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

local function UpdatePingAndPred()
    if tick() - LastPingUpdate < 0.2 then return end -- Cập nhật nhanh hơn chút (0.2s)
    LastPingUpdate = tick()

    local success, statsVal = pcall(function() 
        return StatsService.Network.ServerStatsItem["Data Ping"]:GetValueString() 
    end)
    
    local pingNumber = 60
    if success and statsVal then
        pingNumber = tonumber(statsVal:match("%d+")) or 60
    end
    CurrentPing = pingNumber
    
    if getgenv().AutoConfig.UseAutoPrediction then
        local rawPred = (pingNumber / 1000) + 0.037 
        RealPrediction = math.clamp(rawPred, 0.1, 0.3)
    else
        RealPrediction = getgenv().AutoConfig.BasePrediction
    end
    
    InfoLabel.Text = string.format("Ping: %dms | Pred: %.4f", CurrentPing, RealPrediction)
end

task.spawn(function()
    BountyValue.Text = "Loading..."
    local leaderstats
    repeat
        leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if not leaderstats then task.wait(1) end
    until leaderstats or not LocalPlayer.Parent

    if not leaderstats then return end

    local BountyStat = leaderstats:WaitForChild("Bounty", 10) or leaderstats:WaitForChild("Honor", 10) or leaderstats:WaitForChild("Wanted", 10)
    
    if BountyStat then
        local InitialBounty = BountyStat.Value
        BountyValue.Text = "+ 0"
        
        BountyStat:GetPropertyChangedSignal("Value"):Connect(function()
            local earned = BountyStat.Value - InitialBounty
            BountyValue.Text = (earned >= 0 and "+ " or "- ") .. math.abs(earned)
            BountyValue.TextColor3 = earned >= 0 and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
        end)
    else
        BountyValue.Text = "No Bounty Stat"
    end
end)

local function IsValidTarget(player)
    if not player or not player.Parent or player == LocalPlayer then return false end
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum or hum.Health <= 0 then return false end
    if getgenv().AutoConfig.TeamCheck and player.Team == LocalPlayer.Team then return false end
    return true
end

local function GetSyncedTarget()
    local bestTarget = nil
    local bestDot = getgenv().AutoConfig.SyncThreshold 
    local camLook = Camera.CFrame.LookVector.Unit

    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local char = player.Character
            local root = char:FindFirstChild(getgenv().AutoConfig.AimPart) or char:FindFirstChild("HumanoidRootPart")
            if root then
                local toTarget = (root.Position - Camera.CFrame.Position).Unit
                local dot = camLook:Dot(toTarget)
                
                if dot > bestDot then
                    bestDot = dot
                    bestTarget = player
                end
            end
        end
    end
    return bestTarget
end

RunService.RenderStepped:Connect(function()
    UpdatePingAndPred() 
    CurrentTarget = GetSyncedTarget()

    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Humanoid") then
        local hum = CurrentTarget.Character.Humanoid
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - CurrentTarget.Character.HumanoidRootPart.Position).Magnitude
        
        -- Hiển thị thông tin giống Status của Script A
        StatusLabel.Text = string.format("LOCKED: %s\nHP: %.0f | Dist: %.0f", CurrentTarget.Name, hum.Health, dist)
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Màu đỏ báo động
    else
        StatusLabel.Text = "Status: Scanning...\nWaiting for sync"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200) -- Màu xám nghỉ
    end

    if CurrentTarget and CurrentTarget.Character then
        local targetRoot = CurrentTarget.Character:FindFirstChild(getgenv().AutoConfig.AimPart)
        
        if targetRoot then
            local currentCamPos = Camera.CFrame.Position
            local velocity = targetRoot.AssemblyLinearVelocity
            
            if getgenv().AutoConfig.ShakeFix and velocity.Magnitude < 2 then
                velocity = Vector3.new(0,0,0)
            end

            local predictedPos = targetRoot.Position + (velocity * RealPrediction)
            
            if getgenv().AutoConfig.Smoothness then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(currentCamPos, predictedPos), getgenv().AutoConfig.SmoothnessAmount)
            else
                Camera.CFrame = CFrame.new(currentCamPos, predictedPos)
            end
        end
    end
end)
