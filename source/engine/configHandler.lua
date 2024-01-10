class("ConfigHandler").extends()

function ConfigHandler:init(configSpriteIds)
	self.data = table.create(0, 500)
	
	self.spriteNeedsConfig = table.create(0, 10)
	for _, spriteId in pairs(configSpriteIds) do
		self.spriteNeedsConfig[spriteId] = true
	end
end

function ConfigHandler:load(levelObjects)
	for _, levelObject in pairs(levelObjects) do
		if self.spriteNeedsConfig[levelObject.id] == true then
			self.data[levelObject] = {
				config = levelObject.config,
				loadConfig = table.create(6, 0),
			}
		end
	end
end
