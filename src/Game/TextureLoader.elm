module Game.TextureLoader exposing (Message, Model, get, init, load, update)

import Dict exposing (Dict)
import Task
import WebGL.Texture as Texture exposing (Error, Texture, Wrap, defaultOptions, linear, nearest, nonPowerOfTwoOptions)


type alias Model =
    { images : Dict String Texture
    }


type Message
    = TextureLoaded String (Result Error Texture)


load : String -> String -> Cmd Message
load key url =
    Task.attempt (TextureLoaded key)
        (Texture.loadWith
            { nonPowerOfTwoOptions
                | magnify = nearest
                , minify = nearest
            }
            url
        )


get : String -> Model -> Maybe Texture
get key { images } =
    Dict.get key images


init : Model
init =
    Model Dict.empty


update : Message -> Model -> Model
update msg model =
    case msg of
        TextureLoaded key (Ok texture) ->
            { model | images = Dict.insert key texture model.images }

        TextureLoaded key (Err error) ->
            let
                _ =
                    Debug.log "TextureLoaded:Err" error
            in
            model
