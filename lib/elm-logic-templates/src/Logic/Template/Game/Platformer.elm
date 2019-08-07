module Logic.Template.Game.Platformer exposing (World, decode, encode, game, load, run)

import AltMath.Vector2 as Vec2 exposing (vec2)
import Browser.Dom as Browser
import Browser.Events as Events
import Bytes exposing (Bytes)
import Collision.Physic.AABB as AABB
import Collision.Physic.Narrow.AABB as AABB
import Logic.Component.Singleton as Singleton
import Logic.Entity
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.System as System
import Logic.Template.Camera
import Logic.Template.Camera.PositionLocking
import Logic.Template.Camera.Trigger exposing (Trigger)
import Logic.Template.Component.Animation as TimeLine2
import Logic.Template.Component.AnimationsDict as TimeLineDict2
import Logic.Template.Component.Layer
import Logic.Template.Component.OnScreenControl as OnScreenControl exposing (TwoButtonStick)
import Logic.Template.Component.Physics
import Logic.Template.Component.SFX as AudioSprite
import Logic.Template.Component.Sprite as Sprite exposing (Sprite)
import Logic.Template.Game.Platformer.Common exposing (PlatformerWorld, decoders, empty, encoders, read)
import Logic.Template.Game.Platformer.RenderSystem exposing (debugPhysicsAABB)
import Logic.Template.Input exposing (InputSingleton)
import Logic.Template.Input.Keyboard as Keyboard
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo, setInitResize)
import Logic.Template.SaveLoad as SaveLoad
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Layer exposing (lutCollector)
import Logic.Template.System.Control as Control
import Logic.Template.System.TimelineChange as TimelineChange
import Math.Vector2
import Task exposing (Task)
import WebGL



--ASSETS!!
--https://gumroad.com/l/IDwxw
--https://forums.tigsource.com/index.php?topic=14166.0
--https://www.deviantart.com/madgharr -- super micro characters


type alias World =
    PlatformerWorld


game : Launcher.Document flags PlatformerWorld
game =
    { update = update
    , view = view
    , subscriptions = subscriptions
    , init = \_ -> load "default.json"
    }


encode : String -> Task.Task Launcher.Error ( Bytes, PlatformerWorld )
encode levelUrl =
    SaveLoad.loadTiledAndEncode levelUrl empty read encoders lutCollector
        |> ResourceTask.toTask


decode : Bytes -> Task Launcher.Error (Launcher.World PlatformerWorld)
decode bytes =
    let
        worldTask =
            SaveLoad.loadFromBytes bytes empty decoders |> ResourceTask.toTask
    in
    setInitResize RenderInfo.spec worldTask


run : String -> Task Launcher.Error (Launcher.World PlatformerWorld)
run levelUrl =
    let
        worldTask =
            SaveLoad.loadBytes levelUrl empty decoders |> ResourceTask.toTask
    in
    setInitResize RenderInfo.spec worldTask


load : String -> Task Launcher.Error (Launcher.World PlatformerWorld)
load levelUrl =
    let
        worldTask =
            SaveLoad.loadTiled levelUrl empty read
    in
    setInitResize RenderInfo.spec worldTask



--subscriptions : { world | input : InputSingleton, render : RenderInfo } -> Sub { world | input : InputSingleton }


subscriptions w =
    Sub.batch
        [ Keyboard.sub Logic.Template.Input.spec w
        , Events.onResize (RenderInfo.resize RenderInfo.spec w)
        ]



-- Not works with intellij elm plugin
--view : List (VirtualDom.Attribute msg) -> Launcher.World PlatformerWorld -> List (VirtualDom.Node msg)


view w =
    let
        --        { renderable } =
        --            w.projectile
        --        fxUniforms =
        --            { renderable
        --                | aspectRatio = toFloat w.render.screen.width / toFloat w.render.screen.height
        --                , viewportOffset =
        --                    w.camera.viewportOffset
        --                        |> Vec2.scale w.render.px
        --                        |> Math.Vector2.fromRecord
        --            }
        --        _ =
        --            w.render
        --                |> Debug.log "hello"
        --        space =
        --            Logic.Template.GFX.Space.draw fullscreenVertexShader
        --                ({ viewport = updatedWorld.render.fixed
        --                 , px = w.render.px
        --                 , offset = updatedWorld.render.offset
        --                 , time = toFloat updatedWorld.frame
        --                 }
        --                )
        playerEntityID =
            w.camera.id
    in
    [ Logic.Template.Component.Layer.draw (objRender w) w
        --        ++ aabb.view w.render w []
        --        ++ Projectile.draw fxUniforms
        --        ++ [ space ]
        |> WebGL.toHtmlWith webGLOption (RenderInfo.canvas w.render)
    , OnScreenControl.twoButtonStick (OnScreenControl.onscreenSpecExtend "" "Jump" OnScreenControl.spec (Logic.Template.Input.toComps Logic.Template.Input.spec) playerEntityID) w
    ]
        |> (::) (AudioSprite.draw AudioSprite.spec w)


webGLOption : List WebGL.Option
webGLOption =
    [ WebGL.alpha False
    , WebGL.depth 1
    , WebGL.clearColor (29 / 255) (33 / 255) (45 / 255) 1
    ]


objRender w ( _, objLayer ) =
    System.indexedFoldl3
        (\i _ c1 sprite acc ->
            acc
                |> (::)
                    (Sprite.draw
                        w.render
                        (case Logic.Entity.get i w.animation of
                            Just t ->
                                let
                                    testSprite =
                                        { sprite
                                            | uTileUV = TimeLine2.get w.frame t
                                            , uMirror = t.uMirror
                                        }
                                in
                                { testSprite
                                    | uP =
                                        c1
                                            |> AABB.getPosition
                                            |> (\{ x, y } -> { x = toFloat (round x), y = toFloat (round y) })
                                            |> Math.Vector2.fromRecord
                                }

                            Nothing ->
                                { sprite
                                    | uP =
                                        c1
                                            |> AABB.getPosition
                                            |> Math.Vector2.fromRecord
                                }
                        )
                    )
        )
        objLayer
        (aabb.compsExtracter w)
        w.sprites
        []


update w =
    let
        pixelsPerUnit =
            1.0 / w.render.px

        target_ =
            getPosById w.camera.id w

        target =
            target_
                |> (\a -> Vec2.sub a (getCenter w))

        contactForCamera =
            aabb.spec.get w
                |> AABB.byId w.camera.id
                |> Maybe.map (AABB.getContact >> .y)
                |> Maybe.andThen
                    (\a ->
                        if a == -1 then
                            Just target.y

                        else
                            Nothing
                    )

        cameraStep =
            Logic.Template.Camera.Trigger.yTrigger 3 contactForCamera target
                >> Logic.Template.Camera.PositionLocking.xLock target

        newOffset =
            Math.Vector2.fromRecord w.camera.viewportOffset

        updatedWorld =
            { w | render = RenderInfo.setOffset newOffset w.render }

        moveJump =
            vec2 3 8
    in
    updatedWorld
        |> Control.platformer moveJump Logic.Template.Input.spec aabb.spec AudioSprite.spec
        |> aabb.system
        |> TimelineChange.sideScroll TimeLineDict2.spec aabb.spec TimeLine2.spec
        |> Singleton.update Logic.Template.Camera.spec cameraStep
        |> (\m -> ( m, Cmd.none ))


aabb =
    let
        empty =
            Logic.Template.Component.Physics.empty
    in
    { spec = Logic.Template.Component.Physics.spec
    , empty = { empty | gravity = { x = 0, y = -0.5 } }
    , view = debugPhysicsAABB
    , system = Logic.Template.Component.Physics.system Logic.Template.Component.Physics.spec
    , getPosition = AABB.getPosition
    , compsExtracter = \ecs -> ecs.physics |> AABB.getIndexed |> Logic.Entity.fromList
    }


getPosById id =
    aabb.spec.get
        >> AABB.byId id
        >> Maybe.map AABB.getPosition
        >> Maybe.withDefault (vec2 0 0)


getCenter w =
    let
        aspectRatio =
            toFloat w.render.screen.width / toFloat w.render.screen.height

        pixelsPerUnit =
            1.0 / w.render.px
    in
    { x = 0.5 / w.render.px * aspectRatio
    , y = 0.5 / w.render.px
    }
