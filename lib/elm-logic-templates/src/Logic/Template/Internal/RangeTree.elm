module Logic.Template.Internal.RangeTree exposing (RangeTree(..), empty, fromList, get, insert, toList)


type RangeTree a
    = Value Int a
    | Node Int (RangeTree a) (RangeTree a)


empty : Int -> a -> RangeTree a
empty frame value =
    Value frame value


insert : Int -> a -> RangeTree a -> RangeTree a
insert newFrame newValue tree =
    case tree of
        Value frame_ _ ->
            if frame_ < newFrame then
                Node newFrame tree (empty newFrame newValue)

            else
                Node frame_ (empty newFrame newValue) tree

        Node maxFrame node1 ((Node max2 (Value subMax2 subValue2) rest) as node2) ->
            if newFrame < max2 && newFrame > subMax2 then
                Node maxFrame (insert subMax2 subValue2 node1 |> insert newFrame newValue) rest

            else if maxFrame < newFrame then
                Node newFrame node1 (insert newFrame newValue node2)

            else
                Node maxFrame (insert newFrame newValue node1) node2

        Node maxFrame node1 node2 ->
            if maxFrame < newFrame then
                Node newFrame node1 (insert newFrame newValue node2)

            else
                Node maxFrame (insert newFrame newValue node1) node2


get : Int -> RangeTree a -> a
get i tree =
    case tree of
        Value _ v ->
            v

        Node _ ((Node max1 _ _) as node1) node2 ->
            if i <= max1 then
                get i node1

            else
                get i node2

        Node _ (Value max1 v1) node2 ->
            if i <= max1 then
                v1

            else
                get i node2


fromList : Int -> a -> List ( Int, a ) -> RangeTree a
fromList frame value l =
    List.foldl (\( frame_, value_ ) -> insert frame_ value_) (empty frame value) l


toList : RangeTree a -> List ( Int, a )
toList tree =
    toList_ tree []


toList_ : RangeTree a -> List ( Int, a ) -> List ( Int, a )
toList_ tree acc =
    case tree of
        Value i v ->
            ( i, v ) :: acc

        Node _ node1 node2 ->
            toList_ node1 acc
                |> toList_ node2
