module Logic.Template.Component.Sprite exposing (Sprite, draw, empty, emptyComp, spec)

import Logic.Component exposing (Set, Spec)
import Logic.Template.Internal exposing (tileVertexShader)
import Logic.Template.Sprite
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import WebGL
import WebGL.Texture exposing (Texture)


type alias Sprite =
    { uP : Vec2
    , uDimension : Vec2
    , uIndex : Float
    , uAtlas : Texture
    , uAtlasSize : Vec2
    , uTileSize : Vec2
    , uMirror : Vec2
    , transparentcolor : Vec3
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
    , uDimension = vec2 0 0
    , uIndex = 0
    , uAtlas = uAtlas
    , uAtlasSize = vec2 0 0
    , uTileSize = vec2 0 0
    , uMirror = vec2 0 0
    , transparentcolor = vec3 1 0 1
    }


draw : { a | absolute : Mat4, px : Float } -> Sprite -> WebGL.Entity
draw { absolute, px } info =
    Logic.Template.Sprite.draw tileVertexShader
        { uDimension = info.uDimension |> Vec2.scale px
        , uP = info.uP |> Vec2.scale px
        , uAtlas = info.uAtlas
        , uAtlasSize = info.uAtlasSize
        , uTileSize = info.uTileSize
        , uIndex = info.uIndex
        , uMirror = info.uMirror
        , transparentcolor = info.transparentcolor
        , uAbsolute = absolute
        }
