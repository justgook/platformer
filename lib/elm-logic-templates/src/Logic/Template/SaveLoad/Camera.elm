module Logic.Template.SaveLoad.Camera exposing (decode, encode, read, readId)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode exposing (Encoder)
import Dict
import Logic.Component.Singleton as Singleton
import Logic.Template.Camera.Common
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), defaultRead)
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)
import Logic.Template.SaveLoad.Internal.Util exposing (levelProps)
import Parser exposing ((|.), (|=), Parser)
import Set


read spec_ =
    { defaultRead
        | objectTile = Sync (\_ ( entityID, world ) -> ( entityID, Singleton.update spec_ (\info -> { info | id = entityID }) world ))
    }


readId spec_ =
    { defaultRead
        | objectTile = Sync (\_ ( entityID, world ) -> ( entityID, Singleton.update spec_ (\_ -> entityID) world ))
    }


encode : Singleton.Spec (Logic.Template.Camera.Common.LegacyWithId a) world -> world -> Encoder
encode { get } world =
    E.id (get world).id


decode : Singleton.Spec (Logic.Template.Camera.Common.LegacyWithId a) world -> WorldDecoder world
decode spec_ =
    D.id
        |> D.map (\id -> Singleton.update spec_ (\info -> { info | id = id }))
