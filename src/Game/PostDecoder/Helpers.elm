module Game.PostDecoder.Helpers
    exposing
        ( findTileSet
        , getFloatProp
        , hexColor2Vec3
        , repeat
        , repeat2Int
        , scrollRatio
        , shapeById
        , tileSetInfo
        )

import Dict
import Game.Logic.Collision.Shape as Shape exposing (Shape)
import Game.Model as Model exposing (Repeat(..))
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Tiled.Decode as Tiled


shapeById : (Vec2 -> Vec2) -> Int -> Dict.Dict Int { b | objectgroup : Maybe { a | objects : List Tiled.Object } } -> Maybe Shape
shapeById relative2absolute id tiles =
    Dict.get id tiles
        |> Maybe.andThen
            (\tile ->
                Maybe.andThen
                    (\a ->
                        case a.objects of
                            (Tiled.ObjectRectangle data) :: [] ->
                                Just
                                    (Shape.aabb
                                        { p = relative2absolute (vec2 data.x data.y)
                                        , xw = vec2 (data.width / 2) 0
                                        , yw = vec2 0 (data.height / 2)
                                        }
                                    )

                            _ ->
                                let
                                    _ =
                                        Debug.log "Implement Other Shapes (not only Tiled.ObjectRectangl)" tile
                                in
                                Nothing
                    )
                    tile.objectgroup
            )


repeat2Int : Repeat -> Int
repeat2Int r =
    case r of
        RepeatBoth ->
            3

        RepeatX ->
            2

        RepeatY ->
            1

        RepeatNone ->
            0


repeat : { a | properties : Dict.Dict String Tiled.Property } -> Repeat
repeat data =
    case getStringProp "repeat" "none" data.properties of
        "repeat" ->
            RepeatBoth

        "repeat-x" ->
            RepeatX

        "repeat-y" ->
            RepeatY

        _ ->
            RepeatNone


scrollRatio : { a | properties : Dict.Dict String Tiled.Property } -> Vec2
scrollRatio data =
    let
        default =
            getFloatProp "scrollRatio" 1 data.properties
    in
    vec2
        (getFloatProp "scrollRatio.x" default data.properties)
        (getFloatProp "scrollRatio.y" default data.properties)


{-| TODO move me to Tiled.Decode
-}
getFloatProp : comparable -> Float -> Dict.Dict comparable Tiled.Property -> Float
getFloatProp propName default dict =
    Dict.get propName dict
        |> Maybe.andThen
            (\prop ->
                case prop of
                    Tiled.PropFloat a ->
                        Just a

                    _ ->
                        Nothing
            )
        |> Maybe.withDefault default


{-| TODO move me to Tiled.Decode
-}
getStringProp : comparable -> String -> Dict.Dict comparable Tiled.Property -> String
getStringProp propName default dict =
    Dict.get propName dict
        |> Maybe.andThen
            (\prop ->
                case prop of
                    Tiled.PropString a ->
                        Just a

                    _ ->
                        Nothing
            )
        |> Maybe.withDefault default


{-| TODO move me to Tiled.Decode
-}
hexColor2Vec3 : String -> Result String Vec3
hexColor2Vec3 str =
    let
        withoutHash =
            if String.startsWith "#" str then
                String.dropLeft 1 str
            else
                str
    in
    case String.toList withoutHash of
        [ r1, r2, g1, g2, b1, b2 ] ->
            let
                makeFloat a b =
                    String.fromList [ '0', 'x', a, b ]
                        |> String.toInt
                        |> Result.map (\i -> toFloat i / 255)
            in
            Result.map3 vec3 (makeFloat r1 r2) (makeFloat g1 g2) (makeFloat b1 b2)

        _ ->
            "Can not parse hex color:" ++ str |> Result.Err


tileSetInfo : List Tiled.Tileset -> List Int -> Dict.Dict Int Tiled.EmbeddedTileData
tileSetInfo tilesets ids =
    List.foldl
        (\t acc ->
            findTileSet t tilesets
                |> Maybe.map (\( k, v ) -> Dict.insert k v acc)
                |> Maybe.withDefault acc
        )
        Dict.empty
        ids


findTileSet : Int -> List Tiled.Tileset -> Maybe ( Int, Tiled.EmbeddedTileData )
findTileSet id tilesets =
    List.foldl
        (\t acc ->
            case t of
                Tiled.TilesetEmbedded tileset ->
                    if id >= tileset.firstgid && id <= (tileset.firstgid + tileset.tilecount) then
                        Just
                            ( tileset.firstgid
                            , tileset
                            )
                    else
                        acc

                _ ->
                    acc
        )
        Nothing
        tilesets
