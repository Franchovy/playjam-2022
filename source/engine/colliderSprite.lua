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

-- Returns true if a rect and a circle intersect
function ColliderSprite:_aabbToCircle(rect, circle)
    local rectMin = playdate.geometry.point.new(rect.x, rect.y)
    local rectMax = playdate.geometry.point.new(rect.x + rect.width, rect.y + rect.height)

    -- Here we clamp the circle position to be in bound of the rectangle tested against
    local circleCenter = playdate.geometry.point.new(circle.x, circle.y)
    local closestPoint = playdate.geometry.point.copy(circleCenter)
    if closestPoint.x < rectMin.x then
        closestPoint.x = rectMin.x
    elseif closestPoint.x > rectMax.x then
        closestPoint.x = rectMax.x
    end

    if closestPoint.y < rectMin.y then
        closestPoint.y = rectMin.y
    elseif closestPoint.y > rectMax.y then
        closestPoint.y = rectMax.y
    end

    return closestPoint.squaredDistanceToPoint(circleCenter) <= circle.radius * circle.radius
end

function ColliderSprite:_circleToCircle(a, b)
    local aPos = playdate.geometry.point.new(a.x, a.y)
    local bPos = playdate.geometry.point.new(b.x, b.y)

    local radiiSum = a.radius + b.radius
    return aPos.squaredDistanceToPoint(bPos) <= radiiSum * radiiSum
end

function ColliderSprite:_aabbToAabb(a, b)
    local x, y, w, h = playdate.geometry.rect.fast_intersection(a.x, a.y, a.width, a.height, b.x, b.y, b.width, b.height)
    return x == 0 and y == 0 and w == 0 and h == 0
end