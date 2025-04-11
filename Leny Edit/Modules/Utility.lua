local Utility = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Utility:tween(object, properties, duration, easingStyle, easingDirection)
	local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle[easingStyle or "Circular"], Enum.EasingDirection[easingDirection or "Out"])
	return TweenService:Create(object, tweenInfo, properties)
end

function Utility:lookBeforeChildOfObject(indexFromLoop, object, specifiedObjectName)
	local Object = object:GetChildren()[indexFromLoop-1]
	return Object and Object.Name == specifiedObjectName, Object
end

function Utility:validateOptions(options, defaults)
	assert(type(options) == "table", "Expected options to be a table")

	for key, value in pairs(defaults) do
		options[key] = options[key] or value.Default
		assert(typeof(options[key]) == value.ExpectedType, "Expected '" .. key .. "' to be a " .. value.ExpectedType)
	end
end

function Utility:validateContext(context)
	assert(type(context) == "table", "Expected context to be a table")

	for key, tbl in pairs(context) do
		assert(typeof(tbl.Value) == tbl.ExpectedType, "Expected '" .. key .. "' to be a " .. tbl.ExpectedType)
		context[key] = tbl.Value
	end 

	return context
end

function Utility:getTransparentObjects(objects: Instance)
	local TransparentObjects = {}

	for _, object in ipairs(objects:GetDescendants()) do	
		if object.Name ~= "CurrentValueLabel" and object.Name ~= "Checkmark" then -- exclusions, doing this way since it's more performant, and I'm lazy to do it in another way
			local hasBackgroundTransparency, backgroundTransparencyValue = pcall(function()
				return object.BackgroundTransparency
			end)

			local hasTextTransparency, textTransparencyValue = pcall(function()
				return object.TextTransparency
			end)

			local hasImageTransparency, imageTransparencyValue = pcall(function()
				return object.ImageTransparency
			end)

			if (hasBackgroundTransparency and backgroundTransparencyValue <= 0.1)  then
				table.insert(TransparentObjects, {object = object, property = "BackgroundTransparency"})
			end

			if (hasTextTransparency and textTransparencyValue <= 0.1) then
				table.insert(TransparentObjects, {object = object, property = "TextTransparency"})
			end

			if (hasImageTransparency and imageTransparencyValue <= 0.1) then
				table.insert(TransparentObjects, {object = object, property = "ImageTransparency"})
			end
		end
	end

	return TransparentObjects
end

function Utility:validateKeys(context: table, requiredKeys: table)
	for _, key in ipairs(requiredKeys) do
		assert(context[key], "Context." .. key .. " is nil")
	end
end

local function dragging(library: table, ui: Instance, uiForResizing: Instance, callback)
	local dragging, dragInput, dragStartPosition, currentUIPosition, currentUISizeForUIResizing
	local eventNameToEnableDrag = "InputBegan"

	local function update(input)
		if typeof(dragStartPosition) == "Vector2" then
			input = Vector2.new(input.Position.X, input.Position.Y)
		else
			input = input.Position
		end

		local delta = input - dragStartPosition
		callback(delta, ui, currentUIPosition, currentUISizeForUIResizing)
	end

	local function setInitialPositionsAndSize(initialDragStartPosition)
		dragging = true
		library.dragging = true
		dragStartPosition = initialDragStartPosition
		currentUIPosition = ui.Position

		if uiForResizing then
			currentUISizeForUIResizing = uiForResizing.Size
		end
	end

	local enableDrag = function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setInitialPositionsAndSize(input.Position)
		end
	end

	if ui.ClassName == "TextButton" then
		eventNameToEnableDrag = "MouseButton1Down"

		enableDrag = function()
			setInitialPositionsAndSize(UserInputService:GetMouseLocation())
		end
	end

	local function disableDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			library.dragging = false
		end
	end

	local function handleUpdate(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end
	
	table.insert(library.Connections, ui[eventNameToEnableDrag]:Connect(enableDrag))
	table.insert(library.Connections, UserInputService.InputChanged:Connect(handleUpdate))
	table.insert(library.Connections, UserInputService.InputEnded:Connect(disableDrag))
end

function Utility:draggable(library: table, uiToEnableDrag: Instance)
	dragging(library, uiToEnableDrag, nil, function(delta, ui, currentUIPosition)
		self:tween(ui, {Position = UDim2.new(currentUIPosition.X.Scale, currentUIPosition.X.Offset + delta.X, currentUIPosition.Y.Scale, currentUIPosition.Y.Offset + delta.Y)}, 0.15):Play()
	end)
end

function Utility:resizable(library: table, uiToEnableDrag: Instance, uiToResize: Instance)
	dragging(library, uiToEnableDrag, uiToResize, function(delta, ui, currentUIPosition, currentUISizeForUIResizing)
		self:tween(uiToResize, {Size = UDim2.fromOffset(currentUISizeForUIResizing.X.Offset + delta.X, currentUISizeForUIResizing.Y.Offset + delta.Y)}, 0.15):Play()
	end)
end

return Utility
