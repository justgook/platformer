module Logic.Component.Singleton exposing (Spec, update)


type alias Spec comp world =
    { get : world -> comp
    , set : comp -> world -> world
    }


update : { get : world -> comp, set : comp -> world -> world } -> (comp -> comp) -> world -> world
update spec f world =
    spec.set (f (spec.get world)) world
