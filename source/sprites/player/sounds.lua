
function Wheel:initializeSamples()
	-- Load sound assets
	
	--sampleplayer:addSample("hurt", kAssetsSounds.death1)
	sampleplayer:addSample("coin", kAssetsSounds.coin, 0.8)
	sampleplayer:addSample("bump", kAssetsSounds.bump, 0.3)
	sampleplayer:addSample("land", kAssetsSounds.land, 0.2)
	sampleplayer:addSample("jump", kAssetsSounds.jump, 0.2)
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
	
	local volume = 0.15
	local frequencyFactor = (velocityFactor + 1) * 2.5
	
	synth:setVolume(volume)
	synth:playNote(frequency * frequencyFactor)
end
