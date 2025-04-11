local Navigation = {}
Navigation.__index = Navigation

local Utility = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Averiias/Leny-UI/refs/heads/main/Modules/Utility.lua", true))()
local Popup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Averiias/Leny-UI/refs/heads/main/Modules/Popup.lua", true))()

function Navigation.new(context: table)
	local self = setmetatable(context, Navigation)
	Utility:validateKeys(self, {"ScrollingFrame", "Pages", "Page", "tweenTabOn", "tweenTabsOff", "tweenTabsOff", "animation", "hoverOn"})
	return self
end

function Navigation:enableFirstTab()
	self.tweenTabOn()
	self.Page.Visible = true
end

function Navigation:selectTab()
	local function showPage()
		for _, page in ipairs(self.Pages:GetChildren()) do
			if string.match(page.Name, "Page") and page.Visible then
				page.Visible = false
			end
		end

		self.Page.Visible = true
		self.animation()
	end

	local function tweenTabs(onTween, offTweenCallback)
		for _, tab in ipairs(self.ScrollingFrame:GetChildren()) do
			if string.match(tab.Name, "Tab") then
				self.tweenTabsOff(tab)
			end
		end

		self.tweenTabOn()
	end

	return function()
		if self.Page.Visible then
			return
		end
		
		Popup:hidePopups(false, self.Popups)
		showPage()
		tweenTabs()
	end
end

function Navigation:hoverEffect(boolean)
	return function()	
		if self.Page.Visible then
			return
		end

		if boolean then
			self.hoverOn()
		else
			self.hoverOff()
		end
	end
end

return Navigation
