AppConfig = {}

AppConfig["enableParalaxBackground"] = true

local levelComponents = {}
levelComponents["platformMoving"] = true
levelComponents["platformFloor"] = true
levelComponents["killBlock"] = true
levelComponents["wind"] = true
levelComponents["coin"] = true
levelComponents["wallOfDeath"] = false

AppConfig["enableComponents"] = levelComponents

AppConfig["enableBackgroundMusic"] = true

AppConfig["chunkLength"] = 50