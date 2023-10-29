import "engine"
import "MenuScene"
import "GameScene"
import "GameOverScene"
import "title"

scenes = {
	menu = nil,
	game = nil,
	gameover = nil
}

function loadAllScenes()
	scenes.game = GameScene()
	scenes.gameover = GameOverScene()
end