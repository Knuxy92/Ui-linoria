local TextBox = {}
TextBox.__index = TextBox

function TextBox.new(context: table)
	local self = setmetatable(context, TextBox)	
	return self
end

function TextBox:handleTextBox()
	self.autoSizeTextBox()
	
	self.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		self.autoSizeTextBox()
	end)
	
	self.TextBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			self.callback(self.TextBox.Text)
		end
	end)
end


return TextBox
