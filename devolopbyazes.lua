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
    SyncThreshold = 0.95,
    AntiSuspicious = true -- Bật chế độ chống mạng hạ gục khả nghi
}

local CurrentTarget = nil
local CurrentPing = 0
local RealPrediction = getgenv().AutoConfig.BasePrediction
local LastPingUpdate = 0

local ScreenName = "AzesTracker_Final"
if CoreGui:FindFirstChild(ScreenName) then
    CoreGui[ScreenName]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenName
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0, 10, 0.5, -60) 
Frame.Size = UDim2.new(0, 220, 0, 120)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, -20, 0, 15)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "Devolop By Azes"
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left

local BountyLabel = Instance.new("TextLabel", Frame)
BountyLabel.Size = UDim2.new(1, -20, 0, 25)
BountyLabel.Position = UDim2.new(0, 10, 0, 25)
BountyLabel.BackgroundTransparency = 1
BountyLabel.Text = "Session: Loading..."
BountyLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
BountyLabel.Font = Enum.Font.GothamBold
BountyLabel.TextSize = 18
BountyLabel.TextXAlignment = Enum.TextXAlignment.Left

local StatusLabel = Instance.new("TextLabel", Frame)
StatusLabel.Size = UDim2.new(1, -20, 0, 35)
StatusLabel.Position = UDim2.new(0, 10, 0, 55)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Scanning..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.TextWrapped = true

local InfoLabel = Instance.new("TextLabel", Frame)
InfoLabel.Size = UDim2.new(1, -20, 0, 15)
InfoLabel.Position = UDim2.new(0, 10, 0, 95)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Ping: ... | Pred: ..."
InfoLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
InfoLabel.Font = Enum.Font.Code
InfoLabel.TextSize = 10
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

local function FormatNumber(n)
    return tostring(n):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local function UpdatePingAndPred()
    if tick() - LastPingUpdate < 0.2 then return end
    LastPingUpdate = tick()

    local success, statsVal = pcall(function() 
        return StatsService.Network.ServerStatsItem["Data Ping"]:GetValueString() 
    end)
    local pingNumber = tonumber(statsVal:match("%d+")) or 60
    CurrentPing = pingNumber
    
    if getgenv().AutoConfig.UseAutoPrediction then
        local rawPred = (pingNumber / 1000) + 0.037 
        RealPrediction = math.clamp(rawPred, 0.1, 0.3)
    else
        RealPrediction = getgenv().AutoConfig.BasePrediction
    end
    InfoLabel.Text = string.format("Ping: %dms | Pred: %.4f", CurrentPing, RealPrediction)
end

local function CheckSuspiciousStatus(target)
    if not getgenv().AutoConfig.AntiSuspicious then return false end
    if not target or not target.Character then return true end
    
    local hum = target.Character:FindFirstChild("Humanoid")
    if not hum then return true end

    if hum.Health <= 0 then return true end

    if hum.Health < (hum.MaxHealth * 0.05) then return false end

    return false 
end

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

task.spawn(function()
    local InitialBounty = 0
    local BountyStat = nil
    
    repeat task.wait(0.5) until LocalPlayer:FindFirstChild("leaderstats")
    
    local stats = LocalPlayer.leaderstats
    BountyStat = stats:FindFirstChild("Bounty") or stats:FindFirstChild("Honor") or stats:FindFirstChild("Wanted")
    
    if BountyStat then
        InitialBounty = BountyStat.Value -- Lưu mốc bắt đầu
        BountyLabel.Text = "Session: +0"
        
        local function UpdateBountyUI()
            local earned = BountyStat.Value - InitialBounty
            local sign = earned >= 0 and "+" or "-"
            
            local formatted = FormatNumber(math.abs(earned))
            BountyLabel.Text = string.format("Session: %s%s", sign, formatted)
            
            if earned > 0 then 
                BountyLabel.TextColor3 = Color3.fromRGB(0, 255, 100) -- Xanh lá (Tăng)
            elseif earned < 0 then 
                BountyLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Đỏ (Giảm)
            else 
                BountyLabel.TextColor3 = Color3.fromRGB(200, 200, 200) -- Trắng (Không đổi)
            end
        end
        
        BountyStat:GetPropertyChangedSignal("Value"):Connect(UpdateBountyUI)
        
        while task.wait(1) do
            UpdateBountyUI()
        end
    else
        BountyLabel.Text = "No Bounty Found"
    end
end)

RunService.RenderStepped:Connect(function()
    UpdatePingAndPred() 
    
    local syncTarget = GetSyncedTarget()
    
    local isSuspicious = CheckSuspiciousStatus(syncTarget)
    
    if isSuspicious then
        CurrentTarget = nil 
        StatusLabel.Text = "Anti-Sus: Target Glitched/Dead"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    else
        CurrentTarget = syncTarget
    end

    if CurrentTarget and CurrentTarget.Character then
        local hum = CurrentTarget.Character:FindFirstChild("Humanoid")
        local root = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
        
        if hum and root then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
            StatusLabel.Text = string.format("LOCKED: %s\nHP: %.0f%% | Dist: %.0f", CurrentTarget.Name, (hum.Health/hum.MaxHealth)*100, dist)
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            
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
    elseif not isSuspicious then
        StatusLabel.Text = "Status: Scanning...\nWaiting for sync"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)
