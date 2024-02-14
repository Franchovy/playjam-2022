import "engine"
import "constant"
import "engine/colliderSprite"

class('PlatformCollision').extends(ColliderSprite)

function PlatformCollision.new()
    return PlatformCollision()
end

function PlatformCollision:init()
    PlatformCollision.super.init()

    self:setCenter(0, 0)
    print('inited')
end

function PlatformCollision:ready()
    print('ready')
end

function PlatformCollision:loadConfig(config)
    print('config load')
end