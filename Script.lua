local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Настройки телепортации
local teleportPoints = {
    Vector3.new(172.26, 47.47, 426.68),
    Vector3.new(170.43, 3.66, 474.95)
}

-- Функция моментальной телепортации
local function instantTeleport(targetPosition)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
end

-- Основной цикл телепортации
while true do
    for index, point in ipairs(teleportPoints) do
        instantTeleport(point)
        wait(2) -- Ожидание между точками
    end
    
    -- Автоматический перезаход на другой сервер
    TeleportService:Teleport(game.PlaceId, player)
    wait(2) -- Задержка перед повторной попыткой если телепортация не удалась
end
