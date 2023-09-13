import "levels"

GameConfig = {}

function GameConfig.getLevelConfig(level)
	return {
		theme = level,
		components = levelComponents[level],
		level = level,
	}
end