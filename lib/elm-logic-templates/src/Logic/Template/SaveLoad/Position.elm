module Logic.Template.SaveLoad.Position exposing (decode, encode, read)

import AltMath.Vector2 exposing (vec2)
import Bytes.Decode as D
import Bytes.Encode as E exposing (Encoder)
import Logic.Component exposing (Spec)
import Logic.Entity as Entity
import Logic.Template.Component.Position exposing (Position)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)


read : Logic.Component.Spec Position world -> WorldReader world
read spec =
    { defaultRead
        | objectTile = Sync (\{ x, y } -> Entity.with ( spec, vec2 x y ))
    }


encode : Spec Position world -> world -> Encoder
encode { get } world =
    Entity.toList (get world)
        |> E.list (\( id, item ) -> E.sequence [ E.id id, E.xy item ])


decode : Spec Position world -> WorldDecoder world
decode spec =
    D.reverseList (D.map2 Tuple.pair D.id D.xy)
        |> D.map (\list -> spec.set (Entity.fromList list))
