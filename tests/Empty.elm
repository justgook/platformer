module Empty exposing (suite)

import Expect exposing (Expectation)
import Test exposing (..)


suite : Test
suite =
    test "Just Pass" <|
        \_ ->
            Expect.pass



--    todo "Implement our first test. See https://package.elm-lang.org/packages/elm-explorations/test/latest for how to do this!"
