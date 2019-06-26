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


cartoonParams =
    """
        const int iterations = 15;
        const float formuparam = 0.53;
        const int layerCount = 10;
        const float stepsize = 0.12;
        const float zoom   = .800;
        const float tile   = .850;
        const float speed  = 0.10;
        const float brightness = 0.0000075;
        const float darkmatter = 0.700;
        const float distfading = 1.000;
        const float saturation = 1.850;"""


fragmentShader : Shader {} (Model a) { uv : Vec2 }
fragmentShader =
    [glsl| precision mediump float;
        const int iterations = 15;
        const float formuparam = 0.52;
        const int layerCount = 7;
        const float stepsize = 0.2;
        const float zoom   = 1.2;
        const float tile   = 1.850;
        const float speed  = 0.010;
        const float brightness = 0.00000125;
        const float darkmatter = 0.700;
        const float distfading = 0.630;
        const float saturation = 0.750;
        const float animationSpeed = 3.75;
        const float animationIntensity = 0.0175;
        varying vec2 uv;
        uniform vec2 offset;
        float lengthSquared (vec3 vec) {
            return vec.x * vec.x + vec.y * vec.y + vec.z * vec.z;
        }

        void main() {
            //get coords and direction
            vec3 dir=vec3(uv*zoom,1.);
            vec3 from=vec3(1.,2.3,0.5);
            from+=vec3(offset,-2.);
            //volumetric rendering
            float s=0.1,fade=1.;
            vec3 v=vec3(0.);

            for (int layer=0; layer<layerCount; layer++) {
                vec3 p=from+s*dir*.5;
                p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
                float pa,a=pa=0.;
                for (int i=0; i<iterations; i++) {
                    p=abs(p)/dot(p,p)-formuparam +(sin(from * animationSpeed * float(i)) * animationIntensity); // the magic formula
                    a+=abs(lengthSquared(p)-pa); // absolute sum of average change
                    pa=lengthSquared(p);
                }
                float dm=max(0.,darkmatter-a*a*.001); //dark matter
                a*=a*a; // add contrast
                v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
                fade*=distfading; // distance fading
                s+=stepsize;
            }
            v=mix(vec3(length(v)),v,saturation); //color adjust

            gl_FragColor = vec4(v*.01,0.7);


        }
    |]
