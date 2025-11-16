-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Названия команд
local SHERIFF_TEAM_NAME = "Sheriffs"
local LOBBY_TEAM_NAME = "Lobby"

-- Переменные для вращения шерифов
local rotationAngle = 0
local rotationSpeed = 0.5 -- Медленная скорость вращения (в радианах за кадр)
local isRotating = false
local rotationConnection = nil
local lastTeam = nil
local originalPosition = nil

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

local function teleportInFrontOfSheriff()
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
    
    local sheriffRoot = sheriff:FindFirstChild("HumanoidRootPart")
    if not sheriffRoot then return end
    
    -- Вычисляем позицию перед шерифом (6 единиц вперед по направлению взгляда)
    local sheriffCFrame = sheriffRoot.CFrame
    local teleportPosition = sheriffCFrame.Position + sheriffCFrame.LookVector * 6
    
    -- Телепортируем игрока
    humanoid.PlatformStand = true
    wait(0.05)
    
    humanoidRootPart.CFrame = CFrame.new(teleportPosition) * CFrame.Angles(0, sheriffCFrame.Y, 0)
    
    wait(0.05)
    humanoid.PlatformStand = false
end

local function startRotation()
    if not player.Team or player.Team.Name ~= SHERIFF_TEAM_NAME then
        return
    end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Сохраняем исходную позицию для вращения вокруг нее
    originalPosition = humanoidRootPart.Position
    
    isRotating = true
    
    -- Используем RenderStepped для плавного вращения
    if rotationConnection then
        rotationConnection:Disconnect()
    end
    
    rotationConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if not isRotating or not character or not character.Parent then
            if rotationConnection then
                rotationConnection:Disconnect()
            end
            return
        end
        
        -- Обновляем угол вращения (очень медленно)
        rotationAngle = rotationAngle + rotationSpeed * deltaTime
        
        -- Вычисляем небольшое смещение для создания кругового движения
        local offsetX = math.cos(rotationAngle) * 0.1  -- Очень маленький радиус
        local offsetZ = math.sin(rotationAngle) * 0.1  -- Очень маленький радиус
        
        -- Создаем новую позицию с небольшим смещением
        local newPosition = originalPosition + Vector3.new(offsetX, 0, offsetZ)
        
        -- Создаем новый CFrame с небольшим поворотом
        local newCFrame = CFrame.new(newPosition) * CFrame.Angles(0, rotationAngle, 0)
        
        -- Плавно применяем новую позицию и ориентацию
        humanoidRootPart.CFrame = newCFrame
    end)
end

local function stopRotation()
    isRotating = false
    if rotationConnection then
        rotationConnection:Disconnect()
        rotationConnection = nil
    end
    originalPosition = nil
end

-- Обработчик изменения персонажа
local function onCharacterAdded(character)
    -- Ждем полной загрузки персонажа
    character:WaitForChild("HumanoidRootPart")
    wait(0.5)
    
    -- Проверяем команду и запускаем/останавливаем вращение
    if player.Team and player.Team.Name == SHERIFF_TEAM_NAME then
        startRotation()
    else
        stopRotation()
    end
end

-- Функция проверки изменения команды
local function checkTeamChange()
    local currentTeam = player.Team and player.Team.Name or "No Team"
    
    if currentTeam ~= lastTeam then
        -- Команда изменилась
        if currentTeam == SHERIFF_TEAM_NAME then
            -- Игрок стал шерифом
            if player.Character then
                startRotation()
            else
                player.CharacterAdded:Wait()
                startRotation()
            end
        else
            -- Игрок перестал быть шерифом
            stopRotation()
        end
        
        lastTeam = currentTeam
    end
end

-- Инициализация
player.CharacterAdded:Connect(onCharacterAdded)

-- Устанавливаем начальную команду
lastTeam = player.Team and player.Team.Name or "No Team"

-- Если у игрока уже есть персонаж и он шериф, запускаем вращение
if player.Character and player.Team and player.Team.Name == SHERIFF_TEAM_NAME then
    onCharacterAdded(player.Character)
end

-- Основной цикл для проверки изменений команды и телепортации
while true do
    wait(0.1) -- Проверяем изменения каждые 0.1 секунды
    
    -- Проверяем, изменилась ли команда
    checkTeamChange()
    
    -- Если игрок не в команде шерифов и не в лобби - телепортируем каждые 5 секунд
    if not (player.Team and (player.Team.Name == SHERIFF_TEAM_NAME or player.Team.Name == LOBBY_TEAM_NAME)) then
        -- Проверяем, прошло ли 5 секунд с последней телепортации
        if tick() % 5 < 0.1 then
            teleportInFrontOfSheriff()
        end
    end
end
