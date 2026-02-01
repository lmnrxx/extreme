local Bracket = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Bracket/main/BracketV33.lua"))()
local Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()
local Players, UIS, RunService = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService")
local lp, Camera = Players.LocalPlayer, workspace.CurrentCamera

Sense.teamSettings.enemy.enabled = true
Sense.teamSettings.enemy.box = true
Sense.teamSettings.enemy.boxColor[1] = Color3.new(0, 0.25, 0.75)

local window = Bracket:Window({
	Name = "Extreme",
	Enabled = true,
	Color = Color3.fromRGB(20, 20, 20),
	Size = UDim2.new(0, 500, 0, 500),
	Position = UDim2.new(0.5, -250, 0.5, -250)
})

-- MAIN TAB
local tabMain = window:Tab({
	Name = "Main"
})

-- AIMBOT SECTION
local aimSection = tabMain:Section({
	Name = "Aimbot"
})
local aimbotEnabled, aiming = false, false
local fovRadius = 150

local fovEnabled = true
local r, g, b = 255, 0, 0
local fovColor = Color3.fromRGB(r, g, b)
local fovCircle = Drawing.new("Circle")
fovCircle.Transparency = 0.5
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Visible = fovEnabled
fovCircle.Color = fovColor

local function getClosestHead()
	local mousePos = UIS:GetMouseLocation()
	local closest, dist = nil, math.huge
	for _, v in ipairs(Players:GetPlayers()) do
		if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
			local head = v.Character:FindFirstChild("Head")
			if head then
				local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local delta = (Vector2.new(sp.X, sp.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
					if delta < dist and delta <= fovRadius then
						dist = delta
						closest = head
					end
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	local mp = UIS:GetMouseLocation()
	if fovEnabled then
		fovCircle.Visible = true
		fovCircle.Position = Vector2.new(mp.X, mp.Y)
		fovCircle.Radius = fovRadius
		fovCircle.Color = fovColor
	else
		fovCircle.Visible = false
	end
	if aimbotEnabled and aiming then
		local head = getClosestHead()
		if head then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
		end
	end
end)

UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = true
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = false
	end
end)

aimSection:Toggle({
	Name = "Enable Aimbot",
	Callback = function(v)
		aimbotEnabled = v
	end
})

aimSection:Slider({
	Name = "FOV",
	Min = 10,
	Max = 500,
	Value = fovRadius,
	Callback = function(v)
		fovRadius = v
	end
})
aimSection:Toggle({
	Name = "Enable FOV Circle",
	Callback = function(v)
		fovEnabled = v
	end
})

-- RGB sliders
aimSection:Slider({
	Name = "FOV Color R",
	Min = 0,
	Max = 255,
	Value = r,
	Callback = function(v)
		r = v
		fovColor = Color3.fromRGB(r, g, b)
	end
})
aimSection:Slider({
	Name = "FOV Color G",
	Min = 0,
	Max = 255,
	Value = g,
	Callback = function(v)
		g = v
		fovColor = Color3.fromRGB(r, g, b)
	end
})
aimSection:Slider({
	Name = "FOV Color B",
	Min = 0,
	Max = 255,
	Value = b,
	Callback = function(v)
		b = v
		fovColor = Color3.fromRGB(r, g, b)
	end
})

-- ESP SECTION
local espSection = tabMain:Section({
	Name = "ESP"
})
espSection:Toggle({
	Name = "Enable ESP",
	Callback = function(v)
		if v then
			Sense.Load()
		else
			Sense.Unload()
		end
	end
})

-- MOVEMENT SECTION
local moveSection = tabMain:Section({
	Name = "Movement"
})
local speedValue, jumpValue = 16, 50
moveSection:Toggle({
	Name = "Speed Hack",
	Callback = function(v)
		local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
		if h then
			h.WalkSpeed = v and speedValue or 16
		end
	end
})
moveSection:Slider({
	Name = "Speed",
	Min = 1,
	Max = 200,
	Value = speedValue,
	Callback = function(v)
		speedValue = v
	end
})
moveSection:Toggle({
	Name = "Jump Hack",
	Callback = function(v)
		local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
		if h then
			h.JumpPower = v and jumpValue or 50
		end
	end
})
moveSection:Slider({
	Name = "Jump Power",
	Min = 1,
	Max = 200,
	Value = jumpValue,
	Callback = function(v)
		jumpValue = v
	end
})

-- Toggle menu с клавишей K
local toggleKey = Enum.KeyCode.K
UIS.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == toggleKey then
		window.Enabled = not window.Enabled
	end
end)

-- INFO TAB
local tabInfo = window:Tab({
	Name = "Info"
})
tabInfo:Section({
	Name = "About"
}):Label({
	Text = "press K to close the window"
})
