module Logic.Template.Game.Fight exposing (World, game, run)

import Browser.Dom as Browser
import Browser.Events as Events
import Dict
import Html
import Html.Attributes exposing (style)
import Logic.Launcher as Launcher
import Logic.System as System
import Logic.Template.Component.Network.Status as Status exposing (Status)
import Logic.Template.Component.Position as Position exposing (Position)
import Logic.Template.Component.Velocity as Velocity exposing (Velocity)
import Logic.Template.Game.Fight.Sync as Sync
import Logic.Template.Game.Fight.World as World
import Logic.Template.Input as Input exposing (Input, InputSingleton)
import Logic.Template.Input.Keyboard as Keyboard
import Logic.Template.Network as Network exposing (OutMessage)
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.System.Network as Network
import Logic.Template.System.VelocityPosition
import Random
import Task exposing (Task)


type alias World =
    Launcher.World World.FightWorld


game income outcome =
    { update = update outcome
    , view = view
    , subscriptions = subscriptions income outcome
    , init = \_ -> run "default.ace.bin"
    }


update outcomePort before =
    let
        connect =
            Network.connect "ws://localhost:9001/AAAAA"
                |> outcomePort

        syncData =
            Network.sync Status.spec Sync.protocol outcomePort
    in
    case before.status of
        Status.Slave _ _ ->
            ( before, Cmd.none )

        Status.Master _ _ ->
            before
                |> System.step2 (\( { x, y }, _ ) ( _, setVel ) -> setVel { x = x, y = -y }) (Input.toComps Input.spec) Velocity.spec
                |> Logic.Template.System.VelocityPosition.system Velocity.spec Position.spec
                |> (\after -> ( after, syncData before after ))

        Status.Disconnected ->
            ( { before | status = Status.Connecting }, connect )

        Status.Connecting ->
            ( before, Cmd.none )


view : World -> List (Html.Html msg)
view world =
    let
        pos { x, y } =
            [ style "position" "absolute"
            , style "left" "0"
            , style "top" "0"
            , style "width" "10px"
            , style "height" "10px"
            , style "background-color" "red"
            , style "transform" ("translate(" ++ String.fromFloat x ++ "px," ++ String.fromFloat y ++ "px)")
            ]

        items =
            System.foldl (\p acc -> Html.div (pos p) [] :: acc) (Position.spec.get world) []
    in
    Html.text
        (case world.status of
            Status.Slave sessionId roomId ->
                "Slave (" ++ roomId ++ "::" ++ sessionId ++ ")"

            Status.Master sessionId roomId ->
                "Master(" ++ roomId ++ "::" ++ sessionId ++ ")"

            Status.Connecting ->
                "Connecting"

            Status.Disconnected ->
                "Disconnected"
        )
        :: items


networkSub =
    Network.subscription Status.spec Sync.protocol


subscriptions income outcome before =
    let
        initialWorld =
            World.empty

        syncData =
            Network.sync Status.spec Sync.protocol outcome

        sendClientEntityId sessionId entityId =
            Network.unsafePrivateCmd outcome 0 (E.id entityId) sessionId

        sendCurrentState =
            Network.initSync Sync.protocol outcome initialWorld
    in
    Sub.batch
        [ Events.onResize (RenderInfo.resize RenderInfo.spec before)
        , income (\bytes -> networkSub bytes before)
        , Keyboard.sub Input.spec before
        ]
        |> Sub.map
            (\after ->
                let
                    --TODO move that part to server sync same as idSource
                    cmd =
                        if after.online /= before.online then
                            Dict.diff after.online before.online
                                |> Dict.foldl
                                    (\sessionId entityId acc ->
                                        sendCurrentState after sessionId
                                            :: sendClientEntityId sessionId entityId
                                            :: acc
                                    )
                                    -- Just update random each time new user joins
                                    [ randomCmd ]
                                |> Cmd.batch

                        else
                            Cmd.none
                in
                ( after, Cmd.batch [ syncData before after, cmd ] )
            )


load : String -> ( Task Launcher.Error (Launcher.World World), Cmd msg )
load levelUrl =
    let
        worldTask =
            World.empty
                |> Task.succeed

        --            SaveLoad.loadTiled levelUrl empty read
    in
    ( setInitResize worldTask, Cmd.none )


run : String -> ( Task Launcher.Error (Launcher.World World), Cmd (Launcher.Message World) )
run levelUrl =
    let
        worldTask =
            World.empty
                |> Task.succeed

        --            SaveLoad.loadBytes levelUrl empty decoders
        --                |> ResourceTask.toTask
    in
    ( setInitResize worldTask, Cmd.none )


setInitResize =
    Task.map2
        (\{ scene } w ->
            RenderInfo.resize RenderInfo.spec w (round scene.width) (round scene.height)
         --                |> update
         --                |> Tuple.first
        )
        Browser.getViewport


randomCmd : Cmd (Launcher.Message World)
randomCmd =
    Random.generate (\seed -> Launcher.event (\w -> { w | seed = seed })) Random.independentSeed
