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
    , resizeAndCenterLevelX
    , setInitResize
    , setOffset
    , setOffsetX
    , spec
    , updateOffsetX
    )

import Browser.Dom as Browser
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component.Singleton as Singleton
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.Util as Util
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Task exposing (Task)
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
    , virtualScreen :
        { width : Float
        , height : Float
        }
    , levelSize :
        { width : Int
        , height : Int
        }
    }


type alias Spec world =
    Singleton.Spec RenderInfo world



--setInitResize : Spec world -> Task x world -> Task x world


setInitResize spec__ =
    Task.map2
        (\{ scene } w ->
            resize spec__ w (round scene.width) (round scene.height)
        )
        Browser.getViewport


read : Spec world -> Reader world
read { get, set } =
    { defaultRead
        | level =
            Sync
                (\level ( entityID, world ) ->
                    let
                        renderInfo =
                            get world

                        levelData =
                            Util.levelCommon level

                        aaa =
                            levelData.width
                                * levelData.tilewidth

                        prop =
                            Util.levelProps level

                        px =
                            1 / prop.float "pixelsPerUnit" 0.1

                        x =
                            prop.float "offset.x" 0

                        y =
                            prop.float "offset.y" 0
                    in
                    ( entityID
                    , set
                        (setOffset
                            (Vec2.fromRecord { x = x, y = y })
                            { renderInfo
                                | px = px
                                , levelSize =
                                    { width = levelData.width * levelData.tilewidth
                                    , height = levelData.height * levelData.tileheight
                                    }
                            }
                        )
                        world
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


setOffset : Vec2 -> RenderInfo -> RenderInfo
setOffset newOffset_ info =
    let
        newOffset =
            newOffset_ |> Vec2.scale info.px
    in
    { info
        | offset = newOffset
        , absolute = applyOffsetVec newOffset info.fixed
    }


updateOffsetX : Float -> RenderInfo -> RenderInfo
updateOffsetX newOffsetX info =
    let
        x =
            Vec2.getX info.offset

        newOffset =
            Vec2.setX (x + newOffsetX * info.px) info.offset
    in
    { info
        | offset = newOffset
        , absolute = applyOffsetVec newOffset info.fixed
    }


setOffsetX : Float -> RenderInfo -> RenderInfo
setOffsetX newOffsetX info =
    let
        newOffset =
            Vec2.setX (newOffsetX * info.px) info.offset
    in
    { info
        | offset = newOffset
        , absolute = applyOffsetVec newOffset info.fixed
    }


resizeAndCenterLevelX spec_ world w h =
    resize spec_ world w h
        |> centerLevel spec_


centerLevel { get, set } world =
    let
        info =
            get world

        width =
            info
                |> .virtualScreen
                |> .width

        levelWidth =
            info
                |> .levelSize
                |> .width
                |> toFloat
    in
    set (setOffsetX (width * -0.5) info) world


resize { get, set } world w h =
    let
        render =
            get world

        aspectRatio =
            toFloat w / toFloat h

        fixed =
            Mat4.makeOrtho2D 0 aspectRatio 0 1

        virtualHeight =
            1 / render.px

        virtualWidth =
            toFloat w / toFloat h / render.px
    in
    set
        { render
            | fixed = fixed
            , absolute = applyOffsetVec render.offset fixed
            , screen = { width = w, height = h }
            , virtualScreen = { width = virtualWidth, height = virtualHeight }
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
    , virtualScreen =
        { width = 1
        , height = 1
        }
    , levelSize =
        { width = 1
        , height = 1
        }
    }
