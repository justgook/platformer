module Logic.Template.SaveLoad.Input exposing (read)

import Dict exposing (Dict)
import Logic.Entity as Entity exposing (EntityID)
import Logic.Template.Input exposing (emptyComp)
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), defaultRead)
import Parser exposing ((|.), (|=))
import Set
import Tiled.Properties exposing (Property(..))


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
            let
                keyVar =
                    Parser.variable
                        { start = \c -> Char.isAlphaNum c || c == ' ' -- specific case for space
                        , inner = \c -> Char.isAlphaNum c || c == '_' || c == ' '
                        , reserved = Set.empty
                        }

                onKey =
                    Parser.succeed identity
                        |. Parser.keyword "onKey"
                        |. Parser.symbol "["
                        |= keyVar
                        |. Parser.symbol "]"
                        |. Parser.end
            in
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
                PropString "Move.south" ->
                    ( Just { comp | down = key }, Dict.insert key ( entityId, "Move.south" ) registered_ )

                PropString "Move.west" ->
                    ( Just { comp | left = key }, Dict.insert key ( entityId, "Move.west" ) registered_ )

                PropString "Move.east" ->
                    ( Just { comp | right = key }, Dict.insert key ( entityId, "Move.east" ) registered_ )

                PropString "Move.north" ->
                    ( Just { comp | up = key }, Dict.insert key ( entityId, "Move.north" ) registered_ )

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
