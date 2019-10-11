module Logic.Template.Component.IdSource exposing (IdSource, create, empty, remove, spec)

import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity exposing (EntityID)


type alias IdSource =
    { pool : List EntityID, next : EntityID }


empty : EntityID -> IdSource
empty next =
    { pool = [], next = next }


spec : Singleton.Spec IdSource { world | idSource : IdSource }
spec =
    { get = .idSource
    , set = \comps world -> { world | idSource = comps }
    }


create : Singleton.Spec IdSource world -> world -> ( EntityID, world )
create { get, set } world =
    let
        ({ next, pool } as comp) =
            get world
    in
    case pool of
        id :: rest ->
            Entity.create id (set { comp | pool = rest } world)

        [] ->
            Entity.create next (set { comp | next = next + 1 } world)


remove : Singleton.Spec IdSource world -> EntityID -> world -> ( EntityID, world )
remove { get, set } entityID world =
    let
        comp =
            get world
    in
    ( entityID, set { comp | pool = entityID :: comp.pool } world )
