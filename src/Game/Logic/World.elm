module Game.Logic.World
    exposing
        ( World
        , WorldProperties
        , animations
        , characterAnimations
        , collisions
        , init
        , inputs
        , parseWorldProperties
        , sprites
        )

import Dict
import Game.Logic.Collision.Map as Collision
import Game.Logic.Collision.Shape exposing (Shape)
import Game.Logic.Component as Component
import Keyboard.Extra exposing (Key)
import Slime
import Tiled.Decode as Tiled
import Time exposing (Time)
import WebGL


type alias World =
    Slime.EntitySet
        { animations : Slime.ComponentSet (Component.AnimationData WebGL.Texture)
        , characterAnimations : Slime.ComponentSet (Component.CharacterAnimationData WebGL.Texture)
        , collisions : Slime.ComponentSet Shape
        , sprites : Slime.ComponentSet (Component.SpriteData WebGL.Texture)
        , pressedKeys : List Key
        , runtime_ : Time
        , frame : Int
        , inputs : Slime.ComponentSet Component.InputData
        , gravity : Float
        , pixelsPerUnit : Float
        , collisionMap : Collision.Map
        }


init : WorldProperties -> Collision.Map -> World
init props collisionMap =
    { idSource = Slime.initIdSource
    , animations = Slime.initComponents
    , characterAnimations = Slime.initComponents
    , collisions = Slime.initComponents
    , sprites = Slime.initComponents
    , inputs = Slime.initComponents
    , runtime_ = 0
    , frame = 0
    , pressedKeys = []
    , gravity = props.gravity
    , pixelsPerUnit = props.pixelsPerUnit
    , collisionMap = collisionMap
    }


type alias WorldProperties =
    { gravity : Float
    , pixelsPerUnit : Float
    }


parseWorldProperties : Tiled.CustomProperties -> WorldProperties
parseWorldProperties props =
    -- let
    --     _ =
    --         Debug.log "level props parsing" props
    -- in
    { gravity = getFloatProp "gravity" 1 props
    , pixelsPerUnit = getFloatProp "pixelsPerUnit" 120 props
    }


{-| TODO move me to Tiled.Decode
-}
getFloatProp : String -> Float -> Dict.Dict String Tiled.Property -> Float
getFloatProp propName default dict =
    Dict.get propName dict
        |> Maybe.andThen
            (\prop ->
                case prop of
                    Tiled.PropFloat a ->
                        Just a

                    _ ->
                        Nothing
            )
        |> Maybe.withDefault default


animations : Slime.ComponentSpec (Component.AnimationData WebGL.Texture) World
animations =
    { getter = .animations
    , setter = \comps world -> { world | animations = comps }
    }


characterAnimations : Slime.ComponentSpec (Component.CharacterAnimationData WebGL.Texture) World
characterAnimations =
    { getter = .characterAnimations
    , setter = \comps world -> { world | characterAnimations = comps }
    }


collisions : Slime.ComponentSpec Shape World
collisions =
    { getter = .collisions
    , setter = \comps world -> { world | collisions = comps }
    }


sprites : Slime.ComponentSpec (Component.SpriteData WebGL.Texture) World
sprites =
    { getter = .sprites
    , setter = \comps world -> { world | sprites = comps }
    }


inputs : Slime.ComponentSpec Component.InputData World
inputs =
    { getter = .inputs
    , setter = \comps world -> { world | inputs = comps }
    }
