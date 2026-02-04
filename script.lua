local Bracket = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Bracket/main/BracketV33.lua"))()
local Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()
local Players, UIS, RunService, HttpService = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("HttpService")

local lp, Camera = Players.LocalPlayer, workspace.CurrentCamera
local CONFIG_FILE = "ExtremeConfig.json"

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

local aimbotEnabled, aiming = false, false
local fovRadius = 150
local fovEnabled = false
local r, g, b = 255, 0, 0
local speedValue, jumpValue = 16, 50
local espEnabled = false
local fovchangerEnabled = false
local fovchangerValue = 70

local function getConfig()
	return {
		aimbotEnabled = aimbotEnabled,
		fovRadius = fovRadius,
		fovEnabled = fovEnabled,
		r = r,
		g = g,
		b = b,
		speedValue = speedValue,
		jumpValue = jumpValue,
		espEnabled = espEnabled,
		fovchangerEnabled = fovchangerEnabled,
		fovchangerValue = fovchangerValue
	}
end

local function applyConfig(cfg)
	if not cfg then
		return
	end
	aimbotEnabled = cfg.aimbotEnabled or false
	fovRadius = cfg.fovRadius or 150
	fovEnabled = cfg.fovEnabled ~= false
	r, g, b = cfg.r or 255, cfg.g or 0, cfg.b or 0
	speedValue = cfg.speedValue or 16
	jumpValue = cfg.jumpValue or 50
	espEnabled = cfg.espEnabled or false
	fovchangerEnabled = cfg.fovchangerEnabled or false
	fovchangerValue = cfg.fovchangerValue or 70
	if espEnabled then
		Sense.Load()
	else
		Sense.Unload()
	end
end

local function saveConfig()
	writefile(CONFIG_FILE, HttpService:JSONEncode(getConfig()))
end

local function loadConfig()
	if isfile(CONFIG_FILE) then
		applyConfig(HttpService:JSONDecode(readfile(CONFIG_FILE)))
	end
end

local function deleteConfig()
	if isfile(CONFIG_FILE) then
		delfile(CONFIG_FILE)
	end
end

local tabMain = window:Tab({
	Name = "Main"
})
local aimSection = tabMain:Section({
	Name = "Aimbot"
})

local fovCircle = Drawing.new("Circle")
fovCircle.Transparency = 0.5
fovCircle.Thickness = 2
fovCircle.Filled = false

local function getClosestHead()
	local mousePos = UIS:GetMouseLocation()
	local closest, dist = nil, math.huge
	for _, v in ipairs(Players:GetPlayers()) do
		if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
			local head = v.Character:FindFirstChild("Head")
			if head then
				local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local delta = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
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

local function getMouseTarget()
	local ray = Camera:ScreenPointToRay(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {
		lp.Character
	}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	return result and result.Instance
end

RunService.RenderStepped:Connect(function()
	local mp = UIS:GetMouseLocation()
	if fovEnabled then
		fovCircle.Visible = true
		fovCircle.Position = mp
		fovCircle.Radius = fovRadius
		fovCircle.Color = Color3.fromRGB(r, g, b)
	else
		fovCircle.Visible = false
	end
	if aimbotEnabled and aiming then
		local head = getClosestHead()
		if head then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
		end
	end
	if triggerEnabled and aiming then
		local target = getMouseTarget()
		if target and target.Name == "Head" then
			local hum = target:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid")
			if hum and hum.Health > 0 then
				task.wait(triggerDelay / 1000)
				mouse1click()
			end
		end
	end
end)

UIS.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = true
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = false
	end
end)

aimSection:Toggle({
	Name = "Enable Aimbot",
	Callback = function(v)
		aimbotEnabled = v
	end
})
aimSection:Toggle({
	Name = "Enable FOV Circle",
	Callback = function(v)
		fovEnabled = v
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
aimSection:Slider({
	Name = "FOV Color R",
	Min = 0,
	Max = 255,
	Value = r,
	Callback = function(v)
		r = v
	end
})
aimSection:Slider({
	Name = "FOV Color G",
	Min = 0,
	Max = 255,
	Value = g,
	Callback = function(v)
		g = v
	end
})
aimSection:Slider({
	Name = "FOV Color B",
	Min = 0,
	Max = 255,
	Value = b,
	Callback = function(v)
		b = v
	end
})

local espSection = tabMain:Section({
	Name = "ESP"
})
espSection:Toggle({
	Name = "Enable ESP",
	Callback = function(v)
		espEnabled = v
		if v then
			Sense.Load()
		else
			Sense.Unload()
		end
	end
})

local moveSection = tabMain:Section({
	Name = "Movement"
})

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

local tabConfig = window:Tab({
	Name = "Config"
})
local cfg = tabConfig:Section({
	Name = "Configuration"
})
cfg:Button({
	Name = "Save Config",
	Callback = saveConfig
})
cfg:Button({
	Name = "Load Config",
	Callback = loadConfig
})
cfg:Button({
	Name = "Delete Config",
	Callback = deleteConfig
})

local tabInfo = window:Tab({
	Name = "Info"
})
tabInfo:Section({
	Name = "About"
}):Label({
	Text = "Press K to close the window"
})

local misc = tabMain:Section({
	Name = "Miscellaneous"
})

local function ChangeFov2(state)
	if state == true then
		workspace.CurrentCamera.FieldOfView = fovchangerValue
	else
		workspace.CurrentCamera.FieldOfView = 70
	end
end

misc:Toggle({
	Name = "Enable FOV Changer",
	Callback = function(v)
		fovchangerEnabled = v
		ChangeFov2(fovchangerEnabled)
	end
})
misc:Slider({
	Name = "Fov Changer Value",
	Min = 50,
	Max = 150,
	Value = fovchangerValue,
	Callback = function(v)
		fovchangerValue = v
	end
})

UIS.InputBegan:Connect(function(i, p)
	if not p and i.KeyCode == Enum.KeyCode.K then
		window.Enabled = not window.Enabled
	end
end)
