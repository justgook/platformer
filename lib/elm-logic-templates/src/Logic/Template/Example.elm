module Logic.Template.Example exposing (dimensionSpec, positionSpec)


positionSpec =
    { get = .positions
    , set = \comps world -> { world | positions = comps }
    }


dimensionSpec =
    { get = .dimensions
    , set = \comps world -> { world | dimensions = comps }
    }
