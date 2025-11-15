-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Название команды шерифов (можете изменить если нужно)
local SHERIFF_TEAM_NAME = "Sheriffs"

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

local function teleportInsideSheriff()
    -- Проверяем, что игрок не в команде шерифов
    if player.Team and player.Team.Name == SHERIFF_TEAM_NAME then
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
    
    -- Телепортируем игрока прямо в позицию шерифа
    humanoid.PlatformStand = true
    wait(0.05)
    
    -- Устанавливаем ту же позицию и ориентацию, что и у шерифа
    humanoidRootPart.CFrame = sheriffRoot.CFrame
    
    wait(0.05)
    humanoid.PlatformStand = false
end

-- Основной цикл телепортации
while true do
    wait(5)
    teleportInsideSheriff()
end
