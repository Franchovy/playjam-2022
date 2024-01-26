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

local function rectMin(rect)
    return rect.x, rect.y
end

local function rectMax(rect)
    return rect.x + rect.width, rect.y + rect.height
end

-- Returns true if a rect and a circle intersect
ColliderSprite.aabbToCircle = function(rect, circle)
    local rectMin = playdate.geometry.point.new(rectMin(rect))
    local rectMax = playdate.geometry.point.new(rectMax(rect))

    -- Here we clamp the circle position to be in bound of the rectangle tested against
    local closestPoint = playdate.geometry.point.new(circle.x, circle.y)
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

    return playdate.geometry.squaredDistanceToPoint(closestPoint.x, closestPoint.y, circle.x, circle.y) <= circle.radius * circle.radius
end

ColliderSprite.circleToCircle = function(a, b)
    local radiiSum = a.radius + b.radius
    return playdate.geometry.squaredDistanceToPoint(a.x, a.y, b.x, b.y) <= radiiSum * radiiSum
end

ColliderSprite.aabbToAabb = function(a, b)
    local aMin = playdate.geometry.point.new(rectMin(a))
    local aMax = playdate.geometry.point.new(rectMax(a))
    local bMin = playdate.geometry.point.new(rectMin(b))
    local bMax = playdate.geometry.point.new(rectMax(b))

    local overX = ((bMin.x <= aMax.x) and (aMin.x <= bMax.x))
    local overY = ((bMin.y <= aMax.y) and (aMin.y <= aMax.y))

    return overX and overY
end