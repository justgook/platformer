module World.Component.Animation exposing (animations)

--animations : EcsSpec { a | animations : Logic.Component.Set Vec2 } Vec2 (Logic.Component.Set Vec2)

import Dict exposing (Dict)
import Error exposing (Error(..))
import Logic.Component
import Logic.Entity as Entity
import Math.Vector2 exposing (Vec2)
import Parser exposing ((|.), (|=), Parser)
import ResourceTask
import Set
import Tiled.Properties exposing (Property(..))
import Tiled.Tileset
import WebGL.Texture exposing (Texture)
import World.Component.Common exposing (Read(..), defaultRead)
import World.DirectionHelper as DirectionHelper exposing (Direction(..))


type alias Animations =
    Dict ( String, Int ) Animation


type alias Animation =
    { tileSet : Texture
    , tileSetSize : Vec2
    , tileSize : Vec2
    , mirror : Vec2
    , animLUT : Texture
    , animLength : Int
    }


spec =
    { get = .animations
    , set = \comps world -> { world | animations = comps }
    }


animations =
    { spec = spec
    , empty = Logic.Component.empty
    , read =
        { defaultRead
            | objectTile =
                Async
                    (\{ x, y, width, height, properties, gid, fh, fv, getTilesetByGid } ->
                        getTilesetByGid gid
                            >> ResourceTask.andThen
                                (\t_ ->
                                    case t_ of
                                        Tiled.Tileset.Embedded t ->
                                            properties
                                                |> Dict.filter (\a _ -> String.startsWith "anim" a)
                                                |> fillAnimation Dict.empty

                                        _ ->
                                            ResourceTask.fail (Error 6003 "object tile readers works only with single image tilesets")
                                )
                    )
        }
    }


type What
    = Id
    | Tileset


fillAnimation acc all =
    case Dict.toList all of
        ( k, v ) :: _ ->
            case ( Parser.run parseKey k, v ) of
                ( Ok ( _, NoDirection, _ ), _ ) ->
                    fillAnimation acc (Dict.remove k all)

                ( Ok ( name, dir, Id ), PropInt tileIndex ) ->
                    let
                        rest =
                            Dict.remove k all

                        newAcc =
                            Dict.insert ( name, DirectionHelper.toInt dir ) "tileIndex" acc

                        opposite =
                            dir
                                |> DirectionHelper.opposite

                        haveOpposite =
                            opposite
                                |> DirectionHelper.toString
                                |> List.map (\k2 -> "anim." ++ name ++ "." ++ k2 ++ ".id")

                        ( restWithoutOpposite, accWithOpposite ) =
                            case dictGetFirst haveOpposite all of
                                Just ( k2, PropInt tileIndex2 ) ->
                                    let
                                        _ =
                                            Debug.log "hello" k2
                                    in
                                    ( Dict.remove k2 rest, newAcc )

                                _ ->
                                    ( rest, newAcc )
                    in
                    fillAnimation accWithOpposite restWithoutOpposite

                ( Ok ( name, dir, Tileset ), PropInt tileIndex ) ->
                    ResourceTask.fail (Error 6004 "Animation from other tile set not implemented yet")

                _ ->
                    fillAnimation acc (Dict.remove k all)

        _ ->
            if Dict.isEmpty acc then
                ResourceTask.succeed identity

            else
                ResourceTask.succeed (Entity.with ( spec, acc ))


dictGetFirst : List comparable -> Dict comparable v -> Maybe ( comparable, v )
dictGetFirst keys dict =
    case keys of
        k :: rest ->
            case Dict.get k dict of
                Just v ->
                    Just ( k, v )

                Nothing ->
                    dictGetFirst rest dict

        _ ->
            Nothing


parseKey =
    let
        --anim.(name).(direction).(id|tileset)
        var =
            Parser.variable
                { start = Char.isAlphaNum
                , inner = \c -> Char.isAlphaNum c || c == '_'
                , reserved = Set.empty
                }
    in
    Parser.succeed (\a b c -> ( a, b, c ))
        |. Parser.keyword "anim"
        |. Parser.symbol "."
        |= var
        |. Parser.symbol "."
        |= Parser.map DirectionHelper.fromString var
        --        |= Parser.map (DirectionHelper.fromString >> DirectionHelper.toInt) var
        |. Parser.symbol "."
        |= Parser.oneOf
            [ Parser.map (\_ -> Id) (Parser.keyword "id")
            , Parser.map (\_ -> Tileset) (Parser.keyword "tileset")
            ]
        |. Parser.end
