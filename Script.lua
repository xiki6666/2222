-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

while true do
    wait(5)
    
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            -- Создаем твин для плавного перемещения
            local tweenInfo = TweenInfo.new(
                0.5, -- длительность
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out,
                0, -- повторения
                false, -- отмена при отключении
                0 -- задержка
            )
            
            local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
                Position = Vector3.new(50.79, 3.00, 564.22)
            })
            
            tween:Play()
        end
    end
end
