module Shape exposing (Shape(..))


type Shape
    = Rectangle Rectangle
    | Ellipse Ellipse
    | Triangle Triangle


type Triangle
    = Triangle
    | SlopeLeft -- 90 Deg cut from top
    | SlopeRight


type Rectangle
    = AABB
    | Retcangle


type Ellipse
    = Circle
    | Ellipse
