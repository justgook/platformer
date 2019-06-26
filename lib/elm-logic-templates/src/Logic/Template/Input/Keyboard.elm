module Logic.Template.Input.Keyboard exposing (sub)

import Array
import Browser.Events
import Dict
import Json.Decode as Decode exposing (Decoder)
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity exposing (EntityID)
import Logic.Template.Input exposing (InputSingleton)
import Set exposing (Set)


sub spec world =
    Sub.batch
        [ Browser.Events.onKeyDown (onKeyDown spec world)
        , Browser.Events.onKeyUp (onKeyUp spec world)
        ]


onKeyDown =
    onKeyChange Set.insert


onKeyUp =
    onKeyChange Set.remove


onKeyChange :
    (String -> Set.Set String -> Set.Set String)
    -> Singleton.Spec InputSingleton world
    -> world
    -> Decoder world
onKeyChange update spec world =
    let
        input =
            spec.get world
    in
    Decode.field "key" Decode.string
        |> Decode.andThen (isRegistered input)
        |> Decode.andThen
            (\key ->
                update key input.pressed
                    |> updateKeys spec update key world
            )


isRegistered : { a | registered : Dict.Dict comparable v } -> comparable -> Decoder comparable
isRegistered input key =
    if Dict.member key input.registered then
        Decode.succeed key

    else
        Decode.fail "not registered key"


updateKeys { get, set } update keyChanged world pressed =
    let
        input =
            get world
    in
    if input.pressed == pressed then
        Decode.fail "Nothing change"

    else
        let
            newComps =
                Dict.get keyChanged input.registered
                    |> Maybe.andThen
                        (\( id, action ) ->
                            Array.get id input.comps
                                |> Maybe.andThen identity
                                |> Maybe.map
                                    (\comp ->
                                        let
                                            { x, y } =
                                                arrows comp pressed
                                        in
                                        Entity.spawnComponent id
                                            { comp
                                                | x = x
                                                , y = y
                                                , action = update action comp.action
                                            }
                                            input.comps
                                    )
                        )
                    |> Maybe.withDefault input.comps

            updatedInput =
                { input | comps = newComps }
        in
        Decode.succeed (set { updatedInput | pressed = pressed } world)


arrows : { a | down : comparable, left : comparable, right : comparable, up : comparable } -> Set comparable -> { x : Float, y : Float }
arrows { up, right, down, left } keys =
    let
        x =
            keyToInt right keys - keyToInt left keys

        y =
            keyToInt up keys - keyToInt down keys
    in
    { x = x, y = y }


keyToInt : comparable -> Set comparable -> Float
keyToInt key =
    Set.member key >> boolToFloat


boolToFloat : Bool -> Float
boolToFloat bool =
    if bool then
        1

    else
        0
