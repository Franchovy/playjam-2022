function playdate.file.mkdirIfNeeded(path)
	if not playdate.file.isdir(path) then
		playdate.file.mkdir(path)
	end
end