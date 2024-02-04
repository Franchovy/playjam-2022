import "playdate"
import "engine/colliderSprite"

function circleToCircleTest()
    local a = playdate.geometry.arc.new(0, 0, 10, 0, 360)
    local b = playdate.geometry.arc.new(2, 2, 10, 0, 360)

    assert(ColliderSprite.circleToCircle(a, b) == true)

    b.x = 20
    b.y = 20

    assert(ColliderSprite.circleToCircle(a, b) == false)
end

function aabbToAabbTest()
    local a = playdate.geometry.rect.new(0, 0, 10, 10)
    local b = playdate.geometry.rect.new(5, 5, 10, 10)

    assert(ColliderSprite.aabbToAabb(a, b) == true)

    b.x = 20
    b.y = 20

    assert(ColliderSprite.aabbToAabb(a, b) == false)
end

function aabbToCircleTest()
    local circle = playdate.geometry.arc.new(0, 0, 10, 0, 360)
    local rect = playdate.geometry.rect.new(5, 5, 10, 10)

    assert(ColliderSprite.aabbToCircle(rect, circle) == true)

    rect.x = 20
    rect.y = 20

    assert(ColliderSprite.aabbToCircle(rect, circle) == false)
end

function collisionTests()
    --circleToCircleTest()
    --aabbToAabbTest()
    --aabbToCircleTest()

    --print("Collision test successful")
end