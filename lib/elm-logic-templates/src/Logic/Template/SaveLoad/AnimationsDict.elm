module Logic.Template.SaveLoad.AnimationsDict exposing (decode, encode, read)

import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Dict exposing (Dict)
import Direction as DirectionHelper exposing (Direction(..))
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.Launcher exposing (Error(..))
import Logic.Template.Component.AnimationsDict exposing (AnimationId, TimeLineDict3)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)
import Math.Vector2 as Vec2 exposing (Vec2)
import Parser exposing ((|.), (|=), Parser)
import Set
import Tiled.Properties exposing (Property(..))
import Tiled.Tileset exposing (EmbeddedTileData)


read : (EmbeddedTileData -> Int -> Maybe { a | uMirror : Vec2 }) -> Component.Spec (TimeLineDict3 { a | uMirror : Vec2 }) world -> Reader world
read f spec =
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
                                            |> fillAnimation f spec t Dict.empty

                                    _ ->
                                        ResourceTask.fail (Error 8003 "object tile readers works only with single image tilesets")
                            )
                )
    }


encode : ({ a | uMirror : Vec2 } -> Encoder) -> Component.Spec (TimeLineDict3 { a | uMirror : Vec2 }) world -> world -> Encoder
encode itemEncode { get } world =
    Entity.toList (get world)
        |> E.list
            (\( id, ( current, dict ) ) ->
                let
                    encodeDict =
                        dict
                            |> Dict.toList
                            |> E.list
                                (\( animId, animLine ) ->
                                    E.sequence [ encodeAnimationId animId, itemEncode animLine ]
                                )
                in
                E.sequence [ E.id id, encodeAnimationId current, encodeDict ]
            )


decode : Decoder { a | uMirror : Vec2 } -> Component.Spec (TimeLineDict3 { a | uMirror : Vec2 }) world -> WorldDecoder world
decode decodeItem spec_ =
    let
        decodeDict =
            D.list (D.map2 (\animId animLine -> ( animId, animLine )) decodeAnimationId decodeItem)
                |> D.map Dict.fromList

        decoder =
            D.map3 (\id current dict -> ( id, ( current, dict ) )) D.id decodeAnimationId decodeDict
    in
    D.list decoder
        |> D.map
            (\list -> Singleton.update spec_ (\_ -> Entity.fromList list))


encodeAnimationId : AnimationId -> Encoder
encodeAnimationId ( a, b ) =
    E.sequence [ E.sizedString a, E.unsignedInt8 b ]


decodeAnimationId : Decoder AnimationId
decodeAnimationId =
    D.map2 Tuple.pair D.sizedString D.unsignedInt8


type What
    = Id
    | Tileset


fillAnimation f spec t acc all =
    case Dict.toList all of
        ( k, v ) :: _ ->
            case ( Parser.run parseName k, v ) of
                --                ( Ok ( _, Neither, _ ), _ ) ->
                --                    fillAnimation f spec t acc (Dict.remove k all)
                ( Ok ( name, dir, Id ), PropInt index ) ->
                    (f t index
                        |> Maybe.map ResourceTask.succeed
                        |> Maybe.withDefault (ResourceTask.fail (Error 6005 ("Sprite with index " ++ String.fromInt index ++ "must have animation")))
                    )
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
                                    Just ( k2, PropInt uIndex2 ) ->
                                        (f t uIndex2
                                            |> Maybe.map ResourceTask.succeed
                                            |> Maybe.withDefault (ResourceTask.fail (Error 6005 ("Sprite with index " ++ String.fromInt index ++ "must have animation")))
                                        )
                                            >> ResourceTask.andThen
                                                (\info2 ->
                                                    fillAnimation f
                                                        spec
                                                        t
                                                        (Dict.insert ( name, DirectionHelper.toInt opposite ) info2 accWithCurrent)
                                                        (Dict.remove k2 rest)
                                                )

                                    _ ->
                                        fillAnimation f
                                            spec
                                            t
                                            (Dict.insert ( name, DirectionHelper.toInt opposite )
                                                { info | uMirror = DirectionHelper.oppositeMirror dir |> Vec2.fromRecord }
                                                accWithCurrent
                                            )
                                            rest
                            )

                ( Ok ( _, _, Tileset ), PropInt _ ) ->
                    ResourceTask.fail (Error 6004 "Animation from other tile set not implemented yet")

                _ ->
                    fillAnimation f spec t acc (Dict.remove k all)

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
                { start = \c -> Char.isAlphaNum c || c == '_'
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
