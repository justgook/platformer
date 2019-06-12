module Logic.Template.Component.Sprite exposing (Sprite, draw, empty, emptyComp, spec)

import Logic.Component exposing (Set, Spec)
import Logic.Template.Internal exposing (tileVertexShader2)
import Logic.Template.Sprite
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)
import WebGL
import WebGL.Texture exposing (Texture)


type alias Sprite =
    { uP : Vec2

    --    , uDimension : Vec2
    --    , uIndex : Float
    , uAtlas : Texture
    , uAtlasSize : Vec2

    --    , uTileSize : Vec2
    , uMirror : Vec2
    , uTransparentColor : Vec3
    , uTileUV : Vec4

    -- Encoding related
    , atlasFirstGid : Int
    }


spec : Spec Sprite { world | sprites : Set Sprite }
spec =
    { get = .sprites
    , set = \comps world -> { world | sprites = comps }
    }


empty : Set Sprite
empty =
    Logic.Component.empty


emptyComp : Texture -> Sprite
emptyComp uAtlas =
    { uP = vec2 0 0
    , uAtlas = uAtlas
    , uTileUV = vec4 0 0 1 1
    , uMirror = vec2 0 0
    , uAtlasSize = vec2 0 0
    , uTransparentColor = vec3 1 0 1

    ----
    --    , uDimension = vec2 0 0
    --    , uIndex = 0
    --    , uTileSize = vec2 0 0
    , atlasFirstGid = 0
    }


draw : { a | absolute : Mat4, px : Float } -> Sprite -> WebGL.Entity
draw { absolute, px } info =
    Logic.Template.Sprite.draw2 tileVertexShader2
        { uP = info.uP
        , uAtlas = info.uAtlas
        , uTileUV = info.uTileUV
        , uMirror = info.uMirror
        , uAtlasSize = info.uAtlasSize
        , uTransparentColor = info.uTransparentColor
        , uAbsolute = absolute
        , px = px
        }



--    Logic.Template.Sprite.draw tileVertexShader
--        { uP = info.uP |> Vec2.scale px
--        , uAtlas = info.uAtlas
--        , tile = vec4 newTile.x newTile.y (tile.x * 0.5) (tile.y * 0.5)
--        , uMirror = info.uMirror
--        , uAtlasSize = info.uAtlasSize
--        , uTileSize = info.uTileSize
--        , uIndex = info.uIndex
--        , uTransparentColor = info.uTransparentColor
--        , uAbsolute = absolute
--        , px = px
--        , uDimension = info.uDimension |> Vec2.scale px
--        }
