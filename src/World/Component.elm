module World.Component exposing
    ( dimensions
    , direction
    , objects
    , positions
    )

import Array exposing (Array)
import Logic.Component
import Logic.Entity as Entity exposing (EntityID)
import Math.Vector2 exposing (Vec2, vec2)
import ResourceTask
import World.Component.Common exposing (EcsSpec, Read3(..), defaultRead)
import World.Component.Direction
import World.Component.Object


type alias Direction =
    World.Component.Direction.Direction


direction =
    World.Component.Direction.direction


objects =
    World.Component.Object.objects


positions : EcsSpec { a | positions : Logic.Component.Set Vec2 } layer Vec2 (Logic.Component.Set Vec2)
positions =
    --TODO create other for isometric view
    let
        spec =
            { get = .positions
            , set = \comps world -> { world | positions = comps }
            }
    in
    { spec = spec
    , empty = Array.empty
    , read =
        { defaultRead
            | objectTile =
                Async3
                    (\{ x, y } _ _ ->
                        ResourceTask.getTexture "/assets/apotile.png"
                            >> ResourceTask.map (\img -> Entity.with ( spec, vec2 x y ))
                    )
        }
    }


dimensions : EcsSpec { a | dimensions : Logic.Component.Set Vec2 } layer Vec2 (Logic.Component.Set Vec2)
dimensions =
    let
        spec =
            { get = .dimensions
            , set = \comps world -> { world | dimensions = comps }
            }
    in
    { spec = spec
    , empty = Array.empty
    , read =
        { defaultRead
            | objectTile =
                Sync3
                    (\_ { height, width } _ ->
                        Entity.with ( spec, vec2 width height )
                    )
        }
    }
