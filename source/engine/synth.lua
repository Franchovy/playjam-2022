synth = {
	_synthData = {}
}

function synth:create(key, config)
	local player = playdate.sound.synth.new(config.sample)
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
	
	synthData.player:setVolume(synthData.volume * volumeFactor)
	synthData.player:playNote(synthData.frequency * frequencyFactor)
end