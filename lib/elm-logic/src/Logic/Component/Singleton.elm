module Logic.Component.Singleton exposing (Spec, update)

{-|

@docs Spec, update

-}


{-| Main way of creating ECS "anti-pattern", but time to time you need to create some component that can exist only one per whole application (viewport, keyboard, websocket-connection, etc. )
-}
type alias Spec comp world =
    { get : world -> comp
    , set : comp -> world -> world
    }


{-| Update whole component set, can be used also with `Component.Set` (not only `Singleton`)
-}
update : { get : world -> comp, set : comp -> world -> world } -> (comp -> comp) -> world -> world
update spec f world =
    spec.set (f (spec.get world)) world
