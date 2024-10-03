
print("Test")
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Knuxy92/Ui-linoria/main/Fluent/Fluent.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
	Title = "Normal Hub",
	SubTitle = "| <Free or Premium> Script <Name Map>",
	TabWidth = 160,
	Size = UDim2.fromOffset(550, 350),
	Acrylic = false, 
	Theme = "Normal Theme",
	MinimizeKey = Enum.KeyCode.LeftControl
})

do 
	Config = {
		
	}
	_G.Config = Config
	AllFuncs = {}
	Threads = getgenv().Threads
	Players = game.Players
	LocalPlayer = game.Players.LocalPlayer
	Client = game.Players.LocalPlayer


	-- \\ Module GetService // --

	ReplicatedStorage = game:GetService('ReplicatedStorage')
	RunService = game:GetService("RunService")
	VirtualInputManager = game:GetService('VirtualInputManager')
	CollectionService = game:GetService("CollectionService")
	CoreGui = game:GetService("CoreGui")
	HttpService = game:GetService("HttpService")
	TeleportService = game:GetService("TeleportService")
	VirtualUser = game:GetService("VirtualUser")
	VirtualInputManager = game:GetService("VirtualInputManager")
	UserInputService = game:GetService("UserInputService")


	-- \\ Normal Module // --
	
	Backpack = LocalPlayer.Backpack
	request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
	
	Char = Client.Character
	Character = Client.Character
	if not Threads then getgenv().Threads = {} end

	repeat 
		LocalPlayer = Players.LocalPlayer
		wait()
	until LocalPlayer
end

function Notify(Des,Time, title)
	Fluent:Notify({
		Title= title or "Normal Hub Notify",
		Content = Des,
		Duration = Time or 3
	})
end

_G['Normal Hub Table'] = {
	isWindows = UserInputService:GetPlatform() == Enum.Platform.Windows,
	TypeOs = (table.find({Enum.Platform.Windows}, game:GetService('UserInputService'):GetPlatform()) ~= nil and 'Pc') or 'Mb',
	SizeUi = (not isWindows and UDim2.fromOffset(600,300)) or UDim2.fromOffset(560,600),
	AutoSize = true,
	TweenUiSize = true,
	SpeedTweenUi = 0.25,
	StyleTweenUi = Enum.EasingStyle.Quad,
	Mutiply = 1.80,
	SizeX = 550,
	SafePercent = 20,

	AnimationUiToggle = true,
}

_G['Normal Hub Table'].SizeUi = (not _G['Normal Hub Table'].isWindows and UDim2.fromOffset(600,300)) or UDim2.fromOffset(560,600)
if not _G['Normal Hub Table'].isWindows then
	if game.CoreGui:FindFirstChild('UIBUTTON') then
		game.CoreGui:FindFirstChild('UIBUTTON'):Destroy()
	end

	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local UIBUTTON = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local ImageButton = Instance.new("ImageButton")
	local UICorner = Instance.new("UICorner")
	local UICorner_2 = Instance.new("UICorner")

	UIBUTTON.Name = "UIBUTTON"
	UIBUTTON.Parent = game.CoreGui
	UIBUTTON.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Frame.Parent = UIBUTTON
	Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Transparency = .7
	Frame.Position = UDim2.new(0.157012194, 0, 0.164366379, 0)
	Frame.Size = UDim2.new(0, 115, 0, 49)

	ImageButton.Parent = Frame
	ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageButton.BorderSizePixel = 0
	ImageButton.Position = UDim2.new(0.218742043, 0, -0.155235752, 0)
	ImageButton.Size = UDim2.new(0, 64, 0, 64)
	ImageButton.Image = "rbxassetid://18374973658"
	ImageButton.MouseButton1Click:Connect(function()
		ImageButton:TweenSize(UDim2.new(0, 60, 0, 60), Enum.EasingDirection.In, Enum.EasingStyle.Elastic, 0.01)
		delay(0.1, function()
			ImageButton:TweenSize(UDim2.new(0, 64, 0, 64), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic, 0.01)
		end)
		VirtualInputManager:SendKeyEvent(true,"RightControl",false,game)
		VirtualInputManager:SendKeyEvent(false,"RightControl",false,game)
	end)

	UICorner.CornerRadius = UDim.new(0, 100)
	UICorner.Parent = ImageButton

	UICorner_2.CornerRadius = UDim.new(0, 10)
	UICorner_2.Parent = Frame


	local UIS = game:GetService('UserInputService')
	local frame = Frame
	local dragToggle = nil
	local dragSpeed = 0.25
	local dragStart = nil
	local startPos = nil

	local function updateInput(input)
		local delta = input.Position - dragStart
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		game:GetService('TweenService'):Create(frame, TweenInfo.new(dragSpeed), {Position = position}):Play()
	end

	frame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
			dragToggle = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragToggle then
				Frame.Transparency = 0
				updateInput(input)
			else
				Frame.Transparency = .7
			end
		end
	end)
end

local Tap = {
	General = Window:AddTab({Title = "Generals", Icon = "box"}),
	Settings = Window:AddTab({Title = "Settings", Icon = "settings"})
}


Toggle = function(Section, NameIndex, Description, ConfigName, Function, ...)
	local Misc = {...}
	ConfigName = ConfigName or NameIndex

	local defaultState = Config[ConfigName] or false

	local CreateToggle = Section:AddToggle((NameIndex or NameIndex.."-toggle"), {
		Title = NameIndex or "null",
		Default = defaultState,
		Description = Description or "",
	})

	CreateToggle:OnChanged(function(v)
		
	end)

	return CreateToggle
end


Slider = function(section,Name,min,max,Rounding,...)
	local SettingName,func = ...
	if not func and type(SettingName) == "function" then func = SettingName end
	if not SettingName then SettingName = Name end
	local default = Config[SettingName]
	local CreateSlider = section:AddSlider((Name or Name.."-slider"), {
		Title =Name or "null",
		Min = min or 0,
		Max = max or 1,
		Default = (Config[SettingName] or default) or min,
		Rounding = (Rounding == true and 1) or 0,
	})

	CreateSlider:OnChanged(function(v)

	end)
	task.wait()
	return CreateSlider
end

TextBox = function(section,Name,tooltip,PlaceHolder,Numberic,...)
	local SettingName,func = ...
	if not func and type(SettingName) == "function" then func = SettingName end
	if not SettingName then SettingName = Name end
	local CreateInput =section:AddInput((Name or Name.."-input"), {
		Title =Name or "Null",
		Placeholder = PlaceHolder or "Put text here!",
		Numeric = Numberic or false,
		Finished = true,
		Description = tooltip or "",
		Default = Config[SettingName],
	})

	CreateInput:OnChanged(function(value)
		
	end)
	task.wait()
	return CreateInput
end

Dropdown = function(section, Name, default, list, multi, ...)
	local SettingName, func = ...
	if not func and type(SettingName) == "function" then func = SettingName end
	SettingName = SettingName or Name

	if multi then
		default = (default or Config[SettingName]) or {}
		if type(Config[SettingName]) == "string" then
			Config[SettingName] = {Config[SettingName]}
		end
	else
		default = (default or Config[SettingName]) or ""
	end

	local CreateDropdown = section:AddDropdown((Name or Name.."-dropdown"), {
		Title = Name or "Null",
		Values = list or {"None"},
		Multi = multi or false,
		Default = default
	})

	CreateDropdown:OnChanged(function(v)
		if multi and type(v) == 'table' then
			Config[SettingName] = {}
			for _, selectedValue in pairs(v) do
				table.insert(Config[SettingName], selectedValue)
			end
		else
			Config[SettingName] = v
		end

		if func then
			func(v)
		end
	end)

	return CreateDropdown
end

Main = Tap.General:AddSection('Main') do
	Dropdown(Main, "Example Dropdown", "None", {"LIST","LIST2"},false, "Example Dropdown")
	Dropdown(Main, "Example Dropdown Muti", {"None"}, {"LIST","LIST2"},true, "Example Dropdown Muti")
	Toggle(Main, "Example Toggle","Example Description", "Example Toggle")
	Toggle(Main, "Example Toggle Fun","Example Description", "Example Toggle Fun", function(Value)
		print(Value)
	end)
	TextBox(Main, "Example TextBox", "Example Tooltip", "Example Place Holder", false, "Example Textbox")
	TextBox(Main, "Example TextBox Num Only", "Example Tooltip", "Example Place Holder", true, "Example Textbox Num Only")
	Slider(Main, "Example Slider", 0, 100, false, "Example Slider")
	Slider(Main, "Example Slider Rounding", 0, 100, true, "Example Slider Rounding")
	Main:AddButton({
		Title = "Text Button",
		Callback = function()
			
		end
	})
end

local Old = os.time()

do
	Settings_M = Tap.Settings:AddSection("Misc") do
		Timeing = Settings_M:AddParagraph({        
			Title = "Timeing Server"
		})
		Toggle(Settings_M, "Auto Loading Configs", "", "AutoLoadingConfigs", function(v)
			writefile(tostring(LocalPlayer.UserId).."ALC.txt", tostring(v))
		end)
		Settings_M:AddButton({
			Title = "Join Normal Hub Discord",
			Description = "Click to join",
			Callback = function()

			end,
		})
	end

	RunService.Heartbeat:Connect(function() -- All RunService
		local TimeSinceLastPlay = os.time() - Old
		local hours = tostring(math.floor(TimeSinceLastPlay / 3600))
		local minutes = tostring(math.floor((TimeSinceLastPlay % 3600) / 60))
		local seconds = tostring(TimeSinceLastPlay % 60)
		Timeing:SetTitle("Server Joined "..hours.." H "..minutes.." M "..seconds.." S ")
	end)


	InterfaceManager:SetLibrary(Fluent)
	InterfaceManager:SetFolder("Normal Hub")
	InterfaceManager:BuildInterfaceSection(Tap.Settings)
	Window:SelectTab(1)
	Fluent:Notify({
		Title = "Normal",
		Content = "Loading Success !",
		Duration = 3
	})

	SaveManager:LoadAutoloadConfig()
	Fluent:SetTheme("Normal Theme")
	setfpscap(240)
end
