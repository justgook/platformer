module Main exposing (main)

import Browser
import Bytes exposing (Endianness(..))
import Bytes.Encode as Encode exposing (encode, unsignedInt8)
import Html exposing (img, text)
import Html.Attributes exposing (height, src, width)
import Image.BMP as Bmp exposing (encode24)


main =
    Browser.sandbox
        { init = ()
        , view = view
        , update = \_ _ -> ()
        }


view _ =
    let
        w =
            100

        h =
            100

        pixels =
            List.repeat (w * h) 0x00FF0000

        reuslt =
            pixels
                |> Bmp.encode24 w h
                |> Debug.log "Hello"
    in
    img [ height 100, width 100, src reuslt ] []
