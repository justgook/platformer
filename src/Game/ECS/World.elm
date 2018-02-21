module Game.ECS.World exposing (World, collisions, dimensions, inputs, positions, velocities, world)

import Game.ECS.Component as Component
import Keyboard.Extra exposing (Key)
import Slime


type alias World =
    Slime.EntitySet
        { positions : Slime.ComponentSet Component.Position
        , dimensions : Slime.ComponentSet Component.Dimension
        , velocities : Slime.ComponentSet Component.Velocity
        , inputs : Slime.ComponentSet Component.Input
        , collisions : Slime.ComponentSet Component.Collision
        , pressedKeys : List Key
        , gravity : Float
        }


world : World
world =
    { idSource = Slime.initIdSource
    , dimensions = Slime.initComponents
    , positions = Slime.initComponents
    , velocities = Slime.initComponents
    , inputs = Slime.initComponents
    , collisions = Slime.initComponents
    , pressedKeys = []
    , gravity = -60 -- pixels per frame
    }


collisions : Slime.ComponentSpec Component.Collision World
collisions =
    { getter = .collisions
    , setter = \comps world -> { world | collisions = comps }
    }


inputs : Slime.ComponentSpec Component.Input World
inputs =
    { getter = .inputs
    , setter = \comps world -> { world | inputs = comps }
    }


dimensions : Slime.ComponentSpec Component.Dimension World
dimensions =
    { getter = .dimensions
    , setter = \comps world -> { world | dimensions = comps }
    }


positions : Slime.ComponentSpec Component.Position World
positions =
    { getter = .positions
    , setter = \comps world -> { world | positions = comps }
    }


velocities : Slime.ComponentSpec Component.Velocity World
velocities =
    { getter = .velocities
    , setter = \comps world -> { world | velocities = comps }
    }
