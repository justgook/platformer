module Logic.Template.GFX.Space exposing (Model, draw)

--https://www.shadertoy.com/view/XlfGRj

import Logic.Template.Internal exposing (Plate, entitySettings, plate)
import Math.Vector2 exposing (Vec2)
import WebGL exposing (Shader)


type alias Model a =
    { a
        | offset : Vec2
    }


draw : WebGL.Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity
draw vertexShader_ =
    WebGL.entityWith
        entitySettings
        vertexShader_
        fragmentShader
        plate


fragmentShader : Shader {} (Model a) { uv : Vec2 }
fragmentShader =
    [glsl| precision mediump float;
        const int iterations = 17;
        const float formuparam = 0.53;
        const int volsteps = 20;
        const float stepsize = 0.1;
        const float zoom   = 0.800;
        const float tile   = 0.850;
        const float speed  = 0.010;
        const float brightness = 0.0015;
        const float darkmatter = 0.300;
        const float distfading = 0.730;
        const float saturation = 0.850;
        varying vec2 uv;
        uniform vec2 offset;

        void main() {
            //get coords and direction
            vec3 dir=vec3(uv*zoom,1.);
            vec3 from=vec3(1.,.5,0.5);
            from+=vec3(offset,-2.);
            //volumetric rendering
            float s=0.1,fade=1.;
            vec3 v=vec3(0.);
            for (int r=0; r<volsteps; r++) {
                vec3 p=from+s*dir*.5;
                p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
                float pa,a=pa=0.;
                for (int i=0; i<iterations; i++) {
                    p=abs(p)/dot(p,p)-formuparam; // the magic formula
                    a+=abs(length(p)-pa); // absolute sum of average change
                    pa=length(p);
                }
                float dm=max(0.,darkmatter-a*a*.001); //dark matter
                a*=a*a; // add contrast
                if (r>6) fade*=1.-dm; // dark matter, do nott render near
//                v+=vec3(dm,dm*.5,0.);
                v+=fade;
                v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
                fade*=distfading; // distance fading
                s+=stepsize;
            }
            v=mix(vec3(length(v)),v,saturation); //color adjust

            gl_FragColor = vec4(v*.01,0.7);


        }
    |]
