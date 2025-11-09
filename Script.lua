-- Основной рабочий скрипт

-- Создаем объекты GUI
local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")

-- Переменные управления
local flying = false
local speed = 50
local speedhackSpeed = 33
local speedhackEnabled = false
local flyConnection
local bodyVelocity
local bodyGyro
local menuVisible = true
local speedhackKey = Enum.KeyCode.R
local flyKey = Enum.KeyCode.G
local teleportKey = Enum.KeyCode.T
local proximityKey = Enum.KeyCode.J
local menuKey = Enum.KeyCode.U
local teleportToggle = false
local espEnabled = false
local proximityPromptEnabled = false
local originalDurations = {}

-- Создаем папку для ESP
local espFolder = Instance.new("Folder")
espFolder.Name = "ESP_Holder"

-- Настройки ESP
local ESP = {
	FriendColor = Color3.fromRGB(0, 255, 0),
	EnemyColor = Color3.fromRGB(255, 0, 0),
	UseTeamColor = false
}

-- Настройка GUI
screenGui.Name = "MenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Помещаем ESP folder в screenGui
espFolder.Parent = screenGui

frame.Size = UDim2.new(0, 400, 0, 470)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BackgroundTransparency = 0.2
frame.BorderColor3 = Color3.fromRGB(0, 170, 255)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Функция создания кнопок
local function createButton(text, position)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 380, 0, 30)
	button.Position = position
	button.Text = text
	button.TextScaled = true
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.BorderColor3 = Color3.fromRGB(0, 170, 255)
	button.BorderSizePixel = 2
	button.Parent = frame
	return button
end

-- Функция создания полей ввода
local function createTextBox(placeholder, position)
	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(0, 380, 0, 30)
	textBox.Position = position
	textBox.PlaceholderText = placeholder
	textBox.Text = ""
	textBox.TextScaled = true
	textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	textBox.BorderColor3 = Color3.fromRGB(0, 170, 255)
	textBox.BorderSizePixel = 2
	textBox.Parent = frame
	return textBox
end

-- Создаем элементы GUI
local flyButton = createButton("Enable Fly", UDim2.new(0, 10, 0, 20))
local speedInput = createTextBox("Fly Speed (Current: " .. speed .. ")", UDim2.new(0, 10, 0, 60))
local speedhackInput = createTextBox("Speedhack Speed (Current: " .. speedhackSpeed .. ")", UDim2.new(0, 10, 0, 100))
local speedhackButton = createButton("Enable Speedhack", UDim2.new(0, 10, 0, 140))
local keybindButton = createButton("Speedhack Key: R", UDim2.new(0, 10, 0, 180))
local flyKeybindButton = createButton("Fly Key: G", UDim2.new(0, 10, 0, 220))
local teleportButton = createButton("Teleport to Position 1", UDim2.new(0, 10, 0, 260))
local teleportKeybindButton = createButton("Teleport Key: T", UDim2.new(0, 10, 0, 300))
local proximityPromptButton = createButton("Disable ProximityPrompt", UDim2.new(0, 10, 0, 340))
local proximityKeybindButton = createButton("Proximity Key: J", UDim2.new(0, 10, 0, 380))
local espButton = createButton("Enable ESP", UDim2.new(0, 10, 0, 420))

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 380, 0, 50)
titleLabel.Position = UDim2.new(0, 10, 0, -40)
titleLabel.Text = "chalun"
titleLabel.TextScaled = true
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextStrokeTransparency = 0
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 170, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.BorderSizePixel = 0
titleLabel.Parent = frame

-- Функция для определения цвета игрока
local function getPlayerColor(player)
	if player == game.Players.LocalPlayer then 
		return ESP.FriendColor
	end

	local localPlayer = game.Players.LocalPlayer
	if not localPlayer.Team or not player.Team then
		return ESP.EnemyColor
	end

	if player.Team == localPlayer.Team then
		return ESP.FriendColor
	else
		return ESP.EnemyColor
	end
end

-- Функции полета
local function fly()
	local player = game.Players.LocalPlayer
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = humanoidRootPart

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.CFrame = humanoidRootPart.CFrame
	bodyGyro.Parent = humanoidRootPart

	flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
		if not humanoidRootPart or not humanoidRootPart.Parent then
			if flyConnection then flyConnection:Disconnect() end
			return
		end

		local camera = workspace.CurrentCamera
		local moveDirection = Vector3.new(0, 0, 0)

		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + (camera.CFrame.LookVector * speed)
		end
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - (camera.CFrame.LookVector * speed)
		end
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - (camera.CFrame.RightVector * speed)
		end
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + (camera.CFrame.RightVector * speed)
		end
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
			moveDirection = moveDirection + Vector3.new(0, speed, 0)
		end
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
			moveDirection = moveDirection - Vector3.new(0, speed, 0)
		end

		bodyVelocity.Velocity = moveDirection
		bodyGyro.CFrame = camera.CFrame
	end)
end

local function toggleFly()
	flying = not flying
	flyButton.Text = flying and "Disable Fly" or "Enable Fly"

	if flying then
		fly()
	else
		if flyConnection then flyConnection:Disconnect() end
		if bodyVelocity then bodyVelocity:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
		local character = game.Players.LocalPlayer.Character
		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
			end
		end
	end
end

-- Функции Speedhack
local function toggleSpeedhack()
	speedhackEnabled = not speedhackEnabled
	speedhackButton.Text = speedhackEnabled and "Disable Speedhack" or "Enable Speedhack"

	local character = game.Players.LocalPlayer.Character
	if character and character:FindFirstChild("Humanoid") then
		if speedhackEnabled then
			character.Humanoid.WalkSpeed = speedhackSpeed
		else
			character.Humanoid.WalkSpeed = 16
		end
	end
end

-- Функции телепортации
local function toggleTeleport()
	local player = game.Players.LocalPlayer
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	teleportToggle = not teleportToggle

	if teleportToggle then
		humanoidRootPart.CFrame = CFrame.new(Vector3.new(170.43, 3.66, 474.95))
		teleportButton.Text = "Teleport to Position 2"
	else
		humanoidRootPart.CFrame = CFrame.new(Vector3.new(172.26, 47.47, 426.68))
		teleportButton.Text = "Teleport to Position 1"
	end
end

-- Функции ProximityPrompt
local function updateAllPrompts()
	for _, prompt in ipairs(game:GetService("Workspace"):GetDescendants()) do
		if prompt:IsA("ProximityPrompt") then
			if proximityPromptEnabled then
				if not originalDurations[prompt] then
					originalDurations[prompt] = prompt.HoldDuration
				end
				prompt.HoldDuration = 0
			else
				if originalDurations[prompt] then
					prompt.HoldDuration = originalDurations[prompt]
				end
			end
		end
	end
end

local function toggleProximityPrompts()
	proximityPromptEnabled = not proximityPromptEnabled

	if proximityPromptEnabled then
		proximityPromptButton.Text = "Enable ProximityPrompt"
		proximityPromptButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		proximityPromptButton.Text = "Disable ProximityPrompt"
		proximityPromptButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end

	updateAllPrompts()
end

-- Функции ESP
local function createPlayerESP(player)
	if player == game.Players.LocalPlayer then return end

	local function setupCharacterESP(character)
		if not character or not character:FindFirstChild("Humanoid") then return end

		local oldHighlight = espFolder:FindFirstChild(player.Name .. "_Highlight")
		local oldBillboard = espFolder:FindFirstChild(player.Name .. "_Billboard")

		if oldHighlight then oldHighlight:Destroy() end
		if oldBillboard then oldBillboard:Destroy() end

		local playerColor = getPlayerColor(player)

		local highlight = Instance.new("Highlight")
		highlight.Name = player.Name .. "_Highlight"
		highlight.Adornee = character
		highlight.FillColor = playerColor
		highlight.FillTransparency = 0.3
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = espFolder

		local head = character:FindFirstChild("Head")
		if head then
			local billboard = Instance.new("BillboardGui")
			billboard.Name = player.Name .. "_Billboard"
			billboard.Size = UDim2.new(0, 200, 0, 50)
			billboard.StudsOffset = Vector3.new(0, 3, 0)
			billboard.AlwaysOnTop = true
			billboard.MaxDistance = 1000
			billboard.Adornee = head
			billboard.Parent = espFolder

			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = player.Name
			textLabel.TextColor3 = playerColor
			textLabel.TextSize = 14
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
			textLabel.TextStrokeTransparency = 0.3
			textLabel.ZIndex = 10
			textLabel.Parent = billboard
		end
	end

	if player.Character then
		setupCharacterESP(player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		if espEnabled then
			wait(1)
			setupCharacterESP(character)
		end
	end)
end

local function updateAllESP()
	if not espEnabled then return end

	espFolder:ClearAllChildren()

	for _, player in pairs(game.Players:GetPlayers()) do
		if player ~= game.Players.LocalPlayer then
			createPlayerESP(player)
		end
	end
end

local function toggleESP()
	espEnabled = not espEnabled

	if espEnabled then
		updateAllESP()
		espButton.Text = "Disable ESP"
		espButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

		-- Добавляем обработчик для новых игроков при включении ESP
		game.Players.PlayerAdded:Connect(function(player)
			if espEnabled then
				wait(2)  -- Даем время игроку загрузиться
				createPlayerESP(player)
			end
		end)
	else
		espFolder:ClearAllChildren()
		espButton.Text = "Enable ESP"
		espButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end

-- Обработчики полей ввода
speedInput.FocusLost:Connect(function(enterPressed)
	local newSpeed = tonumber(speedInput.Text)
	if newSpeed then
		speed = newSpeed
		speedInput.PlaceholderText = "Fly Speed (Current: " .. tostring(speed) .. ")"
		speedInput.Text = ""
	else
		speedInput.Text = ""
	end
end)

speedhackInput.FocusLost:Connect(function(enterPressed)
	local newSpeedhackSpeed = tonumber(speedhackInput.Text)
	if newSpeedhackSpeed then
		speedhackSpeed = newSpeedhackSpeed
		if speedhackEnabled then
			local character = game.Players.LocalPlayer.Character
			if character and character:FindFirstChild("Humanoid") then
				character.Humanoid.WalkSpeed = speedhackSpeed
			end
		end
		speedhackInput.PlaceholderText = "Speedhack Speed (Current: " .. tostring(speedhackSpeed) .. ")"
		speedhackInput.Text = ""
	else
		speedhackInput.Text = ""
	end
end

-- Функции настройки клавиш
local function setSpeedhackKeybind()
	keybindButton.Text = "Press any key..."
	local connection
	connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				speedhackKey = input.KeyCode
				keybindButton.Text = "Speedhack Key: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
				connection:Disconnect()
			end
		end
	end)
end

local function setFlyKeybind()
	flyKeybindButton.Text = "Press any key..."
	local connection
	connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				flyKey = input.KeyCode
				flyKeybindButton.Text = "Fly Key: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
				connection:Disconnect()
			end
		end
	end)
end

local function setTeleportKeybind()
	teleportKeybindButton.Text = "Press any key..."
	local connection
	connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				teleportKey = input.KeyCode
				teleportKeybindButton.Text = "Teleport Key: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
				connection:Disconnect()
			end
		end
	end)
end

local function setProximityKeybind()
	proximityKeybindButton.Text = "Press any key..."
	local connection
	connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				proximityKey = input.KeyCode
				proximityKeybindButton.Text = "Proximity Key: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
				connection:Disconnect()
			end
		end
	end)
end

-- Функция скрытия/показа меню
local function toggleMenu()
	menuVisible = not menuVisible
	frame.Visible = menuVisible
end

-- Обработчики клавиш
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed then
		if input.KeyCode == speedhackKey then
			toggleSpeedhack()
		elseif input.KeyCode == flyKey then
			toggleFly()
		elseif input.KeyCode == teleportKey then
			toggleTeleport()
		elseif input.KeyCode == proximityKey then
			toggleProximityPrompts()
		elseif input.KeyCode == menuKey then
			toggleMenu()
		end
	end
end)

-- Привязка кнопок
flyButton.MouseButton1Click:Connect(toggleFly)
speedhackButton.MouseButton1Click:Connect(toggleSpeedhack)
keybindButton.MouseButton1Click:Connect(setSpeedhackKeybind)
flyKeybindButton.MouseButton1Click:Connect(setFlyKeybind)
teleportButton.MouseButton1Click:Connect(toggleTeleport)
teleportKeybindButton.MouseButton1Click:Connect(setTeleportKeybind)
proximityPromptButton.MouseButton1Click:Connect(toggleProximityPrompts)
proximityKeybindButton.MouseButton1Click:Connect(setProximityKeybind)
espButton.MouseButton1Click:Connect(toggleESP)

-- Обработка новых ProximityPrompt
game:GetService("Workspace").DescendantAdded:Connect(function(descendant)
	if descendant:IsA("ProximityPrompt") then
		if proximityPromptEnabled then
			originalDurations[descendant] = descendant.HoldDuration
			descendant.HoldDuration = 0
		end
	end
end)

-- Глобальный обработчик для новых игроков
game.Players.PlayerAdded:Connect(function(player)
	-- Обработка смены команды для новых игроков
	player:GetPropertyChangedSignal("Team"):Connect(function()
		if espEnabled then
			wait(0.5)
			espFolder:ClearAllChildren()
			wait(0.5)
			updateAllESP()
		end
	end)

	-- Автоматическое создание ESP для новых игроков
	if espEnabled then
		wait(2)  -- Даем время игроку загрузиться
		createPlayerESP(player)
	end
end)

-- Обновление ESP при смене команды для существующих игроков
for _, player in pairs(game.Players:GetPlayers()) do
	player:GetPropertyChangedSignal("Team"):Connect(function()
		if espEnabled then
			wait(0.5)
			espFolder:ClearAllChildren()
			wait(0.5)
			updateAllESP()
		end
	end)
end

-- Обработчик смены команды локального игрока
game.Players.LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	if espEnabled then
		wait(1)
		updateAllESP()
	end
end)

-- Восстановление после смерти
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
	wait(2)

	-- Восстанавливаем GUI
	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	frame.Visible = menuVisible

	-- Восстанавливаем Speedhack
	if speedhackEnabled then
		character:WaitForChild("Humanoid").WalkSpeed = speedhackSpeed
	end

	-- Восстанавливаем ProximityPrompt
	if proximityPromptEnabled then
		updateAllPrompts()
	end

	-- Восстанавливаем ESP с задержкой
	if espEnabled then
		wait(3)
		updateAllESP()

		-- Дополнительное обновление через некоторое время
		wait(2)
		updateAllESP()
	end
end)

-- Инициализация при запуске
updateAllPrompts()

-- Автоматическое обновление ESP каждые 5 секунд для надежности
while wait(5) do
	if espEnabled then
		-- Проверяем всех игроков и создаем ESP для тех, у кого его нет
		for _, player in pairs(game.Players:GetPlayers()) do
			if player ~= game.Players.LocalPlayer then
				local hasESP = espFolder:FindFirstChild(player.Name .. "_Highlight")
				if not hasESP and player.Character then
					createPlayerESP(player)
				end
			end
		end
	end
end
