module Logic.Template.System.Network exposing
    ( Pack
    , Packer
    , Protocol
    , Unpack
    , compPacker
    , initSync
    , subscription
    , sync
    , unsafePrivateCmd
    )

import Array exposing (Array)
import Bytes exposing (Bytes)
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.System as System
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
    world -> world -> List Encoder


type alias Unpack world =
    world -> Decoder world


compPacker :
    Component.Spec comp world
    -> (comp -> Encoder)
    -> Decoder comp
    -> Packer world
compPacker spec_ =
    compPacker2 spec_.get spec_


compPacker2 :
    (world -> Component.Set comp)
    -> Component.Spec comp world
    -> (comp -> Encoder)
    -> Decoder comp
    -> Packer world
compPacker2 wasGetter spec2 encode decode =
    ( \was now -> componentDiff (E.maybe encode) (wasGetter was) (spec2.get now) []
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


unsafePrivateCmd : (OutMessage -> Cmd msg) -> Int -> Encoder -> SessionId -> Cmd msg
unsafePrivateCmd outcome packerIndex encoder sessionId =
    Network.sendPrivateData sessionId
        (E.int packerIndex
            :: [ E.id 1, encoder, E.int endOfDecode ]
            |> E.sequence
            |> E.encode
        )
        |> outcome


endOfDecode : Int
endOfDecode =
    -1


packCmd : (OutMessage -> Cmd msg) -> List (Packer world) -> world -> world -> Cmd msg
packCmd outcome list was now =
    let
        dataToSend : List Encoder
        dataToSend =
            prepareData list was now
    in
    if dataToSend == [] then
        Cmd.none

    else
        E.sequence [ E.sequence dataToSend, E.int endOfDecode ]
            |> E.encode
            |> Network.sendData
            |> outcome


prepareData : List (Packer world) -> world -> world -> List Encoder
prepareData list was now =
    list
        |> indexedFoldl
            (\i ( fn, _ ) acc ->
                let
                    diff =
                        fn was now
                in
                if diff /= [] then
                    diff
                        |> E.encodedList
                        |> List.singleton
                        |> (::) (E.int i)
                        |> E.sequence
                        |> (\a -> a :: acc)

                else
                    acc
            )
            []


sync : Singleton.Spec Status world -> Protocol world -> (OutMessage -> Cmd msg) -> world -> world -> Cmd msg
sync { get, set } protocol outcome was now =
    let
        status =
            get now
    in
    case status of
        Status.Slave _ _ ->
            packCmd outcome protocol.event was now

        Status.Master _ _ ->
            packCmd outcome protocol.state was now

        Status.Disconnected ->
            Cmd.none

        Status.Connecting ->
            Cmd.none


initSync : Protocol world -> (OutMessage -> Cmd msg) -> world -> world -> SessionId -> Cmd msg
initSync protocol outcome was now sessionId =
    let
        dataToSend =
            prepareData protocol.state was now
    in
    if dataToSend == [] then
        Cmd.none

    else
        E.sequence [ E.sequence dataToSend, E.int endOfDecode ]
            |> E.encode
            |> Network.sendPrivateData sessionId
            |> outcome


subscription :
    Singleton.Spec Status world
    -> Protocol world
    -> Bytes
    -> world
    -> world
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
