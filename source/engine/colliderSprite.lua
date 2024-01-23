import "playdate"
import "constant"

local gfx <const> = playdate.graphics

-- Base class for a gfx.sprite that overrides default sdk collision handling
class("ColliderSprite").extends(gfx.sprite)

function ColliderSprite:init()
    ColliderSprite.super.init(self)

    self._collider = {}
    self._colliderType = kColliderType.none
    self._collisionType = kCollisionType.ignore -- Defaults to ignore to preserve computation
end

function ColliderSprite:update()
    ColliderSprite.super:update()
end

-- colliderType is expected to be a kColliderType constant and collider the corresponding playdate.geometry object
function ColliderSprite:setCollider(colliderType, collider)
    assert(colliderType ~= kColliderType.none, "Passed colliderType can't be none")

    if colliderType == kColliderType.rect then
        assert(getmetatable(collider) == playdate.geometry.rect, "colliderType is rect but collider is not a valid playdate.geometry.rect")
    end

    if colliderType == kColliderType.circle then
        assert(getmetatable(collider) == playdate.geometry.arc, "colliderType is circle but collider is not a valid playdate.geometry.arc")
        -- enforce full circle
        collider.startAngle = 0
        collider.endAngle = 360
    end

    self._collider = collider
    self._colliderType = colliderType
end

function getCollider()
    return {type = self._colliderType, collider = self._collider}
end

-- collisionType is expected to be a kCollisionType constant
function ColliderSprite:setCollisionType(collisionType)
    -- TODO: add failsafe if collision type is invalid
    self._collisionType = collisionType
end

function ColliderSprite:getCollisionType()
    return self._collisionType
end