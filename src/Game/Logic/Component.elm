module Game.Logic.Component
    exposing
        ( AnimationData
        , CharacterAnimationData
        , Component(Animation, CharacterAnimation, Collision, Input, Sprite)
        , InputData
        , SpriteData
        )

import Game.Logic.Collision.Shape exposing (Shape)
import Keyboard.Extra exposing (Direction, Key)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)


type Component image
    = Collision Shape
    | Animation (AnimationData image)
    | CharacterAnimation (CharacterAnimationData image)
    | Sprite (SpriteData image)
    | Input InputData


{-| Some other ways to deal with collision are using penalty-force or impulse-based methods. Penalty methods use spring forces to pull objects out of collision. Impulse-based methods use instantaneous impulses (changes in velocity) to prevent objects from interpenetrating.
-}
type CollisionResult
    = Hit
    | Pull


type alias CollisionFlags =
    { hits : Int -- remove some live from who step / touches it
    }


type alias AnimationData image =
    { texture : image
    , lut : image
    , frames : Float -- farameCount
    , transparentcolor : Vec3
    , started : Int -- frame on what annimation started
    , width : Float
    , height : Float
    , frameSize : Vec2
    , columns : Float
    , mirror : ( Bool, Bool )
    }


type alias CharacterAnimationData image =
    { stand : AnimationData image
    , right : AnimationData image
    , left : AnimationData image
    }


type alias SpriteData image =
    { texture : image
    , transparentcolor : Vec3
    }


type alias InputData =
    { x : Int
    , y : Int
    , parse : List Key -> { x : Int, y : Int }
    }
