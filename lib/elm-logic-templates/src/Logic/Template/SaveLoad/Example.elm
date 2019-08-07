module Tiled.Read.Example exposing (dimensions)

import AltMath.Vector2 exposing (Vec2, vec2)
import Logic.Component
import Logic.Entity as Entity exposing (EntityID)
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), WorldReader, defaultRead)


dimensions : Logic.Component.Spec Vec2 world -> WorldReader world
dimensions spec =
    { defaultRead
        | objectTile =
            Sync (\{ height, width } -> Entity.with ( spec, vec2 width height ))
    }
