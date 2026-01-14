getgenv().Setting = {
    ["Team"] = "Pirate",
    ["Method Click"] = {["Click Gun"] = false, ["Click Melee"] = true, ["Click Sword"] = true, ["LowHealth"] = 7500, ["Delay Click"] = 0},
    ["Race V4"] = {["Enable"] = true},
    ["Webhook"] = {["Enabled"] = false,["Url Webhook"] = ""},
    ["Misc"] = {["AutoBuyRandomandStoreFruit"] = true,["AutoBuySurprise"] = true},
    ["SafeZone"] = {["Enable"] = true,["LowHealth"] = 4500,["MaxHealth"] = 8000,["Teleport Y"] = 2000},
    ["Method Use Skill"] = {["Use Random"] = true,["Use Number"] = false},
    ["Use random skill if player target low health"] = {["Enabled"] = true,["Low Health"] = 4000},
    ["Use Portal Teleport"] = false,
    ["Target Time"] = 20,
    ["Aim Prediction"] = 0.5,
    ["Select Region"] = {["Enabled"] = false,["Region"] = {["Singapore"] = true,["United States"] = false,["Netherlands"] = false,["Germany"] = false,["India"] = false,["Australia"] = false}},
    ["Ignore Devil Fruit"] = {"Human-Human","Portal-Portal"},
    ["Dodge Skill Player"] = true,
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
            ["Enable"] = false,
            ["Skills"] = {
                ["Z"] = {["Enable"] = true,["HoldTime"] = 0.3,["Number"] = 4},
                ["X"] = {["Enable"] = true,["HoldTime"] = 0.3,["Number"] = 6},
                ["C"] = {["Enable"] = true,["HoldTime"] = 0.3,["Number"] = 9},
                ["V"] = {["Enable"] = false,["HoldTime"] = 0.3,["Number"] = 0},
                ["F"] = {["Enable"] = true,["HoldTime"] = 0.3,["Number"] = 8},
            },
        },
        ["Gun"] = {
            ["Enable"] = false,
            ["Skills"] = {
                ["Z"] = {["Enable"] = true,["HoldTime"] = 0.3,["Number"] = 1},
                ["X"] = {["Enable"] = true,["HoldTime"] = 0.3,["Number"] = 7},
            },
        },
        ["Sword"] = {
            ["Enable"] = true,
            ["Skills"] = {
                ["Z"] = {["Enable"] = true,["HoldTime"] = 0.1,["Number"] = 0},
                ["X"] = {["Enable"] = true,["HoldTime"] = 0.1,["Number"] = 0},
            },
        },
    }
}

task.delay(5, function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local function rand(min, max)
        return min + math.random() * (max - min)
    end

    local function safeWait(t)
        if typeof(t) ~= "number" then t = 0.1 end
        task.wait(t)
    end

    local function PressSkillKey(key, holdTime)
        if not key then return end
        key = tostring(key):upper()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            safeWait(holdTime or 0)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end)
    end

    local function MouseClickOnce()
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            safeWait(0.04 + rand(0, 0.03))
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end

    local function dist(a, b)
        if not a or not b then return 9e9 end
        return (a - b).Magnitude
    end

    local function getMyBounty()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            for _, v in ipairs(ls:GetChildren()) do
                if string.lower(v.Name):find("bounty") then
                    return tonumber(v.Value) or 0, v
                end
            end
        end
        return 0, nil
    end

    local function getPlayerBounty(player)
        if not player then return 0 end
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            for _, v in ipairs(ls:GetChildren()) do
                if string.lower(v.Name):find("bounty") then
                    return tonumber(v.Value) or 0
                end
            end
        end
        return 0
    end

    local function FullCombo()
        if getgenv().Setting["Weapons"]["Sword"]["Enable"] then
            PressSkillKey("Z", getgenv().Setting["Weapons"]["Sword"]["Skills"]["Z"].HoldTime)
            safeWait(0.1 + rand(0, 0.03))
            PressSkillKey("X", getgenv().Setting["Weapons"]["Sword"]["Skills"]["X"].HoldTime)
        end
        if getgenv().Setting["Weapons"]["Melee"]["Enable"] then
            safeWait(0.1 + rand(0, 0.03))
            PressSkillKey("Z", getgenv().Setting["Weapons"]["Melee"]["Skills"]["Z"].HoldTime)
            safeWait(0.1 + rand(0, 0.03))
            PressSkillKey("X", getgenv().Setting["Weapons"]["Melee"]["Skills"]["X"].HoldTime)
            safeWait(0.1 + rand(0, 0.03))
            PressSkillKey("C", getgenv().Setting["Weapons"]["Melee"]["Skills"]["C"].HoldTime)
        end
    end

    task.spawn(function()
        while task.wait(0.25) do
            pcall(function()
                local Target = getgenv().Target
                if not Target or not Target.Parent then return end

                local targetPlayer = Players:GetPlayerFromCharacter(Target)
                if not targetPlayer then return end
                local targetBounty = getPlayerBounty(targetPlayer)

                if targetBounty > 4000000 then
                    getgenv().Target = nil
                    return
                end

                local th = Target:FindFirstChild("Humanoid")
                if not th or th.Health <= 0 then return end
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                if not Target:FindFirstChild("HumanoidRootPart") then return end

                local myHRP = char.HumanoidRootPart
                local targetHRP = Target.HumanoidRootPart
                local d = dist(myHRP.Position, targetHRP.Position)

                local FINISH_RANGE = 25
                local FINISH_HP = 4000

                if th.Health <= FINISH_HP and d <= FINISH_RANGE then
                    local preBounty = getMyBounty()
                    FullCombo()
                    MouseClickOnce()

                    local died = false
                    local conn = th.Died:Connect(function() died = true end)

                    local t0 = tick()
                    local gotBounty = false
                    while tick() - t0 < 4 do
                        if died then break end
                        local curBounty = getMyBounty()
                        if curBounty > (preBounty or 0) then
                            gotBounty = true
                            break
                        end
                        task.wait(0.1)
                    end

                    if conn then conn:Disconnect() end

                    if died and not gotBounty then
                        FullCombo()
                        MouseClickOnce()
                        local t1 = tick()
                        while tick() - t1 < 2 do
                            local curBounty = getMyBounty()
                            if curBounty > (preBounty or 0) then
                                gotBounty = true
                                break
                            end
                            task.wait(0.1)
                        end
                    end

                    safeWait(0.5 + rand(0, 0.3))
                end
            end)
        end
    end)
end)
