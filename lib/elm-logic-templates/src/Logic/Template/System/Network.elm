module Logic.Template.System.Network exposing (IntervalState, Pack, Packer, Protocol, Unpack, compPacker, compPacker2, compPackerWithInterval, intervalSave, prepareData, subscription, sync)

import Array exposing (Array)
import Bytes exposing (Bytes)
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Dict exposing (Dict)
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.Template.Component.Network.Status as Status exposing (Status)
import Logic.Template.Network as Network exposing (Message(..), OutMessage, RoomId, SessionId)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E


type alias Protocol world =
    { state : List (Packer world)
    , event : List (Packer world)
    , join : SessionId -> world -> world
    , leave : SessionId -> world -> world
    }


type alias Packer world =
    ( Pack world, Unpack world )


type alias Pack world =
    world -> world -> ( List Encoder, Dict SessionId (List Encoder) )


type alias Unpack world =
    world -> Decoder world


type alias IntervalState e =
    { e
        | next : Int
    }


compPacker :
    Component.Spec comp world
    -> (comp -> Encoder)
    -> Decoder comp
    -> Packer world
compPacker spec_ =
    compPacker2 spec_.get spec_


compPackerWithInterval topSpec spec spec_ encode decode =
    compPacker2 (topSpec.get >> spec.get) spec_ encode decode
        |> Tuple.mapFirst
            (\fn world ->
                if world.frame == (topSpec.get >> .next) world then
                    fn world

                else
                    \_ -> ( [], Dict.empty )
            )


compPacker2 wasGetter spec2 encode decode =
    ( \was now -> ( componentDiff (E.maybe encode) (wasGetter was) (spec2.get now) [], Dict.empty )
    , \world ->
        D.map2
            (\id maybeComp ->
                case maybeComp of
                    Just comp ->
                        Entity.create id world |> Entity.with ( spec2, comp ) |> Tuple.second

                    Nothing ->
                        Entity.removeFor spec2 ( id, world ) |> Tuple.second
            )
            D.id
            (D.maybe decode)
    )


endOfDecode : Int
endOfDecode =
    -1


packCmd : (OutMessage -> Cmd msg) -> List (Packer world) -> world -> world -> Cmd msg
packCmd outcome list was now =
    let
        ( broadcastData, privateData ) =
            prepareData list was now

        cmdPrivate =
            if Dict.isEmpty privateData then
                []

            else
                privateData
                    |> Dict.foldl
                        (\sessionId dataToSend acc ->
                            (E.sequence [ E.sequence dataToSend, E.int endOfDecode ]
                                |> E.encode
                                |> Network.sendPrivateData sessionId
                                |> outcome
                            )
                                :: acc
                        )
                        []

        cmdBroadcast =
            if broadcastData == [] then
                Cmd.none

            else
                E.sequence [ E.sequence broadcastData, E.int endOfDecode ]
                    |> E.encode
                    |> Network.sendData
                    |> outcome
    in
    cmdBroadcast :: cmdPrivate |> Cmd.batch


prepareData : List (Packer world) -> world -> world -> ( List Encoder, Dict SessionId (List Encoder) )
prepareData list was now =
    list
        |> indexedFoldl
            (\i ( fn, _ ) ( acc1, acc2 ) ->
                let
                    ( broadcast, private ) =
                        fn was now
                in
                ( if broadcast == [] then
                    acc1

                  else
                    broadcast
                        |> E.encodedList
                        |> List.singleton
                        |> (::) (E.int i)
                        |> E.sequence
                        |> (\a -> a :: acc1)
                , if Dict.isEmpty private then
                    acc2

                  else
                    Dict.foldl
                        (\k v acc_ ->
                            let
                                readyValue =
                                    v
                                        |> E.encodedList
                                        |> List.singleton
                                        |> (::) (E.int i)
                                        |> E.sequence

                                newValue =
                                    Dict.get k acc_
                                        |> Maybe.map ((::) readyValue)
                                        |> Maybe.withDefault [ readyValue ]
                            in
                            Dict.insert k newValue acc_
                        )
                        acc2
                        private
                )
            )
            ( [], Dict.empty )


sync : Singleton.Spec Status world -> Protocol world -> (OutMessage -> Cmd msg) -> world -> world -> Cmd msg
sync { get, set } protocol outcome was now =
    if was == now then
        Cmd.none

    else
        case get now of
            Status.Slave _ _ ->
                packCmd outcome protocol.event was now

            Status.Master _ _ ->
                packCmd outcome protocol.state was now

            Status.Disconnected ->
                Cmd.none

            Status.Connecting ->
                Cmd.none


intervalSave frames subWorldSpec listOfSpecs world =
    if remainderBy frames world.frame == 0 then
        let
            sub =
                subWorldSpec.get world

            setter spec =
                spec.set (spec.get world)

            newSub =
                List.foldl setter sub listOfSpecs
        in
        subWorldSpec.set { newSub | next = world.frame + frames } world

    else
        world


subscription : Singleton.Spec Status world -> Protocol world -> Bytes -> world -> world
subscription spec protocol =
    let
        subConfig =
            { masterDecoders =
                decoderIndexing protocol.event
            , slaveDecoders =
                decoderIndexing protocol.state
            , privateDecoders =
                decoderIndexing protocol.state
            , joinCallback =
                protocol.join
            , leaveCallback =
                protocol.leave
            }
    in
    subscription_ spec subConfig


subscription_ spec { masterDecoders, slaveDecoders, privateDecoders, joinCallback, leaveCallback } bytes world =
    bytes
        |> Network.sub
            (\mMessage ->
                case mMessage of
                    RoomData ->
                        case spec.get world of
                            Status.Master _ _ ->
                                syncDecode masterDecoders world

                            Status.Slave _ _ ->
                                syncDecode slaveDecoders world

                            _ ->
                                D.fail

                    PrivateData sessionId ->
                        if Status.getSessionId spec world == sessionId then
                            syncDecode privateDecoders world

                        else
                            D.fail

                    NewUser sessionId ->
                        case spec.get world of
                            Status.Master _ _ ->
                                D.succeed
                                    (joinCallback sessionId world)

                            _ ->
                                D.fail

                    UserLeave sessionId ->
                        case spec.get world of
                            Status.Master _ _ ->
                                D.succeed (leaveCallback sessionId world)

                            _ ->
                                D.fail

                    YouSlave sessionId roomId ->
                        world
                            |> spec.set (Status.Slave sessionId roomId)
                            |> D.succeed

                    YouMaster sessionId roomId ->
                        let
                            _ =
                                if spec.get world == Status.Connecting then
                                    Debug.log "You Master and should start match" (Status.Master sessionId roomId)

                                else
                                    Debug.log "You BECOME Master - continue game" (Status.Master sessionId roomId)
                        in
                        world
                            |> spec.set (Status.Master sessionId roomId)
                            |> D.succeed
            )
        |> Maybe.withDefault world


syncDecode : List ( Int, Unpack world ) -> world -> Decoder world
syncDecode decoders world =
    let
        init_ index =
            { index = index
            , decoders = decoders
            , world = world
            }
    in
    D.id
        |> D.andThen (\index -> D.loop (init_ index) syncDecodeStep)


syncDecodeStep :
    { index : Int, decoders : List ( Int, Unpack world ), world : world }
    -> Decoder (D.Step { index : Int, decoders : List ( Int, Unpack world ), world : world } world)
syncDecodeStep { index, decoders, world } =
    case decoders of
        ( decoderIndex, decoder ) :: rest ->
            if decoderIndex == index then
                D.id
                    |> D.andThen (\count -> D.foldl count decoder world)
                    |> D.andThen
                        (\newWorld ->
                            D.int
                                |> D.map
                                    (\nextIndex ->
                                        if nextIndex /= endOfDecode then
                                            D.Loop { index = nextIndex, decoders = rest, world = newWorld }

                                        else
                                            D.Done newWorld
                                    )
                        )

            else if decoderIndex > index then
                D.Loop { index = index, decoders = rest, world = world }
                    |> D.succeed

            else
                D.fail

        [] ->
            --            D.succeed (D.Done world)
            D.fail


componentDiff : (Maybe comp -> Encoder) -> Component.Set comp -> Component.Set comp -> List Encoder -> List Encoder
componentDiff fn was now acc_ =
    if was == now then
        acc_

    else if Array.length was > Array.length now then
        indexedFoldlArray
            (\entityId compWas acc ->
                let
                    compNow =
                        Array.get entityId now |> Maybe.andThen identity
                in
                if compNow /= compWas then
                    E.sequence [ E.id entityId, fn compNow ] :: acc

                else
                    acc
            )
            acc_
            was

    else
        indexedFoldlArray
            (\entityId compNow acc ->
                if compNow /= (Array.get entityId was |> Maybe.andThen identity) then
                    E.sequence [ E.id entityId, fn compNow ] :: acc

                else
                    acc
            )
            acc_
            now


indexedFoldlArray : (Int -> a -> b -> b) -> b -> Array a -> b
indexedFoldlArray func acc list =
    let
        step : a -> ( Int, b ) -> ( Int, b )
        step x ( i, thisAcc ) =
            ( i + 1, func i x thisAcc )
    in
    Tuple.second (Array.foldl step ( 0, acc ) list)


decoderIndexing : List ( a, b ) -> List ( Int, b )
decoderIndexing =
    indexedFoldl (\i ( _, fn ) acc -> ( i, fn ) :: acc) []


{-| Variant of `foldl` that passes the index of the current element to the step function. `indexedFoldl` is to `List.foldl` as `List.indexedMap` is to `List.map`.
-}
indexedFoldl : (Int -> a -> b -> b) -> b -> List a -> b
indexedFoldl func acc list =
    let
        step : a -> ( Int, b ) -> ( Int, b )
        step x ( i, thisAcc ) =
            ( i + 1, func i x thisAcc )
    in
    Tuple.second (List.foldl step ( 0, acc ) list)
