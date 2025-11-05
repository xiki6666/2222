local player = game.Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")
local playerGui = player:WaitForChild("PlayerGui")

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProximityPromptGUI"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 60)
frame.Position = UDim2.new(0.5, -75, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Parent = screenGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0.6, 0)
toggleBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggleBtn.Text = "ВЫКЛ"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = frame

-- Переменные состояния
local enabled = false
local originalDurations = {}

-- Функция для применения изменений ко всем промптам
local function updateAllPrompts()
    for _, prompt in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if enabled then
                -- Сохраняем оригинальное значение и устанавливаем 0
                if not originalDurations[prompt] then
                    originalDurations[prompt] = prompt.HoldDuration
                end
                prompt.HoldDuration = 0
            else
                -- Восстанавливаем оригинальное значение
                if originalDurations[prompt] then
                    prompt.HoldDuration = originalDurations[prompt]
                end
            end
        end
    end
end

-- Обработчик новых ProximityPrompt
local function onDescendantAdded(descendant)
    if descendant:IsA("ProximityPrompt") then
        if enabled then
            -- Если режим включен, сразу применяем изменения к новому промпту
            originalDurations[descendant] = descendant.HoldDuration
            descendant.HoldDuration = 0
        end
    end
end

-- Подписываемся на событие добавления новых объектов
game:GetService("Workspace").DescendantAdded:Connect(onDescendantAdded)

-- Обработка существующих ProximityPrompt при запуске
updateAllPrompts()

-- Функция переключения состояния
local function toggleProximityPrompts()
    enabled = not enabled
    
    if enabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        toggleBtn.Text = "ВКЛ"
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        toggleBtn.Text = "ВЫКЛ"
    end
    
    -- Применяем изменения ко всем промптам
    updateAllPrompts()
end

-- Обработчик клика по кнопке
toggleBtn.MouseButton1Click:Connect(toggleProximityPrompts)

-- Скрытие GUI по клавише J
local uis = game:GetService("UserInputService")
uis.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.J then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Информационный текст
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0.3, 0)
infoLabel.Position = UDim2.new(0, 0, 0.7, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "J - скрыть GUI"
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.TextScaled = true
infoLabel.Parent = frame
