local Theme = {
	PrimaryBackgroundColor = Color3.fromRGB(0,0,0),
	SecondaryBackgroundColor = Color3.fromRGB(0,0,0),
	TertiaryBackgroundColor = Color3.fromRGB(0,0,0),
	TabBackgroundColor = Color3.fromRGB(255, 255, 255),
	PrimaryTextColor = Color3.fromRGB(255, 255, 255),
	SecondaryTextColor = Color3.fromRGB(255, 255, 255),
	PrimaryColor = Color3.fromRGB(0,0,0),
	ScrollingBarImageColor = Color3.fromRGB(63, 63, 63),
	Line =  Color3.fromRGB(87,87,87),
}


local ThemeObjects = {}

for themeIndexName, _ in pairs(Theme) do
	ThemeObjects[themeIndexName] = {}
end

function Theme:registerToObjects(objects: table, elementType: string)
	for _, data in ipairs(objects) do
		if data.object.Name == "Frame" or data.object.Name == "Line" or data.object.Name == "CurrentTabLabel" or data.object.Name == "SubTabs" then
			for _, theme in pairs(data.theme) do
				data.object[data.property] = Theme[theme]
			end
		end
	end

	for _, data in pairs(objects) do
		for _, theme in pairs(data.theme) do
			if data.circleOn then
				table.insert(ThemeObjects[theme], {object = data.object, property = data.property, circleOn = data.circleOn})
			else
				table.insert(ThemeObjects[theme], {object = data.object, property = data.property})

				-- don't do return since it stops the for loop, tab and subtab do tweens to set the colors so this is nice for me!
				if (theme ~= "PrimaryColor" and (elementType ~= "Tab" or elementType ~= "SubTab")) then
					data.object[data.property] = Theme[theme]
				end
			end
		end
	end
end

function Theme:setTheme(themeName: string, color: Color3)
	local tolerance = 0.01 -- 1% difference check

	local getDifference = function(colorPropertyOne, colorPropertyTwo)
		return math.abs(colorPropertyOne.R - colorPropertyTwo.R) + math.abs(colorPropertyOne.G - colorPropertyTwo.G) + math.abs(colorPropertyOne.B - colorPropertyTwo.B)
	end

	if themeName == "SecondaryTextColor" and getDifference(color, Theme["PrimaryColor"]) <= 0.01 then
		warn("conflicting " .. themeName .. " with " .. "PrimaryTextColor")
		return
	end

	if themeName == "PrimaryColor" and getDifference(color, Theme["SecondaryTextColor"]) <= 0.01 then
		warn("conflicting " .. themeName .. " with " .. "SecondaryTextColor")
		return
	end

	if themeName == "SecondaryBackgroundColor" and getDifference(color, Theme["PrimaryBackgroundColor"]) <= 0.01 then
		warn("conflicting " .. themeName .. " with " .. "PrimaryBackgroundColor")
		return
	end

	if themeName == "PrimaryBackgroundColor" and getDifference(color, Theme["SecondaryBackgroundColor"]) <= 0.01 then
		warn("conflicting " .. themeName .. " with " .. "SecondaryBackgroundColor")
		return
	end

	for _, data in ipairs(ThemeObjects[themeName]) do
		if getDifference(data.object[data.property], Theme[themeName]) <= tolerance then
			if not data.circleOn then
				data.object[data.property] = color
			end

			if themeName == "TertiaryBackgroundColor" and data.circleOn then
				data.object[data.property] = color
			end
		end
	end

	Theme[themeName] = color
end

return Theme
