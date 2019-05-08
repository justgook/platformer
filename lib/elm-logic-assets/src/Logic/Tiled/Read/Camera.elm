module Logic.Tiled.Read.Camera exposing (read, readId)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Defaults exposing (default)
import Dict
import Logic.Asset.Camera as Camera
import Logic.Tiled.Reader exposing (Read(..), defaultRead)
import Logic.Tiled.Util exposing (levelProps)
import Parser exposing ((|.), (|=), Parser)
import Set


readId spec_ =
    let
        baseRead =
            read spec_
    in
    { baseRead
        | objectTile =
            Sync
                (\{ properties } ( entityID, world ) ->
                    properties
                        |> Dict.filter (\a _ -> String.startsWith "camera" a)
                        |> Dict.keys
                        |> List.foldl
                            (\item (( eID, w ) as acc) ->
                                case Parser.run getFollowId item of
                                    Ok ( "follow", "x" ) ->
                                        let
                                            cam =
                                                spec_.get w
                                        in
                                        ( eID, spec_.set { cam | id = eID } w )

                                    _ ->
                                        acc
                            )
                            ( entityID, world )
                )
    }


read spec_ =
    { defaultRead
        | level =
            Sync
                (\level ( entityID, world ) ->
                    let
                        cameraComp =
                            levelProps level
                                |> (\prop ->
                                        let
                                            x =
                                                default.viewportOffset
                                                    |> Vec2.getX
                                                    |> prop.float "offset.x"

                                            y =
                                                default.viewportOffset
                                                    |> Vec2.getX
                                                    |> prop.float "offset.y"

                                            cam =
                                                spec_.get world
                                        in
                                        { cam
                                            | pixelsPerUnit = prop.float "pixelsPerUnit" default.pixelsPerUnit
                                            , viewportOffset = vec2 x y
                                        }
                                   )
                    in
                    ( entityID, spec_.set cameraComp world )
                )
    }


getFollowId =
    let
        var =
            Parser.variable
                { start = Char.isAlphaNum
                , inner = \c -> Char.isAlphaNum c || c == '_'
                , reserved = Set.empty
                }
    in
    Parser.succeed (\a b -> ( a, b ))
        |. Parser.keyword "camera"
        |. Parser.symbol "."
        |= var
        |. Parser.symbol "."
        |= var
        |. Parser.end
