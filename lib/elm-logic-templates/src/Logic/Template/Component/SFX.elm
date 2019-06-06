module Logic.Template.Component.SFX exposing (AudioSprite, add, draw, empty, sound, spawn, spec)

import Dict exposing (Dict)
import Json.Decode
import Json.Encode as Encode exposing (Value)
import Logic.Component.Singleton as Singleton
import Logic.Template.Sound as Sound
import Set exposing (Set)
import VirtualDom exposing (Handler(..))


type alias AudioSprite =
    { config :
        { src : List String
        , srcCache : Value
        , sprite :
            Dict String
                { offset : Float
                , duration : Float
                , loop : Bool
                , cache : Value
                }
        }
    , playing : Dict String Sound_
    , seed : Int
    , idSource : Set String
    }


type alias Sound_ =
    { id : String
    , key : String
    , offset : Float
    , duration : Float
    , loop : Bool
    }


type alias Sound =
    { id : String }


sound : String -> Sound
sound key =
    { id = key }


spec : Singleton.Spec AudioSprite { world | sfx : AudioSprite }
spec =
    { get = .sfx
    , set = \comps world -> { world | sfx = comps }
    }


empty : AudioSprite
empty =
    { config = { src = [], srcCache = Encode.null, sprite = Dict.empty }
    , playing = Dict.empty
    , seed = 0
    , idSource = Set.empty
    }


spawn : Singleton.Spec AudioSprite world -> Sound -> world -> world
spawn spec_ sound_ world =
    let
        comp =
            spec_.get world

        fromConfig =
            comp
                |> .config
                |> .sprite
                |> Dict.get sound_.id
    in
    case fromConfig of
        Just { offset, duration, loop } ->
            Singleton.update spec_
                (\c ->
                    let
                        paddedInt =
                            String.padLeft 3 '0' << String.fromInt

                        ( key, newComps ) =
                            case c.idSource |> Set.toList of
                                id :: rest ->
                                    ( id, { c | idSource = rest |> Set.fromList } )

                                [] ->
                                    ( paddedInt c.seed
                                    , { c | seed = c.seed + 1 }
                                    )
                    in
                    { newComps
                        | playing =
                            Dict.insert key
                                { id = sound_.id
                                , key = key
                                , offset = offset
                                , duration = duration
                                , loop = loop
                                }
                                c.playing
                    }
                )
                world

        Nothing ->
            world


add : Sound -> AudioSprite -> AudioSprite
add sound_ world =
    let
        fromConfig =
            world
                |> .config
                |> .sprite
                |> Dict.get sound_.id
    in
    case fromConfig of
        Just { offset, duration, loop } ->
            world
                |> (\c ->
                        let
                            paddedInt =
                                String.padLeft 3 '0' << String.fromInt

                            ( key, newComps ) =
                                case c.idSource |> Set.toList of
                                    id :: rest ->
                                        ( id, { c | idSource = rest |> Set.fromList } )

                                    [] ->
                                        ( paddedInt c.seed
                                        , { c | seed = c.seed + 1 }
                                        )
                        in
                        { newComps
                            | playing =
                                Dict.insert key
                                    { id = sound_.id
                                    , key = key
                                    , offset = offset
                                    , duration = duration
                                    , loop = loop
                                    }
                                    c.playing
                        }
                   )

        Nothing ->
            world


boolToString bool =
    if bool then
        "true"

    else
        "false"


draw : Singleton.Spec AudioSprite world -> world -> VirtualDom.Node (world -> world)
draw ({ get } as spec_) w =
    let
        { playing, config, idSource } =
            get w
    in
    List.map
        (\{ id, key, offset, duration, loop } ->
            let
                newSprite =
                    Encode.object
                        [ ( id
                          , Encode.list identity
                                [ Encode.float offset
                                , Encode.float duration
                                , Encode.bool loop
                                ]
                          )
                        ]
            in
            ( key
            , Sound.play config.srcCache
                key
                [ Sound.id id
                , Sound.sprite newSprite
                , onend spec_
                , Sound.stop <| boolToString <| Set.member key idSource
                ]
            )
        )
        (Dict.values playing)
        |> VirtualDom.keyedNode "div" []


onend spec_ =
    VirtualDom.on "finish"
        (Custom
            (Json.Decode.at [ "detail", "keys" ] (Json.Decode.list Json.Decode.string)
                |> Json.Decode.map
                    (\keys ->
                        { message =
                            Singleton.update spec_
                                (\c ->
                                    { c
                                        | idSource = Set.fromList keys |> Set.union c.idSource
                                    }
                                )
                        , stopPropagation = True
                        , preventDefault = True
                        }
                    )
            )
        )
