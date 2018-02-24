module Game.Logic.World exposing (World, boundingBoxes, collisions, inputs, sprites, velocities, world)

import Array exposing (Array)
import Game.Logic.Component as Component
import Keyboard.Extra exposing (Key)
import QuadTree exposing (QuadTree)
import Slime
import Time exposing (Time)


items_per_branch : Int
items_per_branch =
    8


type alias World =
    Slime.EntitySet
        { velocities : Slime.ComponentSet Component.Velocity
        , inputs : Slime.ComponentSet Component.Input
        , collisions : Slime.ComponentSet Component.Collision
        , pressedKeys : List Key
        , boundingBoxes : QuadTree Component.BoundingBox
        , boundingBoxes_ : Slime.ComponentSet Component.BoundingBox
        , sprites : Slime.ComponentSet Component.Sprite
        , runtime : Time
        , gravity : Float
        }


world : World
world =
    { idSource = Slime.initIdSource
    , velocities = Slime.initComponents
    , inputs = Slime.initComponents
    , collisions = Slime.initComponents
    , pressedKeys = []
    , gravity = 60 -- pixels per frame
    , boundingBoxes = QuadTree.emptyQuadTree (QuadTree.boundingBox 0 0 0 0) 0
    , boundingBoxes_ = Slime.initComponents
    , sprites = Slime.initComponents
    , runtime = 0
    }


boundingBoxes : Slime.ComponentSpec Component.BoundingBox World
boundingBoxes =
    let
        restTree comps =
            comps
                |> Array.foldl
                    (\a ( acc, size ) ->
                        case a of
                            Nothing ->
                                ( acc, size )

                            Just item ->
                                ( Array.push item acc, getMinMax item size )
                    )
                    ( Array.empty, ( 0, 0, 0, 0 ) )
    in
    { getter = .boundingBoxes_
    , setter =
        \comps world ->
            if world.boundingBoxes_ == comps then
                { world
                    | boundingBoxes_ = comps
                }
            else
                { world
                    | boundingBoxes_ = comps
                    , boundingBoxes =
                        let
                            ( items, size ) =
                                restTree comps.contents

                            result =
                                QuadTree.emptyQuadTree (uncurry4 QuadTree.boundingBox size) items_per_branch
                                    |> QuadTree.insertMany items

                            -- |> flip (Array.foldr (\a b -> QuadTree.insert a b)) items
                            _ =
                                Debug.log "boundingBoxes" (QuadTree.length result)
                        in
                        result

                    -- |> QuadTree.reset
                }
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


sprites : Slime.ComponentSpec Component.Sprite World
sprites =
    { getter = .sprites
    , setter = \comps world -> { world | sprites = comps }
    }


velocities : Slime.ComponentSpec Component.Velocity World
velocities =
    { getter = .velocities
    , setter = \comps world -> { world | velocities = comps }
    }



--- HELPER FUNCTIONS!!


indexedFoldl : (Int -> a -> b -> b) -> b -> Array a -> b
indexedFoldl func acc list =
    let
        step x ( i, acc ) =
            ( i + 1, func i x acc )
    in
    Tuple.second (Array.foldl step ( 0, acc ) list)


getMinMax : Component.BoundingBox -> ( Float, Float, Float, Float ) -> ( Float, Float, Float, Float )
getMinMax item ( minX, maxX, minY, maxY ) =
    let
        { horizontal, vertical } =
            item.boundingBox
    in
    ( min (horizontal.low - 1) minX
    , max (horizontal.high + 1) maxX
    , min (vertical.low - 1) minY
    , max (vertical.high + 1) maxY
    )


uncurry4 : (a -> b -> c -> d -> e) -> ( a, b, c, d ) -> e
uncurry4 func ( a, b, c, d ) =
    func a b c d
