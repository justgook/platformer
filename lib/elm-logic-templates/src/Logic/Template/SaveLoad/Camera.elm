module Logic.Template.SaveLoad.Camera exposing (decodeId, encodeId, read, readId)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode exposing (Encoder)
import Dict
import Logic.Component.Singleton as Singleton
import Logic.Template.Camera.Common
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Parser as Parser
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), defaultRead)
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)
import Logic.Template.SaveLoad.Internal.Util exposing (levelProps)
import Parser exposing ((|.), (|=), Parser)
import Set


readId spec_ =
    let
        baseRead =
            read spec_
    in
    { baseRead
        | objectTile =
            Sync
                (\{ properties } ( entityID, world ) ->
                    properties
                        |> Dict.filter (\a _ -> String.startsWith "camera" a)
                        |> Dict.keys
                        |> List.foldl
                            (\item (( eID, w ) as acc) ->
                                case Parser.run getFollowId item of
                                    Ok ( "follow", "x" ) ->
                                        let
                                            cam =
                                                spec_.get w
                                        in
                                        ( eID, spec_.set { cam | id = eID } w )

                                    _ ->
                                        acc
                            )
                            ( entityID, world )
                )
    }


encodeId : Singleton.Spec (Logic.Template.Camera.Common.WithId a) world -> world -> Encoder
encodeId { get } world =
    E.id (get world).id


decodeId : Singleton.Spec (Logic.Template.Camera.Common.WithId a) world -> WorldDecoder world
decodeId spec_ =
    D.id
        |> D.map (\id -> Singleton.update spec_ (\info -> { info | id = id }))


read spec_ =
    { defaultRead
        | level =
            Sync
                (\level ( entityID, world ) ->
                    let
                        cameraComp =
                            levelProps level
                                |> (\prop ->
                                        let
                                            cam =
                                                spec_.get world

                                            x =
                                                prop.float "offset.x" (Vec2.getX cam.viewportOffset)

                                            y =
                                                prop.float "offset.y" (Vec2.getY cam.viewportOffset)
                                        in
                                        { cam | viewportOffset = vec2 x y }
                                   )
                    in
                    ( entityID, spec_.set cameraComp world )
                )
    }


getFollowId =
    Parser.succeed (\a b -> ( a, b ))
        |. Parser.keyword "camera"
        |. Parser.symbol "."
        |= Parser.var
        |. Parser.symbol "."
        |= Parser.var
        |. Parser.end
