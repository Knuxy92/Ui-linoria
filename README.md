
# Ui For Normal Hub Project OR KNUXY92

- [@Knuxy92](https://discordapp.com/users/1010021431075155979)
- [@chxy.lua](https://discordapp.com/users/1279788240093577249)

# Dev Script
**Dark Dex Mobile**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Knuxy92/Ui-linoria/refs/heads/main/DarkDex_Mobile.lua"))()
```

**Dark Dex Solora**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Knuxy92/Ui-linoria/refs/heads/main/DarkDex_Solora"))()
```
**Remote Spy mobile**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/RS/main/SimpleSpyMobile"))()
```

# UI DOCUMENT
## [Fluent Ui](https://raw.githubusercontent.com/Knuxy92/Ui-linoria/refs/heads/main/Fluent/Fluent.luaa)
**[Example Ui](https://raw.githubusercontent.com/Knuxy92/Ui-linoria/refs/heads/main/Fluent/Example.lua)**


**Import Ui**
```lua
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Knuxy92/Ui-linoria/main/Fluent/Fluent.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

```

**Insall Module**
```lua
do
	Config = {
		
	}
	_G.Config = Config
	AllFuncs = {}
	Threads = getgenv().Threads
	Players = game.Players
	LocalPlayer = game.Players.LocalPlayer
	Client = game.Players.LocalPlayer
	
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
```


**Create Windows**
```lua
local Window = Fluent:CreateWindow({
	Title = "Normal Hub",
	SubTitle = "| <Free or Premium> Script <Name Map>",
	TabWidth = 160,
	Size = UDim2.fromOffset(550, 350),
	Acrylic = false, 
	Theme = "Normal Theme",
	MinimizeKey = Enum.KeyCode.LeftControl
})
```

**Create Tap**
```lua
-- // Icon lucide.dev/icons And Check Name Icon In github.com/dawid-scripts/Fluent/blob/master/src/Icons.lua
local Tap = {
	General = Window:AddTab({Title = "Generals", Icon = "box"}),
	Settings = Window:AddTab({Title = "Settings", Icon = "settings"})
}
```

**Function Create Toggle**
```lua
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
```


**Function Create Slider**
```lua
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
```

**Function Create TextBox**
```lua
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
```

**Function Create Dropdown**
```lua
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
```

**Settings Tap**
```lua
Settings_M = Tap.Settings:AddSection("Misc") do
    Timeing = Settings_M:AddParagraph({        
        Title = "Timeing Server"
    })
    Toggle(Settings_M, "Auto Loading Configs", "", "AutoLoadingConfigs", function(v)
        
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
```
