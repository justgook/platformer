module Logic.Template.RenderInfo exposing (RenderInfo, canvas, empty, pixelPerfectCanvas, read, resize, setOffset, setOffsetVec, spec)

import Logic.Component
import Logic.Template.TiledRead.Internal.Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.TiledRead.Internal.Util exposing (levelProps)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import VirtualDom


type alias RenderInfo =
    { px : Float
    , fixed : Mat4
    , offset : Vec2
    , screen :
        { width : Int
        , height : Int
        }
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
                                --1 / 948
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
            , screen =
                { width = w
                , height = h
                }
        }
        world


canvas { screen } =
    let
        devicePixelRatio =
            1

        { width, height } =
            screen
    in
    [ toFloat width * devicePixelRatio |> round |> String.fromInt |> VirtualDom.attribute "width"
    , toFloat height * devicePixelRatio |> round |> String.fromInt |> VirtualDom.attribute "height"
    , VirtualDom.style "display" "block"
    , VirtualDom.style "width" (String.fromInt width ++ "px")
    , VirtualDom.style "height" (String.fromInt height ++ "px")
    ]


pixelPerfectCanvas { px, screen } =
    let
        devicePixelRatio =
            1

        { width, height } =
            screen

        aspectRatio =
            toFloat width / toFloat height

        newWidth =
            1 / px * aspectRatio |> ceiling

        newHeight =
            1 / px |> ceiling
    in
    [ newWidth |> String.fromInt |> VirtualDom.attribute "width"
    , newHeight |> String.fromInt |> VirtualDom.attribute "height"
    , VirtualDom.style "display" "block"
    , VirtualDom.style "width" (String.fromInt ((width // newWidth + 1) * newWidth) ++ "px")
    , VirtualDom.style "height" (String.fromInt ((height // newHeight + 1) * newHeight) ++ "px")
    ]


empty : RenderInfo
empty =
    { px = 0.1
    , fixed = Mat4.identity

    --    , absolute = Mat4.identity
    , offset = vec2 0 0
    , screen =
        { width = 1
        , height = 1
        }
    }
