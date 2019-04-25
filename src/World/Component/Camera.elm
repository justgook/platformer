module World.Component.Camera exposing (Any, Camera, Follow, camera, cameraWith, target, targetWith)

import Defaults exposing (default)
import Dict
import Logic.Component.Singleton
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Parser exposing ((|.), (|=), Parser)
import Set
import Tiled.Util exposing (levelProps)
import World.Component.Common exposing (EcsSpec, Read(..), SingletonEcsSpec, defaultRead)


type alias Any a =
    { a
        | pixelsPerUnit : Float
        , viewportOffset : Vec2
    }


type alias Camera =
    Any {}


type alias Follow =
    Any { id : Int }


camera : SingletonEcsSpec Camera { a | camera : Camera }
camera =
    let
        empty =
            { pixelsPerUnit = default.pixelsPerUnit
            , viewportOffset = default.viewportOffset
            }
    in
    cameraWith empty defaultSpec


target : SingletonEcsSpec Follow { a | camera : Follow }
target =
    targetWith defaultSpec


defaultSpec =
    { get = .camera
    , set = \comps world -> { world | camera = comps }
    }


targetWith : Logic.Component.Singleton.Spec Follow esc -> SingletonEcsSpec Follow esc
targetWith spec =
    let
        empty =
            { pixelsPerUnit = default.pixelsPerUnit
            , viewportOffset = default.viewportOffset
            , id = 0
            }

        base =
            cameraWith empty spec

        read =
            base.read
    in
    { base
        | empty = empty
        , read =
            { read
                | objectTile =
                    Sync
                        (\{ x, y, properties } ( entityID, world ) ->
                            properties
                                |> Dict.filter (\a _ -> String.startsWith "camera" a)
                                |> Dict.keys
                                |> List.foldl
                                    (\item (( eID, w ) as acc) ->
                                        case Parser.run getFollowId item of
                                            Ok ( "follow", "x" ) ->
                                                let
                                                    cam =
                                                        spec.get w
                                                in
                                                ( eID, spec.set { cam | id = eID } w )

                                            _ ->
                                                acc
                                    )
                                    ( entityID, world )
                        )
            }
    }


cameraWith : Any a -> Logic.Component.Singleton.Spec (Any a) esc -> SingletonEcsSpec (Any a) esc
cameraWith empty spec =
    { spec = spec
    , empty = empty
    , read =
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
                                            in
                                            { empty
                                                | pixelsPerUnit = prop.float "pixelsPerUnit" default.pixelsPerUnit
                                                , viewportOffset = vec2 x y
                                            }
                                       )
                        in
                        ( entityID, spec.set cameraComp world )
                    )
        }
    }


getFollowId =
    let
        --anim.(name).(direction).(id|tileset)
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
