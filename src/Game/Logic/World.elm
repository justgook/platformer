module Game.Logic.World
    exposing
        ( CollisionMap
        , GameFlow(..)
        , World
        , WorldProperties
        , animations
        , characterAnimations
        , collisions
        , init
        , inputs
        , sprites
        , velocities
        )

import Game.Logic.Camera.Model as Camera
import Game.Logic.Collision.Map as Collision
import Game.Logic.Collision.Shape exposing (Shape)
import Game.Logic.Component as Component
import Keyboard.Extra exposing (Key)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random.Pcg as Random exposing (Generator)
import Slime
import Time exposing (Time)
import WebGL


type alias CollisionMap =
    Collision.Map {}


type alias World =
    Slime.EntitySet
        { animations : Slime.ComponentSet (Component.AnimationData WebGL.Texture)
        , characterAnimations : Slime.ComponentSet (Component.CharacterAnimationData WebGL.Texture)
        , collisions : Slime.ComponentSet Component.CollisionData
        , sprites : Slime.ComponentSet (Component.SpriteData WebGL.Texture)
        , velocities : Slime.ComponentSet Component.VelocityData
        , pressedKeys : List Key
        , runtime_ : Time
        , frame : Int
        , inputs : Slime.ComponentSet Component.InputData
        , gravity : Vec2
        , camera : Camera.Model
        , collisionMap : CollisionMap
        , seed0 : Random.Seed
        , flow : GameFlow
        }


init : WorldProperties -> CollisionMap -> World
init props collisionMap =
    let
        _ =
            Debug.log "init World" "asdas"
    in
    { idSource = Slime.initIdSource
    , animations = Slime.initComponents
    , characterAnimations = Slime.initComponents
    , collisions = Slime.initComponents
    , sprites = Slime.initComponents
    , inputs = Slime.initComponents
    , velocities = Slime.initComponents
    , runtime_ = 0
    , frame = 0
    , pressedKeys = []
    , gravity = props.gravity
    , camera = Camera.init props
    , collisionMap = collisionMap
    , seed0 = Random.initialSeed 227852860
    , flow = SlowMotion { frames = 60, fps = 20 }
    }


type GameFlow
    = Running
    | Pause
    | SlowMotion { frames : Int, fps : Int }


type alias WorldProperties =
    { gravity : Vec2
    , pixelsPerUnit : Float
    }


velocities : Slime.ComponentSpec Component.VelocityData World
velocities =
    { getter = .velocities
    , setter = \comps world -> { world | velocities = comps }
    }


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


collisions : Slime.ComponentSpec Component.CollisionData World
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
