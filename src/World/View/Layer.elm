module World.View.Layer exposing (view)

import Layer.Common as Common
import Layer.Image
import Layer.Tiles
import Layer.Tiles.Animated
import Logic.Asset.Layer exposing (Layer(..))
import Math.Vector2 as Vec2


view objRender ({ env, frame, camera, layers } as world) =
    let
        { x, y } =
            camera.viewportOffset

        --, viewportOffset =
        --                Vec2.fromRecord
        --                    { x = (round (x * 64) |> toFloat) / 64
        --                    , y = (round (y * 64) |> toFloat) / 64
        --                    }
        --https://www.h-schmidt.net/FloatConverter/IEEE754.html
        common =
            { pixelsPerUnit = camera.pixelsPerUnit
            , viewportOffset =
                Vec2.fromRecord
                    { x = round x |> toFloat
                    , y = round y |> toFloat
                    }
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

                    AnimatedTiles info ->
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
                        objRender common ( world, info )
            )
