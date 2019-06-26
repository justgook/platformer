module Logic.Template.Component.Example exposing (dimensionSpec)

import Logic.Component exposing (Set, Spec)


dimensionSpec : Spec dimension { world | animations : Set dimension }
dimensionSpec =
    { get = .dimensions
    , set = \comps world -> { world | dimensions = comps }
    }
