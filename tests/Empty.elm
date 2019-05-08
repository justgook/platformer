module Empty exposing (suite)

import Expect exposing (Expectation)
import Test exposing (..)


suite : Test
suite =
    test "Just Pass" <|
        \_ ->
            Expect.pass
