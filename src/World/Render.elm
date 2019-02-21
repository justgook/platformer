module World.Render exposing (view)

import Layer exposing (Layer(..))
import Layer.Common as Common
import Layer.Image
import Layer.Tiles
import Layer.Tiles.Animated


view objRender env ({ camera, layers, frame } as world) ecs =
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
