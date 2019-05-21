module Logic.Template.Component.Sprite exposing (Sprite(..), draw, empty, spec)

import Logic.Component exposing (Set, Spec)
import Logic.Template.AnimatedSprite
import Logic.Template.Component.Layer as Common
import Logic.Template.Internal exposing (pxToScreen, tileVertexShader)
import Logic.Template.Sprite
import Math.Vector2 exposing (Vec2)
import WebGL.Texture exposing (Texture)


type Sprite
    = Sprite (Common.Individual SpriteData)
    | Animated (Common.Individual AnimatedData)


spec : Spec Sprite { world | sprites : Set Sprite }
spec =
    { get = .sprites
    , set = \comps world -> { world | sprites = comps }
    }


empty : Set Sprite
empty =
    Logic.Component.empty


type alias SpriteData =
    { p : Vec2
    , width : Float
    , height : Float
    , tileIndex : Float
    , tileSet : Texture
    , tileSetSize : Vec2
    , tileSize : Vec2
    , mirror : Vec2
    }


type alias AnimatedData =
    { p : Vec2
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


draw time { absolute, px } getPosition _ obj body acc =
    case obj of
        Sprite info ->
            (spriteData absolute
                { px = px }
                { info
                    | p = getPosition body |> pxToScreen px
                }
                |> Logic.Template.Sprite.draw tileVertexShader
            )
                :: acc

        Animated info ->
            (animatedData absolute
                { px = px, time = time }
                { info
                    | p = getPosition body |> pxToScreen px
                }
                |> Logic.Template.AnimatedSprite.draw tileVertexShader
            )
                :: acc


spriteData absolute common individual =
    { height = individual.height * common.px
    , width = individual.width * common.px
    , p = individual.p
    , tileSet = individual.tileSet
    , tileSetSize = individual.tileSetSize
    , tileSize = individual.tileSize
    , tileIndex = individual.tileIndex
    , mirror = individual.mirror

    -- General
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio
    , absolute = absolute
    }


animatedData absolute common individual =
    { height = individual.height * common.px
    , width = individual.width * common.px
    , p = individual.p
    , start = individual.start
    , tileSet = individual.tileSet
    , tileSetSize = individual.tileSetSize
    , tileSize = individual.tileSize
    , mirror = individual.mirror
    , animLUT = individual.animLUT
    , animLength = individual.animLength

    -- General
    , transparentcolor = individual.transparentcolor
    , px = common.px
    , time = common.time
    , absolute = absolute
    }
