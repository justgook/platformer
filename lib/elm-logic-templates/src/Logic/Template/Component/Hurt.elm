module Logic.Template.Component.Hurt exposing
    ( Circles
    , HitBox
    , HurtBox
    , HurtWorld
    , collide
    , debug
    , empty
    , enemyHitBoxSpec
    , playerHitBoxSpec
    , remove
    , spawnEnemyHurtBox
    , spawnHitBox
    , spawnPlayerHurtBox
    , spec
    )

import AltMath.Vector2 as Vec2 exposing (Vec2)
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
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


type alias HurtWorld =
    { playerHitBox : Component.Set HitBox
    , enemyHitBox : Component.Set HitBox
    , playerHurtBox : Component.Set HurtBox
    , enemyHurtBox : Component.Set HurtBox
    }


type alias HitBox =
    Circles


type alias HurtBox =
    Circles


type alias Circles =
    List ( Vec2, Radius )


type alias Radius =
    Float


empty =
    { playerHitBox = Component.empty
    , enemyHitBox = Component.empty
    , playerHurtBox = Component.empty
    , enemyHurtBox = Component.empty
    }


spec : Singleton.Spec HurtWorld { world | hurt : HurtWorld }
spec =
    { get = .hurt
    , set = \comps world -> { world | hurt = comps }
    }


remove : Singleton.Spec HurtWorld world -> ( EntityID, world ) -> ( EntityID, world )
remove spec_ ( entityID, w ) =
    let
        remove_ =
            Entity.removeFor playerHitBoxSpec
                >> Entity.removeFor enemyHitBoxSpec
                >> Entity.removeFor playerHurtBoxSpec
                >> Entity.removeFor enemyHurtBoxSpec
    in
    ( entityID, Singleton.update spec_ (\comps -> remove_ ( entityID, comps ) |> Tuple.second) w )


spawnHitBox : EntityID -> ( EntityID, HitBox ) -> HurtWorld -> HurtWorld
spawnHitBox author ( entityID, info ) w =
    case Entity.get author w.enemyHurtBox of
        Just _ ->
            spawnEnemyHitBox ( entityID, info ) w

        Nothing ->
            case Entity.get author w.playerHurtBox of
                Just _ ->
                    spawnPlayerHitBox ( entityID, info ) w

                _ ->
                    w


spawnPlayerHitBox : ( EntityID, HitBox ) -> HurtWorld -> HurtWorld
spawnPlayerHitBox ( entityID, info ) w =
    Entity.with ( playerHitBoxSpec, info ) ( entityID, w ) |> Tuple.second


playerHitBoxSpec =
    { get = .playerHitBox
    , set = \comps world -> { world | playerHitBox = comps }
    }


spawnEnemyHitBox ( entityID, info ) w =
    Entity.with ( enemyHitBoxSpec, info ) ( entityID, w ) |> Tuple.second


enemyHitBoxSpec =
    { get = .enemyHitBox
    , set = \comps world -> { world | enemyHitBox = comps }
    }


spawnPlayerHurtBox : ( EntityID, HurtBox ) -> HurtWorld -> HurtWorld
spawnPlayerHurtBox ( entityID, hurt ) w =
    Entity.with ( playerHurtBoxSpec, hurt ) ( entityID, w ) |> Tuple.second


playerHurtBoxSpec =
    { get = .playerHurtBox
    , set = \comps world -> { world | playerHurtBox = comps }
    }


spawnEnemyHurtBox : ( EntityID, HurtBox ) -> HurtWorld -> HurtWorld
spawnEnemyHurtBox ( entityID, hurtBox ) w =
    Entity.with ( enemyHurtBoxSpec, hurtBox ) ( entityID, w ) |> Tuple.second


enemyHurtBoxSpec =
    { get = .enemyHurtBox
    , set = \comps world -> { world | enemyHurtBox = comps }
    }


collide : (EntityID -> EntityID -> world -> world) -> (EntityID -> EntityID -> world -> world) -> ( HurtWorld, Component.Set Vec2 ) -> world -> world
collide hitPlayer hitEnemy ( { playerHitBox, enemyHitBox, playerHurtBox, enemyHurtBox }, pos ) =
    checkCollision hitPlayer pos playerHurtBox enemyHurtBox
        >> checkCollision hitPlayer pos playerHurtBox enemyHitBox
        >> checkCollision hitEnemy pos enemyHurtBox playerHitBox


checkCollision f pos pack1 pack2 =
    System.indexedFoldl2
        (\i1 circles1 p1 ->
            System.indexedFoldl2
                (\i2 circles2 p2 acc2 ->
                    let
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


debug :
    { a | get : world -> HurtWorld }
    -> { b | get : world -> Component.Set { x : Float, y : Float } }
    -> { c | uAbsolute : Math.Matrix4.Mat4, px : Float }
    -> world
    -> List WebGL.Entity
debug hurtSpec posSpec { uAbsolute, px } world =
    let
        { playerHitBox, enemyHitBox, playerHurtBox, enemyHurtBox } =
            hurtSpec.get world

        pos =
            posSpec.get world

        comp =
            { color = Math.Vector4.vec4 1 1 0 1
            , uAbsolute = uAbsolute
            , uDimension = Math.Vector2.vec2 0.3 0.3
            , uP = Math.Vector2.vec2 0.5 0.5
            }

        create r g b a uP shapes acc =
            List.foldl
                (\( offset, radius ) ->
                    (::)
                        (Ellipse.draw tileVertexShader
                            { comp
                                | color = Math.Vector4.vec4 r g b a
                                , uP = Math.Vector2.fromRecord uP |> Math.Vector2.add (Math.Vector2.fromRecord offset) |> Math.Vector2.scale px
                                , uDimension = Math.Vector2.vec2 (radius * 2) (radius * 2) |> Math.Vector2.scale px
                            }
                        )
                )
                acc
                shapes
    in
    []
        |> System.foldl2 (create 1 1 1 1) pos playerHitBox
        |> System.foldl2 (create (233 / 255) (56 / 255) (65 / 255) 1) pos enemyHitBox
        |> System.foldl2 (\pos_ circles acc -> create (90 / 255) 1 (80 / 255) 1 pos_ circles acc) pos playerHurtBox
        |> System.foldl2 (\pos_ circles acc -> create (77 / 255) 0.5 (201 / 255) 1 pos_ circles acc) pos enemyHurtBox
