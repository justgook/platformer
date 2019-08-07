module Logic.Template.Input.Keyboard exposing (sub)

import Array
import Browser.Events
import Dict
import Json.Decode as Decode exposing (Decoder)
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity exposing (EntityID)
import Logic.Template.Input exposing (InputSingleton)
import Set exposing (Set)


sub : Singleton.Spec InputSingleton world -> world -> Sub world
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
                                            actionSet =
                                                update action comp.action

                                            { x, y } =
                                                arrows2 keyNames actionSet
                                        in
                                        Component.spawn id
                                            { comp
                                                | x = x
                                                , y = y
                                                , action = actionSet
                                            }
                                            input.comps
                                    )
                        )
                    |> Maybe.withDefault input.comps

            updatedInput =
                { input | comps = newComps }
        in
        Decode.succeed (set { updatedInput | pressed = pressed } world)


keyNames : { down : String, left : String, right : String, up : String }
keyNames =
    { left = "Move.west"
    , right = "Move.east"
    , down = "Move.south"
    , up = "Move.north"
    }


arrows2 : { a | down : String, left : String, right : String, up : String } -> Set String -> { x : Float, y : Float }
arrows2 config actions =
    let
        key =
            { up = Set.member config.up actions |> boolToFloat
            , right = Set.member config.right actions |> boolToFloat
            , down = Set.member config.down actions |> boolToFloat
            , left = Set.member config.left actions |> boolToFloat
            }

        x =
            key.right - key.left

        y =
            key.up - key.down
    in
    { x = x, y = y }


boolToFloat : Bool -> Float
boolToFloat bool =
    if bool then
        1

    else
        0
