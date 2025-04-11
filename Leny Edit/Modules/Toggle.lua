local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(context: table)
	local self = setmetatable(context, Toggle)
	-- validatekeys later
	return self
end

function Toggle:switch()	
	return function()
		self.state = not self.state

		if self.state then
			self.switchOn()			
		else
			self.switchOff()			
		end

		self.callback(self.state)
	end
end

function Toggle:updateState(options: table)
	options.state = options.state or false
	self.state = not options.state
	self:switch()()
end

return Toggle
