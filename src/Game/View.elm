module Game.View exposing (view)

import Array.Hamt as Array
import Game.Logic.Collision.Map as Collision
import Game.Logic.Collision.Shape as Collision exposing (Shape(..), aabbData)
import Game.Logic.World as World exposing (World)
import Game.Model as Game
import Game.View.ImageLayer as ImageLayer
import Game.View.Object as ObjectView
import Game.View.Object.Animated as AnimatedObject
import Game.View.TileLayer as TileLayer
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Slime
import WebGL exposing (Texture)


-- Add linght raycasting
-- https://stackoverflow.com/questions/34708021/how-to-implement-2d-raycasting-light-effect-in-glsl
-- https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows


debug : Bool
debug =
    False


view : Game.Model -> List WebGL.Entity
view model =
    case model.renderData of
        Game.Success { data, world } ->
            let
                debug_ =
                    if debug then
                        debugCollisionView
                            { widthRatio = world.camera.widthRatio
                            , pixelsPerUnit = world.camera.pixelsPerUnit
                            , viewportOffset = world.camera.offset
                            }
                            world.collisionMap
                    else
                        []
            in
                renderGame world data
                    ++ debug_

        _ ->
            []


renderGame : World -> List (Game.Data Texture) -> List WebGL.Entity
renderGame world =
    let
        widthRatio =
            world.camera.widthRatio

        pixelsPerUnit =
            world.camera.pixelsPerUnit

        viewportOffset =
            world.camera.offset
    in
        List.foldr
            (\layer acc ->
                case layer of
                    Game.ImageLayer data ->
                        let
                            data_ =
                                { image = data.texture
                                , scrollRatio = data.scrollRatio
                                , transparentcolor = data.transparentcolor
                                , pixelsPerUnit = pixelsPerUnit
                                , viewportOffset = viewportOffset
                                , widthRatio = widthRatio
                                }
                        in
                            ImageLayer.render data_ :: acc

                    Game.ActionLayer data ->
                        let
                            stepObjects { a } acc_ =
                                let
                                    (Collision.AabbData a_) =
                                        a.boundingBox
                                in
                                    ObjectView.render
                                        { widthRatio = widthRatio
                                        , viewportOffset = viewportOffset
                                        , pixelsPerUnit = pixelsPerUnit
                                        , x = Vec2.getX a_.p
                                        , y = Vec2.getY a_.p
                                        , width = Vec2.length a_.xw * 2
                                        , height = Vec2.length a_.yw * 2
                                        , scrollRatio = data.scrollRatio
                                        }
                                        :: acc_

                            stepAnimations { a, b } acc_ =
                                let
                                    mirror =
                                        case b.mirror of
                                            ( True, True ) ->
                                                3

                                            ( True, False ) ->
                                                2

                                            ( False, True ) ->
                                                1

                                            ( False, False ) ->
                                                0

                                    (Collision.AabbData { p }) =
                                        a.boundingBox

                                    { x, y } =
                                        Vec2.add p a.offset
                                            |> Vec2.toRecord

                                    result =
                                        { widthRatio = widthRatio
                                        , viewportOffset = viewportOffset
                                        , pixelsPerUnit = pixelsPerUnit
                                        , frame = world.frame
                                        , x = x
                                        , y = y
                                        , width = b.width
                                        , height = b.height
                                        , sprite = b.texture
                                        , imageSize = b.imageSize

                                        -- , frameSize = b.frameSize
                                        , columns = b.columns
                                        , frames = b.frames
                                        , started = b.started
                                        , lut = b.lut
                                        , transparentcolor = b.transparentcolor
                                        , mirror = mirror
                                        , scrollRatio = data.scrollRatio
                                        }
                                in
                                    AnimatedObject.render result :: acc_
                        in
                            acc
                                |> (if debug then
                                        flip (List.foldr stepObjects) ((Slime.entities World.collisions).getter world)
                                    else
                                        identity
                                   )
                                |> flip (List.foldr stepAnimations) ((Slime.entities2 World.collisions World.animations).getter world)

                    Game.TileLayer1 data ->
                        TileLayer.render
                            { widthRatio = widthRatio
                            , viewportOffset = viewportOffset
                            , pixelsPerUnit = pixelsPerUnit
                            , lut = data.lutTexture
                            , firstgid = data.firstgid
                            , lutSize = data.lutSize
                            , tileSet = data.tileSetTexture
                            , tileSetSize = data.tileSetSize
                            , tileSize = data.tileSize
                            , transparentcolor = data.transparentcolor
                            , scrollRatio = data.scrollRatio
                            }
                            :: acc
            )
            []


debugCollisionView : { a | pixelsPerUnit : Float, viewportOffset : Vec2, widthRatio : Float } -> Collision.Map b -> List WebGL.Entity
debugCollisionView baseData collisionMap =
    Collision.table collisionMap
        |> Array.foldr
            (\row acc ->
                Array.toList row :: acc
            )
            []
        |> List.concat
        |> List.foldr
            (\maybeShape acc ->
                case maybeShape of
                    Just { boundingBox } ->
                        debugCollisionViewItem baseData boundingBox ++ acc

                    _ ->
                        acc
            )
            []


debugCollisionViewItem : { a | pixelsPerUnit : Float, viewportOffset : Vec2, widthRatio : Float } -> Collision.AabbData -> List WebGL.Entity
debugCollisionViewItem { widthRatio, viewportOffset, pixelsPerUnit } obj =
    let
        (Collision.AabbData a_) =
            obj
    in
        [ ObjectView.render
            { widthRatio = widthRatio
            , viewportOffset = viewportOffset
            , pixelsPerUnit = pixelsPerUnit
            , x = Vec2.getX a_.p
            , y = Vec2.getY a_.p
            , width = Vec2.length a_.xw * 2
            , height = Vec2.length a_.yw * 2
            , scrollRatio = vec2 1 1
            }
        ]
