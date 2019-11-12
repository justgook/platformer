module CustomRunner.Humanize exposing (int, percent)


int : Int -> String
int =
    String.fromInt
        >> String.toList
        >> List.reverse
        >> groupsOf 3
        >> List.reverse
        >> List.map (List.reverse >> String.fromList)
        >> String.join ","


groupsOf : Int -> List a -> List (List a)
groupsOf howMany items =
    case List.take howMany items of
        [] ->
            []

        xs ->
            xs :: groupsOf howMany (List.drop howMany items)


percent : Float -> String
percent =
    (*) 10000
        >> round
        >> toFloat
        >> (\a -> (/) a 100)
        >> String.fromFloat
        >> (\a -> (++) a "%")
