module World.Component.Body exposing (bodies)

import Logic.Component
import Logic.Entity as Entity
import Physic.Body
import ResourceTask
import Tiled.Object
import World.Component.Common exposing (Read(..), commonDimensionArgs, defaultRead)
import World.Component.Util exposing (extractObjectData)


bodies =
    let
        spec =
            { get = .bodies
            , set = \comps world -> { world | bodies = comps }
            }
    in
    { spec = spec
    , empty = Logic.Component.empty
    , read =
        { defaultRead
            | objectTile =
                Async
                    (\{ x, y, width, height, gid, fh, fv, getTilesetByGid } ->
                        getTilesetByGid gid
                            >> ResourceTask.andThen
                                (\t_ ->
                                    let
                                        a =
                                            extractObjectData gid t_
                                                |> Maybe.map .objects
                                                |> Maybe.andThen List.head
                                                |> Maybe.andThen maybeEllipse
                                                |> Maybe.map
                                                    (\o ->
                                                        Physic.Body.ellipse
                                                            (x + o.x - width * 0.5 + o.width * 0.5)
                                                            (y + (o.height - o.y))
                                                            (o.width / 2)
                                                            (o.height / 2)
                                                    )
                                    in
                                    ResourceTask.succeed
                                        (\acc ->
                                            Maybe.map
                                                (\comp ->
                                                    Entity.with ( spec, comp ) acc
                                                )
                                                a
                                                |> Maybe.withDefault acc
                                        )
                                )
                    )
        }
    }


maybeEllipse o =
    case o of
        Tiled.Object.Ellipse common dimension ->
            commonDimensionArgs common dimension
                |> Just

        _ ->
            Nothing
