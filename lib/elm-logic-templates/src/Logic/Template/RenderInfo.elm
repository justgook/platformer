module Logic.Template.RenderInfo exposing
    ( RenderInfo
    , applyOffset
    , applyOffsetVec
    , canvas
    , decode
    , empty
    , encode
    , lowResCanvas
    , read
    , resize
    , spec
    , updateOffset
    )

import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component.Singleton as Singleton
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.Util exposing (levelProps)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import VirtualDom


type alias RenderInfo =
    { px : Float
    , fixed : Mat4
    , absolute : Mat4
    , offset : Vec2
    , screen :
        { width : Int
        , height : Int
        }
    }


type alias Spec world =
    Singleton.Spec RenderInfo world


read : Spec world -> Reader world
read { get, set } =
    { defaultRead
        | level =
            Sync
                (\level ( entityID, world ) ->
                    let
                        renderInfo =
                            get world

                        prop =
                            levelProps level

                        x =
                            prop.float "offset.x" 0

                        y =
                            prop.float "offset.y" 0

                        px =
                            1 / prop.float "pixelsPerUnit" 0.1
                    in
                    ( entityID
                    , set (updateOffset (Vec2.fromRecord { x = x, y = y }) { renderInfo | px = px }) world
                    )
                )
    }


encode : Spec world -> world -> Encoder
encode { get } world =
    E.float (get world).px


decode : Spec world -> Decoder (world -> world)
decode spec_ =
    D.float
        |> D.map (\px -> Singleton.update spec_ (\info -> { info | px = px }))


spec : Spec { world | render : RenderInfo }
spec =
    { get = .render
    , set = \comps world -> { world | render = comps }
    }


applyOffset { x, y } m_ =
    let
        m =
            Mat4.toRecord m_
    in
    { m
        | m14 = m.m14 - m.m11 * x - m.m12 * y
        , m24 = m.m24 - m.m21 * x - m.m22 * y
        , m34 = m.m34 - m.m31 * x - m.m32 * y
        , m44 = m.m44 - m.m41 * x - m.m42 * y
    }
        |> Mat4.fromRecord


applyOffsetVec v =
    applyOffset (Vec2.toRecord v)


updateOffset newOffset info =
    { info
        | offset = newOffset
        , absolute = applyOffsetVec newOffset info.fixed
    }


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
            , absolute = applyOffsetVec renderInfo.offset fixed
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


lowResCanvas { px, screen } =
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
    , absolute = Mat4.identity
    , offset = vec2 0 0
    , screen =
        { width = 1
        , height = 1
        }
    }
