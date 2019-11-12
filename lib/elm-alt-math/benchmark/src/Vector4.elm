module Vector4 exposing (all)

import AltMath.Record.Vector4 as RecordVec4
import AltMath.Tuple.Vector4 as TupleVec4
import AltMath.Vector4 as AdtVec4
import Benchmark exposing (..)
import Math.Vector4 as GLVec4


all { x1, x2, y1, y2, z1, z2, w1, w2 } =
    let
        x1_ =
            String.toFloat x1 |> Maybe.withDefault 1

        x2_ =
            String.toFloat x2 |> Maybe.withDefault 10

        y1_ =
            String.toFloat y1 |> Maybe.withDefault 1

        y2_ =
            String.toFloat y2 |> Maybe.withDefault 10

        z1_ =
            String.toFloat z1 |> Maybe.withDefault 1

        z2_ =
            String.toFloat z2 |> Maybe.withDefault 10

        w1_ =
            String.toFloat w1 |> Maybe.withDefault 1

        w2_ =
            String.toFloat w2 |> Maybe.withDefault 10

        data =
            { glVec1 = GLVec4.vec4 x1_ y1_ z1_ w1_
            , glVec2 = GLVec4.vec4 x2_ y2_ z2_ w2_
            , adtVec1 = AdtVec4.vec4 x1_ y1_ z1_ w1_
            , adtVec2 = AdtVec4.vec4 x2_ y2_ z2_ w2_
            , recVec1 = RecordVec4.vec4 x1_ y1_ z1_ w1_
            , recVec2 = RecordVec4.vec4 x2_ y2_ z2_ w2_
            , tupleVec1 = TupleVec4.vec4 x1_ y1_ z1_ w1_
            , tupleVec2 = TupleVec4.vec4 x2_ y2_ z2_ w2_
            }

        record =
            { x = x1_, y = y1_, z = z1_, w = w1_ }
    in
    [ vec4 x1_ y1_ z1_ w1_
    , getX data
    , getY data
    , getZ data
    , getW data
    , setX data x2_
    , setY data y2_
    , setZ data z2_
    , setW data w2_
    , add data
    , sub data
    , negate data
    , scale data
    , dot data
    , normalize data
    , direction data
    , length data
    , lengthSquared data
    , distance data
    , distanceSquared data
    , toRecord data
    , fromRecord record
    ]


type Wrap
    = GLVec4 GLVec4.Vec4
    | AdtVec4 AdtVec4.Vec4
    | RecordVec4 RecordVec4.Vec4
    | TupleVec4 TupleVec4.Vec4


vec4 x y z w =
    Benchmark.scale "vec4"
        [ ( "Linear Algebra", \_ -> GLVec4.vec4 x y z w |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.vec4 x y z w |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.vec4 x y z w |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.vec4 x y z w |> TupleVec4 )
        ]


getX { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "getX"
        [ ( "Linear Algebra", \_ -> GLVec4.getX glVec1 )
        , ( "ADT", \_ -> AdtVec4.getX adtVec1 )
        , ( "Record", \_ -> RecordVec4.getX recVec1 )
        , ( "Tuple", \_ -> TupleVec4.getX tupleVec1 )
        ]


getY { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "getY"
        [ ( "Linear Algebra", \_ -> GLVec4.getY glVec1 )
        , ( "ADT", \_ -> AdtVec4.getY adtVec1 )
        , ( "Record", \_ -> RecordVec4.getY recVec1 )
        , ( "Tuple", \_ -> TupleVec4.getY tupleVec1 )
        ]


getZ { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "getZ"
        [ ( "Linear Algebra", \_ -> GLVec4.getZ glVec1 )
        , ( "ADT", \_ -> AdtVec4.getZ adtVec1 )
        , ( "Record", \_ -> RecordVec4.getZ recVec1 )
        , ( "Tuple", \_ -> TupleVec4.getZ tupleVec1 )
        ]


getW { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "getW"
        [ ( "Linear Algebra", \_ -> GLVec4.getW glVec1 )
        , ( "ADT", \_ -> AdtVec4.getW adtVec1 )
        , ( "Record", \_ -> RecordVec4.getW recVec1 )
        , ( "Tuple", \_ -> TupleVec4.getW tupleVec1 )
        ]


setX { glVec1, adtVec1, recVec1, tupleVec1 } a =
    Benchmark.scale "setX"
        [ ( "Linear Algebra", \_ -> GLVec4.setX a glVec1 |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.setX a adtVec1 |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.setX a recVec1 |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.setX a tupleVec1 |> TupleVec4 )
        ]


setY { glVec1, adtVec1, recVec1, tupleVec1 } a =
    Benchmark.scale "setY"
        [ ( "Linear Algebra", \_ -> GLVec4.setY a glVec1 |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.setY a adtVec1 |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.setY a recVec1 |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.setY a tupleVec1 |> TupleVec4 )
        ]


setZ { glVec1, adtVec1, recVec1, tupleVec1 } a =
    Benchmark.scale "setZ"
        [ ( "Linear Algebra", \_ -> GLVec4.setZ a glVec1 |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.setZ a adtVec1 |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.setZ a recVec1 |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.setZ a tupleVec1 |> TupleVec4 )
        ]


setW { glVec1, adtVec1, recVec1, tupleVec1 } a =
    Benchmark.scale "setW"
        [ ( "Linear Algebra", \_ -> GLVec4.setW a glVec1 |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.setW a adtVec1 |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.setW a recVec1 |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.setW a tupleVec1 |> TupleVec4 )
        ]


add { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "add"
        [ ( "Linear Algebra", \_ -> GLVec4.add glVec1 glVec2 |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.add adtVec1 adtVec2 |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.add recVec1 recVec2 |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.add tupleVec1 tupleVec2 |> TupleVec4 )
        ]


sub { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "sub"
        [ ( "Linear Algebra", \_ -> GLVec4.sub glVec1 glVec2 |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.sub adtVec1 adtVec2 |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.sub recVec1 recVec2 |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.sub tupleVec1 tupleVec2 |> TupleVec4 )
        ]


negate { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "negate"
        [ ( "Linear Algebra", \_ -> GLVec4.negate glVec1 |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.negate adtVec1 |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.negate recVec1 |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.negate tupleVec1 |> TupleVec4 )
        ]


scale { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "scale"
        [ ( "Linear Algebra", \_ -> GLVec4.scale 2 glVec1 |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.scale 2 adtVec1 |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.scale 2 recVec1 |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.scale 2 tupleVec1 |> TupleVec4 )
        ]


dot { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "dot"
        [ ( "Linear Algebra", \_ -> GLVec4.dot glVec1 glVec2 )
        , ( "ADT", \_ -> AdtVec4.dot adtVec1 adtVec2 )
        , ( "Record", \_ -> RecordVec4.dot recVec1 recVec2 )
        , ( "Tuple", \_ -> TupleVec4.dot tupleVec1 tupleVec2 )
        ]


normalize { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "normalize"
        [ ( "Linear Algebra", \_ -> GLVec4.normalize glVec1 |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.normalize adtVec1 |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.normalize recVec1 |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.normalize tupleVec1 |> TupleVec4 )
        ]


direction { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "direction"
        [ ( "Linear Algebra", \_ -> GLVec4.direction glVec1 glVec2 |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.direction adtVec1 adtVec2 |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.direction recVec1 recVec2 |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.direction tupleVec1 tupleVec2 |> TupleVec4 )
        ]



--
--mul =
--    Benchmark.scale "mul"
--        [ --("Linear Algebra", \_ -> GLVec4.mul glVec1 glVec4|> GLVec4)
--          ( "ADT", \_ -> AdtVec4.mul adtVec1 adtVec4 |> AdtVec4 )
--        , ( "Record", \_ -> RecordVec4.mul recVec1 recVec4 |> RecordVec4 )
--        , ( "Tuple", \_ -> TupleVec4.mul tupleVec1 tupleVec4 |> TupleVec4 )
--        ]


length { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "length"
        [ ( "Linear Algebra", \_ -> GLVec4.length glVec1 )
        , ( "ADT", \_ -> AdtVec4.length adtVec1 )
        , ( "Record", \_ -> RecordVec4.length recVec1 )
        , ( "Tuple", \_ -> TupleVec4.length tupleVec1 )
        ]


lengthSquared { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "lengthSquared"
        [ ( "Linear Algebra", \_ -> GLVec4.lengthSquared glVec1 )
        , ( "ADT", \_ -> AdtVec4.lengthSquared adtVec1 )
        , ( "Record", \_ -> RecordVec4.lengthSquared recVec1 )
        , ( "Tuple", \_ -> TupleVec4.lengthSquared tupleVec1 )
        ]


distance { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "distance"
        [ ( "Linear Algebra", \_ -> GLVec4.distance glVec1 glVec2 )
        , ( "ADT", \_ -> AdtVec4.distance adtVec1 adtVec2 )
        , ( "Record", \_ -> RecordVec4.distance recVec1 recVec2 )
        , ( "Tuple", \_ -> TupleVec4.distance tupleVec1 tupleVec2 )
        ]


distanceSquared { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "distanceSquared"
        [ ( "Linear Algebra", \_ -> GLVec4.distanceSquared glVec1 glVec2 )
        , ( "ADT", \_ -> AdtVec4.distanceSquared adtVec1 adtVec2 )
        , ( "Record", \_ -> RecordVec4.distanceSquared recVec1 recVec2 )
        , ( "Tuple", \_ -> TupleVec4.distanceSquared tupleVec1 tupleVec2 )
        ]


toRecord { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "toRecord"
        [ ( "Linear Algebra", \_ -> GLVec4.toRecord glVec1 )
        , ( "ADT", \_ -> AdtVec4.toRecord adtVec1 )
        , ( "Record", \_ -> RecordVec4.toRecord recVec1 )
        , ( "Tuple", \_ -> TupleVec4.toRecord tupleVec1 )
        ]


fromRecord record =
    Benchmark.scale "fromRecord"
        [ ( "Linear Algebra", \_ -> GLVec4.fromRecord record |> GLVec4 )
        , ( "ADT", \_ -> AdtVec4.fromRecord record |> AdtVec4 )
        , ( "Record", \_ -> RecordVec4.fromRecord record |> RecordVec4 )
        , ( "Tuple", \_ -> TupleVec4.fromRecord record |> TupleVec4 )
        ]
