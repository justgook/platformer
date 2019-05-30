module Logic.Template.SaveLoad.TimeLineDict exposing (decode, encode, fillAnimation, read)

import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Dict exposing (Dict)
import Direction as DirectionHelper exposing (Direction(..))
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.Launcher exposing (Error(..))
import Logic.Template.Component.TimeLine
import Logic.Template.Component.TimeLineDict exposing (AnimationId, TimeLineDict)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)
import Logic.Template.SaveLoad.Internal.Util as Util exposing (animationFraming)
import Logic.Template.SaveLoad.TimeLine exposing (decodeSimple, encodeSimple)
import Math.Vector2 as Vec2 exposing (Vec2)
import Parser exposing ((|.), (|=), Parser)
import Set
import Tiled.Properties exposing (Property(..))
import Tiled.Tileset


encodeAnimationId : AnimationId -> Encoder
encodeAnimationId ( a, b ) =
    E.sequence [ E.sizedString a, E.unsignedInt8 b ]


decodeAnimationId : Decoder AnimationId
decodeAnimationId =
    D.map2 Tuple.pair D.sizedString D.unsignedInt8


encode : Component.Spec TimeLineDict world -> world -> Encoder
encode { get } world =
    Entity.toList (get world)
        |> E.list
            (\( id, ( current, dict ) ) ->
                let
                    encodeDict =
                        dict
                            |> Dict.toList
                            |> E.list
                                (\( animId, animLine ) ->
                                    E.sequence [ encodeAnimationId animId, encodeSimple animLine ]
                                )
                in
                E.sequence [ E.id id, encodeAnimationId current, encodeDict ]
            )


decode : Component.Spec TimeLineDict world -> WorldDecoder world
decode spec_ =
    let
        decodeDict =
            D.list (D.map2 (\animId animLine -> ( animId, animLine )) decodeAnimationId decodeSimple)
                |> D.map Dict.fromList

        decoder =
            D.map3 (\id current dict -> ( id, ( current, dict ) )) D.id decodeAnimationId decodeDict
    in
    D.list decoder
        |> D.map
            (\list -> Singleton.update spec_ (\_ -> Entity.fromList list))


read : Component.Spec TimeLineDict world -> Reader world
read spec =
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
                                            |> fillAnimation spec t Dict.empty

                                    _ ->
                                        ResourceTask.fail (Error 8003 "object tile readers works only with single image tilesets")
                            )
                )
    }


type What
    = Id
    | Tileset


fillAnimation spec t acc all =
    case Dict.toList all of
        ( k, v ) :: _ ->
            case ( Parser.run parseName k, v ) of
                ( Ok ( _, Neither, _ ), _ ) ->
                    fillAnimation spec t acc (Dict.remove k all)

                ( Ok ( name, dir, Id ), PropInt index ) ->
                    animLutPlusImageTask t index
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
                                        animLutPlusImageTask t uIndex2
                                            >> ResourceTask.andThen
                                                (\info2 ->
                                                    fillAnimation spec
                                                        t
                                                        (Dict.insert ( name, DirectionHelper.toInt opposite ) info2 accWithCurrent)
                                                        (Dict.remove k2 rest)
                                                )

                                    _ ->
                                        fillAnimation spec
                                            t
                                            (Dict.insert ( name, DirectionHelper.toInt opposite ) { info | uMirror = DirectionHelper.oppositeMirror dir |> Vec2.fromRecord } accWithCurrent)
                                            rest
                            )

                ( Ok ( _, _, Tileset ), PropInt _ ) ->
                    ResourceTask.fail (Error 6004 "Animation from other tile set not implemented yet")

                _ ->
                    fillAnimation spec t acc (Dict.remove k all)

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


animLutPlusImageTask t uIndex =
    case Util.animation t uIndex of
        Just anim ->
            let
                animLutData =
                    animationFraming anim
                        |> List.map toFloat
            in
            Logic.Template.Component.TimeLine.emptyComp animLutData
                |> ResourceTask.succeed

        Nothing ->
            ResourceTask.fail (Error 6005 ("Sprite with index " ++ String.fromInt uIndex ++ "must have animation"))
