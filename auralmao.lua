wait(2.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local function CreateRing(parent, color)
	local ring = {}

	for i = 1, 48 do
		local segment = Instance.new("Part")
		segment.Size = Vector3.new(0.25, 0.15, 1.2)
		segment.Material = Enum.Material.Neon
		segment.Color = color
		segment.Anchored = true
		segment.CanCollide = false
		segment.CanQuery = false
		segment.CanTouch = false
		segment.Parent = parent

		table.insert(ring, segment)
	end

	return ring
end

local function CreateSpikes(parent)
	local spikes = {}

	for i = 1, 24 do
		local spike = Instance.new("Part")
		spike.Size = Vector3.new(0.3, 0.3, 3)
		spike.Material = Enum.Material.Neon
		spike.Color = Color3.fromRGB(255, 0, 0)
		spike.Anchored = true
		spike.CanCollide = false
		spike.CanQuery = false
		spike.CanTouch = false
		spike.Parent = parent

		table.insert(spikes, spike)
	end

	return spikes
end

local function UpdateRing(ring, center, radius, rotation, transparency)
	local count = #ring

	for i, segment in ipairs(ring) do
		local angle = ((i - 1) / count) * math.pi * 2 + rotation

		local pos = center + Vector3.new(
			math.cos(angle) * radius,
			0,
			math.sin(angle) * radius
		)

		segment.CFrame =
			CFrame.lookAt(pos, center) *
			CFrame.Angles(math.rad(90), 0, 0)

		segment.Transparency = transparency
	end
end

local function UpdateSpikes(spikes, center, radius, rotation)
	for i, spike in ipairs(spikes) do
		local angle = ((i - 1) / #spikes) * math.pi * 2 + rotation

		local length =
			2.5 +
			math.sin(tick() * 8 + i) * 1.5 +
			math.random() * 0.4

		spike.Size = Vector3.new(0.25, 0.25, length)

		local pos = center + Vector3.new(
			math.cos(angle) * radius,
			0,
			math.sin(angle) * radius
		)

		spike.CFrame =
			CFrame.lookAt(
				pos,
				pos + Vector3.new(math.cos(angle), 0, math.sin(angle))
			) *
			CFrame.new(0, 0, -length / 2)
	end
end

local function Aura(character)
	local root = character:WaitForChild("HumanoidRootPart")
	local head = character:WaitForChild("Head")

	local folder = Instance.new("Folder")
	folder.Name = "Aura"
	folder.Parent = workspace

	local OuterRing = CreateRing(folder, Color3.fromRGB(255, 0, 0))
	local InnerRing = CreateRing(folder, Color3.fromRGB(180, 0, 0))
	local Spikes = CreateSpikes(folder)

	-- 🔊 SOUND ON LOAD
	local Sound = Instance.new("Sound")
	Sound.SoundId = "rbxassetid://136391385725568"
	Sound.Volume = 1
	Sound.RollOffMaxDistance = 80
	Sound.Parent = head
	Sound:Play()

	Sound.Ended:Connect(function()
		Sound:Destroy()
	end)

	-- BILLBOARD
	local Billboard = Instance.new("BillboardGui")
	Billboard.Size = UDim2.new(0, 200, 0, 40)
	Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	Billboard.AlwaysOnTop = true
	Billboard.MaxDistance = 120
	Billboard.Parent = head

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.fromScale(1, 1)
	Label.BackgroundTransparency = 1
	Label.TextScaled = true
	Label.Font = Enum.Font.GothamMedium
	Label.TextColor3 = Color3.fromRGB(255, 0, 0)
	Label.TextStrokeTransparency = 0.6
	Label.TextStrokeColor3 = Color3.fromRGB(120, 0, 0)
	Label.Parent = Billboard

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(255, 0, 0)
	Stroke.Thickness = 1.5
	Stroke.Transparency = 0.4
	Stroke.Parent = Label

	-- ✅ YOUR TITLES
	local Titles = { 
		"67",
		"FRESH",
		"DOMINICZEEK",
		"DOMINATOR",
		"DADDY",
		"JEB SIE",
		"HERE I COME"
	}

	local connection

	connection = RunService.RenderStepped:Connect(function()
		if not character.Parent then
			connection:Disconnect()
			folder:Destroy()
			Billboard:Destroy()
			return
		end

		local t = tick()
		local pulse = (math.sin(t * 8) + 1) / 2

		local center = root.Position - Vector3.new(0, 2.85, 0)

		UpdateRing(OuterRing, center, 5.5 + pulse, t * 1.5, 0.35)
		UpdateRing(InnerRing, center, 3 + pulse * 0.4, -t * 3, 0.15)
		UpdateSpikes(Spikes, center, 6 + pulse, -t * 2)

		-- TEXT FX
		local glow = (math.sin(t * 3) + 1) / 2

		Label.TextTransparency = 0.1 + glow * 0.2
		Label.TextStrokeTransparency = 0.55 + glow * 0.2
		Stroke.Thickness = 1.5 + glow * 2

		Billboard.StudsOffset = Vector3.new(0, 3.5 + math.sin(t * 2) * 0.2, 0)

		-- 📏 DISTANCE SCALING
		local cam = workspace.CurrentCamera
		local dist = (cam.CFrame.Position - head.Position).Magnitude
		local scale = math.clamp(1 / (dist / 25), 0.6, 1.2)

		Billboard.Size = UDim2.new(0, 200 * scale, 0, 40 * scale)
		Label.TextSize = 18 * scale

		-- 🔁 TITLE SWITCH
		local index = math.floor(t * 0.25) % #Titles + 1
		Label.Text = Titles[index]
	end)
end

if Player.Character then
	Aura(Player.Character)
end

Player.CharacterAdded:Connect(Aura)
