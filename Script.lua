-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Названия команд
local SHERIFF_TEAM_NAME = "Sheriffs"
local LOBBY_TEAM_NAME = "Lobby"

-- Переменные для Lobby телепортации
local lobbyCounter = 0
local lastTeam = nil
local lobbyTeleportCycle = 0

-- Координаты для Lobby
local lobbyPositions = {
    Vector3.new(172.26, 47.47, 426.68),
    Vector3.new(170.43, 3.66, 474.95)
}

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
    -- 2. Затем смещаемся на 4 единицы вправо от этого направления
    local teleportPosition = handPosition + lookDirection * 6 + rightDirection * 4
    
    return teleportPosition
end

local function teleportNonSheriffNonLobby()
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

local function teleportLobby()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not humanoidRootPart then return end
    
    -- Определяем, какую координату использовать
    local positionIndex
    if lobbyCounter < 4 then
        positionIndex = 1
    else
        positionIndex = 2
    end
    
    local teleportPosition = lobbyPositions[positionIndex]
    
    -- Телепортируем игрока
    humanoid.PlatformStand = true
    wait(0.05)
    
    humanoidRootPart.CFrame = CFrame.new(teleportPosition)
    
    wait(0.05)
    humanoid.PlatformStand = false
    
    -- Увеличиваем счетчик
    lobbyCounter = lobbyCounter + 1
    
    -- Если прошли полный цикл (4 раза в первой точке + 4 раза во второй)
    if lobbyCounter >= 8 then
        lobbyCounter = 0
        lobbyTeleportCycle = lobbyTeleportCycle + 1
    end
end

-- Функция для проверки изменения команды
local function checkTeamChange()
    local currentTeam = player.Team and player.Team.Name or "No Team"
    
    if currentTeam ~= lastTeam then
        -- Команда изменилась
        if currentTeam == LOBBY_TEAM_NAME then
            -- Игрок стал лобби, сбрасываем счетчики
            lobbyCounter = 0
            lobbyTeleportCycle = 0
        end
        
        lastTeam = currentTeam
    end
end

-- Основной цикл
while true do
    wait(5) -- Проверяем каждые 5 секунд
    
    -- Проверяем изменение команды
    checkTeamChange()
    
    local currentTeam = player.Team and player.Team.Name or "No Team"
    
    if currentTeam == SHERIFF_TEAM_NAME then
        -- Игрок в команде шерифов - ничего не делаем
    elseif currentTeam == LOBBY_TEAM_NAME then
        -- Игрок в лобби - телепортируем в точки лобби
        teleportLobby()
    else
        -- Игрок не в шерифах и не в лобби - телепортируем к руке шерифа
        teleportNonSheriffNonLobby()
    end
end
