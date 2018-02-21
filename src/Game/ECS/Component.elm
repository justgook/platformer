module Game.ECS.Component exposing (Collision, Dimension(Rectangle), Input, Position, Velocity)

import Keyboard.Extra exposing (Direction, Key)


type alias Position =
    { x : Float
    , y : Float
    }


type Dimension
    = Rectangle
        { width : Float
        , height : Float
        }


type alias Velocity =
    { vx : Float
    , vy : Float
    , speed : Float
    , acc : Float
    , maxSpeed : Float
    , direction : Direction
    }


type alias Input =
    { x : Int
    , y : Int
    , parse : List Key -> { x : Int, y : Int }
    }


type alias Collision =
    { top : Bool
    , right : Bool
    , bottom : Bool -- onGround
    , left : Bool
    }
