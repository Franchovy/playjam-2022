local sound <const> = playdate.sound
local config = {
	volume = 1,
	sampleplayers = table.create(0, 24)
}

setmetatable(config.sampleplayers, table.weakKeysMetatable)

function samples(widget)
	function widget:loadSample(path, volume, key)
		if key == nil then
			key = path
		end
		local player = sound.sampleplayer.new(path)
		assert(player ~= nil and (err == nil), err)
		
		if volume == nil then
			volume = 1
		end
		
		player:setVolume(volume * config.volume)
		
		self.samples[key] = player
		
		config.sampleplayers[player] = volume * config.volume
	end
	
	function widget:playSample(key, finishedCallback)
		self.samples[key]:play()
		
		if finishedCallback ~= nil then
			self.samples[key]:setFinishCallback(finishedCallback)
		end
	end
	
	function widget:unloadSample(key)
		local player = self.samples[key]
		
		self.samples[key] = nil
		
		config.sampleplayers[player] = nil
	end
	
	widget.samples = {}
	
	widget:_addUnloadCallback(function()
		widget.samples = {}
	end)
end

Settings:addCallback(kSettingsKeys.sfxVolume, function(value)
	config.volume = value
	
	for samplePlayer, volume in pairs(config.sampleplayers) do
		samplePlayer:setVolume(volume * value)
	end
end)

Widget.register("samples", samples, config)
	