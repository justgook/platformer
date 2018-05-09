module App.Update exposing (update)

import App.Message as Message exposing (Message)
import App.Model exposing (Model)
import Game.Model as Game
import Game.Update as Game
import VirtualDom exposing (style, attribute)
import Window exposing (Size)


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Message.Game m ->
            Game.update m model.game
                |> Tuple.mapFirst (\s -> { model | game = s })
                |> Tuple.mapSecond (Cmd.map Message.Game)

        Message.Window size ->
            let
                result =
                    updateCanvas size model
            in
                ( { result | height = size.height, game = Game.updateWidthRatio size result.game }, Cmd.none )


updateCanvas : Size -> Model -> Model
updateCanvas size model =
    let
        device =
            model.device
    in
        { model
            | style =
                [ toFloat size.width * device.pixelRatio |> round |> width
                , toFloat size.height * device.pixelRatio |> round |> height
                , style [ ( "display", "block" ), ( "width", toString size.width ++ "px" ), ( "height", toString size.height ++ "px" ) ]
                ]
        }


width : Int -> VirtualDom.Property msg
width value =
    attribute "width" (toString value)


height : Int -> VirtualDom.Property msg
height value =
    attribute "height" (toString value)
