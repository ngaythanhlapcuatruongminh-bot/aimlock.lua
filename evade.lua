local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Hàm để tìm và teleport đến người bị gục gần nhất (hoặc bất kỳ ai)
local function teleportToDowned()
    local myCharacter = LocalPlayer.Character
    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then return end

    -- Duyệt qua tất cả người chơi
    for _, player in pairs(Players:GetPlayers()) do
        -- Kiểm tra điều kiện: Không phải là chính mình và nhân vật đã tải xong
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            
            -- Kiểm tra xem người đó có đang bị gục không
            -- Lưu ý: Tên Attribute "Downed" có thể thay đổi tùy theo bản cập nhật của game
            local isDowned = player.Character:GetAttribute("Downed")
            
            if isDowned then
                -- Thực hiện Teleport
                -- Cảnh báo: Việc gán CFrame trực tiếp khoảng cách xa sẽ kích hoạt Anti-cheat
                myCharacter.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                
                print("Đã teleport đến: " .. player.Name)
                break -- Dừng lại sau khi tìm thấy 1 người để tránh lỗi
            end
        end
    end
end

-- Cách sử dụng: Gọi hàm (hoặc gắn vào phím tắt)
-- teleportToDowned()
