
function Wheel:initializeSamples()
	-- Load sound assets
	
	sampleplayer:addSample("hurt", kAssetsSounds.playerDied)
	sampleplayer:addSample("coin", kAssetsSounds.coin)
end

local synth = nil
local frequency = 440
local attack = 0.5
local decay = 1.2
local maxVolume = 1.0
local minVolume = 0.1

local volumeChangeSpeed = 0.3
local frequencyChangeSpeed = 15
local previousVolume = nil
local previousFrequency = nil

function Wheel:playMovementBasedSounds(velocityFactor)
	if synth == nil then
		local sample = playdate.sound.sample.new(kAssetsSounds.wheelMovement)
		synth = playdate.sound.synth.new(sample)
		synth:setAttack(attack)
		synth:setDecay(decay)
	end
	
	local volume = math.max(velocityFactor * maxVolume, minVolume)
	local frequencyFactor = (velocityFactor + 1) * 0.7
	
	-- update frequency and volume
	if previousVolume ~= nil then
		previousVolume = math.approach(previousVolume, volume, velocityFactor * volumeChangeSpeed)
	else
		previousVolume = volume
	end
	
	local newFrequency = frequency * frequencyFactor
	if previousFrequency ~= nil then
		previousFrequency = math.approach(previousFrequency, newFrequency, velocityFactor * frequencyChangeSpeed)
	else
		previousFrequency = newFrequency
	end
	
	synth:setVolume(previousVolume)
	synth:playNote(previousFrequency)
end
