AppConfig = {}

AppConfig["enableParalaxBackground"] = true

local levelComponents = {}
levelComponents["platformMoving"] = true
levelComponents["platformFloor"] = true
levelComponents["killBlock"] = true
levelComponents["wind"] = true
levelComponents["coin"] = true
levelComponents["wallOfDeath"] = true

AppConfig["enableComponents"] = levelComponents

AppConfig["enableBackgroundMusic"] = true