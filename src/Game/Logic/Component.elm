module Game.Logic.Component exposing (BoundingBox, Collision, Input, Jump, Sprite, Velocity)

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
    }


type alias Jump =
    { maxHight : Float
    , startHeight : Float
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
