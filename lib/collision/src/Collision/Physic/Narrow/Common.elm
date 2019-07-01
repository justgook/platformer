module Collision.Physic.Narrow.Common exposing (Generic, Options, defaultOptions, empty)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)


type alias Generic comparable =
    { p : Vec2
    , r : Vec2
    , velocity : Vec2
    , invMass : Float
    , index : Maybe comparable
    , contact : Vec2

    --    Bounce and Friction
    }


type alias Options comparable =
    { mass : Float
    , sleep : Bool
    , index : Maybe comparable
    }


defaultOptions : Options comparable
defaultOptions =
    { mass = 0.8 --1
    , sleep = False
    , index = Nothing
    }


empty : Vec2 -> Vec2 -> Options comparable -> Generic comparable
empty p r options =
    { invMass = 1 / options.mass
    , index = options.index
    , p = p
    , r = r
    , velocity = vec2 0 0
    , contact = vec2 0 0
    }
