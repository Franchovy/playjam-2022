import "CoreLibs/object"
import "settings"

-- Libraries

local sound <const> = playdate.sound

--

sampleplayer = {
	sampleplayers = {},
	config = {
		volume = 1
	}
}

function sampleplayer:addSample(key, filePath, volume)
	local player = sound.sampleplayer.new(filePath)
	volume = volume or 1
	
	self.sampleplayers[key] = {
		player = player,
		volume = volume
	}
	
	player:setVolume(volume * self.config.volume)
end

function sampleplayer:playSample(key, callback)
	if AppConfig.sfx.disabled then
		return 
	end
	
	local player = self.sampleplayers[key].player
	
	if callback then
		player:setFinishCallback(callback)
	end
	
	player:play()
end

function sampleplayer:getSample(key)
	return self.sampleplayers[key].player:getSample()
end

Settings:addCallback(kSettingsKeys.sfxVolume, function(value)
	sampleplayer.config.volume = value
	
	for _, sampleplayer in pairs(sampleplayer.sampleplayers) do
		sampleplayer.player:setVolume(sampleplayer.volume * value)
	end
end)
