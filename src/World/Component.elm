module World.Component exposing (animations, delme, dimensions, objects, positions, velocities)

import Dict.Any as Dict


positions =
    { get = .positions
    , set = \comps world -> { world | positions = comps }
    }


delme =
    { get = .delme
    , set = \comps world -> { world | delme = comps }
    }


objects =
    { get = identity
    , set = \comps _ -> comps
    }


dimensions =
    { get = .dimensions
    , set = \comps world -> { world | dimensions = comps }
    }


velocities =
    { get = .velocities
    , set = \comps world -> { world | velocities = comps }
    }


animations =
    { get = .animations2
    , set = \comps world -> { world | animations2 = comps }
    }
