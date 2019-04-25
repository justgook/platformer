module Logic.Component.Singleton exposing (Spec)


type alias Spec comp world =
    { get : world -> comp
    , set : comp -> world -> world
    }
