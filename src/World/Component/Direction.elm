module World.Component.Direction exposing (Direction, direction)

import Array
import Dict exposing (Dict)
import Logic.Component
import Logic.Entity as Entity exposing (EntityID)
import Parser exposing ((|.), (|=))
import Set
import Tiled.Properties exposing (Property(..))
import World.Component.Common exposing (EcsSpec, Read3(..), defaultRead)


type alias Direction =
    { x : Int
    , y : Int
    , down : String
    , left : String
    , right : String
    , up : String
    }


direction :
    EcsSpec
        { a
            | direction :
                { comps : Logic.Component.Set Direction
                , registered : Dict String EntityID
                , pressed : Set.Set String
                }
        }
        layer
        Direction
        { comps : Logic.Component.Set Direction
        , registered : Dict String EntityID
        , pressed : Set.Set String
        }
direction =
    let
        spec =
            { get = .direction >> .comps
            , set =
                \comps world ->
                    let
                        dir =
                            world.direction
                    in
                    { world | direction = { dir | comps = comps } }
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

                typeVar =
                    Parser.variable
                        { start = Char.isAlphaNum
                        , inner = \c -> Char.isAlphaNum c || c == '_'
                        , reserved = Set.empty
                        }

                onKey =
                    Parser.succeed (\a b -> b)
                        |= Parser.keyword "onKey"
                        |. Parser.symbol "["
                        |= typeVar
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
    { spec = spec
    , empty =
        { pressed = Set.empty
        , comps = Array.empty
        , registered = Dict.empty
        }
    , read =
        { defaultRead
            | objectTile =
                Sync3
                    (\{ x, y, properties } _ _ ( entityId, world ) ->
                        let
                            ( comp, registered ) =
                                filterKeys properties ( entityId, world.direction.registered )

                            dir =
                                world.direction
                        in
                        Entity.with ( spec, comp ) ( entityId, { world | direction = { dir | registered = registered } } )
                    )
        }
    }
