module Vector3 exposing (..)

import AltMath.Record.Vector3 as RecordVec3
import AltMath.Tuple.Vector3 as TupleVec3
import AltMath.Vector3 as AdtVec3
import Benchmark exposing (..)
import Math.Vector3 as GLVec3


all { x1, x2, y1, y2, z1, z2 } =
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

        data =
            { glVec1 = GLVec3.vec3 x1_ y1_ z1_
            , glVec2 = GLVec3.vec3 x2_ y2_ z2_
            , adtVec1 = AdtVec3.vec3 x1_ y1_ z1_
            , adtVec2 = AdtVec3.vec3 x2_ y2_ z2_
            , recVec1 = RecordVec3.vec3 x1_ y1_ z1_
            , recVec2 = RecordVec3.vec3 x2_ y2_ z2_
            , tupleVec1 = TupleVec3.vec3 x1_ y1_ z1_
            , tupleVec2 = TupleVec3.vec3 x2_ y2_ z2_
            }

        record =
            { x = x1_, y = y1_, z = z1_ }
    in
    [ vec3 x1_ y1_ z1_
    , add data
    , cross data
    , direction data
    , distance data
    , distanceSquared data
    , dot data
    , fromRecord record
    , getX data
    , getY data
    , getZ data
    , length data
    , lengthSquared data
    , negate data
    , normalize data
    , scale data
    , setX data x1_
    , setY data y1_
    , setZ data z1_
    , sub data
    , toRecord data
    ]


vec3 x y z =
    Benchmark.scale "vec3"
        [ ( "Linear Algebra", \_ -> GLVec3.vec3 x y z |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.vec3 x y z |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.vec3 x y z |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.vec3 x y z |> TupleVec3 )
        ]


type Wrap
    = GLVec3 GLVec3.Vec3
    | AdtVec3 AdtVec3.Vec3
    | RecordVec3 RecordVec3.Vec3
    | TupleVec3 TupleVec3.Vec3


getX { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "getX"
        [ ( "Linear Algebra", \_ -> GLVec3.getX glVec1 )
        , ( "ADT", \_ -> AdtVec3.getX adtVec1 )
        , ( "Record", \_ -> RecordVec3.getX recVec1 )
        , ( "Tuple", \_ -> TupleVec3.getX tupleVec1 )
        ]


getY { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "getY"
        [ ( "Linear Algebra", \_ -> GLVec3.getY glVec1 )
        , ( "ADT", \_ -> AdtVec3.getY adtVec1 )
        , ( "Record", \_ -> RecordVec3.getY recVec1 )
        , ( "Tuple", \_ -> TupleVec3.getY tupleVec1 )
        ]


getZ { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "getZ"
        [ ( "Linear Algebra", \_ -> GLVec3.getZ glVec1 )
        , ( "ADT", \_ -> AdtVec3.getZ adtVec1 )
        , ( "Record", \_ -> RecordVec3.getZ recVec1 )
        , ( "Tuple", \_ -> TupleVec3.getZ tupleVec1 )
        ]


setX { glVec1, adtVec1, recVec1, tupleVec1 } a =
    Benchmark.scale "setX"
        [ ( "Linear Algebra", \_ -> GLVec3.setX a glVec1 |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.setX a adtVec1 |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.setX a recVec1 |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.setX a tupleVec1 |> TupleVec3 )
        ]


setY { glVec1, adtVec1, recVec1, tupleVec1 } a =
    Benchmark.scale "setY"
        [ ( "Linear Algebra", \_ -> GLVec3.setY a glVec1 |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.setY a adtVec1 |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.setY a recVec1 |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.setY a tupleVec1 |> TupleVec3 )
        ]


setZ { glVec1, adtVec1, recVec1, tupleVec1 } a =
    Benchmark.scale "setZ"
        [ ( "Linear Algebra", \_ -> GLVec3.setZ a glVec1 |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.setZ a adtVec1 |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.setZ a recVec1 |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.setZ a tupleVec1 |> TupleVec3 )
        ]


add { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "add"
        [ ( "Linear Algebra", \_ -> GLVec3.add glVec1 glVec2 |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.add adtVec1 adtVec2 |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.add recVec1 recVec2 |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.add tupleVec1 tupleVec2 |> TupleVec3 )
        ]


sub { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "sub"
        [ ( "Linear Algebra", \_ -> GLVec3.sub glVec1 glVec2 |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.sub adtVec1 adtVec2 |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.sub recVec1 recVec2 |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.sub tupleVec1 tupleVec2 |> TupleVec3 )
        ]


negate { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "negate"
        [ ( "Linear Algebra", \_ -> GLVec3.negate glVec1 |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.negate adtVec1 |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.negate recVec1 |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.negate tupleVec1 |> TupleVec3 )
        ]


scale { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "scale"
        [ ( "Linear Algebra", \_ -> GLVec3.scale 2 glVec1 |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.scale 2 adtVec1 |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.scale 2 recVec1 |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.scale 2 tupleVec1 |> TupleVec3 )
        ]


dot { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "dot"
        [ ( "Linear Algebra", \_ -> GLVec3.dot glVec1 glVec2 )
        , ( "ADT", \_ -> AdtVec3.dot adtVec1 adtVec2 )
        , ( "Record", \_ -> RecordVec3.dot recVec1 recVec2 )
        , ( "Tuple", \_ -> TupleVec3.dot tupleVec1 tupleVec2 )
        ]


normalize { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "normalize"
        [ ( "Linear Algebra", \_ -> GLVec3.normalize glVec1 |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.normalize adtVec1 |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.normalize recVec1 |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.normalize tupleVec1 |> TupleVec3 )
        ]


direction { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "direction"
        [ ( "Linear Algebra", \_ -> GLVec3.direction glVec1 glVec2 |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.direction adtVec1 adtVec2 |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.direction recVec1 recVec2 |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.direction tupleVec1 tupleVec2 |> TupleVec3 )
        ]



--
--mul =
--    Benchmark.scale "mul"
--        [ --("Linear Algebra", \_ -> GLVec3.mul glVec1 glVec3|> GLVec3)
--          ( "ADT", \_ -> AdtVec3.mul adtVec1 adtVec3 |> AdtVec3 )
--        , ( "Record", \_ -> RecordVec3.mul recVec1 recVec3 |> RecordVec3 )
--        , ( "Tuple", \_ -> TupleVec3.mul tupleVec1 tupleVec3 |> TupleVec3 )
--        ]


length { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "length"
        [ ( "Linear Algebra", \_ -> GLVec3.length glVec1 )
        , ( "ADT", \_ -> AdtVec3.length adtVec1 )
        , ( "Record", \_ -> RecordVec3.length recVec1 )
        , ( "Tuple", \_ -> TupleVec3.length tupleVec1 )
        ]


lengthSquared { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "lengthSquared"
        [ ( "Linear Algebra", \_ -> GLVec3.lengthSquared glVec1 )
        , ( "ADT", \_ -> AdtVec3.lengthSquared adtVec1 )
        , ( "Record", \_ -> RecordVec3.lengthSquared recVec1 )
        , ( "Tuple", \_ -> TupleVec3.lengthSquared tupleVec1 )
        ]


distance { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "distance"
        [ ( "Linear Algebra", \_ -> GLVec3.distance glVec1 glVec2 )
        , ( "ADT", \_ -> AdtVec3.distance adtVec1 adtVec2 )
        , ( "Record", \_ -> RecordVec3.distance recVec1 recVec2 )
        , ( "Tuple", \_ -> TupleVec3.distance tupleVec1 tupleVec2 )
        ]


distanceSquared { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "distanceSquared"
        [ ( "Linear Algebra", \_ -> GLVec3.distanceSquared glVec1 glVec2 )
        , ( "ADT", \_ -> AdtVec3.distanceSquared adtVec1 adtVec2 )
        , ( "Record", \_ -> RecordVec3.distanceSquared recVec1 recVec2 )
        , ( "Tuple", \_ -> TupleVec3.distanceSquared tupleVec1 tupleVec2 )
        ]


cross { glVec1, adtVec1, recVec1, tupleVec1, glVec2, adtVec2, recVec2, tupleVec2 } =
    Benchmark.scale "cross"
        [ ( "Linear Algebra", \_ -> GLVec3.cross glVec1 glVec2 |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.cross adtVec1 adtVec2 |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.cross recVec1 recVec2 |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.cross tupleVec1 tupleVec2 |> TupleVec3 )
        ]


toRecord { glVec1, adtVec1, recVec1, tupleVec1 } =
    Benchmark.scale "toRecord"
        [ ( "Linear Algebra", \_ -> GLVec3.toRecord glVec1 )
        , ( "ADT", \_ -> AdtVec3.toRecord adtVec1 )
        , ( "Record", \_ -> RecordVec3.toRecord recVec1 )
        , ( "Tuple", \_ -> TupleVec3.toRecord tupleVec1 )
        ]


fromRecord record =
    Benchmark.scale "fromRecord"
        [ ( "Linear Algebra", \_ -> GLVec3.fromRecord record |> GLVec3 )
        , ( "ADT", \_ -> AdtVec3.fromRecord record |> AdtVec3 )
        , ( "Record", \_ -> RecordVec3.fromRecord record |> RecordVec3 )
        , ( "Tuple", \_ -> TupleVec3.fromRecord record |> TupleVec3 )
        ]
