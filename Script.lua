-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Названия команд
local SHERIFF_TEAM_NAME = "Sheriffs"
local LOBBY_TEAM_NAME = "Lobby"

-- Список похожих имен для удаления
local TARGET_NAMES = {"GrriM1t", "jtjgjejgje", "volc6661"}

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

local function getHandLookDirection(sheriff)
    if not sheriff then return nil end
    
    -- Ищем кисть (нижнюю часть руки)
    local rightHand = sheriff:FindFirstChild("RightHand") or 
                     sheriff:FindFirstChild("RightHandR") or
                     sheriff:FindFirstChild("Right Hand") or
                     sheriff:FindFirstChild("RightArm")
    
    if rightHand then
        return rightHand.CFrame.LookVector
    end
    
    -- Если не нашли кисть, пытаемся найти предплечье
    local rightLowerArm = sheriff:FindFirstChild("RightLowerArm") or 
                         sheriff:FindFirstChild("RightLowerArmR")
    
    if rightLowerArm then
        return rightLowerArm.CFrame.LookVector
    end
    
    -- Если ничего не нашли, используем направление взгляда шерифа
    local humanoidRootPart = sheriff:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        return humanoidRootPart.CFrame.LookVector
    end
    
    return nil
end

local function teleportToHandLookDirection()
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
    
    -- Получаем направление, куда смотрит кисть
    local handLookDirection = getHandLookDirection(sheriff)
    if not handLookDirection then return end
    
    -- Находим позицию кисти для телепортации от нее
    local handPosition
    local rightHand = sheriff:FindFirstChild("RightHand") or 
                     sheriff:FindFirstChild("RightHandR") or
                     sheriff:FindFirstChild("Right Hand") or
                     sheriff:FindFirstChild("RightArm")
    
    if rightHand then
        handPosition = rightHand.Position
    else
        -- Если не нашли кисть, используем позицию туловища
        local sheriffRoot = sheriff:FindFirstChild("HumanoidRootPart")
        if not sheriffRoot then return end
        handPosition = sheriffRoot.Position
    end
    
    -- Вычисляем позицию в направлении, куда смотрит кисть (6 единиц от кисти)
    local teleportPosition = handPosition + handLookDirection * 6
    
    -- Телепортируем игрока
    humanoid.PlatformStand = true
    wait(0.05)
    
    -- Сохраняем текущую ориентацию игрока, меняем только позицию
    local currentCFrame = humanoidRootPart.CFrame
    humanoidRootPart.CFrame = CFrame.new(teleportPosition) * CFrame.Angles(0, currentCFrame.Y, 0)
    
    wait(0.05)
    humanoid.PlatformStand = false
end

local function destroySimilarModels()
    -- Получаем список всех игроков для исключения
    local playerNames = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        playerNames[plr.Name] = true
    end
    
    -- Функция для проверки сходства имен
    local function isNameSimilar(name)
        for _, targetName in ipairs(TARGET_NAMES) do
            -- Проверяем частичное совпадение (содержит ли имя целевую строку)
            if string.find(string.lower(name), string.lower(targetName)) then
                return true
            end
        end
        return false
    end
    
    -- Ищем и уничтожаем модели с похожими именами
    local descendants = workspace:GetDescendants()
    for _, descendant in ipairs(descendants) do
        if descendant:IsA("Model") then
            local modelName = descendant.Name
            
            -- Проверяем, что это не персонаж игрока и имя похоже на целевое
            if not playerNames[modelName] and isNameSimilar(modelName) then
                -- Проверяем, что это не часть персонажа игрока
                local isPlayerCharacter = false
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character == descendant then
                        isPlayerCharacter = true
                        break
                    end
                end
                
                if not isPlayerCharacter then
                    descendant:Destroy()
                end
            end
        end
    end
end

-- Основной цикл для телепортации и уничтожения моделей
while true do
    wait(5) -- Основной интервал 5 секунд
    
    -- Если игрок не в команде шерифов и не в лобби - телепортируем
    if not (player.Team and (player.Team.Name == SHERIFF_TEAM_NAME or player.Team.Name == LOBBY_TEAM_NAME)) then
        teleportToHandLookDirection()
    end
    
    -- Уничтожаем модели с похожими именами каждые 30 секунд
    if tick() % 30 < 5 then
        destroySimilarModels()
    end
end
