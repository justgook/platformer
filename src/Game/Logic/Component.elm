module Game.Logic.Component exposing (BoundingBox, Collision, Input, Sprite, Velocity)

import Keyboard.Extra exposing (Direction, Key)
import QuadTree exposing (QuadTree)


type alias BoundingBox =
    QuadTree.Bounded {}


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


type alias Sprite =
    { name : String
    }


type alias Collision =
    { top : Bool
    , right : Bool
    , bottom : Bool -- onGround
    , left : Bool
    }
