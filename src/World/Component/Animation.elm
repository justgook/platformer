module World.Component.Animation exposing (Animation, AnimationDict, animations)

import Dict exposing (Dict)
import Direction as DirectionHelper exposing (Direction(..))
import Error exposing (Error(..))
import Image
import Image.BMP exposing (encodeWith)
import Logic.Component
import Logic.Entity as Entity
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Parser exposing ((|.), (|=), Parser)
import ResourceTask
import Set
import Tiled.Properties exposing (Property(..))
import Tiled.Tileset
import Tiled.Util exposing (animationFraming)
import WebGL.Texture exposing (Texture)
import World.Component.Common exposing (EcsSpec, Read(..), defaultRead)


type alias AnimationDict =
    ( ( String, Int ), Dict ( String, Int ) Animation )


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


animations : EcsSpec { a | animations : Logic.Component.Set AnimationDict } AnimationDict (Logic.Component.Set AnimationDict)
animations =
    { spec = spec
    , empty = Logic.Component.empty
    , read =
        { defaultRead
            | objectTile =
                Async
                    (\{ properties, gid, getTilesetByGid } ->
                        getTilesetByGid gid
                            >> ResourceTask.andThen
                                (\t_ ->
                                    case t_ of
                                        Tiled.Tileset.Embedded t ->
                                            properties
                                                |> Dict.filter (\a _ -> String.startsWith "anim" a)
                                                |> fillAnimation t getTilesetByGid Dict.empty

                                        _ ->
                                            ResourceTask.fail (Error 6003 "object tile readers works only with single image tilesets")
                                )
                    )
        }
    }


type What
    = Id
    | Tileset


fillAnimation t getTilesetByGid acc all =
    case Dict.toList all of
        ( k, v ) :: _ ->
            case ( Parser.run parseName k, v ) of
                ( Ok ( _, Neither, _ ), _ ) ->
                    fillAnimation t getTilesetByGid acc (Dict.remove k all)

                ( Ok ( name, dir, Id ), PropInt tileIndex ) ->
                    animLutPlusImageTask t tileIndex
                        >> ResourceTask.andThen
                            (\info ->
                                let
                                    rest =
                                        Dict.remove k all

                                    accWithCurrent =
                                        Dict.insert ( name, DirectionHelper.toInt dir ) info acc

                                    opposite =
                                        dir
                                            |> DirectionHelper.opposite

                                    haveOpposite =
                                        opposite
                                            |> DirectionHelper.toString
                                            |> List.map (\k2 -> "anim." ++ name ++ "." ++ k2 ++ ".id")
                                in
                                case dictGetFirst haveOpposite all of
                                    Just ( k2, PropInt tileIndex2 ) ->
                                        animLutPlusImageTask t tileIndex2
                                            >> ResourceTask.andThen
                                                (\info2 ->
                                                    fillAnimation
                                                        t
                                                        getTilesetByGid
                                                        (Dict.insert ( name, DirectionHelper.toInt opposite ) info2 accWithCurrent)
                                                        (Dict.remove k2 rest)
                                                )

                                    _ ->
                                        fillAnimation t
                                            getTilesetByGid
                                            (Dict.insert ( name, DirectionHelper.toInt opposite ) { info | mirror = DirectionHelper.oppositeMirror dir |> Vec2.fromRecord } accWithCurrent)
                                            rest
                            )

                ( Ok ( _, _, Tileset ), PropInt _ ) ->
                    ResourceTask.fail (Error 6004 "Animation from other tile set not implemented yet")

                _ ->
                    fillAnimation t getTilesetByGid acc (Dict.remove k all)

        _ ->
            if Dict.isEmpty acc then
                ResourceTask.succeed identity

            else
                ResourceTask.succeed (Entity.with ( spec, ( ( "none", 3 ), acc ) ))


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


parseName =
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
        |. Parser.symbol "."
        |= Parser.oneOf
            [ Parser.map (\_ -> Id) (Parser.keyword "id")
            , Parser.map (\_ -> Tileset) (Parser.keyword "tileset")
            ]
        |. Parser.end


animLutPlusImageTask t tileIndex =
    ResourceTask.getTexture t.image
        >> ResourceTask.andThen
            (\tileSetImage ->
                case Tiled.Util.animation t tileIndex of
                    Just anim ->
                        let
                            animLutData =
                                animationFraming anim

                            animLength =
                                List.length animLutData
                        in
                        ResourceTask.getTexture (encodeWith Image.defaultOptions animLength 1 animLutData)
                            >> ResourceTask.map
                                (\animLUT ->
                                    { tileSet = tileSetImage
                                    , tileSetSize = vec2 (toFloat t.imagewidth) (toFloat t.imageheight)
                                    , tileSize = vec2 (toFloat t.tilewidth) (toFloat t.tileheight)
                                    , mirror = vec2 0 0
                                    , animLUT = animLUT
                                    , animLength = animLength
                                    }
                                )

                    Nothing ->
                        ResourceTask.fail (Error 6005 ("Sprite with index " ++ String.fromInt tileIndex ++ "must have animation"))
            )
