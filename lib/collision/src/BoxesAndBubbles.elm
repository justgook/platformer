module BoxesAndBubbles exposing
    ( bubble, box, bounds
    , step
    )

{-| The interface for the Boxes and Bubbles physics engine.
<https://github.com/jastice/boxes-and-bubbles>


# Concepts


## Simulation

Boxes and Bubbles implements a very simple physics simulation. It updates a list of bodies
at each step. There is no time-normalized integration - if you run it with higher fps,
it will run faster.

See the [example code](https://github.com/jastice/boxes-and-bubbles/blob/master/Example.elm)
and the [example animation](http://jastice.github.io/boxes-and-bubbles/) that it produces
for a working usage example.


## Bodies

Everything in Boxes and Bubbles is a Body. A Body is a Box, or a Bubble.

Bodies have some properties:

  - `position` -- reference point and center of body
  - `velocity` -- direction and speed of movement
  - `mass` -- the mass (stored as inverseMass)
  - `restitution` -- bounciness factor: how much force is preserved on collisions
  - `shape` -- radius for Bubble, extents for Box, wrapped in an ADT.

Bodies can have infinite mass. Infinite mass bodies are not affected by any forces.


## Forces

Two types of global forces: gravity and ambient. Both are vectors,
so that they could point in any direction. Both can vary over time.
Ambient force takes the mass of objects into account, while gravity does not.


# Functions


## Constructors and helpers

@docs bubble, box, bounds


## Running the simulation

@docs step

-}

import BoxesAndBubbles.Bodies exposing (..)
import BoxesAndBubbles.Engine exposing (..)
import BoxesAndBubbles.Math2D exposing (Vec2)
import List



-- constructors


{-| Create a bubble. Mass is derived from density and size.

    bubble radius density restitution position velocity meta

Create a bubble with radius 100 with density 1 and restitution 1
at origin and a string "tag", moving toward the upper right:

    bubble 100 1 1 ( 0, 0 ) ( 3, 3 ) "tag"

-}
bubble : Float -> Float -> Float -> Vec2 -> Vec2 -> meta -> Body meta
bubble radius density restitution pos velocity meta =
    { pos = pos
    , velocity = velocity
    , inverseMass = 1 / (pi * radius * radius * density)
    , restitution = restitution
    , shape = Bubble radius
    , meta = meta
    }


{-| Create a box. Mass is derived from density and size.

    box ( width, height ) position velocity density restitution

Create a box with width 100, height 20, density 1 and restitution 1
at origin, moving toward the upper right:

    box ( 100, 20 ) 1 1 ( 0, 0 ) ( 3, 3 )

-}
box : Vec2 -> Float -> Float -> Vec2 -> Vec2 -> meta -> Body meta
box ( w, h ) density restitution pos velocity meta =
    { pos = pos
    , velocity = velocity
    , inverseMass = 1 / (w * h * density)
    , restitution = restitution
    , shape = Box ( w / 2, h / 2 )
    , meta = meta
    }


{-| Create a bounding box made up of boxes with infinite mass.

    bounds ( width, height ) thickness restitution center meta

Create bounds with width and height 800, 50 thick walls and 0.6 restitution and a String tag
at the origin:

    bounds ( 800, 800 ) 50 0.6 ( 0, 0 ) "tag"

-}
bounds : Vec2 -> Float -> Float -> Vec2 -> meta -> List (Body meta)
bounds ( w, h ) thickness restitution ( cx, cy ) meta =
    let
        ( wExt, hExt ) =
            ( w / 2, h / 2 )

        halfThick =
            thickness / 2

        inf =
            1 / 0
    in
    [ box ( w, thickness ) inf restitution ( cx, hExt + halfThick ) ( 0, 0 ) meta
    , box ( w, thickness ) inf restitution ( cx, -(hExt + halfThick) ) ( 0, 0 ) meta
    , box ( thickness, h ) inf restitution ( wExt + halfThick, cy ) ( 0, 0 ) meta
    , box ( thickness, h ) inf restitution ( -(wExt + halfThick), cy ) ( 0, 0 ) meta
    ]


{-| Perform a step in the physics simulation. Applies forces to objects and updates them based
on their velocity and collisions. Order of bodies in input list is not preserved in the output.

The `gravity` parameter give a global force that ignores object masses, while `force`
takes mass into account. Since both types of forces are vectors, they can point in any direction.
The ambient force can be used to simulate a current, for example.

    step gravity ambient bodies

Apply a downward gravity and sideways ambient force to bodies:

    step ( 0, -0.2 ) ( 20, 0 ) bodies

-}
step : Vec2 -> Vec2 -> List (Body meta) -> List (Body meta)
step gravity ambient bodies =
    List.map (update gravity ambient) (collide [] bodies)
