import "engine"

-- ========== --
-- Game class --

-- loads levels, holds the game objects

class("Game").extends()

Game = Game()

gameState = {
	lobby = 0,
	playing = 1,
	ended = 2,
}

function Game:init() 
	-- Update game state
	
	self.state = gameState.lobby
	self.scene = GameScene
	
	-- Create Sound fileplayer for background music
	soundFile = sound.fileplayer.new("music/music_main")

	-- Load background music
	
	soundFile:play(0)
	soundFile:pause()
end

function Game:start()
	self.state = gameState.playing
end

function Game:update()
	
end

function Game:setEnded()
	
end

function Game:ended()
	self.hasJustEnded = true
	self.ended = true
end
