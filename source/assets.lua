local dirFonts = "assets/fonts/"
local dirImages = "assets/images/"
local dirSounds = "assets/sounds/"
local dirTracks = "assets/tracks/"
local dirLevels = "assets/levels/"

kAssetsImages = {
	menuWheel = dirImages.."menu/wheel",
	checkpoint = dirImages.."sprites/checkpoint/checkpoint",
	checkpointSet = dirImages.."sprites/checkpoint/checkpoint_isSet",
	coin = dirImages.."sprites/coin",
	killBlock = dirImages.."sprites/killBlock",
	platform = dirImages.."sprites/platform",
	levelEnd = dirImages.."sprites/portal",
	wheel = dirImages.."sprites/wheel/wheel",
	star = dirImages.."sprites/star/star",
	starMenu = dirImages.."sprites/menu/star",
	particles = dirImages.."sprites/particles",
	background = dirImages.."sprites/background",
	background2 = dirImages.."sprites/background2",
	background3 = dirImages.."sprites/background3",
	background4 = dirImages.."sprites/background4",
	menuMountain = dirImages.."backgrounds/menu-mountain",
	menuSpace = dirImages.."backgrounds/menu-space",
	menuCity = dirImages.."backgrounds/menu-city",
	screw = dirImages.."menu/screw"
}

kAssetsSounds = {
	checkpointSet = dirSounds.."checkpoint",
	coin = dirSounds.."coin",
	death1 = dirSounds.."death1",
	death2 = dirSounds.."death2",
	menuSelectFail = dirSounds.."menu-fail",
	menuSelect = dirSounds.."menu-select",
	wheelMovement = dirSounds.."wheel_movement",
	click = dirSounds.."click",
	jump = dirSounds.."jump",
	intro = dirSounds.."intro",
	land = dirSounds.."land",
	bump = dirSounds.."bump",
	land = dirSounds.."land",
	rev = dirSounds.."rev",
	menuAccept = dirSounds.."menu-accept",
	levelCompleteBlink = dirSounds.."levelCompleteBlink",
	levelCompleteCard = dirSounds.."levelCompleteCard",
	tick = dirSounds.."tick",
	transitionSwoosh = dirSounds.."transition-swoosh",
	transitionSlam = dirSounds.."transition-slam",
	transitionOut = dirSounds.."transition-out"
}

kAssetsTracks = {
	menu = dirTracks.."menu"
}

kAssetsFonts = {
	twinbee = dirFonts.."Twinbee (1)",
	marbleMadness = dirFonts.."Marble Madness [unused 1] (1)"
}

kAssetsLevels = {
	mountain = dirLevels.."1_mountain.json",
	space = dirLevels.."2_space.json",
	city = dirLevels.."3_city.json",
}