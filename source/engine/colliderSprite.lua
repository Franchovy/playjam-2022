import "playdate"
import "constant"
import "bit32"

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
    assert(colliderType ~= kColliderType.none, "Passed colliderType can't be none") -- should we allow no collider ?

    -- All of these checks are parameter validation, the real function are the two last lines
    if colliderType == kColliderType.rect then
        assert(getmetatable(collider) == playdate.geometry.rect, "colliderType is rect but collider is not a valid playdate.geometry.rect")
    end

    if colliderType == kColliderType.circle then
        assert(getmetatable(collider) == playdate.geometry.arc, "colliderType is circle but collider is not a valid playdate.geometry.arc")
        -- enforce full circle, not really necessary since we'll only use the radius and position anyway
        collider.startAngle = 0
        collider.endAngle = 360
    end

    self._collider = collider
    self._colliderType = colliderType
end

-- Returns a table where key "type" is a kColliderType value and "collider" is a corresponding playdate.geometry object
function ColliderSprite:getCollider()
    return {type = self._colliderType, collider = self._collider}
end

-- collisionType is expected to be a kCollisionType constant — !! kCollisionType and kColliderType are not the same
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
    local rectMinX, rectMinY = rectMin(rect)
    local rectMaxX, rectMaxY = rectMax(rect)

    -- Here we clamp the circle position to be in bound of the rectangle tested against
    local closestPointX, closestPointY = circle.x, circle.y
    if closestPointX < rectMinX then
        closestPointX = rectMinX
    elseif closestPointX > rectMaxX then
        closestPointX = rectMaxX
    end

    if closestPointY < rectMinY then
        closestPointY = rectMinY
    elseif closestPointY > rectMaxY then
        closestPointY = rectMaxY
    end

    local sqDistance = playdate.geometry.squaredDistanceToPoint(closestPointX, closestPointY, circle.x, circle.y)

    local overlap = sqDistance <= circle.radius * circle.radius -- is there an actual overlap

    local overlapInformation = {}
    if overlap then
        -- some data needed for resolution
        overlapInformation = {circle = playdate.geometry.arc.copy(circle), closestPoint = {x = closestPointX, y = closestPointY}, sqDistance = sqDistance}
    end

    return overlap, overlapInformation
end

ColliderSprite.aabbToCircleResolution = function(overlapInfo)
    local distance = math.sqrt(overlapInfo.sqDistance)
    local overlap = overlapInfo.circle.radius - distance

    local moveDirX = (overlapInfo.circle.x - overlapInfo.closestPoint.x) / distance
    local moveDirY = (overlapInfo.circle.y - overlapInfo.closestPoint.y) / distance

    return {
        x = moveDirX * overlap,
        y = moveDirY * overlap
    }
end

-- Convenience function for ColliderSprite:overlapsWith
ColliderSprite.circleToAabb = function(circle, rect)
    return ColliderSprite.aabbToCircle(rect, circle)
end

-- Returns true if a circle and a circle intersect
ColliderSprite.circleToCircle = function(a, b)
    local radiiSum = a.radius + b.radius
    local overlap = playdate.geometry.squaredDistanceToPoint(a.x, a.y, b.x, b.y) <= radiiSum * radiiSum
    
    local overlapInfo = {}
    if overlap then
        overlapInfo = {a = playdate.geometry.arc.copy(a), b = playdate.geometry.arc.copy(b)}
    end

    return overlap, overlapInfo
end

-- Returns the smallest amount by how much b should move to resolve the collision, asssumes both circle are overlapping
ColliderSprite.circleToCircleResolution = function(overlapInfo)
    local a = overlapInfo.a
    local b = overlapInfo.b

    local radiiSum = a.radius + b.radius
    local bToA_x = b.x - a.x    -- naming convention broken for readability
    local bToA_y = b.y - a.y 

    local bToALength = math.sqrt(bToA_x * bToA_x + bToA_y * bToA_y)

    local moveDirX = bToA_x / bToALength
    local moveDirY = bToA_y / bToALength

    return {x = a.x + moveDirX * radiiSum, y = a.y + moveDirY * radiiSum}
end

-- Returns true if a rect and a rect intersect
ColliderSprite.aabbToAabb = function(a, b)
    local aMinX, aMinY = rectMin(a)
    local aMaxX, aMaxY = rectMax(a)
    local bMinX, bMinY = rectMin(b)
    local bMaxX, bMaxY = rectMax(b)

    local overX = ((bMinX <= aMaxX) and (aMinX <= bMaxX))
    local overY = ((bMinY <= aMaxY) and (aMinY <= bMaxY))

    local overlap = overX and overY

    local overlapInfo = {}
    if overlap then
        overlapInfo = {
            aMin = {x = aMinX, y = aMinY},
            bMin = {x = bMinX, y = bMinY},
            aMax = {x = aMaxX, y = aMaxY},
            bMax = {x = bMaxX, y = bMaxY}
        }
    end

    return overlap, overlapInfo
end

-- Returns the smallest amount by how much b should move to resolve the collision, assumes both rectangles are overlapping
ColliderSprite.calculateAabbToAabbResolution = function(overlapInfo)

    local aMin = overlapInfo.aMin
    local aMax = overlapInfo.aMax
    local bMin = overlapInfo.bMin
    local bMax = overlapInfo.bMax

    local moveLeft = aMin.x - bMax.x
    local moveRight = aMax.x - bMin.x
    local xMove = math.abs(moveLeft) < math.abs(moveRight) and moveLeft or moveRight

    local moveUp = aMin.y - bMax.y
    local moveDown = aMax.y - bMin.y
    local yMove = math.abs(moveUp) < math.abs(moveDown) and moveUp or moveDown

    if math.abs(xMove) < math.abs(yMove) then
        return {x = xMove, y = 0}
    else
        return {x = 0, y = yMove}
    end
end

-- given two collision types, returns true if we should check overlap between both colliders
-- this function was abstracted away to make it easier to test
-- In game logic, it's probably better to call ColliderSprite:checkOverlapWith
function ColliderSprite.shouldCheckOverlap(firstCollisionType, secondCollisionType)
    local mask = bit32.bor(firstCollisionType, secondCollisionType)

    -- If any is set to "ignore" mode we just return false
    if bit32.band(mask, kCollisionType.ignore) == kCollisionType.ignore then
        return false
    end

    local truthTable = {
        [bit32.bor(kCollisionType.dynamic, kCollisionType.dynamic)] = true,
        [bit32.bor(kCollisionType.dynamic, kCollisionType.static)] = true,
        [bit32.bor(kCollisionType.dynamic, kCollisionType.trigger)] = true,
        [bit32.bor(kCollisionType.static, kCollisionType.trigger)] = false,
        [bit32.bor(kCollisionType.static, kCollisionType.static)] = false,
        [bit32.bor(kCollisionType.trigger, kCollisionType.trigger)] = true,
    }

    return truthTable[mask]
end

function ColliderSprite:checkOverlapWith(other)
    return ColliderSprite.shouldCheckOverlap(self.getCollisionType(), other.getCollisionType())
end

-- Returns true if two ColliderSprites overlap regardless of collision masks, collision enabled or collision types
function ColliderSprite:overlapsWith(other)
    -- Maps each pair of collider type to a collision checking function 
    -- The keys are set up that way so we know which collider types are the first and second parameters of the function
    local collisionFunctions = {
        [kColliderType.rect * 10 + kColliderType.rect]      = ColliderSprite.aabbToAabb,
        [kColliderType.rect * 10 + kColliderType.circle]    = ColliderSprite.aabbToCircle,
        [kColliderType.circle * 10 + kColliderType.circle]  = ColliderSprite.circleToCircle,
        [kColliderType.circle * 10 + kColliderType.rect]    = ColliderSprite.circleToAabb
    }

    return collisionFunctions[self._colliderType * 10 + other._colliderType](self._collider, other._collider)
end