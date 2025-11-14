local TARGET_POSITION = Vector3.new(50.79, 3.00, 564.22)
local TELEPORT_INTERVAL = 5 -- Секунды

-- Вариант 1: Для телепортации модели, к которой прикреплен скрипт
local function teleportPart()
    while true do
        wait(TELEPORT_INTERVAL)
        
        -- Проверяем существование родителя
        if script.Parent then
            if script.Parent:IsA("BasePart") then
                script.Parent.Position = TARGET_POSITION
            elseif script.Parent:IsA("Model") then
                local humanoidRootPart = script.Parent:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.Position = TARGET_POSITION
                end
            end
        end
    end
end

-- Вариант 2: Для телепортации игрока (LocalScript в StarterPlayer)
local function teleportPlayer()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    -- Ждем появления персонажа
    local character = player.Character or player.CharacterAdded:Wait()
    
    while true do
        wait(TELEPORT_INTERVAL)
        
        character = player.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.Position = TARGET_POSITION
            end
        end
    end
end

-- Выберите нужный вариант:
teleportPart() -- Для объектов
-- teleportPlayer() -- Для игрока (раскомментируйте если используете LocalScript)
