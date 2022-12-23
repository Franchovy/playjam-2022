import "engine"
import "MenuScene"
import "GameScene"
import "GameOverScene"

scenes = {
	menu = nil,
	game = nil,
	gameover = nil
}

function loadInitialScene()
	scenes.menu = MenuScene()
end

function loadAllScenes()
	scenes.game = GameScene()
	scenes.gameover = GameOverScene()
end