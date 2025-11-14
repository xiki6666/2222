-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function teleportCharacter()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and humanoidRootPart then
        -- Временно отключаем физику
        humanoid.PlatformStand = true
        wait(0.1)
        
        -- Телепортируем
        humanoidRootPart.CFrame = CFrame.new(50.79, 3.00, 564.22)
        
        -- Включаем физику обратно
        wait(0.1)
        humanoid.PlatformStand = false
    end
end

while true do
    wait(5)
    teleportCharacter()
end
