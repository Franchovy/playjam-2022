local dirFonts = "assets/fonts/"
local dirImages = "assets/images/"
local dirSounds = "assets/sounds/"
local dirTracks = "assets/tracks/"
local dirLevels = "assets/levels/"

kAssetsImages = {
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
	screw = dirImages.."menu/screw",
	transitionBackground = dirImages.."transition/background",
	transitionForeground = dirImages.."transition/foreground",
	menuSettings = dirImages.."menu/settings"
}

kAssetsSounds = {
	checkpointSet = dirSounds.."checkpoint",
	coin = dirSounds.."coin",
	death1 = dirSounds.."death1",
	death2 = dirSounds.."death2",
	death3 = dirSounds.."death3",
	menuSelectFail = dirSounds.."menu-fail",
	menuSelect = dirSounds.."menu-navigate",
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
	twinbee = dirFonts.."Twinbee",
	twinbee2x = dirFonts.."Twinbee_2x",
	twinbee15x = dirFonts.."Twinbee_1.5x",
	marbleMadness = dirFonts.."Marble Madness"
}

kAssetsLevels = {
	mountain = dirLevels.."1_mountain.json",
	space = dirLevels.."2_space.json",
	city = dirLevels.."3_city.json",
}