module Logic.Template.Component.Layer exposing (Common, Individual, Layer(..), LayerData(..), Uniform, draw, empty, spec)

import Logic.Component
import Logic.Component.Singleton as Component
import Logic.Template.AnimatedTiles as AnimatedTiles
import Logic.Template.Image as Image
import Logic.Template.Internal exposing (fullscreenVertexShader)
import Logic.Template.Tiles as Tiles
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL.Texture exposing (Texture)


type Layer
    = Tiles (Individual TilesData)
    | AnimatedTiles (Individual AnimatedTilesData)
    | ImageX (Individual ImageData)
    | ImageY (Individual ImageData)
    | ImageNo (Individual ImageData)
    | Image (Individual ImageData)
    | Object (Logic.Component.Set ())


type alias TilesData =
    { lut : Texture
    , lutSize : Vec2
    , tileSet : Texture
    , tileSetSize : Vec2
    , tileSize : Vec2
    }


type alias AnimatedTilesData =
    { lut : Texture
    , lutSize : Vec2
    , animLUT : Texture
    , animLength : Int
    , tileSet : Texture
    , tileSetSize : Vec2
    , tileSize : Vec2
    }


type alias ImageData =
    { image : Texture
    , size : Vec2
    }


spec : Component.Spec (List Layer) { world | layers : List Layer }
spec =
    { get = .layers
    , set = \layers world -> { world | layers = layers }
    }


tilesData : Common -> Individual TilesData -> Uniform TilesData
tilesData common individual =
    { px = common.px
    , viewport = common.viewport
    , offset = common.offset
    , time = common.time
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio
    , tileSet = individual.tileSet
    , tileSetSize = individual.tileSetSize
    , tileSize = individual.tileSize
    , lut = individual.lut
    , lutSize = individual.lutSize
    }


animatedTilesData : Common -> Individual AnimatedTilesData -> Uniform AnimatedTilesData
animatedTilesData common individual =
    { px = common.px
    , viewport = common.viewport
    , offset = common.offset
    , time = common.time
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio
    , tileSet = individual.tileSet
    , tileSetSize = individual.tileSetSize
    , tileSize = individual.tileSize
    , lut = individual.lut
    , lutSize = individual.lutSize
    , animLUT = individual.animLUT
    , animLength = individual.animLength
    }


imageData : Common -> Individual ImageData -> Uniform ImageData
imageData common individual =
    { px = common.px
    , viewport = common.viewport
    , offset = common.offset
    , time = common.time
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio
    , image = individual.image
    , size = individual.size
    }


empty : List Layer
empty =
    []


draw objRender ({ frame, layers, render } as world) =
    let
        --, viewportOffset =
        --                Vec2.fromRecord
        --                    { x = (round (x * 64) |> toFloat) / 64
        --                    , y = (round (y * 64) |> toFloat) / 64
        --                    }
        --https://www.h-schmidt.net/FloatConverter/IEEE754.html
        common =
            { viewport = render.fixed
            , time = frame
            , px = render.px
            , offset = render.offset
            }
    in
    layers
        |> List.concatMap
            (\income ->
                case income of
                    Tiles info ->
                        [ tilesData common info
                            |> Tiles.draw fullscreenVertexShader
                        ]

                    AnimatedTiles info ->
                        [ animatedTilesData common info
                            |> AnimatedTiles.draw fullscreenVertexShader
                        ]

                    Image info ->
                        [ imageData common info
                            |> Image.draw fullscreenVertexShader
                        ]

                    ImageX info ->
                        [ imageData common info
                            |> Image.drawX fullscreenVertexShader
                        ]

                    ImageY info ->
                        [ imageData common info
                            |> Image.drawY fullscreenVertexShader
                        ]

                    ImageNo info ->
                        [ imageData common info
                            |> Image.drawNo fullscreenVertexShader
                        ]

                    Object info ->
                        objRender info
            )


type LayerData a
    = LayerData Common (Individual a)


type alias Common =
    CommonCommon {}


type alias CommonCommon a =
    { a
        | px : Float
        , viewport : Mat4
        , offset : Vec2
        , time : Int
    }


type alias Uniform a =
    Individual (CommonCommon a)


type alias Individual a =
    { a
        | transparentcolor : Vec3
        , scrollRatio : Vec2
    }
