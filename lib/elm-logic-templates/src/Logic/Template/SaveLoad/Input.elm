module Logic.Template.SaveLoad.Input exposing (decode, encode, haveInput, read)

import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Dict exposing (Dict)
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity exposing (EntityID)
import Logic.Template.Input as Input exposing (Input, InputSingleton, emptyComp)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (GuardReader, Read(..), WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)
import Parser exposing ((|.), (|=), Parser)
import Set
import Tiled.Properties exposing (Property(..))


encode : Singleton.Spec InputSingleton world -> world -> Encoder
encode { get } world =
    let
        { registered } =
            get world
    in
    Dict.toList registered
        |> E.list
            (\( key, ( id, action ) ) ->
                E.sequence
                    [ E.id id
                    , E.sizedString key
                    , E.sizedString action
                    ]
            )


decode : Singleton.Spec InputSingleton world -> WorldDecoder world
decode spec_ =
    let
        decoder =
            D.map3
                (\id key action -> ( key, ( id, action ) ))
                D.id
                D.sizedString
                D.sizedString
    in
    D.list decoder
        |> D.map
            (\registered ->
                Singleton.update spec_
                    (\info ->
                        let
                            newInfo =
                                List.foldl
                                    (\( _, ( id, _ ) ) acc ->
                                        let
                                            comp =
                                                Entity.get id acc.comps
                                                    |> Maybe.withDefault emptyComp
                                        in
                                        { acc
                                            | comps = Component.spawn id comp acc.comps
                                        }
                                    )
                                    info
                                    registered
                        in
                        { newInfo | registered = Dict.fromList registered }
                    )
            )


haveInput : GuardReader
haveInput =
    { defaultRead
        | objectTile =
            Sync
                (\{ properties } ->
                    properties
                        |> Dict.keys
                        |> List.any (Parser.run onKey >> Result.toMaybe >> (/=) Nothing)
                )
    }


read : Singleton.Spec InputSingleton world -> WorldReader world
read spec =
    let
        compsSpec =
            { get = spec.get >> .comps
            , set =
                \comps world ->
                    let
                        dir =
                            spec.get world
                    in
                    spec.set { dir | comps = comps } world
            }

        filterKeys props ( entityId, registered ) =
            Dict.foldl
                (\k v ( maybeComp, registered_ ) ->
                    Parser.run onKey k
                        |> Result.map (setKey entityId registered_ maybeComp v)
                        |> Result.withDefault ( maybeComp, registered_ )
                )
                ( Nothing, registered )
                props

        setKey entityId registered_ comp_ dir key =
            let
                comp =
                    Maybe.withDefault emptyComp comp_
            in
            case dir of
                PropString other ->
                    ( Just comp, Dict.insert key ( entityId, other ) registered_ )

                _ ->
                    ( comp_, registered_ )
    in
    { defaultRead
        | objectTile =
            Sync
                (\{ properties } ( entityId, world ) ->
                    let
                        dir =
                            spec.get world

                        ( comp_, registered ) =
                            filterKeys properties ( entityId, dir.registered )

                        newWorld =
                            spec.set { dir | registered = registered } world
                    in
                    (comp_
                        |> Maybe.map (\comp -> Entity.with ( compsSpec, comp ))
                        |> Maybe.withDefault identity
                    )
                        ( entityId, newWorld )
                )
    }


onKey : Parser String
onKey =
    let
        keyVar =
            Parser.variable
                { start = \c -> Char.isAlphaNum c || c == ' ' -- specific case for space
                , inner = \c -> Char.isAlphaNum c || c == '_' || c == ' '
                , reserved = Set.empty
                }
    in
    Parser.succeed identity
        |. Parser.keyword "onKey"
        |. Parser.symbol "["
        |= keyVar
        |. Parser.symbol "]"
        |. Parser.end
