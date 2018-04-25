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


renderGame : { a | pixelsPerUnit : Float, viewportOffset : Vec2, widthRatio : Float, world : World } -> List (Game.Data Texture) -> List WebGL.Entity
renderGame { widthRatio, pixelsPerUnit, viewportOffset, world } =
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
                            case a.shape of
                                AABB _ ->
                                    let
                                        a_ =
                                            aabbData a
                                    in
                                        ObjectView.render
                                            { widthRatio = widthRatio
                                            , viewportOffset = viewportOffset
                                            , pixelsPerUnit = pixelsPerUnit
                                            , x = Vec2.getX a_.p
                                            , y = Vec2.getY a_.p
                                            , width = Vec2.length a_.xw * 2 --b.width
                                            , height = Vec2.length a_.yw * 2 --b.height
                                            , scrollRatio = data.scrollRatio
                                            }
                                            :: acc_

                                _ ->
                                    acc

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

                                p =
                                    Collision.position a
                            in
                                AnimatedObject.render
                                    { widthRatio = widthRatio
                                    , viewportOffset = viewportOffset
                                    , pixelsPerUnit = pixelsPerUnit
                                    , frame = world.frame
                                    , x = Vec2.getX p
                                    , y = Vec2.getY p
                                    , width = b.width
                                    , height = b.height
                                    , sprite = b.texture
                                    , frameSize = b.frameSize
                                    , columns = b.columns
                                    , frames = b.frames
                                    , started = b.started
                                    , lut = b.lut
                                    , transparentcolor = b.transparentcolor
                                    , mirror = mirror
                                    , scrollRatio = data.scrollRatio
                                    }
                                    :: acc_
                    in
                        acc
                            |> flip (List.foldr stepObjects) ((Slime.entities World.collisions).getter world)
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


view : Game.Model -> List WebGL.Entity
view model =
    case model.renderData of
        Game.Success { data, world } ->
            let
                debug =
                    debugCollisionView
                        { widthRatio = world.camera.widthRatio
                        , pixelsPerUnit = world.camera.pixelsPerUnit
                        , viewportOffset = world.camera.offset
                        }
                        world.collisionMap
            in
                renderGame
                    { world = world
                    , widthRatio = world.camera.widthRatio
                    , pixelsPerUnit = world.camera.pixelsPerUnit
                    , viewportOffset = world.camera.offset
                    }
                    data
                    ++ debug

        -- Game.Loading _ ->
        --     []
        _ ->
            []


debugCollisionView : { a | pixelsPerUnit : Float, viewportOffset : Vec2, widthRatio : Float } -> World.CollisionMap -> List WebGL.Entity
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
                    Just shape ->
                        debugCollisionViewItem baseData shape ++ acc

                    _ ->
                        acc
            )
            []


debugCollisionViewItem : { a | pixelsPerUnit : Float, viewportOffset : Vec2, widthRatio : Float } -> Collision.WithShape b -> List WebGL.Entity
debugCollisionViewItem { widthRatio, viewportOffset, pixelsPerUnit } obj =
    case obj.shape of
        AABB _ ->
            let
                a_ =
                    aabbData obj
            in
                [ ObjectView.render
                    { widthRatio = widthRatio
                    , viewportOffset = viewportOffset
                    , pixelsPerUnit = pixelsPerUnit
                    , x = Vec2.getX a_.p
                    , y = Vec2.getY a_.p
                    , width = Vec2.length a_.xw * 2 --b.width
                    , height = Vec2.length a_.yw * 2 --b.height
                    , scrollRatio = vec2 1 1
                    }
                ]

        _ ->
            []
