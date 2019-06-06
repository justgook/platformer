module Logic.Template.GFX.Particle exposing (Emitter, draw, simpleFragmentShader, update)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)
import Random
import WebGL exposing (Mesh, Shader)
import WebGL.Settings exposing (Setting)



--
--https://p5js.org/examples/simulate-particle-system.html
--https://github.com/jsoverson/JavaScript-Particle-System/tree/master/js/lib


type alias Emitter uniforms a =
    --Emitter
    { live : List { a | id : Int, data : Vec4 }
    , dead : List { a | id : Int, data : Vec4 }
    , generator : Int -> Random.Generator { a | id : Int, data : Vec4 }
    , spawn : Random.Seed -> Float
    , queue : Float
    , seed : Random.Seed
    , renderable : uniforms
    }



--


draw :
    List Setting -- entitySettings
    -> Mesh { index : Float } -- points
    -> Shader {} uniforms { data : Vec4 } -- fragmentShader
    -> WebGL.Shader { index : Float } uniforms { data : Vec4 } -- vertexShader
    -> uniforms
    -> WebGL.Entity
draw entitySettings points fragmentShader vertexShader =
    WebGL.entityWith
        entitySettings
        vertexShader
        fragmentShader
        points


simpleFragmentShader : Shader a { b | aspectRatio : Float } { data : Vec4 }
simpleFragmentShader =
    [glsl|
        precision mediump float;
        varying vec4 data;
        //varying float index;
//        uniform float aspectRatio;
        float map(float min1, float max1, float min2, float max2, float value) {
          return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
        }
// Simplex 2D noise
//
vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v){
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
           -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
  + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}
        void main () {

//            vec3 color = vec3(snoise(gl_PointCoord + 15.),snoise(gl_PointCoord + 25.),snoise(gl_PointCoord + 45.));
            float delme = ((snoise(gl_PointCoord) + 1.) /  2.);
            vec3 color = vec3(delme, delme, delme);
//            vec3 color = vec3(snoise(data.xy + gl_PointCoord),0.,0.);
            float dist = distance( gl_PointCoord, vec2(0.5) );
            float alpha = 1.0 - smoothstep(0.45,0.5,dist);
            float alpha2 = map(0., 30., 0., 0.1, data.w);
            gl_FragColor = vec4(color, alpha * alpha2 );
        }
    |]


update updateParticle updateShaderData income_ =
    let
        income =
            { income_ | queue = income_.spawn income_.seed + income_.queue }
                |> reSpawn
    in
    List.foldl
        (\(item as oldItem) acc ->
            if Vec4.getW item.data > 0 then
                let
                    newItem =
                        updateParticle item
                in
                { acc
                    | live = newItem :: acc.live
                    , renderable = updateShaderData item.id newItem.data acc.renderable
                }

            else
                let
                    count =
                        128

                    i_ =
                        toFloat item.id

                    delme =
                        vec4 (i_ / count + 1 / count) 0.3 20 0

                    newAcc =
                        { acc
                            | renderable =
                                --                                P128.updateShaderData i (vec4 -3 -3 0 0) acc.renderable
                                updateShaderData item.id delme acc.renderable
                        }
                in
                { newAcc | dead = oldItem :: acc.dead }
        )
        { income | live = [] }
        income.live


spawn : Int -> List { a | id : Int, data : Vec4 } -> Emitter uniforms a -> Emitter uniforms a
spawn id rest acc =
    let
        ( data, seed ) =
            Random.step (acc.generator id) acc.seed
    in
    { acc
        | live = data :: acc.live
        , seed = seed
        , dead = rest
    }


reSpawn : Emitter uniforms a -> Emitter uniforms a
reSpawn acc =
    case acc.dead of
        { id } :: rest ->
            if acc.queue > 1 then
                spawn id rest { acc | queue = acc.queue - 1 }
                    |> reSpawn

            else
                acc

        [] ->
            acc
