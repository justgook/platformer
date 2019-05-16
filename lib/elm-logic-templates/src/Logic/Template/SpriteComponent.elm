module Logic.Template.SpriteComponent exposing (Sprite(..), draw, empty, spec)

import Logic.Component
import Logic.Template.Internal exposing (pxToScreen, tileVertexShader)
import Logic.Template.Layer as Common
import Logic.Template.Layer.Object.Animated
import Logic.Template.Layer.Object.Sprite
import Math.Vector2 exposing (Vec2)
import WebGL.Texture exposing (Texture)


type Sprite
    = Sprite (Common.Individual SpriteData)
    | Animated (Common.Individual AnimatedData)


spec =
    { get = .sprites
    , set = \comps world -> { world | sprites = comps }
    }


empty =
    Logic.Component.empty


type alias SpriteData =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , tileIndex : Float
    , tileSet : Texture
    , tileSetSize : Vec2
    , tileSize : Vec2
    , mirror : Vec2
    }


type alias AnimatedData =
    { x : Float
    , y : Float
    , start : Float
    , width : Float
    , height : Float
    , tileSet : Texture
    , tileSetSize : Vec2
    , tileSize : Vec2
    , mirror : Vec2
    , animLUT : Texture
    , animLength : Int
    }


draw getPosition common _ obj body acc =
    case obj of
        Sprite info ->
            let
                pos =
                    getPosition body
            in
            (spriteData common { info | x = pos.x |> round |> toFloat, y = pos.y |> round |> toFloat }
                |> Logic.Template.Layer.Object.Sprite.draw tileVertexShader
            )
                :: acc

        Animated info ->
            let
                pos =
                    getPosition body
            in
            (animatedData common { info | x = pos.x |> round |> toFloat, y = pos.y |> round |> toFloat }
                |> Logic.Template.Layer.Object.Animated.draw tileVertexShader
            )
                :: acc



--
--spriteData : Common.Common -> Individual TilesData -> Uniform TilesData


spriteData : Common.Common -> Common.Individual SpriteData -> Common.Uniform SpriteData
spriteData common individual =
    { height = individual.height * common.px
    , width = individual.width * common.px
    , x = individual.x * common.px
    , y = individual.y * common.px
    , tileSet = individual.tileSet
    , tileSetSize = individual.tileSetSize
    , tileSize = individual.tileSize
    , tileIndex = individual.tileIndex
    , mirror = individual.mirror

    -- General
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio

    --    , pixelsPerUnit = common.pixelsPerUnit
    , px = common.px

    --    , viewportOffset = common.viewportOffset |> Math.Vector2.scale common.px
    --    , aspectRatio = common.aspectRatio
    , time = common.time
    , viewport = common.viewport
    , offset = common.offset

    --    , absolute = common.absolute
    }


animatedData common individual =
    { height = individual.height * common.px
    , width = individual.width * common.px
    , x = individual.x * common.px
    , y = individual.y * common.px
    , start = individual.start
    , tileSet = individual.tileSet
    , tileSetSize = individual.tileSetSize
    , tileSize = individual.tileSize
    , mirror = individual.mirror
    , animLUT = individual.animLUT
    , animLength = individual.animLength

    -- General
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio

    --    , pixelsPerUnit = common.pixelsPerUnit
    , px = common.px

    --    , viewportOffset = common.viewportOffset |> Math.Vector2.scale common.px
    --    , aspectRatio = common.aspectRatio
    , time = common.time
    , viewport = common.viewport
    , offset = common.offset

    --    , absolute = common.absolute
    }
