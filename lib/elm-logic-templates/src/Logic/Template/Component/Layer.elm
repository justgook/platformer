module Logic.Template.Component.Layer exposing (Common, Layer(..), animatedTilesData, draw, empty, spec, tilesData)

import Logic.Component
import Logic.Component.Singleton as Singleton
import Logic.Template.AnimatedTiles as AnimatedTiles
import Logic.Template.Image as Image
import Logic.Template.Internal exposing (FullScreenVertexShaderModel, TileVertexShaderModel, fullscreenVertexShader)
import Logic.Template.Tiles as Tiles
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL
import WebGL.Texture exposing (Texture)


type Layer
    = Tiles TilesData
    | AnimatedTiles AnimatedTilesData
    | ImageNo ImageData
    | ImageX ImageData
    | ImageY ImageData
    | Image ImageData
    | Object ( Int, Logic.Component.Set () )


type alias TilesData =
    { uLut : Texture
    , uLutSize : Vec2
    , uAtlas : Texture
    , uAtlasSize : Vec2
    , uTileSize : Vec2
    , uTransparentColor : Vec3
    , scrollRatio : Vec2

    -- Encoding related
    , id : Int
    , data : List Int
    , firstgid : Int
    }


type alias AnimatedTilesData =
    { uLut : Texture
    , uLutSize : Vec2
    , animLUT : Texture
    , animLength : Int
    , uAtlas : Texture
    , uAtlasSize : Vec2
    , uTileSize : Vec2
    , uTransparentColor : Vec3
    , scrollRatio : Vec2

    -- Encoding related
    , data : List Int
    }


type alias ImageData =
    { image : Texture
    , uSize : Vec2
    , uTransparentColor : Vec3
    , scrollRatio : Vec2
    , id : Int
    }


spec : Singleton.Spec (List Layer) { world | layers : List Layer }
spec =
    { get = .layers
    , set = \layers world -> { world | layers = layers }
    }


tilesData : Common -> TilesData -> FullScreenVertexShaderModel (Tiles.Model {})
tilesData common individual =
    { px = common.px
    , viewport = common.viewport
    , offset = common.offset
    , uTransparentColor = individual.uTransparentColor
    , scrollRatio = individual.scrollRatio
    , uAtlas = individual.uAtlas
    , uAtlasSize = individual.uAtlasSize
    , uTileSize = individual.uTileSize
    , uLut = individual.uLut
    , uLutSize = individual.uLutSize
    }



--animatedTilesData : Common -> AnimatedTilesData -> FullScreenVertexShaderModel (AnimatedTiles.Model {})


animatedTilesData : Common -> AnimatedTilesData -> FullScreenVertexShaderModel (AnimatedTiles.Model {})
animatedTilesData common individual =
    { px = common.px
    , viewport = common.viewport
    , offset = common.offset
    , uTransparentColor = individual.uTransparentColor

    --    , scrollRatio = individual.scrollRatio
    , uAtlas = individual.uAtlas
    , uAtlasSize = individual.uAtlasSize
    , uTileSize = individual.uTileSize
    , uLut = individual.uLut
    , uLutSize = individual.uLutSize
    , animLUT = individual.animLUT
    , animLength = individual.animLength
    , time = common.time
    }


imageData : Common -> ImageData -> FullScreenVertexShaderModel (Image.Model {})
imageData common individual =
    let
        scrollRatio =
            individual.scrollRatio
                |> Vec2.toRecord

        { x, y } =
            common.offset
                |> Vec2.toRecord

        newOffset =
            { x = x * scrollRatio.x, y = y * scrollRatio.y }
    in
    { px = common.px
    , viewport = common.viewport
    , offset = newOffset |> Vec2.fromRecord
    , uTransparentColor = individual.uTransparentColor

    --    , scrollRatio = individual.scrollRatio
    , image = individual.image
    , uSize = individual.uSize
    }


empty : List Layer
empty =
    []


draw :
    (( Int, Logic.Component.Set () ) -> List WebGL.Entity)
    ->
        { b
            | frame : Int
            , layers : List Layer
            , render :
                { a
                    | fixed : Mat4
                    , offset : Vec2
                    , px : Float
                }
        }
    -> List WebGL.Entity
draw objRender ({ frame, layers, render } as world) =
    let
        --, viewportOffset =
        --                Vec2.fromRecord
        --                    { x = (round (x * 64) |> toFloat) / 64
        --                    , y = (round (y * 64) |> toFloat) / 64
        --                    }
        --https://www.h-schmidt.net/FloatConverter/IEEE754.html
        common : Common
        common =
            { viewport = render.fixed
            , px = render.px
            , offset = render.offset
            , time = frame
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


type alias Common =
    { viewport : Mat4
    , px : Float
    , offset : Vec2
    , time : Int
    }
