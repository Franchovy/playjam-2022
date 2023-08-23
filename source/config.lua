AppConfig = {}

AppConfig["hideBackground"] = true

local levelComponents = {}
levelComponents["platformMoving"] = true
levelComponents["platformFloor"] = false
levelComponents["killBlock"] = true
levelComponents["wind"] = true
levelComponents["coin"] = true
levelComponents["wallOfDeath"] = true

AppConfig["disableComponents"] = levelComponents

AppConfig["disableBackgroundMusic"] = true