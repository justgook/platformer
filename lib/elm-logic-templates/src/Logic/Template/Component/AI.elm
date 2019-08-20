module Logic.Template.Component.AI exposing (AiTargets, Spot, empty, emptySpot, spec)

import AltMath.Vector2 exposing (Vec2)
import Logic.Component
import Logic.System


type alias AiTargets =
    { waiting : Int
    , prev : List Spot
    , target : Spot
    , next : List Spot
    }


type alias Spot =
    { position : Vec2
    , action : List String
    , wait : Int
    , invSteps : Float
    }


emptySpot : Spot
emptySpot =
    { position = { x = 0, y = 0 }
    , action = []
    , wait = 0
    , invSteps = 0.01
    }


spec : Logic.Component.Spec AiTargets { world | ai2 : Logic.Component.Set AiTargets }
spec =
    { get = .ai2
    , set = \comps world -> { world | ai2 = comps }
    }


empty : Logic.Component.Set AiTargets
empty =
    Logic.Component.empty
