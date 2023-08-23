
function Wheel:initializeSamples()
	-- Load sound assets
	
	sampleplayer:addSample("hurt", "sfx/player_hurt_v1")
	sampleplayer:addSample("coin", "sfx/coin_pickup_v1")
	sampleplayer:addSample("touch_ground", "sfx/player_touches_ground_v1")
	sampleplayer:addSample("backward_start", "sfx/wheel_backward_v1")
	sampleplayer:addSample("backward_loop", "sfx/wheel_backward_loop_v1")
	sampleplayer:addSample("forward_start", "sfx/wheel_forward_v1")
	sampleplayer:addSample("forward_loop", "sfx/wheel_forward_loop_v1")
	sampleplayer:addSample("wind", "sfx/wind_v1")
end

function Wheel:playLandingBasedSound()
	
end

local synth = nil
local frequency = 440
local attack = 0.5
local decay = 1.2
local maxVolume = 0.7
local minVolume = 0.0

local volumeChangeSpeed = 0.1
local frequencyChangeSpeed = 10
local previousVolume = nil
local previousFrequency = nil

function Wheel:playMovementBasedSounds(velocityFactor)
	if synth == nil then
		local sample = playdate.sound.sample.new("sfx/wheel_movement")
		synth = playdate.sound.synth.new(sample)
		synth:setAttack(attack)
		synth:setDecay(decay)
	end
	
	local volume = math.max(velocityFactor * maxVolume, minVolume)
	local frequencyFactor = (velocityFactor + 1) * 0.7
	
	-- update frequency and volume
	if previousVolume ~= nil then
		previousVolume = math.approach(previousVolume, volume, volumeChangeSpeed)
	else
		previousVolume = volume
	end
	
	local newFrequency = frequency * frequencyFactor
	if previousFrequency ~= nil then
		previousFrequency = math.approach(previousFrequency, newFrequency, frequencyChangeSpeed)
	else
		previousFrequency = newFrequency
	end
	
	synth:setVolume(previousVolume)
	synth:playNote(previousFrequency)
end

local windSampleHasFinishedPlaying = false
function Wheel:playWindBasedSounds()
	if self.currentWindPower > 0 and windSampleHasFinishedPlaying then
		sampleplayer:playSample("wind", function () windSampleHasFinishedPlaying = true end)
	end
end
