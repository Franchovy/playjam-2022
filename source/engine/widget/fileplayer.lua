local sound <const> = playdate.sound
local config = {
	volume = 1,
	fileplayers = {} -- TODO: Same memory leak issue as dep.samples here.
}

function fileplayer(widget)
	function widget:loadFilePlayer(path)
		self.fileplayer = sound.fileplayer.new(path)
		self.fileplayer:setVolume(config.volume)
		
		table.insert(config.fileplayers, self.fileplayer)
	end
	
	function widget:playFilePlayer()
		if AppConfig.enableBackgroundMusic == false then
			return
		end
		
		self.fileplayer:play(0)
	end
	
	function widget:stopFilePlayer()
		self.fileplayer:stop()
	end
	
	widget.fileplayers = {}
end

Settings:addCallback(kSettingsKeys.musicVolume, function(value)
	config.volume = value
	
	for _, player in pairs(config.fileplayers) do
		if player ~= nil then
			player:setVolume(value)
		end
	end
end)

Widget.register("fileplayer", fileplayer, config)