local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = game:GetObjects("rbxassetid://99852798675591")[1]
ScreenGui.Enabled = false

if RunService:IsStudio() then
	ScreenGui.Parent = game.StarterGui
else
	ScreenGui.Parent = cloneref(game.CoreGui)
end

local Library = {
	sizeX = 800,
	sizeY = 600,
	tabSizeX = 200,

	dragging = false,
	sliderDragging = false,
	firstTabDebounce = false,
	firstSubTabDebounce = false, 
	processedEvent = false,
	managerCreated = false, -- Using this as a check to clean up unused Addon objects
	lineIndex = 0,

	Connections = {},
	Addons = {}, -- To store addon frames to clean up unused ones later, this is my solution to this problem, if you can find a better solution then just create a pull request, thanks.
	Exclusions = {},
	SectionFolder = {
		Left = {},
		Right = {},
	},
	Flags = {
		Toggle = {},
		Slider = {},
		TextBox = {},
		Keybind = {},
		Dropdown = {},	
		ColorPicker = {},
	},
	Theme = {},
	DropdownSizes = {}, -- to store previous opened dropdown size to resize scrollingFrame canvassize
}
Library.__index = Library

shared.Flags = Library.Flags

local Connections = Library.Connections
local Exclusions = Library.Exclusions

local Assets = ScreenGui.Assets
local Modules = {
	Dropdown = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/L3nyFromV3rm/Leny-UI/refs/heads/main/Modules/Dropdown.lua", true))(),
	Toggle = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/L3nyFromV3rm/Leny-UI/refs/heads/main/Modules/Toggle.lua", true))(),
	Popup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/L3nyFromV3rm/Leny-UI/refs/heads/main/Modules/Popup.lua", true))(),
	Slider = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/L3nyFromV3rm/Leny-UI/refs/heads/main/Modules/Slider.lua", true))(),
	Keybind = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/L3nyFromV3rm/Leny-UI/refs/heads/main/Modules/Keybind.lua", true))(),
	TextBox = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/L3nyFromV3rm/Leny-UI/refs/heads/main/Modules/TextBox.lua", true))(),
	Navigation = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/L3nyFromV3rm/Leny-UI/refs/heads/main/Modules/Navigation.lua", true))(),
	ColorPicker = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/L3nyFromV3rm/Leny-UI/refs/heads/main/Modules/ColorPicker.lua", true))(),
}

local Utility = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/L3nyFromV3rm/Leny-UI/refs/heads/main/Modules/Utility.lua", true))()
local Theme = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Knuxy92/Ui-linoria/refs/heads/main/Leny%20Edit/Theme.lua", true))()
Library.Theme = Theme

local Popups = ScreenGui.Popups

-- Set default size for UI
local Glow = ScreenGui.Glow
Glow.Size = UDim2.fromOffset(Library.sizeX, Library.sizeY)

local Background = Glow.Background

local Tabs = Background.Tabs
local Filler = Tabs.Filler
local Resize = Filler.Resize
local Line = Filler.Line
local Title = Tabs.Frame.Title

-- Tab resizing stuff
local tabResizing = false
Resize.MouseButton1Down:Connect(function()
	tabResizing = true
end)

local touchMoved = UserInputService.TouchMoved:Connect(function()
	if tabResizing then
		local newSizeX = math.clamp(((input.Position.X - Glow.AbsolutePosition.X) / Glow.AbsoluteSize.X) * Glow.AbsoluteSize.X, 72, 208)
		Utility:tween(Tabs, {Size = UDim2.new(0, newSizeX, 1, 0)}, 0.2):Play()
		Utility:tween(Background.Pages, {Size = UDim2.new(1, -newSizeX, 1, 0)}, 0.2):Play()
	end
end)

local inputChanged = UserInputService.InputChanged:Connect(function(input)
	if tabResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
		local newSizeX = math.clamp(((input.Position.X - Glow.AbsolutePosition.X) / Glow.AbsoluteSize.X) * Glow.AbsoluteSize.X, 72, 208)
		Utility:tween(Tabs, {Size = UDim2.new(0, newSizeX, 1, 0)}, 0.2):Play()
		Utility:tween(Background.Pages, {Size = UDim2.new(1, -newSizeX, 1, 0)}, 0.2):Play()
	end
end)

local touchEnded = UserInputService.TouchEnded:Connect(function(input)
	if tabResizing then
		tabResizing = false
	end
end)

table.insert(Connections, inputChanged)

Resize.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		tabResizing = false
	end
end)

-- Mobile compatibility
Glow:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	for _, data in ipairs(Library.SectionFolder.Right) do
		if Glow.AbsoluteSize.X <= 660 then
			data.folders.Right.Visible = false
			data.folders.Left.Size = UDim2.fromScale(1, 1)
			data.object.Parent = data.folders.Left
		else
			data.folders.Left.Size = UDim2.new(0.5, -7, 1, 0)
			data.folders.Right.Visible = true
			data.object.Parent = data.folders.Right
		end
	end

	for _, data in ipairs(Library.SectionFolder.Left) do
		if Glow.AbsoluteSize.X <= 660 then
			data.folders.Right.Visible = false
			data.folders.Left.Size = UDim2.fromScale(1, 1)
		else
			data.folders.Left.Size = UDim2.new(0.5, -7, 1, 0)
			data.folders.Right.Visible = true
		end
	end
end)

function Library.new(options)
	Utility:validateOptions(options, {
		sizeX = {Default = Library.sizeX, ExpectedType = "number"},
		sizeY = {Default = Library.sizeY, ExpectedType = "number"},
		tabSizeX = {Default = Library.tabSizeX, ExpectedType = "number"},
		title = {Default = "Leny", ExpectedType = "string"},
		PrimaryBackgroundColor = {Default = Library.Theme.PrimaryBackgroundColor, ExpectedType = "Color3"},
		SecondaryBackgroundColor = {Default = Library.Theme.SecondaryBackgroundColor, ExpectedType = "Color3"},
		TertiaryBackgroundColor = {Default = Library.Theme.TertiaryBackgroundColor, ExpectedType = "Color3"},
		TabBackgroundColor = {Default = Library.Theme.TabBackgroundColor, ExpectedType = "Color3"},
		PrimaryTextColor = {Default = Library.Theme.PrimaryTextColor, ExpectedType = "Color3"},
		SecondaryTextColor = {Default = Library.Theme.SecondaryTextColor, ExpectedType = "Color3"},
		PrimaryColor = {Default = Library.Theme.PrimaryColor, ExpectedType = "Color3"},
		ScrollingBarImageColor = {Default = Library.Theme.ScrollingBarImageColor, ExpectedType = "Color3"},
		Line = {Default = Library.Theme.Line, ExpectedType = "Color3"},
	})

	Library.tabSizeX = math.clamp(options.tabSizeX, 72, 208)
	Library.sizeX = options.sizeX
	Library.sizeY = options.sizeY
	Library.Theme.PrimaryBackgroundColor = options.PrimaryBackgroundColor
	Library.Theme.SecondaryBackgroundColor = options.SecondaryBackgroundColor
	Library.Theme.TertiaryBackgroundColor = options.TertiaryBackgroundColor -- new
	Library.Theme.TabBackgroundColor = options.TabBackgroundColor
	Library.Theme.PrimaryTextColor = options.PrimaryTextColor
	Library.Theme.SecondaryTextColor = options.SecondaryTextColor
	Library.Theme.PrimaryColor = options.PrimaryColor
	Library.Theme.ScrollingBarImageColor = options.ScrollingBarImageColor
	Library.Theme.Line = options.Line

	ScreenGui.Enabled = true
	Title.Text = options.title
	Title.RichText = true
	Glow.Size = UDim2.fromOffset(options.sizeX, options.sizeY)
end

function Library:createAddons(text, imageButton, scrollingFrame, additionalAddons)	
	local Addon = Assets.Elements.Addons:Clone()
	Addon.Size = UDim2.fromOffset(scrollingFrame.AbsoluteSize.X * 0.5, Addon.Inner.UIListLayout.AbsoluteContentSize.Y)
	table.insert(self.Addons, Addon)

	local Inner = Addon.Inner

	local TextLabel = Inner.TextLabel
	TextLabel.Text = text .. " Addons"

	local PopupContext = Utility:validateContext({
		Popup = {Value = Addon, ExpectedType = "Instance"},
		Target = {Value = imageButton, ExpectedType = "Instance"},
		Library = {Value = Library, ExpectedType = "table"},
		TransparentObjects = {Value = Utility:getTransparentObjects(Addon), ExpectedType = "table"},
		ScrollingFrame = {Value = scrollingFrame, ExpectedType = "Instance"},
		Popups = {Value = Popups, ExpectedType = "Instance"},
		Inner = {Value = Inner, ExpectedType = "Instance"},
		PositionPadding = {Value = 18 + 7, ExpectedType = "number"},
		SizePadding = {Value = 30, ExpectedType = "number"},
	})

	Theme:registerToObjects({
		{object = Addon, property = "BackgroundColor3", theme = {"Line"}},
		{object = Inner, property = "BackgroundColor3", theme = {"PrimaryBackgroundColor"}},
		{object = TextLabel, property = "TextColor3", theme = {"PrimaryTextColor"}},
	})

	local Popup = Modules.Popup.new(PopupContext)
	imageButton.MouseButton1Down:Connect(Popup:togglePopup())
	Popup:hidePopupOnClickingOutside()

	local DefaultAddons = {
		createToggle = function(self, options)
			Library:createToggle(options, Addon.Inner, scrollingFrame)
		end,

		createSlider = function(self, options)
			Library:createSlider(options, Addon.Inner, scrollingFrame)
		end,

		createDropdown = function(self, options)
			options.default = {} -- need to do this for some reason since I clearly implied that default was as table value but guess not?
			Library:createDropdown(options, Addon.Inner, scrollingFrame)
		end,

		createPicker = function(self, options)
			Library:createPicker(options, Addon.Inner, scrollingFrame, true)
		end,

		createKeybind = function(self, options)
			Library:createKeybind(options, Addon.Inner, scrollingFrame)
		end,

		createButton = function(self, options)
			Library:createButton(options, Addon.Inner, scrollingFrame)
		end,

		createTextBox = function(self, options)
			Library:createTextBox(options, Addon.Inner, scrollingFrame)
		end,
	}

	for key, value in pairs(additionalAddons or  {}) do
		DefaultAddons[key] = value
	end

	return setmetatable({},  {
		__index = function(table, key)
			local originalFunction = DefaultAddons[key]

			if type(originalFunction) == "function" then
				return function(...)
					-- Show imageButton if the index name is "create"
					if string.match(key, "create") then
						if Addon.Parent == nil then
							Addon.Parent = Popups
						end

						imageButton.Visible = true
					end

					-- updateTransparentObjects again to account for the new creation of element after the call.
					return originalFunction(...), Popup:updateTransparentObjects(Addon)
				end
			else
				return originalFunction
			end
		end,

		__newindex = function(table, key, value)
			DefaultAddons[key] = value
		end
	})
end

function Library:destroy()
	for _, rbxSignals in ipairs(Connections) do
		rbxSignals:disconnect()
	end
	task.wait(0.1)
	ScreenGui:Destroy()
end

function Library:createLabel(options: table)
	Utility:validateOptions(options, {
		text = {Default = "Main", ExpectedType = "string"},
	})

	options.text = string.upper(options.text)

	local ScrollingFrame = Background.Tabs.Frame.ScrollingFrame

	local Line = Assets.Tabs.Line:Clone()
	Line.Visible = true
	Line.BackgroundColor3 = Theme.Line
	Line.Parent = ScrollingFrame

	local TextLabel = Assets.Tabs.TextLabel:Clone()
	TextLabel.Visible = true
	TextLabel.Text = options.text
	TextLabel.Parent = ScrollingFrame

	for _, line in ipairs(ScrollingFrame:GetChildren()) do
		if line.Name ~= "Line" then
			continue
		end

		self.lineIndex += 1

		if self.lineIndex == 1 then
			line:Destroy()
		end
	end

	Theme:registerToObjects({
		{object = TextLabel, property = "TextColor3", theme = {"SecondaryTextColor"}},
		{object = Line, property = "BackgroundColor3", theme = {"Line"}},
	})
end
local Icons = {
	["lucide"] = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"))(),
	["craft"] = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua"))(),
}

function GetIconImage(Icon)
	local IconModule = {
		IconsType = "lucide"
	}

	function IconModule.SetIconsType(iconType)
		IconModule.IconsType = iconType
	end

	function IconModule.Icon(Icon, Type)
		local iconType = Icons[Type or IconModule.IconsType]
		if iconType.Icons[Icon] then
			return { iconType.Spritesheets[tostring(iconType.Icons[Icon].Image)], iconType.Icons[Icon] }
		end
		return nil
	end
	IconModule.SetIconsType("lucide")
	return IconModule.Icon(Icon)
end

function Library:createTab(options: table)
	Utility:validateOptions(options, {
		text = {Default = "Tab", ExpectedType = "string"},
		icon = {Default = "124718082122263", ExpectedType = "string"},
	})

	-- Change tab size depending on Library.tabSizeX, maybe make resizer for tabs later
	Background.Tabs.Size = UDim2.new(0, Library.tabSizeX, 1, 0)
	Background.Pages.Size = UDim2.new(1, -Library.tabSizeX, 1, 0)

	local ScrollingFrame = Background.Tabs.Frame.ScrollingFrame

	local Tab = Assets.Tabs.Tab:Clone()
	Tab.Visible = true
	Tab.Parent = ScrollingFrame

	local ImageButton = Tab.ImageButton

	local Icon = ImageButton.Icon
	if type(options.icon) == "string" and string.match(options.icon, "%a") then
		local IconGen = GetIconImage(options.icon)
		Icon.Image = IconGen[1]
		Icon.ImageRectOffset = IconGen[2]["ImageRectPosition"]
		Icon.ImageRectSize = IconGen[2]["ImageRectSize"]
	else
		Icon.Image = "rbxassetid://" .. options.icon
	end

	local TextButton = ImageButton.TextButton
	TextButton.Text = options.text

	local Page = Assets.Pages.Page:Clone()
	Page.Parent = Background.Pages

	local Frame = Page.Frame
	local PageLine = Frame.Line

	local CurrentTabLabel = Frame.CurrentTabLabel
	CurrentTabLabel.Text = options.text
	CurrentTabLabel.TextColor3 = Theme.PrimaryTextColor

	local SubTabs = Page.SubTabs
	local SubLine = SubTabs.Line

	local function tweenTabAssets(tab: Instance, icon: Instance, textButton: Instance, color: textColor3, backgroundColor3: Color3, backgroundTransparency: number, textTransparency: number, imageTransparency: number)
		Utility:tween(tab, {BackgroundColor3 = backgroundColor3, BackgroundTransparency = backgroundTransparency}, 0.5):Play()
		Utility:tween(icon, {ImageTransparency = imageTransparency, ImageColor3 = color}, 0.5):Play()
		Utility:tween(textButton, {TextColor3 = color, TextTransparency = textTransparency}, 0.5):Play()
	end	

	local function fadeAnimation()
		local function tweenFadeAndPage(fade: Instance, backgroundTransparency: number, textTransparency: number, paddingY: number)
			Utility:tween(fade, {BackgroundTransparency = backgroundTransparency}, 0.2):Play()
			Utility:tween(CurrentTabLabel.UIPadding, {PaddingBottom = UDim.new(0, paddingY)}, 0.2):Play()
		end

		for _, subPage in ipairs(Page:GetChildren()) do
			if subPage.Name == "SubPage" and subPage.Visible and subPage:FindFirstChild("ScrollingFrame") then
				Utility:tween(subPage.ScrollingFrame.UIPadding, {PaddingTop = UDim.new(0, 10)}, 0.2):Play()

				task.delay(0.2, function()
					Utility:tween(subPage.ScrollingFrame.UIPadding, {PaddingTop = UDim.new(0, 0)}, 0.2):Play()
				end)
			end
		end

		local Fade = Assets.Pages.Fade:Clone()
		Fade.BackgroundTransparency = 1
		Fade.Visible = true
		Fade.Parent = Background.Pages

		tweenFadeAndPage(Fade, 0, 1, 14)

		task.delay(0.2, function()
			tweenFadeAndPage(Fade, 1, 0, 0)
			task.wait(0.2)
			Fade:Destroy()
		end)
	end

	local Context = Utility:validateContext({
		Page = {Value = Page, ExpectedType = "Instance"},
		Pages = {Value = Background.Pages, ExpectedType = "Instance"},
		Popups = {Value = Popups, ExpectedType = "Instance"},
		ScrollingFrame = {Value = Background.Tabs.Frame.ScrollingFrame, ExpectedType = "Instance"},
		animation = {Value = fadeAnimation, ExpectedType = "function"},

		tweenTabOn = {Value = function()
			tweenTabAssets(Tab, Icon, TextButton, Theme.PrimaryColor, Theme.TabBackgroundColor, 0, 0, 0)
		end, ExpectedType = "function"},

		tweenTabsOff = {Value = function(tab)
			tweenTabAssets(tab, tab.ImageButton.Icon, tab.ImageButton.TextButton, Theme.SecondaryTextColor, Theme.TabBackgroundColor, 1, 0, 0)
		end, ExpectedType = "function"},

		hoverOn = {Value = function()
			tweenTabAssets(Tab, Icon, TextButton, Theme.PrimaryColor, Theme.TabBackgroundColor, 0.16, 0.3, 0.3)
		end, ExpectedType = "function"},

		hoverOff = {Value = function()
			tweenTabAssets(Tab, Icon, TextButton, Theme.SecondaryTextColor, Theme.TabBackgroundColor, 1, 0, 0)
		end, ExpectedType = "function"},
	})

	local Navigation = Modules.Navigation.new(Context)

	-- this is stupid but anyways!!!
	if not self.firstTabDebounce then
		Navigation:enableFirstTab()
		self.firstTabDebounce = true
	end

	ScrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollingFrame.UIListLayout.AbsoluteContentSize.Y + ScrollingFrame.UIListLayout.Padding.Offset)
	end)

	ImageButton.MouseButton1Down:Connect(Navigation:selectTab())
	Icon.MouseButton1Down:Connect(Navigation:selectTab())
	TextButton.MouseButton1Down:Connect(Navigation:selectTab())
	ImageButton.MouseEnter:Connect(Navigation:hoverEffect(true))
	ImageButton.MouseLeave:Connect(Navigation:hoverEffect(false))

	Theme:registerToObjects({
		{object = Tab, property = "BackgroundColor3", theme = {"TabBackgroundColor"}},
		{object = Icon, property = "ImageColor3", theme = {"SecondaryTextColor", "PrimaryColor"}},
		{object = TextButton, property = "TextColor3", theme = {"SecondaryTextColor", "PrimaryColor"}},
		{object = Frame, property = "BackgroundColor3", theme = {"PrimaryBackgroundColor"}},
		{object = SubTabs, property = "BackgroundColor3", theme = {"PrimaryBackgroundColor"}},
		{object = PageLine, property = "BackgroundColor3", theme = {"Line"}},
		{object = SubLine, property = "BackgroundColor3", theme = {"Line"}},
		{object = CurrentTabLabel, property = "TextColor3", theme = {"PrimaryTextColor"}},
	}, "Tab")

	local PassingContext = setmetatable({Page = Page}, Library)
	return PassingContext
end

function Library:createSubTab(options: table)
	-- Use provided options, or fall back to defaults if not provided	
	Utility:validateOptions(options, {
		sectionStyle = {Default = "Double", ExpectedType = "string"},
		text = {Default = "SubTab", ExpectedType = "string"},
	})

	local Moveable = self.Page.SubTabs.Frame.Moveable
	local Underline, ScrollingFrame = Moveable.Underline, Moveable.Parent.ScrollingFrame

	local SubPage = Assets.Pages.SubPage:Clone()
	SubPage.Parent = self.Page

	local Left, Right = SubPage.ScrollingFrame.Left, SubPage.ScrollingFrame.Right

	local SubTab = Assets.Pages.SubTab:Clone()
	SubTab.Visible = true
	SubTab.Text = options.text
	SubTab.TextColor3 = Theme.SecondaryTextColor
	SubTab.Parent = ScrollingFrame

	local TextService = game:GetService("TextService")
	SubTab.Size = UDim2.new(0, TextService:GetTextSize(options.text, 15, Enum.Font.MontserratMedium, SubTab.AbsoluteSize).X, 1, 0)

	-- Calculate subTab position to position underline
	local subTabIndex, subTabPosition = 0, 0

	for index, subTab in ipairs(ScrollingFrame:GetChildren()) do
		if subTab.Name ~= "SubTab" then
			continue
		end

		subTabIndex += 1

		if subTabIndex == 1 then
			subTabPosition = 0
		else				
			local condition, object = Utility:lookBeforeChildOfObject(index, ScrollingFrame, "SubTab")
			subTabPosition += subTab.Size.X.Offset + ScrollingFrame.UIListLayout.Padding.Offset

			if condition then
				subTabPosition -= (subTab.Size.X.Offset - object.Size.X.Offset)
			end		
		end
	end

	local function tweenSubTabAssets(subTab, underline, textColor, textTransparency: number, disableUnderlineTween: boolean)
		Utility:tween(subTab, {TextColor3 = textColor, TextTransparency = textTransparency}, 0.2):Play()

		if not disableUnderlineTween then
			Utility:tween(underline, {BackgroundColor3 = Theme.PrimaryColor, Position = UDim2.new(0, subTabPosition, 1, 0), Size = UDim2.new(0, subTab.Size.X.Offset, 0, 2)}, 0.2):Play()
		end
	end

	local function autoCanvasSizeSubPageScrollingFrame()
		local max = math.max(Left.UIListLayout.AbsoluteContentSize.Y, Right.UIListLayout.AbsoluteContentSize.Y)
		SubPage.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, max)
	end

	local function updateSectionAnimation()
		Utility:tween(SubPage.ScrollingFrame.UIPadding, {PaddingTop = UDim.new(0, 10)}, 0.2):Play()

		task.delay(0.2, function()
			Utility:tween(SubPage.ScrollingFrame.UIPadding, {PaddingTop = UDim.new(0, 0)}, 0.2):Play()
		end)
	end

	local Context = Utility:validateContext({
		Page = {Value = SubPage, ExpectedType = "Instance"},
		Pages = {Value = self.Page, ExpectedType = "Instance"},
		Popups = {Value = Popups, ExpectedType = "Instance"},
		ScrollingFrame = {Value = ScrollingFrame, ExpectedType = "Instance"},
		animation = {Value = updateSectionAnimation, ExpectedType = "function"},

		tweenTabOn = {Value = function()
			tweenSubTabAssets(SubTab, Underline, Theme.PrimaryColor, 0, false)
		end, ExpectedType = "function"},

		tweenTabsOff = {Value = function(subTab)
			tweenSubTabAssets(subTab, Underline, Theme.SecondaryTextColor, 0, true)
		end, ExpectedType = "function"},

		hoverOn = {Value = function()
			tweenSubTabAssets(SubTab, Underline, Theme.PrimaryColor, 0.3, true)
		end, ExpectedType = "function"},

		hoverOff = {Value = function()
			tweenSubTabAssets(SubTab, Underline, Theme.SecondaryTextColor, 0, true)
		end, ExpectedType = "function"},
	})

	local Navigation = Modules.Navigation.new(Context)

	if not self.firstSubTabDebounce then
		Navigation:enableFirstTab()
		self.firstSubTabDebounce = true
	end

	Left.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(autoCanvasSizeSubPageScrollingFrame)
	Right.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(autoCanvasSizeSubPageScrollingFrame)

	SubTab.MouseButton1Down:Connect(Navigation:selectTab())
	SubTab.MouseEnter:Connect(Navigation:hoverEffect(true))
	SubTab.MouseLeave:Connect(Navigation:hoverEffect(false))

	Theme:registerToObjects({
		{object = Underline, property = "BackgroundColor3", theme = {"PrimaryColor"}},
		{object = SubTab, property = "TextColor3", theme = {"SecondaryTextColor", "PrimaryColor"}},
		{object = SubPage.ScrollingFrame, property = "ScrollBarImageColor3", theme = {"ScrollingBarImageColor"}}
	}, "SubTab")

	local PassingContext = setmetatable({Left = Left, Right = Right, sectionStyle = options.sectionStyle}, Library)
	return PassingContext
end

function Library:createSection(options: table)
	Utility:validateOptions(options, {
		text = {Default = "Section", ExpectedType = "string"},
		position = {Default = "Left", ExpectedType = "string"},
	})

	local Section = Assets.Pages.Section:Clone()
	Section.Visible = true
	Section.Parent = self[options.position]

	-- Change section style 
	local screenSize = workspace.CurrentCamera.ViewportSize
	if self.sectionStyle == "Single" or (screenSize.X <= 740 and screenSize.Y <= 590) or self.sizeX <= 660 then
		if (options.position == "Right") then
			table.insert(self.SectionFolder.Right, {folders = {Left = self.Left, Right = self.Right}, object = Section})
		end

		self.Right.Visible = false
		self.Left.Size = UDim2.fromScale(1, 1)
		Section.Parent = self.Left
	end

	-- Store objects to change section style depending on the size of the UI
	if (options.position == "Right" and self.sectionStyle ~= "Single") then
		table.insert(self.SectionFolder.Right, {folders = {Left = self.Left, Right = self.Right}, object = Section})
	end

	if (options.position == "Left" and self.sectionStyle ~= "Single") then
		table.insert(self.SectionFolder.Left, {folders = {Left = self.Left, Right = self.Right}, object = Section})
	end

	local Inner = Section.Inner

	local TextLabel = Inner.TextLabel
	TextLabel.Text = options.text

	-- Auto size section
	Section.Inner.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Section.Size = UDim2.new(1, 0, 0, Section.Inner.UIListLayout.AbsoluteContentSize.Y + 28)
	end)

	Theme:registerToObjects({
		{object = Section, property = "BackgroundColor3", theme = {"Line"}},
		{object = Inner, property = "BackgroundColor3", theme = {"PrimaryBackgroundColor"}},
		{object = TextLabel, property = "TextColor3", theme = {"PrimaryTextColor"}},
	})

	local PassingContext = setmetatable({Section = Inner, ScrollingFrame = Section.Parent.Parent}, Library)
	return PassingContext
end

function Library:createToggle(options: table, parent, scrollingFrame)
	Utility:validateOptions(options, {
		text = {Default = "Toggle", ExpectedType = "string"},
		state = {Default = false, ExpectedType = "boolean"},
		callback = {Default = function() end, ExpectedType = "function"}
	})

	scrollingFrame = self.ScrollingFrame or scrollingFrame

	local Toggle = Assets.Elements.Toggle:Clone()
	Toggle.Visible = true
	Toggle.Parent = parent or self.Section

	local TextLabel = Toggle.TextLabel
	TextLabel.Text = options.text

	local ImageButton = TextLabel.ImageButton
	local TextButton = TextLabel.TextButton
	local Background = TextButton.Background
	local Circle = Background.Circle

	local function tweenToggleAssets(backgroundColor: Color3, circleColor: Color3, anchorPoint: Vector2, position: UDim2)
		Utility:tween(Background, {BackgroundColor3 = backgroundColor}, 0.2):Play()
		Utility:tween(Circle, {BackgroundColor3 = circleColor, AnchorPoint = anchorPoint, Position = position}, 0.2):Play()
	end

	local circleOn = false

	local Context = Utility:validateContext({
		state = {Value = options.state, ExpectedType = "boolean"},
		callback = {Value = options.callback, ExpectedType = "function"},

		switchOff = {Value = function()
			tweenToggleAssets(Theme.SecondaryBackgroundColor, Theme.PrimaryBackgroundColor, Vector2.new(0, 0.5), UDim2.fromScale(0, 0.5), 0.2)
			circleOn = false
		end, ExpectedType = "function"},

		switchOn = {Value = function()
			tweenToggleAssets(Theme.PrimaryColor, Theme.TertiaryBackgroundColor, Vector2.new(1, 0.5), UDim2.fromScale(1, 0.5), 0.2)
			circleOn = true
		end, ExpectedType = "function"}
	})

	local Toggle = Modules.Toggle.new(Context)
	Toggle:updateState({state = options.state})
	TextButton.MouseButton1Down:Connect(Toggle:switch())

	Theme:registerToObjects({
		{object = TextLabel, property = "TextColor3", theme = {"SecondaryTextColor"}},
		{object = Background, property = "BackgroundColor3", theme = {"PrimaryColor", "SecondaryBackgroundColor"}},
		{object = Circle, property = "BackgroundColor3", theme = {"TertiaryBackgroundColor", "PrimaryBackgroundColor"}, circleOn = circleOn},
		{object = ImageButton, property = "ImageColor3", theme = {"SecondaryTextColor"}},
	})

	shared.Flags.Toggle[options.text] = {
		getState = function(self)
			return Context.state
		end,

		updateState = function(self, options: table)
			Toggle:updateState(options)
		end,
	}

	return self:createAddons(options.text, ImageButton, scrollingFrame, {
		getState = function(self)
			return Context.state
		end,

		updateState = function(self, options: table)
			Toggle:updateState(options)
		end,
	})
end

function Library:createSlider(options: table, parent, scrollingFrame)
	Utility:validateOptions(options, {
		text = {Default = "Slider", ExpectedType = "string"},
		min = {Default = 0, ExpectedType = "number"},
		max = {Default = 100, ExpectedType = "number"},
		step = {Default = 1, ExpectedType = "number"},
		callback = {Default = function() end, ExpectedType = "function"}
	})

	options.default = options.default or options.min
	options.value = options.default 
	scrollingFrame = self.ScrollingFrame or scrollingFrame

	local Slider = Assets.Elements.Slider:Clone()
	Slider.Visible = true
	Slider.Parent = parent or self.Section

	local TextLabel = Slider.TextButton.TextLabel
	local ImageButton = TextLabel.ImageButton
	local TextBox = TextLabel.TextBox

	local Line = Slider.Line
	local TextButton = Slider.TextButton
	local Fill = Line.Fill

	local TextLabel = TextButton.TextLabel
	TextLabel.Text = options.text

	local Circle = Fill.Circle
	local InnerCircle = Circle.InnerCircle
	local CurrentValueLabel = Circle.TextButton.CurrentValueLabel

	local function tweenSliderInfoAssets(transparency: number)
		local TextBoundsX = math.clamp(CurrentValueLabel.TextBounds.X + 14, 10, 200)
		Utility:tween(CurrentValueLabel, {Size = UDim2.fromOffset(TextBoundsX, 20), BackgroundTransparency = transparency, TextTransparency = transparency}):Play()
	end

	local Context = Utility:validateContext({
		min = {Value = options.min, ExpectedType = "number"},
		max = {Value = options.max, ExpectedType = "number"},
		step = {Value = options.step, ExpectedType = "number"},
		value = {Value = options.default, ExpectedType = "number"},
		callback = {Value = options.callback, ExpectedType = "function"},
		Line = {Value = Line, ExpectedType = "Instance"},
		TextBox = {Value = TextLabel.TextBox, ExpectedType = "Instance"},
		Library = {Value = Library, ExpectedType = "table"},
		CurrentValueLabel = {Value = CurrentValueLabel, ExpectedType = "Instance"},
		Connections = {Value = Connections, ExpectedType = "table"},

		autoSizeTextBox = {Value = function()
			local TextBoundsX = math.clamp(TextLabel.TextBox.TextBounds.X + 14, 10, 200)
			Utility:tween(TextLabel.TextBox, {Size = UDim2.fromOffset(TextBoundsX, 20)}, 0.2):Play()
		end, ExpectedType = "function"},

		updateFill = {Value = function(sizeX)
			Utility:tween(Line.Fill, {Size = UDim2.fromScale(sizeX, 1)}, 0.2):Play()
		end, ExpectedType = "function"},

		showInfo = {Value = function()
			tweenSliderInfoAssets(0)
		end, ExpectedType = "function"},

		dontShowInfo ={Value = function()
			tweenSliderInfoAssets(1)
		end, ExpectedType = "function"},
	})

	local Slider = Modules.Slider.new(Context)
	Slider:handleSlider()

	Theme:registerToObjects({
		{object = TextLabel, property = "TextColor3", theme = {"SecondaryTextColor"}},
		{object = Line, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
		{object = Fill, property = "BackgroundColor3", theme = {"PrimaryColor"}},
		{object = Circle, property = "BackgroundColor3", theme = {"PrimaryColor"}},
		{object = ImageButton, property = "ImageColor3", theme = {"SecondaryTextColor"}},
		{object = TextBox, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
		{object = TextBox, property = "TextColor3", theme = {"SecondaryTextColor"}},
		{object = CurrentValueLabel, property = "TextColor3", theme = {"TertiaryBackgroundColor"}},
		{object = CurrentValueLabel, property = "BackgroundColor3", theme = {"PrimaryColor"}},
		{object = InnerCircle, property = "BackgroundColor3", theme = {"TertiaryBackgroundColor"}},
	})

	Fill.BackgroundColor3 = Theme.PrimaryColor
	Circle.BackgroundColor3 = Theme.PrimaryColor
	InnerCircle.BackgroundColor3 = Theme.TertiaryBackgroundColor
	CurrentValueLabel.BackgroundColor3 = Theme.PrimaryColor

	shared.Flags.Slider[options.text] =  {
		getValue = function(self)
			return Context.value
		end,

		updateValue = function(self, options: table)
			Slider:updateValue(options)
		end,
	}

	return self:createAddons(options.text, ImageButton, scrollingFrame, {
		getValue = function(self)
			return Context.value
		end,

		updateValue = function(self, options: table)
			Slider:updateValue(options)
		end,
	})
end

function Library:createPicker(options: table, parent, scrollingFrame, isPickerBoolean)
	Utility:validateOptions(options, {
		text = {Default = "Picker", ExpectedType = "string"},
		default = {Default = Color3.fromRGB(255, 0, 0), ExpectedType = "Color3"},
		color = {Default = Color3.fromRGB(255, 0, 0), ExpectedType = "Color3"},
		callback = {Default = function() end, ExpectedType = "function"},
	})

	isPickerBoolean = isPickerBoolean or false
	options.color = options.default
	scrollingFrame = self.ScrollingFrame or scrollingFrame

	local Picker = Assets.Elements.Picker:Clone()
	Picker.Visible = true
	Picker.Parent = parent or self.Section

	local TextLabel = Picker.TextLabel
	TextLabel.Text = options.text

	local ImageButton = TextLabel.ImageButton
	local Background = TextLabel.Background
	local TextButton = Background.TextButton

	local ColorPicker = Assets.Elements.ColorPicker:Clone()
	ColorPicker.Parent = Popups

	-- Put transparent objects to not be visible to make cool effect later!!
	local ColorPickerTransparentObjects = Utility:getTransparentObjects(ColorPicker)

	for _, data in ipairs(ColorPickerTransparentObjects) do
		data.object[data.property] = 1
	end

	local Inner = ColorPicker.Inner
	local HSV = Inner.HSV
	local Slider = Inner.Slider
	local Submit = Inner.Submit
	local Hex = Inner.HexAndRGB.Hex
	local RGB = Inner.HexAndRGB.RGB

	local PopupContext = Utility:validateContext({
		Popup = {Value = ColorPicker, ExpectedType = "Instance"},
		Target = {Value = Background, ExpectedType = "Instance"},
		Library = {Value = Library, ExpectedType = "table"},
		TransparentObjects = {Value = ColorPickerTransparentObjects, ExpectedType = "table"},
		Popups = {Value = Popups, ExpectedType = "Instance"},
		isPicker = {Value = isPickerBoolean, ExpectedType = "boolean"},
		ScrollingFrame = {Value = scrollingFrame, ExpectedType = "Instance"},
		PositionPadding = {Value = 18 + 7, ExpectedType = "number"},
		Connections = {Value = Connections, ExpectedType = "table"},
		SizePadding = {Value = 14, ExpectedType = "number"},
	})

	local Popup = Modules.Popup.new(PopupContext)
	TextButton.MouseButton1Down:Connect(Popup:togglePopup())
	Popup:hidePopupOnClickingOutside()

	local ColorPickerContext = Utility:validateContext({
		ColorPicker = {Value = ColorPicker, ExpectedType = "Instance"},
		Hex = {Value = Hex, ExpectedType = "Instance"},
		RGB = {Value = RGB, ExpectedType = "Instance"},
		Slider = {Value = Slider, ExpectedType = "Instance"},
		HSV = {Value = HSV, ExpectedType = "Instance"},
		Submit = {Value = Submit, ExpectedType = "Instance"},
		Background = {Value = Background, ExpectedType = "Instance"},
		Connections = {Value = Connections, ExpectedType = "table"},
		color = {Value = options.color, ExpectedType = "Color3"},
		callback = {Value = options.callback, ExpectedType = "function"},

		submitAnimation = {Value = function()
			Utility:tween(Submit.TextLabel, {BackgroundTransparency = 0}, 0.2):Play()
			Utility:tween(Submit.TextLabel, {TextColor3 = Theme.PrimaryColor, TextTransparency = 0}, 0.2):Play()

			task.delay(0.2, function()
				Utility:tween(Submit.TextLabel, {TextColor3 = Theme.SecondaryTextColor, TextTransparency = 0}, 0.2):Play()
				Utility:tween(Submit.TextLabel, {BackgroundTransparency = 0.3}, 0.2):Play()
			end)
		end, ExpectedType = "function"},

		hoveringOn = {Value = function()
			Utility:tween(Submit.TextLabel, {BackgroundTransparency = 0.3}, 0.2):Play()
			Utility:tween(Submit.TextLabel, {TextColor3 = Theme.PrimaryColor, TextTransparency = 0.3}, 0.2):Play()
		end, ExpectedType = "function"},

		hoveringOff = {Value = function()
			Utility:tween(Submit.TextLabel, {BackgroundTransparency = 0}, 0.2):Play()
			Utility:tween(Submit.TextLabel, {TextColor3 = Theme.SecondaryTextColor, TextTransparency = 0}, 0.2):Play()
		end, ExpectedType = "function"}, 
	})

	Theme:registerToObjects({
		{object = TextLabel, property = "TextColor3", theme = {"SecondaryTextColor"}},
		{object = ColorPicker, property = "BackgroundColor3", theme = {"Line"}},
		{object = ImageButton, property = "ImageColor3", theme = {"SecondaryTextColor"}},
		{object = Inner, property = "BackgroundColor3", theme = {"PrimaryBackgroundColor"}},
		{object = Submit, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
		{object = Hex, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
		{object = RGB, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
		{object = Submit.TextLabel, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}}
	})

	local ColorPicker = Modules.ColorPicker.new(ColorPickerContext)
	ColorPicker:handleColorPicker()

	shared.Flags.ColorPicker[options.text] = {
		getColor = function(self)
			return ColorPickerContext.color
		end,

		updateColor = function(self, options: table)
			ColorPicker:updateColor(options)
		end,
	}

	return self:createAddons(options.text, ImageButton, scrollingFrame, {
		getColor = function(self)
			return ColorPickerContext.color
		end,

		updateColor = function(self, options: table)
			ColorPicker:updateColor(options)
		end,
	})
end

function Library:createDropdown(options: table, parent, scrollingFrame)
	Utility:validateOptions(options, {
		text = {Default = "Dropdown", ExpectedType = "string"},
		list = {Default = {"Option 1", "Option 2"}, ExpectedType = "table"},
		default = {Default = {}, ExpectedType = "table"},
		multiple = {Default = false, ExpectedType = "boolean"},
		callback = {Default = function() end, ExpectedType = "function"},
	})

	scrollingFrame = self.ScrollingFrame or scrollingFrame

	local Dropdown = Assets.Elements.Dropdown:Clone()
	Dropdown.Visible = true
	Dropdown.Parent = parent or self.Section

	local TextLabel = Dropdown.TextLabel
	TextLabel.Text = options.text

	local ImageButton = TextLabel.ImageButton
	local Box = Dropdown.Box

	local TextButton = Box.TextButton
	TextButton.Text = table.concat(options.default, ", ")

	if options.default[1] == nil then
		TextButton.Text = "None"
	end

	local List = Dropdown.List
	local Inner = List.Inner
	local DropButtons = Inner.ScrollingFrame
	local Search = Inner.TextBox

	-- Auto size ScrollingFrame and List
	DropButtons.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		DropButtons.CanvasSize = UDim2.new(0, 0, 0, DropButtons.UIListLayout.AbsoluteContentSize.Y + Inner.UIListLayout.Padding.Offset)
		DropButtons.Size = UDim2.new(1, 0, 0, math.clamp(DropButtons.UIListLayout.AbsoluteContentSize.Y + Inner.UIListLayout.Padding.Offset, 0, 164))

		if List.Size.Y.Offset > 0 then
			Utility:tween(List, {Size = UDim2.new(1, 0, 0, math.clamp(Inner.UIListLayout.AbsoluteContentSize.Y, 0, 210))}, 0.2):Play()

			for index, value in ipairs(self.DropdownSizes) do
				scrollingFrame.CanvasSize = scrollingFrame.CanvasSize - value.size
				scrollingFrame.CanvasSize = scrollingFrame.CanvasSize + UDim2.new(0, 0, 0, math.clamp(Inner.UIListLayout.AbsoluteContentSize.Y, 0, 210))
				table.remove(Library.DropdownSizes, index)
				table.insert(Library.DropdownSizes, {object = Dropdown, size = UDim2.new(0, 0, 0, math.clamp(Inner.UIListLayout.AbsoluteContentSize.Y, 0, 210))})
			end
		end
	end)

	-- As long we don't spam it were good i guess when changing canvassize when tweened but let's not do that
	local function toggleList()
		if List.Size.Y.Offset <= 0 then
			for index, value in ipairs(Library.DropdownSizes) do
				if value.object ~= Dropdown then
					scrollingFrame.CanvasSize = scrollingFrame.CanvasSize - value.size
					table.remove(Library.DropdownSizes, index)
				end
			end

			-- Hide current open dropdowns and make sure enabled dropdown is on top
			for _, object in ipairs(scrollingFrame:GetDescendants()) do
				if object.Name == "Section" then
					object.ZIndex = 1
				end

				if object.Name == "List" and object ~= List then
					object.Parent.ZIndex = 1
					Utility:tween(object, {Size = UDim2.new(1, 0, 0, 0)}, 0.2):Play()
				end
			end

			for _, object in ipairs(Popups:GetDescendants()) do
				if object.Name == "List" and object ~= List then
					object.Parent.ZIndex = 1
					Utility:tween(object, {Size = UDim2.new(1, 0, 0, 0)}, 0.2):Play()
				end
			end

			Dropdown.ZIndex = 2

			if self.Section then
				self.Section.Parent.ZIndex = 2
			end

			Utility:tween(List, {Size = UDim2.new(1, 0, 0, math.clamp(Inner.UIListLayout.AbsoluteContentSize.Y, 0, 210))}, 0.2):Play()
			table.insert(Library.DropdownSizes, {object = Dropdown, size = UDim2.new(0, 0, 0, math.clamp(Inner.UIListLayout.AbsoluteContentSize.Y, 0, 210))})

			scrollingFrame.CanvasSize = scrollingFrame.CanvasSize + UDim2.new(0, 0, 0, math.clamp(Inner.UIListLayout.AbsoluteContentSize.Y, 0, 210))
		else
			Utility:tween(List, {Size = UDim2.new(1, 0, 0, 0)}, 0.2):Play()

			for index, value in ipairs(Library.DropdownSizes) do
				if value.object == Dropdown then
					scrollingFrame.CanvasSize = scrollingFrame.CanvasSize - value.size
					table.remove(Library.DropdownSizes, index)
				end
			end
		end
	end

	local function createDropButton(value)
		local DropButton = Assets.Elements.DropButton:Clone()
		DropButton.Visible = true
		DropButton.Parent = DropButtons

		local TextButton = DropButton.TextButton
		local Background = TextButton.Background
		local Checkmark = TextButton.Checkmark

		local TextLabel = DropButton.TextLabel
		TextLabel.Text = tostring(value)

		Theme:registerToObjects({
			{object = TextLabel, property = "TextColor3", theme = {"SecondaryTextColor"}},
			{object = Background, property = "BackgroundColor3", theme = {"PrimaryColor", "SecondaryBackgroundColor"}},
			{object = Checkmark, property = "ImageColor3", theme = {"TertiaryBackgroundColor"}},
		})

		return TextButton
	end

	local function tweenDropButton(dropButton: Instance, backgroundColor: Color3, imageTransparency: number)
		Utility:tween(dropButton.Background, {BackgroundColor3 = backgroundColor}, 0.2, "Circular", "InOut"):Play()
		Utility:tween(dropButton.Checkmark, {ImageTransparency = imageTransparency}, 0.3):Play()
	end

	local Context = Utility:validateContext({
		text = {Value = options.text, ExpectedType = "string"},
		default = {Value = options.default, ExpectedType = "table"},
		list = {Value = options.list, ExpectedType = "table"},
		callback = {Value = options.callback, ExpectedType = "function"},
		TextButton = {Value = TextButton, ExpectedType = "Instance"},
		DropButtons = {Value = DropButtons, ExpectedType = "Instance"},
		createDropButton = {Value = createDropButton, ExpectedType = "function"},
		ScrollingFrame = {Value = scrollingFrame, ExpectedType = "Instance"},
		multiple = {Value = options.multiple, ExpectedType = "boolean"},

		tweenDropButtonOn = {Value = function(dropButton)
			tweenDropButton(dropButton, Theme.PrimaryColor, 0)
		end, ExpectedType = "function"},

		tweenDropButtonOff = {Value = function(dropButton)
			tweenDropButton(dropButton, Theme.SecondaryBackgroundColor, 1)
		end, ExpectedType = "function"},
	})

	TextButton.MouseButton1Down:Connect(toggleList)

	-- Search drop buttons function
	Search:GetPropertyChangedSignal("Text"):Connect(function()
		for _, dropButton in ipairs(DropButtons:GetChildren()) do
			if not dropButton:IsA("Frame") then
				continue
			end

			if Search.Text == "" or string.match(string.lower(dropButton.TextLabel.Text), string.lower(Search.Text)) then
				dropButton.Visible = true
			else
				dropButton.Visible = false
			end
		end
	end)

	local Dropdown = Modules.Dropdown.new(Context)
	Dropdown:handleDropdown()

	Theme:registerToObjects({
		{object = ImageButton, property = "ImageColor3", theme = {"SecondaryTextColor"}},
		{object = TextLabel, property = "TextColor3", theme = {"SecondaryTextColor"}},
		{object = Box, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
		{object = TextButton, property = "TextColor3", theme = {"SecondaryTextColor"}},
		{object = List, property = "BackgroundColor3", theme = {"Line"}},
		{object = Inner, property = "BackgroundColor3", theme = {"PrimaryBackgroundColor"}},
		{object = Search, property = "TextColor3", theme = {"SecondaryTextColor"}},
		{object = Search, property = "PlaceholderColor3", theme = {"SecondaryTextColor"}},
		{object = Search, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
		{object = Search.Parent, property =  "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
	})

	List.BackgroundColor3 = Theme.Line
	Inner.BackgroundColor3 = Theme.PrimaryBackgroundColor
	Box.BackgroundColor3 = Theme.SecondaryBackgroundColor
	Search.BackgroundColor3 = Theme.SecondaryBackgroundColor

	shared.Flags.Dropdown[options.text] = {
		getList = function()
			return Context.list
		end,

		getValue = function()
			return Dropdown:getValue()	
		end,

		updateList = function(self, options: table)
			Dropdown:updateList(options)
		end,
	}

	return self:createAddons(options.text, ImageButton, scrollingFrame, {
		getList = function()
			return Context.list
		end,

		getValue = function()
			return Dropdown:getValue()	
		end,

		updateList = function(self, options: table)
			Dropdown:updateList(options)
		end,
	})
end

function Library:createKeybind(options: table, parent, scrollingFrame)
	Utility:validateOptions(options, {
		text = {Default = "Keybind", ExpectedType = "string"},
		default = {Default = "None", ExpectedType = "string"},
		onHeld = {Default = false, ExpectedType = "boolean"},
		callback = {Default = function() end, ExpectedType = "function"},
	})

	scrollingFrame = self.ScrollingFrame or scrollingFrame

	local Keybind = Assets.Elements.Keybind:Clone()
	Keybind.Visible = true
	Keybind.Parent = parent or self.Section

	local TextLabel = Keybind.TextLabel
	TextLabel.Text = options.text

	local ImageButton = TextLabel.ImageButton
	local Background = TextLabel.Background

	local TextButton = Background.TextButton

	if not table.find(self.Exclusions, options.default) then
		TextButton.Text = options.default
	else
		TextButton.Text = "None"
		warn("You already have this key binded")
	end

	if options.default ~= "None" then
		table.insert(Exclusions, options.default)
	end

	local Context = Utility:validateContext({
		default = {Value = options.default, ExpectedType = "string"},
		callback = {Value = options.callback, ExpectedType = "function"},
		Background = {Value = TextButton.Parent, ExpectedType = "Instance"},
		TextButton = {Value = TextButton, ExpectedType = "Instance"},
		Connections = {Value = Connections, ExpectedType = "table"},
		Library = {Value = Library, ExpectedType = "table"},
		onHeld = {Value = options.onHeld, ExpectedType = "boolean"},
		Exclusions = {Value = Exclusions, ExpectedType = "table"},

		autoSizeBackground = {Value = function()
			local TextBoundsX = math.clamp(TextButton.TextBounds.X + 14, 10, 200)
			Utility:tween(TextButton.Parent, {Size = UDim2.fromOffset(TextBoundsX, 20)}, 0.2):Play()
		end, ExpectedType = "function"},
	})

	local Keybind = Modules.Keybind.new(Context)
	Keybind:handleKeybind()

	Theme:registerToObjects({
		{object = TextLabel, property = "TextColor3", theme = {"SecondaryTextColor"}},
		{object = ImageButton, property = "ImageColor3", theme = {"SecondaryTextColor"}},
		{object = Background, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
		{object = TextButton, property = "TextColor3", theme = {"SecondaryTextColor"}}
	})

	shared.Flags.Keybind[options.text] = {
		getKeybind = function(self)
			return TextButton.Text
		end,

		updateKeybind = function(self, options: table)
			Keybind:updateKeybind(options)
		end,
	}

	return self:createAddons(options.text, ImageButton, scrollingFrame, {
		getKeybind = function(self)
			return TextButton.Text
		end,

		updateKeybind = function(self, options: table)
			Keybind:updateKeybind(options)
		end,
	})
end

-- Rushed this, later put it into a module like the other elements, even though it's simple.
function Library:createButton(options: table, parent, scrollingFrame)
	Utility:validateOptions(options, {
		text = {Default = "Button", ExpectedType = "string"},
		callback = {Default = function() end, ExpectedType = "function"},
	})

	scrollingFrame = self.ScrollingFrame or scrollingFrame

	local Button = Assets.Elements.Button:Clone()
	Button.Visible = true
	Button.Parent = parent or self.Section

	local Background = Button.Background

	local TextButton = Background.TextButton
	TextButton.Text = options.text

	TextButton.MouseButton1Down:Connect(function() 
		Utility:tween(Background, {BackgroundTransparency = 0}, 0.2):Play()
		Utility:tween(TextButton, {TextColor3 = Theme.PrimaryColor, TextTransparency = 0}, 0.2):Play()

		task.delay(0.2, function()
			Utility:tween(TextButton, {TextColor3 = Theme.SecondaryTextColor, TextTransparency = 0}, 0.2):Play()
			Utility:tween(Background, {BackgroundTransparency = 0.3}, 0.2):Play()
		end)

		options.callback() 
	end)

	Background.MouseEnter:Connect(function(input)
		Utility:tween(Background, {BackgroundTransparency = 0.3}, 0.2):Play()
		Utility:tween(TextButton, {TextColor3 = Theme.PrimaryColor, TextTransparency = 0.3}, 0.2):Play()
	end)

	Background.MouseLeave:Connect(function()
		Utility:tween(Background, {BackgroundTransparency = 0}, 0.2):Play()
		Utility:tween(TextButton, {TextColor3 = Theme.SecondaryTextColor, TextTransparency = 0}, 0.2):Play()
	end)

	Theme:registerToObjects({
		{object = Background, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
		{object = TextButton, property = "TextColor3", theme = {"SecondaryTextColor"}},
	})
end

-- Redo textbox later
function Library:createTextBox(options: table, parent, scrollingFrame)
	Utility:validateOptions(options, {
		text = {Default = "Textbox", ExpectedType = "string"},
		default = {Default = "", ExpectedType = "string"},
		callback = {Default = function() end, ExpectedType = "function"},
	})

	scrollingFrame = self.ScrollingFrame or scrollingFrame

	local TextBox = Assets.Elements.TextBox:Clone()
	TextBox.Visible = true
	TextBox.Parent = parent or self.Section

	local TextLabel = TextBox.TextLabel
	TextLabel.Text = options.text

	local ImageButton = TextLabel.ImageButton

	local Box = TextLabel.TextBox
	Box.Text = options.default

	local Context = Utility:validateContext({
		default = {Value = options.default, ExpectedType = "string"},
		callback = {Value = options.callback, ExpectedType = "function"},
		TextBox = {Value = Box, ExpectedType = "Instance"},

		autoSizeTextBox = {Value = function()
			local TextBoundsX = math.clamp(Box.TextBounds.X + 14, 0, 100)
			Utility:tween(Box, {Size = UDim2.fromOffset(TextBoundsX, 20)}, 0.2):Play()
		end, ExpectedType = "function"}
	})

	local TextBox = Modules.TextBox.new(Context)
	TextBox:handleTextBox()

	Theme:registerToObjects({
		{object = TextLabel, property = "TextColor3", theme = {"SecondaryTextColor"}},
		{object = Box, property = "TextColor3", theme = {"SecondaryTextColor"}},
		{object = Box, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
	})

	shared.Flags.TextBox[options.text] = {
		getText = function(self)
			return Box.Text
		end,

		updateText = function(self, options: table)
			Box.Text = options.text or ""
			Context.callback(Box.Text)
		end,
	}

	return self:createAddons(options.text, ImageButton, scrollingFrame, {
		getText = function(self)
			return Box.Text
		end,

		updateText = function(self, options: table)
			Box.Text = options.text or ""
			Context.callback(Box.Text)
		end,
	})
end

-- Later put this into a module, but this is fine if it's put here anyways.
local ChildRemoved = false
function Library:notify(options: table)
	Utility:validateOptions(options, {
		title = {Default = "Notification", ExpectedType = "string"},
		text = {Default = "Hello world", ExpectedType = "string"},
		duration = {Default = 3, ExpectedType = "number"},
		maxSizeX = {Default = 300, ExpectedType = "number"},
		scaleX = {Default = 0.165, ExpectedType = "number"},
		sizeY = {Default = 100, ExpectedType = "number"},
	})

	local Notification = Assets.Elements.Notification:Clone()
	Notification.Visible = true
	Notification.Parent = ScreenGui.Notifications
	Notification.Size = UDim2.new(options.scaleX, 0, 0, options.sizeY)
	Notification.UISizeConstraint.MaxSize = Vector2.new(options.maxSizeX, 9e9)

	local Title = Notification.Title
	Title.Text = options.title

	local Body = Notification.Body
	Body.Text = options.text

	local Line = Notification.Line

	-- Put transparent objects to not be visible to make cool effect
	local NotificationTransparentObjects = Utility:getTransparentObjects(Notification)

	for _, data in ipairs(NotificationTransparentObjects) do
		data.object[data.property] = 1
	end

	Notification.BackgroundTransparency = 1

	-- Get back NotificationTransparentObjects again and make it visible now with cool effect!!
	for _, data in ipairs(NotificationTransparentObjects) do
		Utility:tween(data.object, {[data.property] = 0}, 0.2):Play()
	end

	Utility:tween(Notification, {["BackgroundTransparency"] = 0}, 0.2):Play()

	local notificationPosition = -24
	local notificationSize = 0
	local PADDING_Y = 14

	for index, notification in ipairs(ScreenGui.Notifications:GetChildren()) do
		if index == 1 then
			notificationSize = notification.AbsoluteSize.Y
			Utility:tween(notification, {Position = UDim2.new(1, -24, 1, notificationPosition)}, 0.2):Play()
			continue
		end

		-- Current notification position
		notificationPosition -= notificationSize + PADDING_Y
		-- Update notification size for next time to get proper position
		notificationSize = notification.Size.Y.Offset
		Notification.Position = UDim2.new(1, Notification.Position.X.Offset, 1, notificationPosition)
	end

	-- Update notification position when notification is removed
	if not ChildRemoved then
		ScreenGui.Notifications.ChildRemoved:Connect(function(child)		
			for index, notification in ipairs(ScreenGui.Notifications:GetChildren()) do
				if index == 1 then
					notificationPosition = -14
					notificationSize = notification.AbsoluteSize.Y
					Utility:tween(notification, {Position = UDim2.new(1, -24, 1, notificationPosition)}, 0.2):Play()
					continue
				end

				-- Current notification position
				notificationPosition -= notificationSize + PADDING_Y
				-- Update notification size for next time to get proper position
				notificationSize = notification.AbsoluteSize.Y
				Utility:tween(notification, {Position = UDim2.new(1, -24, 1, notificationPosition)}, 0.2):Play()
			end
		end)

		ChildRemoved = true
	end

	-- Auto remove notification after a delay
	task.delay(options.duration, function()
		if Notification then
			for _, data in ipairs(Utility:getTransparentObjects(Notification)) do
				Utility:tween(data.object, {[data.property] = 1}, 0.2):Play()
			end

			Utility:tween(Notification, {["BackgroundTransparency"] = 1}, 0.2):Play()

			task.wait(0.2)
			Notification:Destroy()
		end
	end)

	-- Show notification
	Utility:tween(Notification, {Position = UDim2.new(1, -24, 1, notificationPosition)}, 0.2):Play()
	task.wait(0.2)

	-- Register to Theme
	Theme:registerToObjects({
		{object = Notification, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
		{object = Title, property = "BackgroundColor3", theme = {"PrimaryBackgroundColor"}},
		{object = Title, property = "TextColor3", theme = {"PrimaryTextColor"}},
		{object = Line, property = "BackgroundColor3", theme = {"Line"}},
		{object = Body, property = "TextColor3", theme = {"SecondaryTextColor"}},
	})
end

-- Save Manager, Theme Manager, UI settings
function Library:createManager(options: table)
	Utility:validateOptions(options, {
		folderName = {Default = "Leny", ExpectedType = "string"},
		icon = {Default = "124718082122263", ExpectedType = "string"}
	})

	local function getJsons() 
		local jsons = {}
		for _, file in ipairs(listfiles(options.folderName)) do
			if not string.match(file, "Theme") and not string.match(file, "autoload") then
				file = string.gsub(file, options.folderName .. "\\", "")
				file = string.gsub(file, ".json", "")
				table.insert(jsons, file)
			end
		end

		return jsons
	end

	local function getThemeJsons()
		local themeJsons = {}
		for _, file in ipairs(listfiles(options.folderName .. "/Theme")) do
			file = string.gsub(file, options.folderName .. "/Theme" .. "\\", "")
			file = string.gsub(file, ".json", "")
			table.insert(themeJsons, file)
		end

		return themeJsons
	end

	local function getSavedData()
		local SavedData = {
			Dropdown = {},
			Toggle = {},
			Keybind = {},
			Slider = {},
			TextBox = {},
			ColorPicker = {},
		}

		local Excluded = {"Line", "PrimaryColor", "PrimaryTextColor", "SecondaryTextColor", "PrimaryBackgroundColor", "SecondaryBackgroundColor", "TertiaryBackgroundColor", "ScrollingBarImageColor", "TabBackgroundColor"}

		for elementType, elementData in pairs(shared.Flags) do
			for elementName, addon in pairs(elementData) do
				if elementType == "Dropdown" and typeof(addon) == "table" and addon.getList and addon.getValue then
					SavedData.Dropdown[elementName] = {list = addon:getList(), value = addon:getValue()}
				end

				if elementType == "Toggle" and typeof(addon) == "table" and addon.getState then
					SavedData.Toggle[elementName] = {state = addon:getState()}
				end

				if elementType == "Slider" and typeof(addon) == "table" and addon.getValue then
					SavedData.Slider[elementName] = {value = addon:getValue()}
				end

				if elementType == "Keybind" and typeof(addon) == "table" and addon.getKeybind then
					SavedData.Keybind[elementName] = {keybind = addon:getKeybind()}
				end

				if elementType == "TextBox" and typeof(addon) == "table" and addon.getText then
					SavedData.TextBox[elementName] = {text = addon:getText()}
				end

				if not table.find(Excluded, elementName) and elementType == "ColorPicker" and typeof(addon) == "table" and addon.getColor then
					SavedData.ColorPicker[elementName] = {color = {addon:getColor().R * 255, addon:getColor().G * 255, addon:getColor().B * 255}}
				end
			end
		end

		return SavedData
	end

	local function getThemeData()
		local SavedData = {
			ColorPicker = {},
		}

		for elementType, elementData in pairs(shared.Flags) do
			for elementName, addon in pairs(elementData) do
				for _, themeName in ipairs({"Line", "PrimaryColor", "PrimaryTextColor", "SecondaryTextColor", "PrimaryBackgroundColor", "SecondaryBackgroundColor", "TertiaryBackgroundColor", "ScrollingBarImageColor", "TabBackgroundColor"}) do
					if elementName == themeName and elementType == "ColorPicker" and typeof(addon) == "table" and addon.getColor then
						SavedData.ColorPicker[elementName] = {color = {addon:getColor().R * 255, addon:getColor().G * 255, addon:getColor().B * 255}}
					end
				end
			end
		end

		return SavedData
	end

	local function loadSaveConfig(fileName: string)
		local decoded = game:GetService("HttpService"):JSONDecode(readfile(options.folderName .. "/" .. fileName .. ".json"))

		for elementType, elementData in pairs(shared.Flags) do
			for elementName, _ in pairs(elementData) do
				if elementType == "Dropdown" and decoded.Dropdown[elementName] and elementName ~= "Configs" then
					shared.Flags.Dropdown[elementName]:updateList({list = decoded.Dropdown.list, default = decoded.Dropdown.value})
				end

				if elementType == "Toggle" and decoded.Toggle[elementName] then
					shared.Flags.Toggle[elementName]:updateState({state = decoded.Toggle[elementName].state})
				end

				if elementType == "Slider" and decoded.Slider[elementName] then
					shared.Flags.Slider[elementName]:updateValue({value = decoded.Slider[elementName].value})
				end

				if elementType == "Keybind" and decoded.Keybind[elementName] then
					shared.Flags.Keybind[elementName]:updateKeybind({bind = decoded.Keybind[elementName].keybind})
				end

				if elementType == "TextBox" and decoded.TextBox[elementName] then
					shared.Flags.TextBox[elementName]:updateText({text = decoded.TextBox[elementName].text})
				end

				if elementType == "ColorPicker" and decoded.ColorPicker[elementName] then
					shared.Flags.ColorPicker[elementName]:updateColor({color = Color3.fromRGB(unpack(decoded.ColorPicker[elementName].color))})
				end
			end
		end
	end

	local function loadThemeConfig(fileName: string)
		local decoded = game:GetService("HttpService"):JSONDecode(readfile(options.folderName .. "/" .. "Theme/" .. fileName .. ".json"))

		for elementType, elementData in pairs(shared.Flags) do
			for elementName, _ in pairs(elementData) do
				if elementType == "ColorPicker" and decoded.ColorPicker[elementName] then
					shared.Flags.ColorPicker[elementName]:updateColor({color = Color3.fromRGB(unpack(decoded.ColorPicker[elementName].color))})
				end
			end
		end
	end

	local UI = Library:createTab({text = "UI", icon = options.icon})
	local Page = UI:createSubTab({text = "Page 1"})
	local UI = Page:createSection({text = "UI"})
	local SaveManager = Page:createSection({position = "Right", text = "Save Manager"})
	local ThemeManager = Page:createSection({position = "Right", text = "Theme Manager"})

	-- Create color pickers to change UI color
	UI:createPicker({
		text = "SecondaryTextColor", 
		default = Theme.SecondaryTextColor, 
		callback = function(color)
			Theme:setTheme("SecondaryTextColor", color)
		end,
	})

	UI:createPicker({
		text = "PrimaryTextColor", 
		default = Theme.PrimaryTextColor,
		callback = function(color)
			Theme:setTheme("PrimaryTextColor", color)
		end,
	})

	UI:createPicker({
		text = "PrimaryBackgroundColor", 
		default = Theme.PrimaryBackgroundColor, 
		callback = function(color)
			Theme:setTheme("PrimaryBackgroundColor", color)
		end,
	})

	UI:createPicker({
		text = "SecondaryBackgroundColor", 
		default = Theme.SecondaryBackgroundColor, 
		callback = function(color)
			Theme:setTheme("SecondaryBackgroundColor", color)
		end,
	})

	UI:createPicker({
		text = "TabBackgroundColor", 
		default = Theme.TabBackgroundColor, 
		callback = function(color)
			Theme:setTheme("TabBackgroundColor", color)
		end,
	})

	UI:createPicker({
		text = "PrimaryColor", 
		default = Theme.PrimaryColor, 
		callback = function(color)
			Theme:setTheme("PrimaryColor", color)
		end,
	})

	UI:createPicker({
		text = "Outline", 
		default = Theme.Line, 
		callback = function(color)
			Theme:setTheme("Line", color)
		end,
	})

	UI:createPicker({
		text = "TertiaryBackgroundColor", 
		default = Theme.TertiaryBackgroundColor, 
		callback = function(color)
			Theme:setTheme("TertiaryBackgroundColor", color)
		end,
	})

	UI:createPicker({
		text = "SecondaryTextColor", 
		default = Theme.SecondaryTextColor, 
		callback = function(color)
			Theme:setTheme("SecondaryTextColor", color)
		end,
	})

	UI:createPicker({
		text = "ScrollingBarImageColor", 
		default = Theme.ScrollingBarImageColor, 
		callback = function(color)
			Theme:setTheme("ScrollingBarImageColor", color)
		end,
	})	

	UI:createKeybind({
		text = "Hide UI", 
		default = "Insert",
		callback = function()
			ScreenGui.Enabled = not ScreenGui.Enabled
		end,
	})

	UI:createButton({text = "Destroy UI", callback = function() Library:destroy() end})

	-- File system
	if not isfolder(options.folderName) then
		makefolder(options.folderName)
	end

	if not isfolder(options.folderName .. "/Theme") then
		makefolder(options.folderName .. "/Theme")
	end

	local configName = SaveManager:createTextBox({text = "Config Name"})
	local jsons = getJsons()

	SaveManager:createButton({text = "Create Config", callback = function()
		local SavedData = getSavedData()
		local encoded = game:GetService("HttpService"):JSONEncode(SavedData)
		writefile(options.folderName .. "/" .. configName:getText() .. ".json", encoded)

		if shared.Flags.Dropdown["Configs"] then
			shared.Flags.Dropdown["Configs"]:updateList({list = getJsons(), default = {shared.Flags.Dropdown["Configs"]:getValue()}})
		end
	end})

	local Configs = SaveManager:createDropdown({text = "Configs", list = jsons})

	SaveManager:createButton({text = "Save/Overwrite Config", callback = function()
		local SavedData = getSavedData()
		local encoded = game:GetService("HttpService"):JSONEncode(SavedData)
		writefile(options.folderName .. "/" .. Configs:getValue() .. ".json", encoded)
		Configs:updateList({list = getJsons(), default = {Configs:getValue()}})
	end,})

	SaveManager:createButton({
		text = "Load Config", 
		callback = function()
			loadSaveConfig(Configs:getValue())
		end
	})

	-- Auto load
	SaveManager:createButton({
		text = "Set as Auto Load", 
		callback = function()
			writefile(options.folderName .. "/autoload.txt", Configs:getValue())
		end
	})

	if isfile(options.folderName .. "/autoload.txt") then
		loadConfig(readfile(options.folderName .. "/autoload.txt"))
	end

	local themeConfigName = ThemeManager:createTextBox({text = "Theme Config Name"})

	ThemeManager:createButton({
		text = "Create Theme Config", 
		callback = function()
			local ThemeData = getThemeData()
			local encoded = game:GetService("HttpService"):JSONEncode(ThemeData)
			writefile(options.folderName .. "/" .. "Theme/" .. themeConfigName:getText() .. ".json", encoded)

			if shared.Flags.Dropdown["Theme Configs"] then
				shared.Flags.Dropdown["Theme Configs"]:updateList({list = getThemeJsons(), default = {shared.Flags.Dropdown["Theme Configs"]:getValue()}})
			end
		end
	})

	local ThemeConfigs = ThemeManager:createDropdown({
		text = "Theme Configs", 
		list = getThemeJsons(),
	})

	ThemeManager:createButton({
		text = "Save Theme Config", 
		callback = function()
			local ThemeData = getThemeData()
			local encoded = game:GetService("HttpService"):JSONEncode(ThemeData)
			writefile(options.folderName .. "/" .. "Theme/" .. ThemeConfigs:getValue() .. ".json", encoded)
			ThemeConfigs:updateList({list = getThemeJsons(), default = {ThemeConfigs:getValue()}})
		end
	})

	ThemeManager:createButton({
		text = "Load Theme Config", 
		callback = function()
			loadThemeConfig(ThemeConfigs:getValue())
		end
	})

	self.managerCreated = true
end

-- Set users theme choice or default theme when initiliazed, could make this cleaner lol, but nah.
Theme:registerToObjects({
	{object = Glow, property = "ImageColor3", theme = {"PrimaryBackgroundColor"}},
	{object = Background, property = "BackgroundColor3", theme = {"SecondaryBackgroundColor"}},
	{object = Line , property = "BackgroundColor3", theme = {"Line"}},
	{object = Tabs , property = "BackgroundColor3", theme = {"PrimaryBackgroundColor"}},
	{object = Filler , property = "BackgroundColor3", theme = {"PrimaryBackgroundColor"}},
	{object = Title , property = "TextColor3", theme = {"PrimaryTextColor"}},
	{object = Assets.Pages.Fade, property = "BackgroundColor3", theme = {"PrimaryBackgroundColor"}},
})

-- Make UI Draggable and Resizable
Utility:draggable(Library, Glow)
Utility:resizable(Library, Glow.Background.Pages.Resize, Glow)

-- Clean up Addon objects with no Addons
task.spawn(function()
	while not Library.managerCreated do
		task.wait()
	end

	for _, addon in pairs(Library.Addons) do
		if addon.Parent == nil then
			addon:Destroy()
		end
	end
end)

return Library
