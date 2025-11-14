-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

while true do
    wait(5)
    
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            -- Отключаем физику на момент телепортации
            humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            -- Телепортируем всю модель целиком
            local offset = humanoidRootPart.Position - character:GetPivot().Position
            character:PivotTo(CFrame.new(Vector3.new(50.79, 3.00, 564.22) + offset))
        end
    end
end
