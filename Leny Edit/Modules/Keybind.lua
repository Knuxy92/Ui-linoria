local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(context: table)
	local self = setmetatable(context, Keybind)

	self.onHeldDebounce = false

	-- Auto size background
	self.autoSizeBackground()
	self.TextButton:GetPropertyChangedSignal("Text"):Connect(self.autoSizeBackground)

	return self
end

function Keybind:handleKeybind()
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")

	local changingBind = false

	self.TextButton.MouseButton1Down:Connect(function()
		changingBind = true
		self.Library.processedEvent = changingBind

		for index, keyCode in ipairs(self.Exclusions) do
			if self.TextButton.Text == keyCode then
				table.remove(self.Exclusions, index)
			end
		end

		self.TextButton.Text = "Changing..."
	end)

	local inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent and input.UserInputType == Enum.UserInputType.Keyboard then
			if changingBind and (not table.find(self.Exclusions, input.KeyCode.Name)) then
				self.TextButton.Text = input.KeyCode.Name
				table.insert(self.Exclusions, input.KeyCode.Name)
				changingBind = false
				self.Library.processedEvent = changingBind
			end

			if not changingBind and input.KeyCode.Name == self.TextButton.Text and not self.Library.processedEvent then
				if self.onHeld then
					self.onHeldDebounce = true

					while self.onHeldDebounce do
						self.callback(input.KeyCode.Name)
						task.wait()
					end
				else
					self.callback(input.KeyCode.Name)
				end				
			end
		end
	end)

	local inputEnded = UserInputService.InputEnded:Connect(function(input, gameProccesedEvent)
		if not gameProccesedEvent and input.UserInputType == Enum.UserInputType.Keyboard and self.onHeld and input.KeyCode.Name == self.TextButton.Text then
			self.onHeldDebounce = false
		end
	end)

	table.insert(self.Connections, inputBegan)
	table.insert(self.Connections, inputEnded)
end

function Keybind:updateKeybind(options: table)
	options.bind = options.bind or "None"
	self.onHeld = options.onHeld or false

	if not table.find(self.Exclusions, options.bind) then
		self.TextButton.Text = options.bind
		table.insert(self.Exclusions, options.bind)
	else
		self.TextButton.Text = "None"
		warn("You already have this key binded")
	end
end

return Keybind
