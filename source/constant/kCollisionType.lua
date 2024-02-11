kCollisionType = {
    static = 1,     -- Defines objects that aren't meant to move. Static to static collisions are ignored
    dynamic = 2,    -- Defines objects that are meant to move. Collides with static and dynamic objects
    triggerDynamic = 4,    -- Defines objects that should overlap with dynamic objects but not resolve any collisions
    triggerStatic = 8,    -- Defines objects that should overlap with dynamic objects but not resolve any collisions
    ignore = 16      -- Not taken into account in collision detection
}