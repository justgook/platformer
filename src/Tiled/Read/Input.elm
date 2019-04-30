module Tiled.Read.Input exposing (read)

import Dict exposing (Dict)
import Logic.Entity as Entity exposing (EntityID)
import Parser exposing ((|.), (|=))
import Set
import Tiled.Properties exposing (Property(..))
import Tiled.Read exposing (Read(..), defaultRead)



--direction :
--    EcsSpec
--        { a
--            | direction :
--                { comps : Logic.Component.Set Component
--                , registered : Dict String EntityID
--                , pressed : Set.Set String
--                }
--        }
--        Component
--        { comps : Logic.Component.Set Component
--        , registered : Dict String EntityID
--        , pressed : Set.Set String
--        }


read spec =
    let
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
                        ( comp, registered ) =
                            filterKeys properties ( entityId, world.direction.registered )

                        dir =
                            world.direction
                    in
                    Entity.with ( spec, comp ) ( entityId, { world | direction = { dir | registered = registered } } )
                )
    }
