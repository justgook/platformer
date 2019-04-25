module Layer exposing (Layer(..), view)

import Defaults exposing (default)
import Layer.Common as Common
import Layer.Image
import Layer.Tiles
import Layer.Tiles.Animated
import Logic.Component
import WebGL


type Layer
    = Tiles (Common.Individual Layer.Tiles.Model)
    | AbimatedTiles (Common.Individual Layer.Tiles.Animated.Model)
    | ImageX (Common.Individual Layer.Image.Model)
    | ImageY (Common.Individual Layer.Image.Model)
    | ImageNo (Common.Individual Layer.Image.Model)
    | Image (Common.Individual Layer.Image.Model)
    | Object (Logic.Component.Set ())


view objRender ({ env, layers, frame } as world) ({ camera } as ecs) =
    let
        common =
            { pixelsPerUnit = camera.pixelsPerUnit
            , viewportOffset = camera.viewportOffset
            , widthRatio = env.widthRatio
            , time = frame
            }
    in
    layers
        |> List.concatMap
            (\income ->
                case income of
                    Tiles info ->
                        [ Common.Layer common info |> Layer.Tiles.render ]

                    AbimatedTiles info ->
                        [ Common.Layer common info |> Layer.Tiles.Animated.render ]

                    Image info ->
                        [ Common.Layer common info |> Layer.Image.render ]

                    ImageX info ->
                        [ Common.Layer common info |> Layer.Image.renderX ]

                    ImageY info ->
                        [ Common.Layer common info |> Layer.Image.renderY ]

                    ImageNo info ->
                        [ Common.Layer common info |> Layer.Image.renderNo ]

                    Object info ->
                        objRender common ( ecs, info )
            )
