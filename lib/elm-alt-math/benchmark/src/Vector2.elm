module Vector2 exposing (all)

import AltMath.Record.Vector2 as RecordVec2
import AltMath.Tuple.Vector2 as TupleVec2
import AltMath.Vector2 as AdtVec2
import Benchmark exposing (..)
import Math.Vector2 as GLVec2


all { x1, x2, y1, y2 } =
    let
        x1_ =
            String.toFloat x1 |> Maybe.withDefault 1

        x2_ =
            String.toFloat x2 |> Maybe.withDefault 10

        y1_ =
            String.toFloat y1 |> Maybe.withDefault 1

        y2_ =
            String.toFloat y2 |> Maybe.withDefault 10

        data =
            { glVec1 = GLVec2.vec2 x1_ y1_
            , glVec2 = GLVec2.vec2 x2_ y2_
            , adtVec1 = AdtVec2.vec2 x1_ y1_
            , adtVec2 = AdtVec2.vec2 x2_ y2_
            , recVec1 = RecordVec2.vec2 x1_ y1_
            , recVec2 = RecordVec2.vec2 x2_ y2_
            , tupleVec1 = TupleVec2.vec2 x1_ y1_
            , tupleVec2 = TupleVec2.vec2 x2_ y2_
            }

        record =
            { x = x1_, y = y1_ }
    in
    [ vec2 x1_ y1_
    , add data
    , direction data
    , distance data
    , distanceSquared data
    , dot data
    , fromRecord record
    , getX data
    , getY data
    , length data
    , lengthSquared data
    , mul data
    , negate data
    , normalize data
    , scale data
    , setX data x2_
    , setY data y2_
    , sub data
    , toRecord data
    ]


type Wrap
    = GLVec2 GLVec2.Vec2
    | AdtVec2 AdtVec2.Vec2
    | RecordVec2 RecordVec2.Vec2
    | TupleVec2 TupleVec2.Vec2


vec2 x y =
    Benchmark.scale "vec2"
        [ ( "Linear Algebra", \_ -> GLVec2.vec2 x y |> GLVec2 )
        , ( "ADT", \_ -> AdtVec2.vec2 x y |> AdtVec2 )
        , ( "Record", \_ -> RecordVec2.vec2 x y |> RecordVec2 )
        , ( "Tuple", \_ -> TupleVec2.vec2 x y |> TupleVec2 )
        ]


getX { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "getX"
        [ ( "Linear Algebra", \_ -> GLVec2.getX glVec1 )
        , ( "ADT", \_ -> AdtVec2.getX adtVec1 )
        , ( "Record", \_ -> RecordVec2.getX recVec1 )
        , ( "Tuple", \_ -> TupleVec2.getX tupleVec1 )
        ]


getY { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "getY"
        [ ( "Linear Algebra", \_ -> GLVec2.getY glVec1 )
        , ( "ADT", \_ -> AdtVec2.getY adtVec1 )
        , ( "Record", \_ -> RecordVec2.getY recVec1 )
        , ( "Tuple", \_ -> TupleVec2.getY tupleVec1 )
        ]


setX { glVec1, adtVec1, recVec1, tupleVec1 } x =
    Benchmark.scale "setX"
        [ ( "Linear Algebra", \_ -> GLVec2.setX x glVec1 |> GLVec2 )
        , ( "ADT", \_ -> AdtVec2.setX x adtVec1 |> AdtVec2 )
        , ( "Record", \_ -> RecordVec2.setX x recVec1 |> RecordVec2 )
        , ( "Tuple", \_ -> TupleVec2.setX x tupleVec1 |> TupleVec2 )
        ]


setY { glVec1, adtVec1, recVec1, tupleVec1 } y =
    Benchmark.scale "setY"
        [ ( "Linear Algebra", \_ -> GLVec2.setY y glVec1 |> GLVec2 )
        , ( "ADT", \_ -> AdtVec2.setY y adtVec1 |> AdtVec2 )
        , ( "Record", \_ -> RecordVec2.setY y recVec1 |> RecordVec2 )
        , ( "Tuple", \_ -> TupleVec2.setY y tupleVec1 |> TupleVec2 )
        ]


add { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "add"
        [ ( "Linear Algebra", \_ -> GLVec2.add glVec1 glVec2 |> GLVec2 )
        , ( "ADT", \_ -> AdtVec2.add adtVec1 adtVec2 |> AdtVec2 )
        , ( "Record", \_ -> RecordVec2.add recVec1 recVec2 |> RecordVec2 )
        , ( "Tuple", \_ -> TupleVec2.add tupleVec1 tupleVec2 |> TupleVec2 )
        ]


sub { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "sub"
        [ ( "Linear Algebra", \_ -> GLVec2.sub glVec1 glVec2 |> GLVec2 )
        , ( "ADT", \_ -> AdtVec2.sub adtVec1 adtVec2 |> AdtVec2 )
        , ( "Record", \_ -> RecordVec2.sub recVec1 recVec2 |> RecordVec2 )
        , ( "Tuple", \_ -> TupleVec2.sub tupleVec1 tupleVec2 |> TupleVec2 )
        ]


negate { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "negate"
        [ ( "Linear Algebra", \_ -> GLVec2.negate glVec1 |> GLVec2 )
        , ( "ADT", \_ -> AdtVec2.negate adtVec1 |> AdtVec2 )
        , ( "Record", \_ -> RecordVec2.negate recVec1 |> RecordVec2 )
        , ( "Tuple", \_ -> TupleVec2.negate tupleVec1 |> TupleVec2 )
        ]


scale { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "scale"
        [ ( "Linear Algebra", \_ -> GLVec2.scale 2 glVec1 |> GLVec2 )
        , ( "ADT", \_ -> AdtVec2.scale 2 adtVec1 |> AdtVec2 )
        , ( "Record", \_ -> RecordVec2.scale 2 recVec1 |> RecordVec2 )
        , ( "Tuple", \_ -> TupleVec2.scale 2 tupleVec1 |> TupleVec2 )
        ]


dot { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "dot"
        [ ( "Linear Algebra", \_ -> GLVec2.dot glVec1 glVec2 )
        , ( "ADT", \_ -> AdtVec2.dot adtVec1 adtVec2 )
        , ( "Record", \_ -> RecordVec2.dot recVec1 recVec2 )
        , ( "Tuple", \_ -> TupleVec2.dot tupleVec1 tupleVec2 )
        ]


normalize { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "normalize"
        [ ( "Linear Algebra", \_ -> GLVec2.normalize glVec1 |> GLVec2 )
        , ( "ADT", \_ -> AdtVec2.normalize adtVec1 |> AdtVec2 )
        , ( "Record", \_ -> RecordVec2.normalize recVec1 |> RecordVec2 )
        , ( "Tuple", \_ -> TupleVec2.normalize tupleVec1 |> TupleVec2 )
        ]


direction { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "direction"
        [ ( "Linear Algebra", \_ -> GLVec2.direction glVec1 glVec2 |> GLVec2 )
        , ( "ADT", \_ -> AdtVec2.direction adtVec1 adtVec2 |> AdtVec2 )
        , ( "Record", \_ -> RecordVec2.direction recVec1 recVec2 |> RecordVec2 )
        , ( "Tuple", \_ -> TupleVec2.direction tupleVec1 tupleVec2 |> TupleVec2 )
        ]


mul { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "mul"
        [ --("Linear Algebra", \_ -> GLVec2.mul glVec1 glVec2|> GLVec2)
          ( "ADT", \_ -> AdtVec2.mul adtVec1 adtVec2 |> AdtVec2 )
        , ( "Record", \_ -> RecordVec2.mul recVec1 recVec2 |> RecordVec2 )
        , ( "Tuple", \_ -> TupleVec2.mul tupleVec1 tupleVec2 |> TupleVec2 )
        ]


length { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "length"
        [ ( "Linear Algebra", \_ -> GLVec2.length glVec1 )
        , ( "ADT", \_ -> AdtVec2.length adtVec1 )
        , ( "Record", \_ -> RecordVec2.length recVec1 )
        , ( "Tuple", \_ -> TupleVec2.length tupleVec1 )
        ]


lengthSquared { glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "lengthSquared"
        [ ( "Linear Algebra", \_ -> GLVec2.lengthSquared glVec2 )
        , ( "ADT", \_ -> AdtVec2.lengthSquared adtVec2 )
        , ( "Record", \_ -> RecordVec2.lengthSquared recVec2 )
        , ( "Tuple", \_ -> TupleVec2.lengthSquared tupleVec2 )
        ]


distance { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "distance"
        [ ( "Linear Algebra", \_ -> GLVec2.distance glVec1 glVec2 )
        , ( "ADT", \_ -> AdtVec2.distance adtVec1 adtVec2 )
        , ( "Record", \_ -> RecordVec2.distance recVec1 recVec2 )
        , ( "Tuple", \_ -> TupleVec2.distance tupleVec1 tupleVec2 )
        ]


distanceSquared { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "distanceSquared"
        [ ( "Linear Algebra", \_ -> GLVec2.distanceSquared glVec1 glVec2 )
        , ( "ADT", \_ -> AdtVec2.distanceSquared adtVec1 adtVec2 )
        , ( "Record", \_ -> RecordVec2.distanceSquared recVec1 recVec2 )
        , ( "Tuple", \_ -> TupleVec2.distanceSquared tupleVec1 tupleVec2 )
        ]


toRecord { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "toRecord"
        [ ( "Linear Algebra", \_ -> GLVec2.toRecord glVec1 )
        , ( "ADT", \_ -> AdtVec2.toRecord adtVec1 )
        , ( "Record", \_ -> RecordVec2.toRecord recVec1 )
        , ( "Tuple", \_ -> TupleVec2.toRecord tupleVec1 )
        ]


fromRecord record =
    Benchmark.scale "fromRecord"
        [ ( "Linear Algebra", \_ -> GLVec2.fromRecord record |> GLVec2 )
        , ( "ADT", \_ -> AdtVec2.fromRecord record |> AdtVec2 )
        , ( "Record", \_ -> RecordVec2.fromRecord record |> RecordVec2 )
        , ( "Tuple", \_ -> TupleVec2.fromRecord record |> TupleVec2 )
        ]
