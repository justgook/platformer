module Logic.Tiled.Read.Input exposing (read)

import Dict exposing (Dict)
import Logic.Entity as Entity exposing (EntityID)
import Logic.Tiled.Reader exposing (Read(..), defaultRead)
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
                emptyComp =
                    { x = 0
                    , y = 0
                    , down = ""
                    , left = ""
                    , right = ""
                    , up = ""
                    }

                var =
                    Parser.variable
                        { start = Char.isAlphaNum
                        , inner = \c -> Char.isAlphaNum c || c == '_'
                        , reserved = Set.empty
                        }

                onKey =
                    Parser.succeed identity
                        |. Parser.keyword "onKey"
                        |. Parser.symbol "["
                        |= var
                        |. Parser.symbol "]"
                        |. Parser.end
            in
            Dict.foldl
                (\k v ( comp, registered_ ) ->
                    Parser.run onKey k
                        |> Result.map (\key -> ( setKey comp v key, Dict.insert key entityId registered_ ))
                        |> Result.withDefault
                            ( comp, registered_ )
                )
                ( emptyComp, registered )
                props

        setKey comp dir key =
            case dir of
                PropString "Move.south" ->
                    { comp | down = key }

                PropString "Move.west" ->
                    { comp | left = key }

                PropString "Move.east" ->
                    { comp | right = key }

                PropString "Move.north" ->
                    { comp | up = key }

                _ ->
                    comp
    in
    { defaultRead
        | objectTile =
            Sync
                (\{ x, y, properties } ( entityId, world ) ->
                    let
                        dir =
                            spec.get world

                        ( comp, registered ) =
                            filterKeys properties ( entityId, dir.registered )

                        newWorld =
                            spec.set { dir | registered = registered } world
                    in
                    Entity.with ( compsSpec, comp ) ( entityId, newWorld )
                )
    }
