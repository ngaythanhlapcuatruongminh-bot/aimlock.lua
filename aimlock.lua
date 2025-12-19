local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().AutoConfig = {
    Range = 2500,                
    Prediction = 0.135,         
    AimPart = "HumanoidRootPart",
    TeamCheck = false,           
    Smoothness = false          
}

local CurrentTarget = nil

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Auto CamLock";
        Text = "Active! Searching targets...";
        Duration = 3;
    })
end)

local function IsValidTarget(player)
    if not player or not player.Parent or player == LocalPlayer then return false end
    
    local char = player.Character
    if not char then return false end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    if not root or not hum or hum.Health <= 0 then return false end
    
    if getgenv().AutoConfig.TeamCheck and player.Team == LocalPlayer.Team then
        return false
    end
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot then
        local dist = (myRoot.Position - root.Position).Magnitude
        if dist > getgenv().AutoConfig.Range then return false end
    end
    
    return true
end

local function GetNearestTarget()
    local nearestDist = getgenv().AutoConfig.Range
    local nearestPlayer = nil
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local targetRoot = player.Character.HumanoidRootPart
            local dist = (myRoot.Position - targetRoot.Position).Magnitude
            
            if dist < nearestDist then
                nearestDist = dist
                nearestPlayer = player
            end
        end
    end
    return nearestPlayer
end

RunService.RenderStepped:Connect(function()
    if not IsValidTarget(CurrentTarget) then
        CurrentTarget = nil -- Reset
        
        local newTarget = GetNearestTarget()
        if newTarget then
            CurrentTarget = newTarget
        end
    end

    if CurrentTarget and CurrentTarget.Character then
        local targetRoot = CurrentTarget.Character:FindFirstChild(getgenv().AutoConfig.AimPart)
        
        if targetRoot then
            local currentCamPos = Camera.CFrame.Position
            
            local velocity = targetRoot.AssemblyLinearVelocity
            local predictedPos = targetRoot.Position + (velocity * getgenv().AutoConfig.Prediction)
            
            if getgenv().AutoConfig.Smoothness then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(currentCamPos, predictedPos), 0.2)
            else
                Camera.CFrame = CFrame.new(currentCamPos, predictedPos)
            end
        end
    end
end)
