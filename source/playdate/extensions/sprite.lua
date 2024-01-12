
playdate.sprite = playdate.graphics.sprite

function playdate.sprite.loadConfig(self, config)
	-- Not Implemented
end

function playdate.sprite.copyConfig(self, config)
	-- Not Implemented
end

function playdate.sprite.getConfigCopy(self)
	return table.shallowcopy(self.config)
end