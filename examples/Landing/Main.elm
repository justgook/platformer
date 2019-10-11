module Landing.Main exposing (main)

import Browser
import Browser.Dom as Browser
import Html
import Landing.Start
import Logic.Launcher exposing (Error(..))
import Logic.Template.Game.Platformer as Platformer
import Logic.Template.Game.Platformer.Common as Platformer
import Logic.Template.Game.TopDown as TopDown
import Logic.Template.RenderInfo as RenderInfo
import Logic.Template.SaveLoad.Internal.Loader exposing (CacheTiled(..))
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.TiledReader as TiledReader
import Task


main : Program () Model Message
main =
    Browser.document
        { init = \_ -> ( initModel, Cmd.none )
        , view = \m -> { title = "", body = view m }
        , update = update
        , subscriptions = subscriptions
        }


platformerInline =
    Logic.Launcher.inline Platformer.game


topDownInline =
    Logic.Launcher.inline TopDown.game


subscriptions model =
    case model of
        Platformer w ->
            Sub.map RunningPlatformer (platformerInline.subscriptions w)

        TopDown w ->
            Sub.map RunningTopDown (topDownInline.subscriptions w)

        _ ->
            Sub.none


update msg model =
    case ( model, msg ) of
        ( Platformer w, RunningPlatformer msg_ ) ->
            platformerInline.update msg_ w |> Tuple.mapBoth Platformer (Cmd.map RunningPlatformer)

        ( TopDown w, RunningTopDown msg_ ) ->
            topDownInline.update msg_ w |> Tuple.mapBoth TopDown (Cmd.map RunningTopDown)

        ( Start _, Fail e ) ->
            ( model, Cmd.none )

        ( Start _, Success game ) ->
            ( game, Cmd.none )

        ( Start start, Init startMsg ) ->
            Landing.Start.update Fail startMsg start
                |> Tuple.mapFirst Start

        _ ->
            ( model, Cmd.none )


findLevel l =
    case l of
        ( url, Level_ _ ) :: _ ->
            Just url

        _ :: rest ->
            findLevel rest

        [] ->
            Nothing


type Model
    = Platformer Platformer.PlatformerWorld
    | TopDown TopDown.World
    | Start (Landing.Start.Model Model Message)


type Message
    = Success Model
    | Fail String
    | RunningPlatformer (Logic.Launcher.Message Platformer.PlatformerWorld)
    | RunningTopDown (Logic.Launcher.Message TopDown.World)
    | Init (Landing.Start.Message Model Message)


initModel : Model
initModel =
    Start
        { items = games
        , dragOver = -1
        }


gamePlatformer name thumbnail =
    { success = Success
    , fail = "String"
    , name = name
    , templateUrl = "https://github.com/z0lv/platformer-puzzle"
    , thumbnail = thumbnail
    , startUrl = ""
    , parse =
        \level ->
            TiledReader.parse Platformer.empty Platformer.read level
                >> initResize
                >> ResourceTask.map Platformer
    }


gameTopDown name thumbnail =
    { success = Success
    , fail = "String"
    , name = name
    , templateUrl = "https://github.com/z0lv/top-down-adventure"
    , thumbnail = thumbnail
    , startUrl = ""
    , parse =
        \level ->
            TiledReader.parse TopDown.empty TopDown.read level
                >> initResize
                >> ResourceTask.map TopDown
    }


games =
    [ gamePlatformer "Platformer puzzle" "dist/MazePlatformer_thumbnail.png"
    , gameTopDown "Top-down Adventure" "dist/RPG_thumbnail.png"
    ]


view m_ =
    case m_ of
        Platformer w ->
            platformerInline.view w
                |> List.map (Html.map RunningPlatformer)

        TopDown w ->
            topDownInline.view w
                |> List.map (Html.map RunningTopDown)

        Start m ->
            Landing.Start.view m |> List.map (Html.map Init)


initResize =
    Task.andThen
        (\( w, c ) ->
            Browser.getViewport
                |> Task.map
                    (\{ scene } ->
                        RenderInfo.resize RenderInfo.spec w (round scene.width) (round scene.height)
                    )
                |> Task.map (\w2 -> ( w2, c ))
        )
