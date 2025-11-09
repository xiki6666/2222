local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

-- Функция для ожидания появления персонажа
local function waitForCharacter()
    local character = player.Character
    if character then
        return character
    end
    return player.CharacterAdded:Wait()
end

-- Настройки телепортации
local teleportPoints = {
    Vector3.new(172.26, 47.47, 426.68),
    Vector3.new(170.43, 3.66, 474.95)
}

-- Функция моментальной телепортации
local function instantTeleport(targetPosition)
    local character = waitForCharacter()
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
    end
end

-- Основной цикл телепортации
while true do
    for index, point in ipairs(teleportPoints) do
        instantTeleport(point)
        wait(1) -- Ожидание 1 секунда между телепортами
    end
    
    -- Автоматический перезаход на другой сервер
    local success, error = pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
    
    if not success then
        wait(5) -- Если ошибка, ждем 5 секунд перед повторной попыткой
    end
end
