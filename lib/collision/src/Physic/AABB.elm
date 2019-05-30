module Physic.AABB exposing (Config, World, addBody, byId, clear, empty, getConfig, getIndexed, setById, setConfig, simulate, toList)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Broad.Grid
import Dict exposing (Dict)
import Physic.Narrow.AABB as AABB exposing (AABB)
import Set


type alias World comparable =
    { static : Broad.Grid.Grid (AABB comparable)
    , gravity : Vec2

    --    , enableSleeping : Bool
    --    , timScale : Float
    , indexed : Dict comparable (AABB comparable)
    }


type alias Config =
    { gravity : Vec2

    --    , enableSleeping : Bool
    --    , timScale : Float
    , grid : Broad.Grid.NewConfig
    }


empty : World comparable
empty =
    { static = Broad.Grid.empty
    , gravity = vec2 0 -1

    --    , enableSleeping = False
    --    , timScale = 0.3
    , indexed = Dict.empty
    }


getConfig : World comparable -> Config
getConfig world =
    { gravity = world.gravity

    --    , enableSleeping = world.enableSleeping
    --    , timScale = world.timScale
    , grid = Broad.Grid.getConfig world.static
    }


setConfig : Config -> World comparable -> World comparable
setConfig config world =
    { world
        | static = Broad.Grid.setConfig config.grid world.static
        , gravity = config.gravity

        --        , enableSleeping = config.enableSleeping
        --        , timScale = config.timScale
    }


clear : World comparable -> World comparable
clear world =
    { world
        | static = Broad.Grid.optimize AABB.union world.static
    }


addBody : AABB comparable -> World comparable -> World comparable
addBody aabb ({ static, indexed } as engine) =
    let
        insert : AABB comparable -> Broad.Grid.Grid (AABB comparable) -> Broad.Grid.Grid (AABB comparable)
        insert aabb_ grid =
            Broad.Grid.insert (AABB.boundary aabb_) aabb_ grid
    in
    if AABB.isStatic aabb then
        { engine | static = insert aabb static }

    else
        case AABB.getIndex aabb of
            Just index ->
                { engine | indexed = Dict.insert index aabb indexed }

            Nothing ->
                engine


getIndexed : World comparable -> List ( comparable, AABB comparable )
getIndexed { indexed } =
    indexed |> Dict.toList


byId : comparable -> World comparable -> Maybe (AABB comparable)
byId id { indexed } =
    Dict.get id indexed


setById : comparable -> AABB comparable -> World comparable -> World comparable
setById id value ({ indexed } as world) =
    { world | indexed = Dict.insert id value indexed }


toList : World comparable -> List (AABB comparable)
toList world =
    Dict.values world.indexed ++ Broad.Grid.toList world.static


dragForce c velocity =
    Vec2.normalize velocity |> Vec2.scale (Vec2.lengthSquared velocity)


simulate dt ({ indexed, static, gravity } as world) =
    let
        --http://buildnewgames.com/gamephysics/ -- add Velocity Verlet
        --        acceleration = force / mass
        step =
            Broad.Grid.getConfig static |> .cell

        newIndexed =
            Dict.map
                (\_ aabb ->
                    let
                        acceleration_ =
                            Vec2.scale (AABB.getInvMass aabb) gravity

                        withAccelerationObj =
                            AABB.updateVelocity (\v -> Vec2.add v acceleration_) aabb

                        vLeft =
                            Vec2.add acceleration_ (AABB.getVelocity aabb)

                        stepsLeft =
                            max (abs vLeft.x / step.width) (abs vLeft.y / step.height)

                        oneStep =
                            if stepsLeft == 0 then
                                vLeft

                            else
                                Vec2.scale (1 / stepsLeft) vLeft

                        zeroVelocityObj =
                            AABB.setVelocity (vec2 0 0) aabb

                        resultAABB =
                            move
                                withAccelerationObj
                                zeroVelocityObj
                                oneStep
                                static
                                stepsLeft
                                Set.empty
                                AABB.None
                                (vec2 0 0)
                    in
                    AABB.applyVelocity resultAABB
                )
                indexed
    in
    { world | indexed = newIndexed }


move withAccelerationObj obj step grid left tested prevResponse contact =
    case prevResponse of
        AABB.XandY _ _ ->
            AABB.setContact contact obj

        _ ->
            let
                boundaryObj =
                    obj
                        |> AABB.updateVelocity
                            (\v ->
                                (if left > 1 then
                                    Vec2.add v step

                                 else
                                    Vec2.add v (Vec2.scale left step)
                                )
                                    |> (\vv ->
                                            case prevResponse of
                                                AABB.Y _ ->
                                                    Vec2.setY v.y vv

                                                AABB.X _ ->
                                                    Vec2.setX v.x vv

                                                _ ->
                                                    vv
                                       )
                            )

                boundary =
                    boundaryObj
                        |> AABB.applyVelocity
                        |> AABB.boundary

                targets =
                    Broad.Grid.query boundary grid

                --                        |> Debug.log "targets"
            in
            case moveFold (Dict.toList targets) withAccelerationObj prevResponse tested contact of
                Continue obj__ prevResponse__ tested2 contact__ ->
                    if left > 1 then
                        move obj__ obj__ step grid (left - 1) tested2 prevResponse__ contact__

                    else
                        AABB.setContact contact__ obj__

                Break obj__ contact__ ->
                    AABB.setContact contact__ obj__


type MoveStep a b tested contact
    = Break a contact
    | Continue a b tested contact


sumContact a b =
    { x = a.x + b.x |> limit
    , y = a.y + b.y |> limit
    }


limit a =
    if a < -1 then
        -1

    else if a > 1 then
        1

    else
        a


moveFold l obj prevResponse tested contact =
    case l of
        ( k, item ) :: rest ->
            if Set.member k tested then
                moveFold rest obj prevResponse tested contact

            else
                let
                    ( newResponse, contact__ ) =
                        AABB.response obj item

                    unionResponse =
                        AABB.unionCollision prevResponse newResponse

                    contact_ =
                        sumContact contact contact__

                    --                    _ =
                    --                        Debug.log "newResponse" { a = AABB.getVelocity obj, b = prevResponse, c = newResponse, d = unionResponse }
                    newTested =
                        Set.insert k tested
                in
                case unionResponse of
                    AABB.XandY a b ->
                        Break (AABB.updateVelocity (\v -> { v | x = v.x * a, y = v.y * b }) obj) contact_

                    AABB.XorY _ _ ->
                        moveFold rest obj unionResponse newTested contact_

                    AABB.X a ->
                        moveFold rest (AABB.updateVelocity (\v -> { v | x = v.x * a }) obj) (AABB.X 1) newTested contact_

                    AABB.Y a ->
                        moveFold rest (AABB.updateVelocity (\v -> { v | y = v.y * a }) obj) (AABB.Y 1) newTested contact_

                    AABB.None ->
                        moveFold rest obj unionResponse newTested contact_

        [] ->
            Continue obj prevResponse tested contact
