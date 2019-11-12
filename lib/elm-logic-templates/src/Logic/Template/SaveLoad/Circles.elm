module Logic.Template.SaveLoad.Circles exposing
    ( decodeCircles
    , encodeCircles
    , extractCircles
    , readCircles
    )

import AltMath.Vector2 exposing (vec2)
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component as Component
import Logic.Entity as Entity
import Logic.Template.Component.Circles exposing (Circles)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (ExtractAsync, GuardReader, Read(..), TileData, WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.Util exposing (getCollision, getCollisionWith)
import Tiled.Level exposing (Level)
import Tiled.Object exposing (Gid, Object(..))


readCircles : Component.Spec Circles world -> WorldReader world
readCircles spec =
    { defaultRead
        | objectTile =
            Async
                (\info ->
                    extractCircles info.level info.gid
                        >> ResourceTask.map
                            (\hurt_ ( entityID, world ) ->
                                case hurt_ of
                                    Just hurt ->
                                        Entity.with ( spec, hurt ) ( entityID, world )

                                    Nothing ->
                                        ( entityID, world )
                            )
                )
    }


extractCircles : Level -> Gid -> ExtractAsync (Maybe Circles)
extractCircles level gid =
    getCollisionWith level gid
        >> ResourceTask.map
            (Maybe.andThen
                (\( objectgroup, tileset ) ->
                    objectgroup.objects
                        |> List.foldl
                            (\item acc ->
                                case item of
                                    Ellipse { x, y, width } ->
                                        let
                                            r =
                                                width * 0.5
                                        in
                                        ( vec2 (x + r - toFloat tileset.tilewidth * 0.5) (toFloat tileset.tileheight * 0.5 - r - y), r ) :: acc

                                    _ ->
                                        acc
                            )
                            []
                        |> (\l ->
                                if List.isEmpty l then
                                    Nothing

                                else
                                    Just l
                           )
                )
            )


encodeCircles : Circles -> Encoder
encodeCircles shapes =
    let
        encodeItem ( offset, radius ) =
            E.sequence [ E.vec2 offset, E.float radius ]
    in
    E.list encodeItem shapes


decodeCircles : Decoder Circles
decodeCircles =
    let
        decodeItem =
            D.map2 Tuple.pair D.vec2 D.float
    in
    D.reverseList decodeItem
