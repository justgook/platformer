module Logic.Template.Game.Fight.Sync exposing (protocol)

import Bytes.Decode as D
import Bytes.Encode as E
import Dict
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity exposing (EntityID)
import Logic.Template.Component.IdSource as IdSource
import Logic.Template.Component.Position as Position
import Logic.Template.Component.Velocity as Velocity
import Logic.Template.Game.Fight.World as World exposing (FightWorld, networkSpec)
import Logic.Template.Input as Input
import Logic.Template.Network exposing (SessionId)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.System.Network as Network exposing (Packer)
import Random exposing (Generator)
import Set


protocol : Network.Protocol FightWorld
protocol =
    { event = [ inputSync ] -- from Client
    , state = [ setInput, idSourceSync, velocitySync, positionSync ] --  from Server State
    , join = join
    , leave = leave
    }


join : SessionId -> FightWorld -> FightWorld
join sessionId world =
    let
        x_ =
            toFloat world.render.screen.width * 0.25

        y_ =
            toFloat world.render.screen.height * 0.25

        ( pos, seed ) =
            (Random.map2 (\x y -> { x = x, y = y })
                (normal x_ (x_ * 0.25))
                (normal y_ (x_ * 0.25))
                |> Random.step
            )
                world.seed

        ( entityId, newWorld ) =
            IdSource.create IdSource.spec world
                |> Entity.with ( Input.toComps Input.spec, Input.emptyComp )
                |> Entity.with ( Velocity.spec, { x = 0, y = 0 } )
                |> Entity.with ( Position.spec, pos )

        network =
            world.network
    in
    { newWorld
        | seed = seed
        , network = { network | online = Dict.insert sessionId entityId world.network.online }
    }


leave : SessionId -> FightWorld -> FightWorld
leave sessionId world =
    let
        remove entityId w =
            IdSource.remove IdSource.spec entityId w
                |> Entity.removeFor Velocity.spec
                |> Entity.removeFor Position.spec
                |> Entity.removeFor (Input.toComps Input.spec)
    in
    Dict.get sessionId world.network.online
        |> Maybe.map (\id -> remove id world |> Tuple.second)
        |> Maybe.withDefault world
        |> (\w ->
                let
                    network =
                        w.network
                in
                { w | network = { network | online = Dict.remove sessionId w.network.online } }
           )


velocitySync : Packer FightWorld
velocitySync =
    Network.compPacker Velocity.spec E.xy D.xy


inputSync : Packer FightWorld
inputSync =
    let
        inputEncode { x, y, action } =
            E.sequence [ E.float x, E.float y, action |> Set.toList |> E.list E.sizedString ]

        inputDecode =
            D.map3
                (\x y action ->
                    { x = x, y = y, action = Set.fromList action }
                )
                D.float
                D.float
                (D.reverseList D.sizedString)
    in
    Network.compPacker (Input.toComps Input.spec) inputEncode inputDecode


positionSync : Packer FightWorld
positionSync =
    Network.compPackerWithInterval networkSpec Position.spec Position.spec E.xy D.xy


setInput : Packer FightWorld
setInput =
    let
        createDiff before after =
            let
                privateMsg =
                    if after.network.online /= before.network.online then
                        Dict.diff after.network.online before.network.online
                            |> Dict.foldl
                                (\sessionId entityId -> Dict.insert sessionId [ E.id 1, E.id entityId ])
                                Dict.empty

                    else
                        Dict.empty
            in
            ( [], privateMsg )
    in
    ( createDiff
    , \world ->
        D.map (\entityId -> setInitialKeys entityId world) D.id
    )


setInitialKeys : EntityID -> FightWorld -> FightWorld
setInitialKeys entityId world_ =
    world_
        |> Singleton.update Input.spec
            (\input ->
                { input
                    | registered =
                        Dict.fromList
                            [ ( "a", ( entityId, "Move.west" ) )
                            , ( "d", ( entityId, "Move.east" ) )
                            , ( "s", ( entityId, "Move.south" ) )
                            , ( "w", ( entityId, "Move.north" ) )
                            ]
                }
            )
        |> Entity.create entityId
        |> Entity.with ( Input.toComps Input.spec, Input.emptyComp )
        |> Tuple.second


idSourceSync : Packer FightWorld
idSourceSync =
    ( \was now ->
        if was.idSource /= now.idSource then
            -- E.encodedList to be able parse with same as components
            ( [ E.id 1, E.id now.idSource.next ], Dict.empty )

        else
            ( [], Dict.empty )
    , \world ->
        D.id
            |> D.andThen
                (\next ->
                    let
                        idSource =
                            world.idSource
                    in
                    D.succeed { world | idSource = { idSource | next = next } }
                )
    )



------------------------------------------------------------------------
--From Random.Extra
------------------------------------------------------------------------


{-| Create a generator of floats that is normally distributed with
given mean and standard deviation.
-}
normal : Float -> Float -> Generator Float
normal mean stdDev =
    Random.map (\u -> u * stdDev + mean) standardNormal


{-| A generator that follows a standard normal distribution (as opposed to
a uniform distribution)
-}
standardNormal : Generator Float
standardNormal =
    Random.map2
        (\u theta -> sqrt (-2 * logBase e (1 - max 0 u)) * cos theta)
        (Random.float 0 1)
        (Random.float 0 (2 * pi))
