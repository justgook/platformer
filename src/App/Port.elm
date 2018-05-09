port module App.Port exposing (..)

-- port for sending strings out to JavaScript


port play : String -> Cmd msg


port stop : String -> Cmd msg



-- port for listening for suggestions from JavaScript
-- port suggestions : (List String -> msg) -> Sub msg
