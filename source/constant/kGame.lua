kGame = {
	gridSize = 24,
	worldPosToGrid = function(x, y)
		return x // kGame.gridSize, y // kGame.gridSize
	end,

	gridPosToWorld = function(x, y)
		return x * kGame.gridSize, y * kGame.gridSize
	end
}