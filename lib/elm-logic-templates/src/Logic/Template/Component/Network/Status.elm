module Logic.Template.Component.Network.Status exposing (Status(..), empty, getSessionId, spec)

import Logic.Component.Singleton as Singleton
import Logic.Template.Network exposing (RoomId, SessionId)


{-| TODO rename to role
-}
type Status
    = Slave SessionId RoomId
    | Master SessionId RoomId
    | Connecting
    | Disconnected


spec : Singleton.Spec Status { world | status : Status }
spec =
    { get = .status
    , set = \comps world -> { world | status = comps }
    }


empty : Status
empty =
    Disconnected


getSessionId spec_ world =
    case spec_.get world of
        Master sessionId _ ->
            sessionId

        Slave sessionId _ ->
            sessionId

        _ ->
            ""
