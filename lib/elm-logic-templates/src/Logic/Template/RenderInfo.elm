module Logic.Template.RenderInfo exposing (RenderInfo, empty, read, resize, setOffset, setOffsetVec, spec)

import Logic.Component
import Logic.Template.TiledRead.Internal.Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.TiledRead.Internal.Util exposing (levelProps)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


type alias RenderInfo =
    { px : Float
    , fixed : Mat4
    , absolute : Mat4
    , offset : Vec2
    }


type alias Spec world =
    Logic.Component.SingletonSpec RenderInfo world


read : Spec world -> Reader world
read { get, set } =
    { defaultRead
        | level =
            Sync
                (\level ( entityID, world ) ->
                    let
                        renderInfo =
                            get world
                    in
                    ( entityID
                    , set
                        { renderInfo
                            | px =
                                levelProps level |> (\prop -> 1 / prop.float "pixelsPerUnit" 0.1)
                        }
                        world
                    )
                )
    }


spec : Spec { world | render : RenderInfo }
spec =
    { get = .render
    , set = \comps world -> { world | render = comps }
    }


setOffset { x, y } m_ =
    let
        m =
            Mat4.toRecord m_
    in
    { m
        | m14 = m.m11 * x + m.m12 * y + m.m14
        , m24 = m.m21 * x + m.m22 * y + m.m24
        , m34 = m.m31 * x + m.m32 * y + m.m34
        , m44 = m.m41 * x + m.m42 * y + m.m44
    }
        |> Mat4.fromRecord


setOffsetVec v =
    setOffset (Vec2.toRecord v)


resize { get, set } world w h =
    let
        renderInfo =
            get world

        aspectRatio =
            toFloat w / toFloat h

        fixed =
            Mat4.makeOrtho2D 0 aspectRatio 0 1
    in
    set
        { renderInfo
            | fixed = fixed
            , absolute = setOffsetVec renderInfo.offset fixed
        }
        world


empty : RenderInfo
empty =
    { px = 0.1
    , fixed = Mat4.identity
    , absolute = Mat4.identity
    , offset = vec2 0 0
    }
