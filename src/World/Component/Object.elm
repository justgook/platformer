module World.Component.Object exposing (Object(..), objects)

import Defaults exposing (default)
import Layer.Common as Common
import Layer.Object.Ellipse
import Layer.Object.Rectangle
import Layer.Object.Tile
import Logic.Entity as Entity
import Math.Vector2 exposing (vec2)
import Math.Vector4 exposing (vec4)
import Task
import World.Component.Common exposing (defaultRead)


type Object
    = Rectangle (Common.Individual Layer.Object.Rectangle.Model)
    | Ellipse (Common.Individual Layer.Object.Ellipse.Model)
    | Tile (Common.Individual Layer.Object.Tile.Model)


objects =
    --TODO create other for isometric view
    let
        spec =
            { get = identity
            , set = \comps _ -> comps
            }
    in
    { spec = spec
    , read =
        { defaultRead
            | objectTile =
                \getImageData { x, y } { width, height } gid result ->
                    let
                        _ =
                            getImageData gid
                    in
                    Task.succeed result

            --                    inSecond
            --                        (Entity.with
            --                            ( spec
            --                            , Rectangle
            --                                { delme
            --                                    | width = width
            --                                    , height = height
            --                                    , x = x
            --                                    , y = y
            --                                }
            --                            )
            --                        )
        }
    }


delme =
    { x = 106
    , y = 30
    , width = 16
    , height = 16
    , color = vec4 1 0 1 1
    , scrollRatio = vec2 1 1
    , transparentcolor = default.transparentcolor
    }
