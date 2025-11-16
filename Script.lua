-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Названия команд
local SHERIFF_TEAM_NAME = "Sheriffs"
local LOBBY_TEAM_NAME = "Lobby"

-- Переменные для вращения шерифов
local rotationAngle = 0
local rotationSpeed = 2 -- Скорость вращения (в градусах за кадр)
local isRotating = false
local bodyGyro = nil

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
    
    -- Создаем BodyGyro для плавного вращения
    if not bodyGyro then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 1000
        bodyGyro.D = 100
        bodyGyro.MaxTorque = Vector3.new(0, 4000, 0)
        bodyGyro.Parent = humanoidRootPart
    end
    
    isRotating = true
    
    -- Используем RenderStepped для плавного вращения
    local connection
    connection = RunService.RenderStepped:Connect(function(deltaTime)
        if not isRotating or not character or not character.Parent then
            connection:Disconnect()
            return
        end
        
        -- Обновляем угол вращения
        rotationAngle = rotationAngle + math.rad(rotationSpeed) * deltaTime * 60
        
        -- Устанавливаем вращение через BodyGyro
        if bodyGyro and bodyGyro.Parent then
            bodyGyro.CFrame = CFrame.Angles(0, rotationAngle, 0)
        else
            connection:Disconnect()
        end
    end)
end

local function stopRotation()
    isRotating = false
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

-- Обработчик изменения команды
local function onTeamChanged()
    if player.Team and player.Team.Name == SHERIFF_TEAM_NAME then
        -- Ждем появления персонажа
        if player.Character then
            startRotation()
        else
            player.CharacterAdded:Wait()
            startRotation()
        end
    else
        stopRotation()
    end
end

-- Обработчик изменения персонажа
local function onCharacterAdded(character)
    if player.Team and player.Team.Name == SHERIFF_TEAM_NAME then
        wait(1) -- Ждем полной загрузки персонажа
        startRotation()
    end
end

-- Инициализация
player.TeamChanged:Connect(onTeamChanged)
player.CharacterAdded:Connect(onCharacterAdded)

-- Запускаем начальную проверку
onTeamChanged()

-- Основной цикл для телепортации не-шерифов
while true do
    wait(0.1)
    
    -- Если игрок не в команде шерифов и не в лобби - телепортируем каждые 5 секунд
    if not (player.Team and (player.Team.Name == SHERIFF_TEAM_NAME or player.Team.Name == LOBBY_TEAM_NAME)) then
        -- Проверяем, прошло ли 5 секунд с последней телепортации
        if tick() % 5 < 0.1 then
            teleportInFrontOfSheriff()
        end
    end
end
