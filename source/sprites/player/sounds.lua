
function Wheel:initializeSamples()
	-- Load sound assets
	
	sampleplayer:addSample("coin", kAssetsSounds.coin, 0.5)
	sampleplayer:addSample("bump", kAssetsSounds.bump, 0.3)
	sampleplayer:addSample("land", kAssetsSounds.land, 0.2)
	sampleplayer:addSample("jump", kAssetsSounds.jump, 0.2)
		
	sampleplayer:addSample("death"..1, kAssetsSounds.death1, 0.6)
	sampleplayer:addSample("death"..2, kAssetsSounds.death2, 0.6)
	sampleplayer:addSample("death"..3, kAssetsSounds.death3, 0.6)
end

local synth = nil
local frequency = 440
local attack = 0.5
local decay = 1.2
local maxVolume = 1.0
local minVolume = 0.1

local volumeChangeSpeed = 0.3
local previousFrequency = nil

function Wheel:playMovementBasedSounds(velocityFactor)
	if AppConfig.sfx.disabled then
		return
	end
	
	if synth == nil then
		local sample = playdate.sound.sample.new(kAssetsSounds.rev)
		synth = playdate.sound.synth.new(sample)
		synth:setAttack(attack)
		synth:setDecay(decay)
	end
	
	local volume = 0.35
	local frequencyFactor = (velocityFactor + 1) * 2.5
	local volumeFactor = (velocityFactor + 1) * volume
	
	synth:setVolume(volume * volumeFactor)
	synth:playNote(frequency * frequencyFactor)
end
