getgenv().Setting = {
    ["Team"] = "Pirate",

    ["Method Click"] = {
        ["Click Gun"] = true,
        ["Click Melee"] = false,
        ["Click Sword"] = false,
        ["Click Fruit"] = true,
        ["LowHealth"] = 0,
        ["Delay Click"] = 0.01
    },

    ["Hitbox"] = {
        ["Enabled"] = true,
        ["Size"] = 45,
        ["Transparency"] = 1,
        ["TeamCheck"] = true,
        ["CheckAlive"] = true
    },

    ["Fast Attack"] = {
        ["Enabled"] = true,
        ["Attack Speed"] = 0.002,
        ["Animation Speed"] = 3.5,
        ["Use Cooldown Bypass"] = true
    },

    ["Fast Fly"] = {
        ["Enabled"] = true,
        ["Speed"] = 500
    },

    ["FPS Lock"] = {
        ["Enabled"] = true,
        ["FPS"] = 120
    },

    ["Race V4"] = {
        ["Enable"] = true
    },

    ["Webhook"] = {
        ["Enabled"] = false,
        ["Url Webhook"] = ""
    },

    ["Misc"] = {
        ["AutoBuyRandomandStoreFruit"] = true,
        ["AutoBuySurprise"] = false,
    },

    ["SafeZone"] = {
        ["Enable"] = true,
        ["LowHealth"] = 1500,
        ["MaxHealth"] = 3000,
        ["Teleport Y"] = 300,
    },

    ["Method Use Skill"] = {
        ["Use Random"] = true,
        ["Use Number"] = false
    },

    ["Use random skill if player target low health"] = {
        ["Enabled"] = true,
        ["Low Health"] = 4000,
    },

    ["Use Portal Teleport"] = false,
    ["Target Time"] = 30,
    ["Aim Prediction"] = 0.7,

    ["Select Region"] = {
        ["Enabled"] = false,
        ["Region"] = {
            ["Singapore"] = true,
            ["United States"] = false,
            ["Netherlands"] = false,
            ["Germany"] = false,
            ["India"] = false,
            ["Australia"] = false
        }
    },

    ["Ignore Devil Fruit"] = {
        "Human-Human",
        "Portal-Portal"
    },

    ["Dodge Skill Player"] = true,
    ["Spam Dash"] = false,

    ["Weapons"] = {
        ["Melee"] = {
            ["Enable"] = true,
            ["Skills"] = {
                ["Z"] = {["Enable"] = true,["HoldTime"] = 0,["Number"] = 2},
                ["X"] = {["Enable"] = true,["HoldTime"] = 0,["Number"] = 3},
                ["C"] = {["Enable"] = true,["HoldTime"] = 0,["Number"] = 5},
            },
        },
        ["Blox Fruit"] = {
            ["Enable"] = true,
            ["Skills"] = {
                ["Z"] = {["Enable"] = true,["HoldTime"] = 0.2,["Number"] = 4}, 
                ["X"] = {["Enable"] = true,["HoldTime"] = 0.2,["Number"] = 6},
                ["C"] = {["Enable"] = true,["HoldTime"] = 0.2,["Number"] = 9},
                ["V"] = {["Enable"] = false,["HoldTime"] = 0.2,["Number"] = 0},
                ["F"] = {["Enable"] = true,["HoldTime"] = 0.2,["Number"] = 8},
            },
        },
        ["Gun"] = {
            ["Enable"] = true,
            ["Skills"] = {
                ["Z"] = {["Enable"] = true,["HoldTime"] = 0.2,["Number"] = 1},
                ["X"] = {["Enable"] = true,["HoldTime"] = 0.2,["Number"] = 7},
            },
        },
        ["Sword"] = {
            ["Enable"] = true,
            ["Skills"] = {
                ["Z"] = {["Enable"] = true,["HoldTime"] = 0.15,["Number"] = 0},
                ["X"] = {["Enable"] = true,["HoldTime"] = 0.15,["Number"] = 0},
            },
        },
    }
}

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Client = Players.LocalPlayer

local function getPing()
    return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
end

local function isStunned()
    local char = Client.Character
    if not char then return true end
    if char:GetAttribute("Stun") or char:GetAttribute("Busy") or char:GetAttribute("NoAttack") then 
        return true 
    end
    local hum = char:FindFirstChild("Humanoid")
    if hum and (hum:GetState() == Enum.HumanoidStateType.PlatformStanding or hum:GetState() == Enum.HumanoidStateType.Ragdoll) then
        return true
    end
    return false
end

local function getRandomDelay()
    return math.random(80, 150) / 1000 
end

task.spawn(function()
    local lastClick = 0
    RunService.Heartbeat:Connect(function()
        if isStunned() then return end -- Nếu bị choáng thì dừng (Fix Sus)
        
        local delayTime = 0.2
        if getgenv().IsFinishing then 
            delayTime = 0.45 -- Nếu đang kết liễu (máu thấp) thì click chậm lại
        end

        if tick() - lastClick > delayTime then
            pcall(function()
                local char = Client.Character
                if not char then return end
                local tool = char:FindFirstChildOfClass("Tool")

                if tool and tool.ToolTip == "Blox Fruit" then
                    local viewport = workspace.CurrentCamera.ViewportSize
                    local x, y = viewport.X / 2, viewport.Y / 2
                    
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
                    task.wait(0.05) 
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
                    lastClick = tick()
                end
            end)
        end
    end)
end)

task.delay(5, function() 
    local function safeWait(t)
        local ping = getPing()
        local extra = 0
        if ping > 150 then extra = 0.2 end 
        if ping > 300 then extra = 0.5 end 
        task.wait((t or 0.1) + extra)
    end

    local function PressSkillKey(key, holdTime)
        if not key or isStunned() then return end 
        key = tostring(key):upper()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            safeWait(holdTime or 0.15)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end)
    end

    local function dist(a, b)
        if not a or not b then return 9e9 end
        return (a - b).Magnitude
    end

    task.spawn(function()
        local function getBloxFruitBounty(player)
            if not player or not player:FindFirstChild("leaderstats") then return 0 end
            local pirateBounty = player.leaderstats:FindFirstChild("Bounty")
            local marineHonor = player.leaderstats:FindFirstChild("Honor")
            return math.max((pirateBounty and pirateBounty.Value) or 0, (marineHonor and marineHonor.Value) or 0)
        end

        while task.wait(1) do
            pcall(function()
                local rawTarget = getgenv().Target
                if rawTarget then
                    local targetPlayer = nil
                    if typeof(rawTarget) == "string" then
                         targetPlayer = game:GetService("Players"):FindFirstChild(rawTarget)
                    elseif typeof(rawTarget) == "Instance" and rawTarget:IsA("Model") then
                         targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(rawTarget)
                    else
                         targetPlayer = rawTarget
                    end

                    if targetPlayer and targetPlayer:IsA("Player") then
                        if getBloxFruitBounty(targetPlayer) > 10000000 then 
                            getgenv().Target = nil
                        end
                    end
                end
            end)
        end
    end)

    task.spawn(function()
        while task.wait(0.1) do
            pcall(function()
                local Target = getgenv().Target
                if Target and typeof(Target) == "Instance" and Target:IsA("Player") then
                    Target = Target.Character
                end
                if not Target then getgenv().IsFinishing = false; return end

                local th = Target:FindFirstChild("Humanoid")
                if not th or th.Health <= 0 then getgenv().IsFinishing = false; return end
                
                local char = Client.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                if not Target:FindFirstChild("HumanoidRootPart") then return end

                local myHRP = char.HumanoidRootPart
                local targetHRP = Target.HumanoidRootPart
                local d = dist(myHRP.Position, targetHRP.Position)

                local COMBAT_RANGE = 40
                local LOW_HP_THRESHOLD = 3000 
                
                if d <= COMBAT_RANGE then
                    if th.Health < LOW_HP_THRESHOLD then
                        getgenv().IsFinishing = true 
                        
                        if tick() % 2 == 0 then 
                             if getgenv().Setting["Weapons"]["Melee"]["Enable"] then
                                PressSkillKey("Z", 0.1)
                             end
                        end
                        task.wait(0.2)
                    else
                        getgenv().IsFinishing = false
                        
                        if getgenv().Setting["Weapons"]["Sword"]["Enable"] then
                            PressSkillKey("Z", 0.15)
                            safeWait(0.2) 
                            PressSkillKey("X", 0.15)
                        end
                        
                        safeWait(0.25)
                        
                        if getgenv().Setting["Weapons"]["Melee"]["Enable"] then
                            PressSkillKey("Z", 0.15)
                            safeWait(0.2)
                            PressSkillKey("X", 0.15)
                            safeWait(0.2)
                            PressSkillKey("C", 0.15)
                        end
                        
                        safeWait(0.5) 
                    end
                else
                    getgenv().IsFinishing = false
                end
            end)
        end
    end)
end)
