module Logic.Template.SaveLoad.EventSequence exposing (decode, encode)

import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Template.Component.EventSequence as EventSequence exposing (EventSequence)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E


encode : (e -> Encoder) -> EventSequence e -> Encoder
encode encoder events =
    E.list (\( i, item ) -> E.sequence [ E.id i, encoder item ]) (EventSequence.toList events)


decode : Decoder e -> Decoder (EventSequence e)
decode decoder =
    D.reverseList (D.map2 Tuple.pair D.id decoder)
        |> D.map (List.reverse >> EventSequence.fromList)
