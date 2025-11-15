-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local EXCLUDED_TEAMS = {"Sheriffs", "Lobby"}

local function shouldTeleportPlayer()
	if not player.Team then
		return true
	end

	for _, teamName in ipairs(EXCLUDED_TEAMS) do
		if player.Team.Name == teamName then
			return false
		end
	end

	return true
end

local function teleportToDeath()
	if not shouldTeleportPlayer() then
		return
	end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not humanoidRootPart then return end

	humanoid.PlatformStand = true
	wait(0.05)

	humanoidRootPart.CFrame = CFrame.new(0, -500, 0)

	wait(0.05)
	humanoid.PlatformStand = false

	wait(1)
	if humanoid.Health > 0 then
		humanoid.Health = 0
	end
end

while true do
	wait(5)
	teleportToDeath()
end
