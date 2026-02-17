--/// CẤU HÌNH ///--
local Settings = {
    BoxColor_Enemy = Color3.fromRGB(255, 0, 0),    -- Màu Đỏ (Địch)
    BoxColor_Team  = Color3.fromRGB(0, 255, 0),    -- Màu Xanh Lá (Đồng đội)
    BoxThickness   = 2,                            -- Độ dày nét vẽ
    BoxTransparency = 0                            -- Độ trong suốt (0 là rõ nhất)
}

--/// DỊCH VỤ ///--
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--/// KHO CHỨA AN TOÀN ///--
-- Kiểm tra folder, nếu chưa có thì tạo
local StorageName = "ESP_Box_Holder_Safe"
local SafeStorage = CoreGui:FindFirstChild(StorageName) or Instance.new("Folder")
if not SafeStorage.Parent then
    SafeStorage.Name = StorageName
    SafeStorage.Parent = CoreGui
end

--/// HÀM HỖ TRỢ ///--

-- Kiểm tra đồng đội
local function IsTeammate(player)
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    return false 
end

-- Hàm cập nhật màu
local function UpdateBoxColor(stroke, player)
    if IsTeammate(player) then
        stroke.Color = Settings.BoxColor_Team
    else
        stroke.Color = Settings.BoxColor_Enemy
    end
end

--/// HÀM TẠO BOX CHO 1 NGƯỜI ///--
local function CreateBoxESP(player)
    
    local function ApplyToCharacter(char)
        -- Đợi phần gốc của nhân vật load xong
        local root = char:WaitForChild("HumanoidRootPart", 10)
        if not root then return end

        -- Đặt tên ID riêng để quản lý
        local espName = player.Name .. "_BoxESP"
        
        -- Xóa cái cũ nếu bị lỗi kẹt
        if SafeStorage:FindFirstChild(espName) then
            SafeStorage[espName]:Destroy()
        end

        -- 1. TẠO KHUNG CHỨA (BillboardGui)
        local bb = Instance.new("BillboardGui")
        bb.Name = espName
        bb.Adornee = root
        bb.Size = UDim2.new(4, 0, 5.5, 0) -- Kích thước hộp (Rộng 4, Cao 5.5)
        bb.StudsOffset = Vector3.new(0, 0, 0)
        bb.AlwaysOnTop = true
        bb.Parent = SafeStorage -- Giấu vào CoreGui

        -- 2. TẠO VIỀN HỘP (Frame + UIStroke)
        -- Dùng UIStroke sẽ đẹp và nhẹ hơn là tạo 4 cái Frame làm viền
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1 -- Trong suốt nền
        frame.Parent = bb

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = Settings.BoxThickness
        stroke.Transparency = Settings.BoxTransparency
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = frame

        -- 3. CẬP NHẬT MÀU
        UpdateBoxColor(stroke, player)

        -- Tự đổi màu nếu người chơi đổi team
        local teamConnection
        teamConnection = player:GetPropertyChangedSignal("Team"):Connect(function()
            if stroke.Parent then 
                UpdateBoxColor(stroke, player)
            else
                teamConnection:Disconnect()
            end
        end)

        -- 4. DỌN DẸP KHI NHÂN VẬT CHẾT/BIẾN MẤT
        -- Rất quan trọng: Khi nhân vật chết, BillboardGui vẫn còn trong CoreGui nếu không xóa
        local ancestryConnection
        ancestryConnection = char.AncestryChanged:Connect(function(_, parent)
            if not parent then
                bb:Destroy()
                if teamConnection then teamConnection:Disconnect() end
                if ancestryConnection then ancestryConnection:Disconnect() end
            end
        end)
    end

    -- Xử lý ngay nếu nhân vật đã có sẵn
    if player.Character then
        ApplyToCharacter(player.Character)
    end

    -- Xử lý khi nhân vật hồi sinh
    player.CharacterAdded:Connect(function(char)
        ApplyToCharacter(char)
    end)
end

--/// KHỞI CHẠY ///--

-- 1. Quét người chơi hiện có
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateBoxESP(player)
    end
end

-- 2. Đón người chơi mới
Players.PlayerAdded:Connect(function(player)
    CreateBoxESP(player)
end)

-- 3. Dọn dẹp khi thoát game
Players.PlayerRemoving:Connect(function(player)
    local espName = player.Name .. "_BoxESP"
    if SafeStorage:FindFirstChild(espName) then
        SafeStorage[espName]:Destroy()
    end
end)

-- 4. Cập nhật khi chính BẠN đổi team
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    -- Quét lại tất cả box để đổi màu
    for _, child in ipairs(SafeStorage:GetChildren()) do
        if child:IsA("BillboardGui") and child.Adornee then
            local player = Players:GetPlayerFromCharacter(child.Adornee)
            if player then
                local stroke = child:FindFirstChild("Frame") and child.Frame:FindFirstChild("UIStroke")
                if stroke then
                    UpdateBoxColor(stroke, player)
                end
            end
        end
    end
end)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui") -- Nơi an toàn để giấu ESP
local LocalPlayer = Players.LocalPlayer

-- Tạo một kho chứa ESP an toàn (Nằm ngoài tầm kiểm soát của Game)
local SafeStorageName = "ESP_Holder_Safe"
if CoreGui:FindFirstChild(SafeStorageName) then
    CoreGui[SafeStorageName]:Destroy()
end

local SafeStorage = Instance.new("Folder")
SafeStorage.Name = SafeStorageName
SafeStorage.Parent = CoreGui

-- Hàm tạo Highlight (Đã tách ra để dùng cho vòng lặp)
local function EnsureESP(player)
    if player == LocalPlayer then return end -- Bỏ qua bản thân
    
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local espName = player.Name .. "_ESP"
    local existingHL = SafeStorage:FindFirstChild(espName)

    -- TRƯỜNG HỢP 1: Chưa có ESP -> Tạo mới
    if not existingHL then
        local hl = Instance.new("Highlight")
        hl.Name = espName
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        
        -- Parent vào SafeStorage (Anti-cheat game không quét ở đây)
        hl.Parent = SafeStorage
        -- Adornee vào nhân vật (Hiển thị lên nhân vật)
        hl.Adornee = char
    
    -- TRƯỜNG HỢP 2: Đã có ESP nhưng bị gắn sai người (Do qua round mới)
    elseif existingHL.Adornee ~= char then
        existingHL.Adornee = char
    end
end

-- Kết nối sự kiện cơ bản (Để hoạt động ngay khi vào game)
for _, v in pairs(Players:GetPlayers()) do
    EnsureESP(v)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1) -- Đợi load nhân vật
        EnsureESP(player)
    end)
end)

-- Xử lý xóa ESP khi người chơi thoát
Players.PlayerRemoving:Connect(function(player)
    local espName = player.Name .. "_ESP"
    if SafeStorage:FindFirstChild(espName) then
        SafeStorage[espName]:Destroy()
    end
end)

-- =================================================================
-- PHẦN BẠN YÊU CẦU: VÒNG LẶP VÔ TẬN (KIỂM TRA LIÊN TỤC)
-- =================================================================
task.spawn(function()
    while true do
        -- Thời gian chờ giữa các lần quét (0.5 giây là vừa đủ nhanh và không lag)
        task.wait(0.5) 
        
        -- Quét tất cả người chơi
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                -- Nếu nhân vật tồn tại, gọi hàm đảm bảo ESP
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    EnsureESP(player)
                end
            end
        end
        
        -- Dọn dẹp ESP rác (Của người chơi đã chết hoặc thoát nhưng chưa kịp xóa)
        for _, child in pairs(SafeStorage:GetChildren()) do
            local playerName = string.gsub(child.Name, "_ESP", "")
            local player = Players:FindFirstChild(playerName)
            
            -- Nếu người chơi không còn tồn tại hoặc nhân vật đã mất -> Xóa ESP
            if not player or not player.Character then
                child:Destroy()
            end
        end
    end
end)
