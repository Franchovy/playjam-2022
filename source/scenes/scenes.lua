import "engine"
import "MenuScene"
import "GameScene"
import "GameOverScene"
import "widget"
import "title"
import "levelSelect"

scenes = {
	menu = nil,
	game = nil,
	gameover = nil
}

function loadAllScenes()
	scenes.game = GameScene()
	scenes.gameover = GameOverScene()
end