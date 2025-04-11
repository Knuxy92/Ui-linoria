local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(context: table)
	local self = setmetatable(context, Dropdown)
	self.value = self.default
	self.multipleTable = {}
	-- validatekeys later
	return self
end

function Dropdown:handleDropdown()
	local function updateValue(newValue)
		self.value = newValue
		self.callback(self.value)

		if (typeof(newValue) == "table" and self.multiple) then
			if self.multipleTable[1] == nil then
				self.TextButton.Text = "None"
			else
				self.TextButton.Text = table.concat(newValue, ", ")
			end
		else
			self.TextButton.Text = tostring(newValue)
		end
	end

	local function setDefault(dropButton, value)
		if table.find(self.default, value) then
			self.tweenDropButtonOn(dropButton)

			if not self.multiple then
				updateValue(value)
			else
				table.insert(self.multipleTable, value)
				updateValue(self.multipleTable)
			end
		end
	end

	local function choose(dropButton, value)
		local function single()
			for _, button in ipairs(self.DropButtons:GetChildren()) do
				if button.Name == "DropButton" then
					self.tweenDropButtonOff(button.TextButton)					
				end
			end

			self.tweenDropButtonOn(dropButton)
			updateValue(value)
		end

		local function multiple()
			if not table.find(self.multipleTable, value) then
				self.tweenDropButtonOn(dropButton)
				table.insert(self.multipleTable, value)
			else
				self.tweenDropButtonOff(dropButton)
				table.remove(self.multipleTable, table.find(self.multipleTable, value))
			end

			updateValue(self.multipleTable)
		end

		return function()
			if not self.multiple then
				single()
			else
				multiple()
			end
		end
	end

	-- Create all drop buttons
	for _, value in ipairs(self.list) do
		local dropButton = self.createDropButton(value)	
		setDefault(dropButton, value)
		dropButton.MouseButton1Down:Connect(choose(dropButton, value))
	end
end

function Dropdown:updateList(options: table)
	for _, button in ipairs(self.DropButtons:GetChildren()) do
		if button.Name == "DropButton" then
			button:Destroy()				
		end
	end

	self.list = options.list or {}
	self.default = options.default or {}
	self.multipleTable = {}
	self:handleDropdown()
end

function Dropdown:getValue()
	return self.value
end

return Dropdown
