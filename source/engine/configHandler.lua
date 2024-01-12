class("ConfigHandler").extends()

local _spriteNeedsConfig

local _erase = table.erase
local _create = table.create
local _min = math.min
local _max = math.max

function ConfigHandler:init(configSpriteIds)
	self.data = table.create(0, 500)
	
	_spriteNeedsConfig = table.create(0, 10)
	for _, spriteId in pairs(configSpriteIds) do
		_spriteNeedsConfig[spriteId] = true
	end
end

function ConfigHandler:load(levelObjects)
	for _, levelObject in pairs(levelObjects) do
		if _spriteNeedsConfig[levelObject.id] == true then
			self.data[levelObject] = {
				config = levelObject.config,
				loadConfig = _create(6, 0),
			}
		end
	end
end

function ConfigHandler:getIndexedConfig(levelObject, loadIndex)
	local config = self.data[levelObject]
	
	for i=loadIndex, 1, -1 do
		if config.loadConfig[i] ~= nil then
			return config.loadConfig[i]
		end
	end
	
	return config.config
end

function ConfigHandler:setIndexedConfig(levelObject, loadIndex, config)
	local config = self.data[levelObject]

	if config.loadConfig[loadIndex] == nil then
		config.loadConfig[loadIndex] = _create(0, 1)
	end
	
	levelObject.sprite:copyConfig(config.loadConfig[loadIndex])
end

function ConfigHandler:loadConfig(levelObject, loadIndex)
	if _spriteNeedsConfig[levelObject.id] == true then
		local config = self:getIndexedConfig(levelObject, loadIndex)
		levelObject.sprite:loadConfig(config)
	end
end

function ConfigHandler:saveConfig(levelObject, loadIndex)
	if _spriteNeedsConfig[levelObject.id] == true then
		self:setIndexedConfig(levelObject, loadIndex, config)
	end
end

function ConfigHandler:discardConfig(levelObject, loadIndex, shouldDiscardAll)
	if _spriteNeedsConfig[levelObject.id] == true then
		if shouldDiscardAll == true then
			self.data[levelObject].loadConfig = table.create(6, 0)
		else
			self.data[levelObject].loadConfig[loadIndex] = nil
		end
	end
end
