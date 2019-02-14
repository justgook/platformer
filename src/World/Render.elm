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
                    Image info ->
                        [ Common.Layer common info |> Layer.Image.render ]

                    Tiles info ->
                        [ Common.Layer common info |> Layer.Tiles.render ]

                    AbimatedTiles info ->
                        [ Common.Layer common info |> Layer.Tiles.Animated.render ]

                    Object info ->
                        objRender common ( ecs, info )
            )
