--// Ashen Hub
--// LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--// Theme
local THEME = {
	Background = Color3.fromRGB(22, 22, 25),
	TitleBar   = Color3.fromRGB(30, 30, 34),
	Element    = Color3.fromRGB(38, 38, 43),
	Accent     = Color3.fromRGB(255, 106, 43), -- ember
	AccentDim  = Color3.fromRGB(150, 70, 35),
	Text       = Color3.fromRGB(235, 235, 235),
	SubText    = Color3.fromRGB(140, 140, 148),
	Off        = Color3.fromRGB(70, 70, 78),
}

--// State
local state = {
	WalkSpeed = 16,
	JumpPower = 50,
	Noclip = false,
	SpeedTouched = false,
	JumpTouched = false,
}

--// Helpers
local function create(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	for _, child in ipairs(children or {}) do
		child.Parent = obj
	end
	return obj
end

local function corner(radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

local function tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function getHumanoid()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

--// Remove old copy
local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("AshenHub")
if old then old:Destroy() end

--// ScreenGui
local gui = create("ScreenGui", {
	Name = "AshenHub",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

--// Main window
local main = create("Frame", {
	Name = "Main",
	Size = UDim2.new(0, 300, 0, 290),
	Position = UDim2.new(0.5, -150, 0.5, -145),
	BackgroundColor3 = THEME.Background,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Parent = gui,
}, {
	corner(10),
	create("UIStroke", { Color = THEME.Accent, Thickness = 1, Transparency = 0.6 }),
})

--// Title bar
local titleBar = create("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1, 0, 0, 38),
	BackgroundColor3 = THEME.TitleBar,
	BorderSizePixel = 0,
	Parent = main,
}, { corner(10) })

-- square off the bottom corners of the title bar
create("Frame", {
	Size = UDim2.new(1, 0, 0, 10),
	Position = UDim2.new(0, 0, 1, -10),
	BackgroundColor3 = THEME.TitleBar,
	BorderSizePixel = 0,
	Parent = titleBar,
})

create("Frame", { -- ember accent dot
	Size = UDim2.new(0, 8, 0, 8),
	Position = UDim2.new(0, 14, 0.5, -4),
	BackgroundColor3 = THEME.Accent,
	BorderSizePixel = 0,
	Parent = titleBar,
}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

create("TextLabel", {
	Text = "ASHEN HUB",
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	TextColor3 = THEME.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -90, 1, 0),
	Position = UDim2.new(0, 30, 0, 0),
	Parent = titleBar,
})

local minimizeBtn = create("TextButton", {
	Text = "–",
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextColor3 = THEME.SubText,
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 32, 0, 32),
	Position = UDim2.new(1, -68, 0, 3),
	Parent = titleBar,
})

local closeBtn = create("TextButton", {
	Text = "×",
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextColor3 = THEME.SubText,
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 32, 0, 32),
	Position = UDim2.new(1, -36, 0, 3),
	Parent = titleBar,
})

for _, btn in ipairs({ minimizeBtn, closeBtn }) do
	btn.MouseEnter:Connect(function() tween(btn, { TextColor3 = THEME.Accent }) end)
	btn.MouseLeave:Connect(function() tween(btn, { TextColor3 = THEME.SubText }) end)
end

--// Content container
local content = create("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -24, 1, -52),
	Position = UDim2.new(0, 12, 0, 46),
	BackgroundTransparency = 1,
	Parent = main,
}, {
	create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
})

--// Dragging
do
	local dragging, dragStart, startPos

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--// Section label
local function createLabel(text, order)
	return create("TextLabel", {
		Text = text,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = THEME.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		LayoutOrder = order,
		Parent = content,
	})
end

--// Slider
local function createSlider(name, min, max, default, order, callback)
	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = THEME.Element,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = content,
	}, { corner(8) })

	create("TextLabel", {
		Text = name,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.6, 0, 0, 20),
		Position = UDim2.new(0, 12, 0, 8),
		Parent = holder,
	})

	local valueLabel = create("TextLabel", {
		Text = tostring(default),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = THEME.Accent,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.4, -12, 0, 20),
		Position = UDim2.new(0.6, 0, 0, 8),
		Parent = holder,
	})

	local track = create("Frame", {
		Size = UDim2.new(1, -24, 0, 6),
		Position = UDim2.new(0, 12, 0, 38),
		BackgroundColor3 = THEME.Off,
		BorderSizePixel = 0,
		Parent = holder,
	}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local fill = create("Frame", {
		Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel = 0,
		Parent = track,
	}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local knob = create("Frame", {
		Size = UDim2.new(0, 14, 0, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = fill,
	}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local dragging = false

	local function update(input)
		local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (max - min) * rel + 0.5)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		valueLabel.Text = tostring(value)
		callback(value)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			tween(knob, { Size = UDim2.new(0, 18, 0, 18) }, 0.1)
			update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			tween(knob, { Size = UDim2.new(0, 14, 0, 14) }, 0.1)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

--// Toggle
local function createToggle(name, order, callback)
	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = THEME.Element,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = content,
	}, { corner(8) })

	create("TextLabel", {
		Text = name,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.6, 0, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		Parent = holder,
	})

	local switch = create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(0, 42, 0, 22),
		Position = UDim2.new(1, -54, 0.5, -11),
		BackgroundColor3 = THEME.Off,
		BorderSizePixel = 0,
		Parent = holder,
	}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local dot = create("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, 3, 0.5, -8),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = switch,
	}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local on = false
	switch.MouseButton1Click:Connect(function()
		on = not on
		tween(switch, { BackgroundColor3 = on and THEME.Accent or THEME.Off })
		tween(dot, { Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) })
		callback(on)
	end)
end

--// Build controls
createLabel("MOVEMENT", 1)

createSlider("WalkSpeed", 16, 200, state.WalkSpeed, 2, function(v)
	state.WalkSpeed = v
	state.SpeedTouched = true
	local hum = getHumanoid()
	if hum then hum.WalkSpeed = v end
end)

createSlider("JumpPower", 50, 300, state.JumpPower, 3, function(v)
	state.JumpPower = v
	state.JumpTouched = true
	local hum = getHumanoid()
	if hum then
		hum.UseJumpPower = true
		hum.JumpPower = v
	end
end)

createLabel("PLAYER", 4)

createToggle("Noclip", 5, function(on)
	state.Noclip = on
end)

--// Keep values applied (some games reset them)
RunService.Heartbeat:Connect(function()
	local hum = getHumanoid()
	if not hum then return end

	if state.SpeedTouched and hum.WalkSpeed ~= state.WalkSpeed then
		hum.WalkSpeed = state.WalkSpeed
	end
	if state.JumpTouched then
		hum.UseJumpPower = true
		if hum.JumpPower ~= state.JumpPower then
			hum.JumpPower = state.JumpPower
		end
	end
end)

--// Noclip loop
RunService.Stepped:Connect(function()
	if not state.Noclip then return end
	local char = player.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.CanCollide then
			part.CanCollide = false
		end
	end
end)

--// Minimize / close / hotkey
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	tween(main, { Size = minimized and UDim2.new(0, 300, 0, 38) or UDim2.new(0, 300, 0, 290) }, 0.2)
end)

closeBtn.MouseButton1Click:Connect(function()
	state.Noclip = false
	gui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		main.Visible = not main.Visible
	end
end)
