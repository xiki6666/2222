-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Названия команд
local SHERIFF_TEAM_NAME = "Sheriffs"
local LOBBY_TEAM_NAME = "Lobby"

local function findClosestSheriff()
    local character = player.Character
    if not character then return nil end
    
    local myPosition = character:GetPivot().Position
    local closestSheriff = nil
    local closestDistance = math.huge
    
    -- Ищем всех игроков в команде шерифов
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Team and otherPlayer.Team.Name == SHERIFF_TEAM_NAME then
            local sheriffCharacter = otherPlayer.Character
            if sheriffCharacter then
                local sheriffPosition = sheriffCharacter:GetPivot().Position
                local distance = (myPosition - sheriffPosition).Magnitude
                
                if distance < closestDistance then
                    closestDistance = distance
                    closestSheriff = sheriffCharacter
                end
            end
        end
    end
    
    return closestSheriff
end

local function getTeleportPosition(sheriff)
    if not sheriff then return nil end
    
    -- Ищем кисть (нижнюю часть руки)
    local rightHand = sheriff:FindFirstChild("RightHand") or 
                     sheriff:FindFirstChild("RightHandR") or
                     sheriff:FindFirstChild("Right Hand") or
                     sheriff:FindFirstChild("RightArm")
    
    if not rightHand then
        -- Если не нашли кисть, используем позицию туловища
        local sheriffRoot = sheriff:FindFirstChild("HumanoidRootPart")
        if not sheriffRoot then return nil end
        return sheriffRoot.Position + sheriffRoot.CFrame.LookVector * 6
    end
    
    -- Получаем CFrame кисти
    local handCFrame = rightHand.CFrame
    local handPosition = rightHand.Position
    
    -- Получаем направление, куда смотрит кисть (LookVector)
    local lookDirection = handCFrame.LookVector
    
    -- Получаем правое направление кисти (RightVector)
    local rightDirection = handCFrame.RightVector
    
    -- Вычисляем позицию телепортации:
    -- 1. Сначала идем на 6 единиц вперед от кисти по направлению взгляда
    -- 2. Затем смещаемся на 2 единицы вправо от этого направления
    local teleportPosition = handPosition + lookDirection * 6 + rightDirection * 2
    
    return teleportPosition
end

local function teleportToRightOfHandDirection()
    -- Проверяем, что игрок не в команде шерифов и не в лобби
    if player.Team and (player.Team.Name == SHERIFF_TEAM_NAME or player.Team.Name == LOBBY_TEAM_NAME) then
        return
    end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not humanoidRootPart then return end
    
    -- Находим ближайшего шерифа
    local sheriff = findClosestSheriff()
    if not sheriff then return end
    
    -- Получаем позицию для телепортации (чуть правее от направления кисти)
    local teleportPosition = getTeleportPosition(sheriff)
    if not teleportPosition then return end
    
    -- Телепортируем игрока
    humanoid.PlatformStand = true
    wait(0.05)
    
    -- Сохраняем текущую ориентацию игрока, меняем только позицию
    local currentCFrame = humanoidRootPart.CFrame
    humanoidRootPart.CFrame = CFrame.new(teleportPosition) * CFrame.Angles(0, currentCFrame.Y, 0)
    
    wait(0.05)
    humanoid.PlatformStand = false
end

-- Основной цикл для телепортации
while true do
    wait(5) -- Телепортация каждые 5 секунд
    
    -- Если игрок не в команде шерифов и не в лобби - телепортируем
    if not (player.Team and (player.Team.Name == SHERIFF_TEAM_NAME or player.Team.Name == LOBBY_TEAM_NAME)) then
        teleportToRightOfHandDirection()
    end
end
