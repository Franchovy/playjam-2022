import "engine"
import "MenuScene"
import "GameScene"
import "GameOverScene"

scenes = {
	menu = nil,
	game = nil,
	gameover = nil
}

function loadAllScenes()
	scenes.game = GameScene()
	scenes.gameover = GameOverScene()
end