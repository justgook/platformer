module App.Update exposing (update)

import App.Message as Message exposing (Message)
import App.Model exposing (Model)
import Html.Attributes exposing (height, style, width)
import Window exposing (Size)


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        -- http://package.elm-lang.org/packages/zaidan/elm-collision/latest
        Message.Animate dt ->
            ( { model
                | runtime = dt + model.runtime
              }
            , Cmd.none
            )

        Message.Window size ->
            ( updateCanvas size model, Cmd.none )


updateCanvas : Size -> Model -> Model
updateCanvas size model =
    let
        device =
            model.device
    in
    { model
        | widthRatio = toFloat size.width / toFloat size.height

        -- uniforms = uniforms |> Uniforms.set (\data -> { data | widthRatio = toFloat size.width / toFloat size.height })
        , style =
            [ toFloat size.width * device.pixelRatio |> round |> width
            , toFloat size.height * device.pixelRatio |> round |> height
            , style [ ( "display", "block" ), ( "width", toString size.width ++ "px" ), ( "height", toString size.height ++ "px" ) ]
            ]
    }
