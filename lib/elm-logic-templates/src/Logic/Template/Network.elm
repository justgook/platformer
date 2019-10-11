module Logic.Template.Network exposing
    ( Message(..)
    , OutMessage
    , RoomId
    , SessionId
    , connect
    , decode
    , sendData
    , sendPrivateData
    , sub
    )

import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as Db
import Bytes.Encode as Eb
import Json.Decode as D
import Json.Encode as E
import Logic.Template.SaveLoad.Internal.Decode as Db
import Logic.Template.SaveLoad.Internal.Encode as Eb


fastWs =
    "https://github.com/uNetworking/uWebSockets.js"


adiInspiration =
    "https://github.com/colyseus/colyseus"


client =
    "https://github.com/colyseus/colyseus"


type alias SessionId =
    String


type alias RoomId =
    String


type Message
    = NewUser SessionId
    | UserLeave SessionId
    | YouSlave SessionId RoomId
    | YouMaster SessionId RoomId
    | RoomData
    | PrivateData SessionId


type Internal
    = ConnectTo String


type alias OutMessage =
    Bytes


type OutMessageInternal data patch
    = System Internal
    | Private SessionId Bytes
    | Broadcast Bytes


withSync networkSpec spec_ =
    ""


decode : (Message -> Db.Decoder world) -> Db.Decoder world
decode fn =
    --            { newUser = 10
    --            , userLeave = 11
    --            , roomData = 12
    --            , privateRoomData = 13
    --            , yourAreMaster = 14
    --            , yourAreSlave = 15
    --            }
    let
        initStatus : (a -> Db.Decoder world) -> (String -> String -> a) -> Db.Decoder world
        initStatus fn1 fn3 =
            Db.sizedString
                |> Db.andThen
                    (\a ->
                        Db.sizedString
                            |> Db.andThen (\b -> fn1 (fn3 a b))
                    )
    in
    Db.int
        |> Db.andThen
            (\msgType ->
                case msgType of
                    10 ->
                        Db.sizedString
                            |> Db.andThen (NewUser >> fn)

                    11 ->
                        Db.sizedString
                            |> Db.andThen (UserLeave >> fn)

                    12 ->
                        fn RoomData

                    13 ->
                        Db.sizedString
                            |> Db.andThen (PrivateData >> fn)

                    14 ->
                        initStatus fn YouMaster

                    15 ->
                        initStatus fn YouSlave

                    _ ->
                        Db.fail
            )


sub : (Message -> Db.Decoder world) -> Bytes -> Maybe world
sub fn bytes =
    Db.decode (decode fn) bytes


outWrap : OutMessageInternal data patch -> OutMessage
outWrap msg_ =
    (case msg_ of
        Private sessionId info ->
            [ Eb.int 13, Eb.sizedString sessionId, Eb.bytes info ]

        Broadcast info ->
            [ Eb.int 12, Eb.bytes info ]

        System (ConnectTo s) ->
            [ Eb.int 0, Eb.sizedString s ]
    )
        |> Eb.sequence
        |> Eb.encode


connect : String -> OutMessage
connect =
    ConnectTo >> System >> outWrap


sendData : Bytes -> OutMessage
sendData =
    Broadcast >> outWrap


sendPrivateData : SessionId -> Bytes -> OutMessage
sendPrivateData sessionId =
    Private sessionId >> outWrap
