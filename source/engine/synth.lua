import "settings"

local sound <const> = playdate.sound

synth = {
	_synthData = {},
	config = {
		volume = 1
	}
}

function synth:create(key, config)
	local player = sound.synth.new(config.sample)
	player:setAttack(config.attack)
	player:setDecay(config.decay)
	
	self._synthData[key] = {
		player = player,
		volume = config.volume,
		frequency = config.frequency
	}
end

function synth:play(key, frequencyFactor, volumeFactor)
	local synthData = self._synthData[key]
	
	synthData.player:setVolume(synthData.volume * volumeFactor * self.config.volume)
	synthData.player:playNote(synthData.frequency * frequencyFactor)
end

Settings:addCallback(kSettingsKeys.sfxVolume, function(value)
	synth.config.volume = value
end)
