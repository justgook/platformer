module Logic.Template.Component.Example exposing (dimensionSpec, positionSpec)

import Logic.Component exposing (Set, Spec)


positionSpec : Spec position { world | animations : Set position }
positionSpec =
    { get = .positions
    , set = \comps world -> { world | positions = comps }
    }


dimensionSpec : Spec dimension { world | animations : Set dimension }
dimensionSpec =
    { get = .dimensions
    , set = \comps world -> { world | dimensions = comps }
    }
