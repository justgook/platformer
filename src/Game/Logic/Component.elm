module Game.Logic.Component
    exposing
        ( AnimationData
        , AnimationAtlasData
        , CollisionData
        , Component(Animation, Camera, AnimationAtlas, Collision, Input, Sprite, Velocity, Jump)
        , JumpData
        , InputData
        , SpriteData
        , VelocityData
        , CollisionEffect(..)
        )

import Game.Logic.Camera.Model as Camera
import Game.Logic.Collision.Shape exposing (WithShape)
import Game.Logic.Collision.Map as Collision
import Keyboard.Extra exposing (Key)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import Dict exposing (Dict)
import Slime exposing (EntityID)


type Component image
    = Collision CollisionData
    | Animation (AnimationData image)
    | AnimationAtlas (AnimationAtlasData image)
    | Sprite (SpriteData image)
    | Input InputData
    | Velocity VelocityData
    | Camera Camera.Behavior
    | Jump JumpData


type alias CollisionData =
    Collision.Collider
        { response : Vec2
        , offset : Vec2
        , shapes : List (WithShape {})

        -- , shapes : List (WithShape { effect : CollisionEffect })
        }


type CollisionEffect
    = SolidEffect
    | SpringEffect
    | DeadlyEffect EntityID --ID who gona die
    | Save --Save Checkpoint


type alias JumpData =
    { impulse : Float, count : Int }


type alias VelocityData =
    Vec2


{-|


## Some other ways to deal with collision are using penalty-force or impulse-based methods. Penalty methods use spring forces to pull objects out of collision. Impulse-based methods use instantaneous impulses (changes in velocity) to prevent objects from interpenetrating.
-}



-- type CollisionResult
--     = Hit
--     | Pull
-- type alias CollisionFlags =
--     { hits : Int -- remove some live from who step / touches it
--     }


type alias AnimationData image =
    { name : String
    , texture : image
    , lut : image
    , frames : Int -- farameCount
    , transparentcolor : Vec3
    , started : Int -- frame on what annimation started
    , width : Float
    , height : Float
    , imageSize : Vec2

    -- , frameSize : Vec2
    , columns : Int
    , mirror : ( Bool, Bool )
    }



-- type alias CharacterAnimationData image =
--     { stand : AnimationData image
--     , right : AnimationData image
--     , left : AnimationData image
--     }


type alias AnimationAtlasData image =
    Dict String (AnimationData image)


type alias SpriteData image =
    { texture : image
    , transparentcolor : Vec3
    }


type ControlsData
    = UserInpu { x : Int, y : Int }
    | AutoRun
    | AI


type alias InputData =
    { x : Int
    , y : Int
    , parse :
        List Key
        ->
            { x : Int
            , y : Int
            }
    }
