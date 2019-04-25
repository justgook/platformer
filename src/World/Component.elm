module World.Component exposing
    ( animations
    , dimensions
    , direction
    , positions
    , sprites
    )

import AltMath.Vector2 exposing (Vec2, vec2)
import Logic.Component
import Logic.Entity as Entity exposing (EntityID)
import World.Component.Animation
import World.Component.Common exposing (EcsSpec, Read(..), defaultRead)
import World.Component.Input
import World.Component.Sprite


type alias Direction =
    World.Component.Input.Direction


direction =
    World.Component.Input.direction


sprites =
    World.Component.Sprite.sprites


animations =
    World.Component.Animation.animations


positions : EcsSpec { a | positions : Logic.Component.Set Vec2 } Vec2 (Logic.Component.Set Vec2)
positions =
    --TODO create other for isometric view
    let
        spec =
            { get = .positions
            , set = \comps world -> { world | positions = comps }
            }
    in
    { spec = spec
    , empty = Logic.Component.empty
    , read =
        { defaultRead
            | objectTile =
                Sync
                    (\{ x, y } ->
                        Entity.with ( spec, vec2 x y )
                    )
        }
    }


dimensions : EcsSpec { a | dimensions : Logic.Component.Set Vec2 } Vec2 (Logic.Component.Set Vec2)
dimensions =
    let
        spec =
            { get = .dimensions
            , set = \comps world -> { world | dimensions = comps }
            }
    in
    { spec = spec
    , empty = Logic.Component.empty
    , read =
        { defaultRead
            | objectTile =
                Sync
                    (\{ height, width } ->
                        Entity.with ( spec, vec2 width height )
                    )
        }
    }
