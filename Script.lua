-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Названия команд
local SHERIFF_TEAM_NAME = "Sheriffs"
local LOBBY_TEAM_NAME = "Lobby"

-- Переменные для вращения шерифов
local rotationAngle = 0
local rotationSpeed = 2 -- Скорость вращения (в градусах за шаг)

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

local function rotateSheriff()
    -- Проверяем, что игрок в команде шерифов
    if not player.Team or player.Team.Name ~= SHERIFF_TEAM_NAME then
        return
    end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Увеличиваем угол вращения
    rotationAngle = rotationAngle + rotationSpeed
    
    -- Преобразуем угол в радианы
    local radians = math.rad(rotationAngle)
    
    -- Создаем новый CFrame с вращением вокруг оси Y
    local currentPosition = humanoidRootPart.Position
    humanoidRootPart.CFrame = CFrame.new(currentPosition) * CFrame.Angles(0, radians, 0)
end

-- Основной цикл
while true do
    wait(0.1) -- Уменьшаем интервал для плавного вращения
    
    -- Если игрок в команде шерифов - вращаем его
    if player.Team and player.Team.Name == SHERIFF_TEAM_NAME then
        rotateSheriff()
    -- Если игрок не в команде шерифов и не в лобби - телепортируем каждые 5 секунд
    elseif not (player.Team and player.Team.Name == LOBBY_TEAM_NAME) then
        -- Проверяем, прошло ли 5 секунд с последней телепортации
        if tick() % 5 < 0.1 then -- Примерно каждые 5 секунд
            teleportInFrontOfSheriff()
        end
    end
end
