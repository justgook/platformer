A library for building decoders for [Tiled](http://www.mapeditor.org/) levels.

## Motivation

I can not find good library that decodes Tiled data and is up to date, and use JavaScript ports was not an option.


## Examples

```elm
module Main exposing (main)

import Browser
import Html
import Http
import Tiled
import Tiled.Level exposing (Level)


type Message
    = LevelLoaded (Result Http.Error Level)


load : String -> Cmd Message
load url =
    Http.get
        { url = url
        , expect = Http.expectJson LevelLoaded Tiled.decode
        }


main : Program () (Maybe Level) Message
main =
    Browser.element
        { init = \_ -> ( Nothing, load "./some_tiled_level.json" )
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }


view : Maybe Level -> Html.Html Message
view model =
    Html.text (Debug.toString model)


update : Message -> Maybe Level -> ( Maybe Level, Cmd msg )
update msg model =
    case msg of
        LevelLoaded (Ok level) ->
            ( Just level, Cmd.none )

        LevelLoaded (Err _) ->
            ( model, Cmd.none )


```
