module World.Component.ObjetLayer exposing (objectLayer)

import Layer
import Logic.Component as Component
import Logic.Entity as Entity exposing (EntityID)
import ResourceTask
import Tiled.Layer
import Tiled.Object
import World.Component.Common exposing (Read1(..), Read2(..), Read3(..), Reader)


objectLayer :
    (Tiled.Object.Object -> Tiled.Object.Object)
    -> List (Reader world (Component.Set comp))
    ->
        { c
            | ecs : world
            , idSource : Int
            , layers : List (Layer.Layer (Component.Set comp))
        }
    -> Tiled.Layer.ObjectData
    -> ResourceTask.CacheTask
    ->
        ResourceTask.ResourceTask
            { c
                | ecs : world
                , idSource : Int
                , layers : List (Layer.Layer (Component.Set comp))
            }
objectLayer fix readers info_ objectData start =
    objectData.objects
        |> List.foldr
            (\obj ->
                case fix obj of
                    Tiled.Object.Point common ->
                        ResourceTask.andThen
                            (\( layerECS, info ) ->
                                combine1 .objectPoint common readers (Entity.create info.idSource info.ecs)
                                    >> ResourceTask.map (\newECS -> validateAndUpdate ( layerECS, info ) newECS layerECS)
                            )

                    Tiled.Object.Rectangle common dimension ->
                        ResourceTask.andThen
                            (\( layerECS, info ) ->
                                combine2 .objectRectangle { a = common, b = dimension } readers (Entity.create info.idSource info.ecs)
                                    >> ResourceTask.map (\newECS -> validateAndUpdate ( layerECS, info ) newECS layerECS)
                            )

                    Tiled.Object.Ellipse common dimension ->
                        ResourceTask.andThen
                            (\( layerECS, info ) ->
                                combine2 .objectEllipse { a = common, b = dimension } readers (Entity.create info.idSource info.ecs)
                                    >> ResourceTask.map (\newECS -> validateAndUpdate ( layerECS, info ) newECS layerECS)
                            )

                    Tiled.Object.Polygon common dimension polyPoints ->
                        ResourceTask.andThen
                            (\( layerECS, info ) ->
                                combine3 .objectPolygon { a = common, b = dimension, c = polyPoints } readers (Entity.create info.idSource info.ecs)
                                    >> ResourceTask.map (\newECS -> validateAndUpdate ( layerECS, info ) newECS layerECS)
                            )

                    Tiled.Object.PolyLine common dimension polyPoints ->
                        ResourceTask.andThen
                            (\( layerECS, info ) ->
                                combine3 .objectPolyLine { a = common, b = dimension, c = polyPoints } readers (Entity.create info.idSource info.ecs)
                                    >> ResourceTask.map (\newECS -> validateAndUpdate ( layerECS, info ) newECS layerECS)
                            )

                    Tiled.Object.Tile common dimension gid ->
                        ResourceTask.andThen
                            (\( layerECS, info ) ->
                                ResourceTask.map2 (validateAndUpdate ( layerECS, info ))
                                    (combine3 .objectTile { a = common, b = dimension, c = gid } readers (Entity.create info.idSource info.ecs))
                                    (combine3 .objectTileRenderable { a = common, b = dimension, c = gid } readers (Entity.create info.idSource layerECS))
                            )
            )
            (ResourceTask.succeed ( Component.empty, info_ ) start)
        >> ResourceTask.map
            (\( layer, info ) ->
                { info | layers = Layer.Object layer :: info.layers }
            )


combine1 :
    (reader -> Read1 world a)
    -> a
    -> List reader
    -> ( EntityID, world )
    -> ResourceTask.CacheTask
    -> ResourceTask.ResourceTask world
combine1 getKey arg readers acc =
    case readers of
        item :: rest ->
            case getKey item of
                None1 ->
                    combine1 getKey arg rest acc

                Sync1 f ->
                    combine1 getKey arg rest (f arg acc)

                Async1 f ->
                    f arg >> ResourceTask.andThen (\f1 -> combine1 getKey arg rest (f1 acc))

        [] ->
            let
                ( _, newECS ) =
                    acc
            in
            ResourceTask.succeed newECS


combine2 :
    (reader -> Read2 world a b)
    -> { a : a, b : b }
    -> List reader
    -> ( EntityID, world )
    -> ResourceTask.CacheTask
    -> ResourceTask.ResourceTask world
combine2 getKey ({ a, b } as args) readers acc =
    case readers of
        item :: rest ->
            case getKey item of
                None2 ->
                    combine2 getKey args rest acc

                Sync2 f ->
                    combine2 getKey args rest (f a b acc)

                Async2 f ->
                    f a b >> ResourceTask.andThen (\f1 -> combine2 getKey args rest (f1 acc))

        [] ->
            let
                ( _, newECS ) =
                    acc
            in
            ResourceTask.succeed newECS


combine3 :
    (reader -> Read3 world a b c)
    -> { a : a, b : b, c : c }
    -> List reader
    -> ( EntityID, world )
    -> ResourceTask.CacheTask
    -> ResourceTask.ResourceTask world
combine3 getKey ({ a, b, c } as args) readers acc =
    case readers of
        item :: rest ->
            case getKey item of
                None3 ->
                    combine3 getKey args rest acc

                Sync3 f ->
                    combine3 getKey args rest (f a b c acc)

                Async3 f ->
                    f a b c >> ResourceTask.andThen (\f1 -> combine3 getKey args rest (f1 acc))

        [] ->
            let
                ( _, newECS ) =
                    acc
            in
            ResourceTask.succeed newECS


validateAndUpdate ( layerECS, info ) newECS newLayerECS =
    case ( newECS == info.ecs, layerECS == newLayerECS ) of
        ( True, True ) ->
            ( layerECS, info )

        ( False, True ) ->
            ( layerECS, { info | idSource = info.idSource + 1, ecs = newECS } )

        ( True, False ) ->
            ( newLayerECS, { info | idSource = info.idSource + 1 } )

        ( False, False ) ->
            ( newLayerECS, { info | idSource = info.idSource + 1, ecs = newECS } )
