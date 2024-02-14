import "engine"
import "constant"
import "engine/colliderSprite"

class('PlatformCollision').extends(ColliderSprite)

function PlatformCollision.new()
    return PlatformCollision()
end

function PlatformCollision:init()
    PlatformCollision.super.init(self)

    self:setCenter(0, 0)
    self:setCollisionType(kCollisionType.static)
end

function PlatformCollision:ready(config)
    self:setCollider(kColliderType.rect, rectNew(self.x, self.y, kGame.gridSize * config.w, kGame.gridSize * config.h))
    self:readyToCollide()
end