local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")

-- 1. Gửi thông báo để bạn biết script đã chạy
StarterGui:SetCore("SendNotification", {
    Title = "Auto Revive Đang Chạy!";
    Text = "Đang quét người bị gục...";
    Duration = 5;
})

-- 2. Vòng lặp vĩnh cửu (Chạy liên tục không ngừng)
task.spawn(function()
    while true do
        task.wait(0.5) -- Nghỉ 0.5 giây mỗi lần quét để đỡ lag máy

        pcall(function() -- Dùng pcall để nếu có lỗi script không bị dừng
            -- Kiểm tra nhân vật của mình có tồn tại không
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                
                local foundDowned = false

                -- Duyệt qua tất cả người chơi trong server
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        
                        -- Kiểm tra xem người đó có bị gục không
                        local isDowned = player.Character:GetAttribute("Downed")
                        
                        if isDowned then
                            foundDowned = true
                            
                            -- A. THỰC HIỆN TELEPORT
                            -- Bay đến vị trí người đó (cao hơn 3 đơn vị để không bị kẹt)
                            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                            
                            -- B. THỰC HIỆN CỨU (Giữ phím E)
                            -- Evade cần giữ phím E khoảng 3-4 giây để cứu xong
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game) -- Nhấn xuống
                            task.wait(4) -- Giữ trong 4 giây (đợi thanh cứu chạy xong)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) -- Thả ra
                            
                            -- Sau khi cứu xong 1 người, vòng lặp sẽ quay lại từ đầu để tìm người tiếp theo
                            break 
                        end
                    end
                end
                
                -- Nếu không tìm thấy ai, nhân vật sẽ đứng yên (hoặc bạn có thể tự chạy)
            end
        end)
    end
end)
