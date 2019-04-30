module Tiled.Read.Example exposing (dimensions, positions)

import AltMath.Vector2 exposing (Vec2, vec2)
import Logic.Component
import Logic.Entity as Entity exposing (EntityID)
import Tiled.Read exposing (Read(..), Reader, defaultRead)


positions : Logic.Component.Spec Vec2 world -> Reader world
positions spec =
    { defaultRead
        | objectTile = Sync (\{ x, y } -> Entity.with ( spec, vec2 x y ))
    }


dimensions : Logic.Component.Spec Vec2 world -> Reader world
dimensions spec =
    { defaultRead
        | objectTile =
            Sync (\{ height, width } -> Entity.with ( spec, vec2 width height ))
    }
