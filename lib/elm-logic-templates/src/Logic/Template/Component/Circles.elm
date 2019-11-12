module Logic.Template.Component.Circles exposing
    ( Circles
    ,  collide
       --    , debug

    )

import AltMath.Vector2 as Vec2 exposing (Vec2)
import Logic.Component as Component
import Logic.Entity as Entity exposing (EntityID)
import Logic.System as System exposing (applyIf)
import Logic.Template.Ellipse as Ellipse
import Logic.Template.Internal exposing (tileVertexShader)
import Math.Matrix4
import Math.Vector2
import Math.Vector4
import WebGL



--https://mcleodgaming.fandom.com/wiki/Hitbox
--https://developer.amazon.com/blogs/appstore/post/cc08d63b-2b7c-4dee-abb4-272b834d7c3a/gamemaker-basics-hitboxes-and-hurtboxes


type alias Circles =
    List ( Vec2, Radius )


type alias Radius =
    Float


collide : (EntityID -> EntityID -> world -> world) -> Component.Set Vec2 -> Component.Set (List ( Vec2, Float )) -> Component.Set (List ( Vec2, Float )) -> world -> world
collide f pos pack1 pack2 =
    System.indexedFoldl2
        (\i1 circles1 p1 ->
            System.indexedFoldl2
                (\i2 circles2 p2 acc2 ->
                    let
                        isColliding_ : ( Vec2, Float ) -> ( Vec2, Float ) -> Bool
                        isColliding_ ( o1, r1 ) ( o2, r2 ) =
                            Vec2.distanceSquared (Vec2.add o1 p1) (Vec2.add o2 p2) < (r1 * r1 + r2 * r2)
                    in
                    applyIf (any2 isColliding_ circles1 circles2) (f i1 i2) acc2
                )
                pack2
                pos
        )
        pack1
        pos


any2 : (a -> b -> Bool) -> List a -> List b -> Bool
any2 f l1 l2 =
    List.any (\a -> List.any (f a) l2) l1



--debug : { r : Float, g : Float, b : Float } -> Component.Set (List ( { x : Float, y : Float }, Float )) -> Component.Set { x : Float, y : Float } -> { c | uAbsolute : Math.Matrix4.Mat4, px : Float } -> List WebGL.Entity
--debug color circles_ pos { uAbsolute, px } =
--    let
--        comp =
--            { color = Math.Vector4.vec4 1 1 0 1
--            , uAbsolute = uAbsolute
--            , uDimension = Math.Vector2.vec2 0.3 0.3
--            , uP = Math.Vector2.vec2 0.5 0.5
--            }
--
--        create { r, g, b } uP shapes acc =
--            List.foldl
--                (\( offset, radius ) ->
--                    (::)
--                        (Ellipse.draw tileVertexShader
--                            { comp
--                                | color = Math.Vector4.vec4 r g b 1
--                                , uP = Math.Vector2.fromRecord uP |> Math.Vector2.add (Math.Vector2.fromRecord offset) |> Math.Vector2.scale px
--                                , uDimension = Math.Vector2.vec2 (radius * 2) (radius * 2) |> Math.Vector2.scale px
--                            }
--                        )
--                )
--                acc
--                shapes
--    in
--    []
--        |> System.foldl2 (create color) pos circles_
