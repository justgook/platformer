module Logic.Template.FX.Projectile exposing (Projectile, Setting, draw, empty, emptyWith, update, updateWith)

import AltMath.Vector2 as Vec2 exposing (Vec2)
import Logic.Template.FX.P16 as P16
import Logic.Template.FX.Particle as Particle exposing (Emitter)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)
import Random
import WebGL.Settings as WebGL
import WebGL.Settings.Blend as Blend


type alias Projectile =
    Emitter Uniforms Particle


type alias Uniforms =
    P16.Particles


values =
    { amount = 16
    , vertexShader = P16.vertexShader
    , fragmentShader = Particle.simpleFragmentShader
    , points = P16.points
    , entitySettings =
        [ WebGL.cullFace WebGL.front
        , Blend.add Blend.srcAlpha Blend.oneMinusSrcAlpha
        , WebGL.colorMask True True True False
        ]
    }


type alias Setting =
    { generator : Vec2 -> Int -> Random.Generator Particle
    , spawn : Random.Seed -> Float
    }


type alias Particle =
    { acceleration : Vec2
    , velocity : Vec2
    , id : Int
    , data : Vec4
    }


updateShaderData =
    P16.updateShaderData


empty : Projectile
empty =
    emptyWith defaultSettings


emptyWith : Setting -> Projectile
emptyWith settings =
    { live = []
    , dead = []
    , generator = settings.generator (Vec2 -3 -3)
    , spawn = settings.spawn
    , queue = 0
    , seed = Random.initialSeed 42
    , renderable = P16.empty
    }
        |> fill values.amount


defaultSettings : Setting
defaultSettings =
    { generator =
        \pos i ->
            Random.map5
                (\size acceleration velocity position lifespan ->
                    { id = i
                    , acceleration = acceleration
                    , velocity = velocity
                    , data = vec4 position.x position.y size lifespan
                    }
                )
                (Random.float 5 10)
                (Random.map2 Vec2 (Random.constant 0.000003) (Random.constant 0))
                (Random.map2 Vec2 (Random.float -0.001 0.001) (Random.float 0.001 0.003))
                --(Random.map2 Vec2 (Random.constant 0.75) (Random.constant 0.5))
                (Random.constant pos)
                (Random.float 10 160)
    , spawn = \seed -> Random.step (Random.float (1 / 60) 3) seed |> Tuple.first
    }


fill amount config =
    let
        ( result, _ ) =
            List.foldl
                (\i ( acc, seed ) ->
                    let
                        ( particle, seed1 ) =
                            Random.step (acc.generator i) seed
                    in
                    ( { acc | dead = particle :: acc.dead }, seed1 )
                )
                ( config, config.seed )
                (List.range 0 (amount - 1))
    in
    result


update =
    updateWith defaultSettings


updateWith settings income emitter =
    let
        gravityUpdate__ : Particle -> Particle
        gravityUpdate__ item =
            let
                { x, y, z, w } =
                    Vec4.toRecord item.data

                velocity =
                    item.acceleration
                        |> Vec2.scale (sin (w / 5) * 10)
                        |> Vec2.add item.velocity

                position =
                    Vec2.add { x = x, y = y } velocity
            in
            { item
                | velocity = velocity
                , data = vec4 position.x position.y z (w - 1)
            }
    in
    { emitter
        | generator = settings.generator income.position
        , spawn = settings.spawn
    }
        |> Particle.update gravityUpdate__ updateShaderData


draw uniforms =
    [ Particle.draw
        values.entitySettings
        values.points
        values.fragmentShader
        values.vertexShader
        uniforms
    ]
