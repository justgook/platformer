module Logic.Template.SaveLoad.AI exposing (decodeOne, encodeOne)

import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Template.Component.AI exposing (AiTargets, Spot)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E


encodeOne : AiTargets -> Encoder
encodeOne ai =
    E.sequence
        [ ai.waiting |> E.id
        , ai.prev |> E.list encodeSpot_
        , ai.target |> encodeSpot_
        , ai.next |> E.list encodeSpot_
        ]


encodeSpot_ : Spot -> Encoder
encodeSpot_ spot =
    E.sequence
        [ spot.position |> E.xy
        , spot.action |> E.list E.sizedString
        , spot.wait |> E.id
        , spot.invSteps |> E.float
        ]


decodeOne : Decoder AiTargets
decodeOne =
    D.succeed AiTargets
        |> D.andMap D.id
        |> D.andMap (D.reverseList decodeSpot_ |> D.map List.reverse)
        |> D.andMap decodeSpot_
        |> D.andMap (D.reverseList decodeSpot_ |> D.map List.reverse)


decodeSpot_ : Decoder Spot
decodeSpot_ =
    D.succeed Spot
        |> D.andMap D.xy
        |> D.andMap (D.reverseList D.sizedString |> D.map List.reverse)
        |> D.andMap D.id
        |> D.andMap D.float
