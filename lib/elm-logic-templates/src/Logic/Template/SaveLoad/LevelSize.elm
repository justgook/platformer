module Logic.Template.SaveLoad.LevelSize exposing (decode, encode, read)

import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component.Singleton as Singleton
import Logic.Template.Component.LevelSize exposing (LevelSize)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.Util as Util


read : Singleton.Spec LevelSize world -> WorldReader world
read { get, set } =
    { defaultRead
        | level =
            Sync
                (\level ( entityId, world ) ->
                    let
                        levelData =
                            Util.levelCommon level
                    in
                    ( entityId
                    , set
                        { width = levelData.width * levelData.tilewidth
                        , height = levelData.height * levelData.tileheight
                        }
                        world
                    )
                )
    }


encode : Singleton.Spec LevelSize world -> world -> Encoder
encode { get } world =
    let
        info =
            get world
    in
    E.sequence
        [ E.int info.width
        , E.int info.height
        ]


decode : Singleton.Spec LevelSize world -> Decoder (world -> world)
decode spec_ =
    D.map2
        (\width height ->
            Singleton.update spec_ (\info -> { width = width, height = height })
        )
        D.id
        D.id
