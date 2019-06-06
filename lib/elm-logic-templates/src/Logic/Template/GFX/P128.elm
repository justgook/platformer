module Logic.Template.GFX.P128 exposing (Particles, empty, points, render, updateShaderData, vertexShader)

import Math.Vector4 exposing (Vec4, vec4)
import WebGL exposing (Mesh, Shader)
import WebGL.Settings exposing (Setting)


type alias Particles =
    { aspectRatio : Float
    , p0 : Vec4
    , p1 : Vec4
    , p2 : Vec4
    , p3 : Vec4
    , p4 : Vec4
    , p5 : Vec4
    , p6 : Vec4
    , p7 : Vec4
    , p8 : Vec4
    , p9 : Vec4
    , p10 : Vec4
    , p11 : Vec4
    , p12 : Vec4
    , p13 : Vec4
    , p14 : Vec4
    , p15 : Vec4
    , p16 : Vec4
    , p17 : Vec4
    , p18 : Vec4
    , p19 : Vec4
    , p20 : Vec4
    , p21 : Vec4
    , p22 : Vec4
    , p23 : Vec4
    , p24 : Vec4
    , p25 : Vec4
    , p26 : Vec4
    , p27 : Vec4
    , p28 : Vec4
    , p29 : Vec4
    , p30 : Vec4
    , p31 : Vec4
    , p32 : Vec4
    , p33 : Vec4
    , p34 : Vec4
    , p35 : Vec4
    , p36 : Vec4
    , p37 : Vec4
    , p38 : Vec4
    , p39 : Vec4
    , p40 : Vec4
    , p41 : Vec4
    , p42 : Vec4
    , p43 : Vec4
    , p44 : Vec4
    , p45 : Vec4
    , p46 : Vec4
    , p47 : Vec4
    , p48 : Vec4
    , p49 : Vec4
    , p50 : Vec4
    , p51 : Vec4
    , p52 : Vec4
    , p53 : Vec4
    , p54 : Vec4
    , p55 : Vec4
    , p56 : Vec4
    , p57 : Vec4
    , p58 : Vec4
    , p59 : Vec4
    , p60 : Vec4
    , p61 : Vec4
    , p62 : Vec4
    , p63 : Vec4
    , p64 : Vec4
    , p65 : Vec4
    , p66 : Vec4
    , p67 : Vec4
    , p68 : Vec4
    , p69 : Vec4
    , p70 : Vec4
    , p71 : Vec4
    , p72 : Vec4
    , p73 : Vec4
    , p74 : Vec4
    , p75 : Vec4
    , p76 : Vec4
    , p77 : Vec4
    , p78 : Vec4
    , p79 : Vec4
    , p80 : Vec4
    , p81 : Vec4
    , p82 : Vec4
    , p83 : Vec4
    , p84 : Vec4
    , p85 : Vec4
    , p86 : Vec4
    , p87 : Vec4
    , p88 : Vec4
    , p89 : Vec4
    , p90 : Vec4
    , p91 : Vec4
    , p92 : Vec4
    , p93 : Vec4
    , p94 : Vec4
    , p95 : Vec4
    , p96 : Vec4
    , p97 : Vec4
    , p98 : Vec4
    , p99 : Vec4
    , p100 : Vec4
    , p101 : Vec4
    , p102 : Vec4
    , p103 : Vec4
    , p104 : Vec4
    , p105 : Vec4
    , p106 : Vec4
    , p107 : Vec4
    , p108 : Vec4
    , p109 : Vec4
    , p110 : Vec4
    , p111 : Vec4
    , p112 : Vec4
    , p113 : Vec4
    , p114 : Vec4
    , p115 : Vec4
    , p116 : Vec4
    , p117 : Vec4
    , p118 : Vec4
    , p119 : Vec4
    , p120 : Vec4
    , p121 : Vec4
    , p122 : Vec4
    , p123 : Vec4
    , p124 : Vec4
    , p125 : Vec4
    , p126 : Vec4
    , p127 : Vec4
    }


render : List Setting -> WebGL.Shader {} Particles { data : Math.Vector4.Vec4 } -> Particles -> WebGL.Entity
render entitySettings fragmentShader =
    WebGL.entityWith
        entitySettings
        vertexShader
        fragmentShader
        points


empty : Particles
empty =
    { aspectRatio = 0
    , p0 = vec4 0.0078125 0.0078125 10 0.0078125
    , p1 = vec4 0.015625 0.015625 11 0.015625
    , p2 = vec4 0.0234375 0.0234375 12 0.0234375
    , p3 = vec4 0.03125 0.03125 13 0.03125
    , p4 = vec4 0.0390625 0.0390625 14 0.0390625
    , p5 = vec4 0.046875 0.046875 15 0.046875
    , p6 = vec4 0.0546875 0.0546875 16 0.0546875
    , p7 = vec4 0.0625 0.0625 17 0.0625
    , p8 = vec4 0.0703125 0.0703125 18 0.0703125
    , p9 = vec4 0.078125 0.078125 19 0.078125
    , p10 = vec4 0.0859375 0.0859375 20 0.0859375
    , p11 = vec4 0.09375 0.09375 21 0.09375
    , p12 = vec4 0.1015625 0.1015625 22 0.1015625
    , p13 = vec4 0.109375 0.109375 23 0.109375
    , p14 = vec4 0.1171875 0.1171875 24 0.1171875
    , p15 = vec4 0.125 0.125 25 0.125
    , p16 = vec4 0.1328125 0.1328125 26 0.1328125
    , p17 = vec4 0.140625 0.140625 27 0.140625
    , p18 = vec4 0.1484375 0.1484375 28 0.1484375
    , p19 = vec4 0.15625 0.15625 29 0.15625
    , p20 = vec4 0.1640625 0.1640625 30 0.1640625
    , p21 = vec4 0.171875 0.171875 31 0.171875
    , p22 = vec4 0.1796875 0.1796875 32 0.1796875
    , p23 = vec4 0.1875 0.1875 33 0.1875
    , p24 = vec4 0.1953125 0.1953125 34 0.1953125
    , p25 = vec4 0.203125 0.203125 35 0.203125
    , p26 = vec4 0.2109375 0.2109375 36 0.2109375
    , p27 = vec4 0.21875 0.21875 37 0.21875
    , p28 = vec4 0.2265625 0.2265625 38 0.2265625
    , p29 = vec4 0.234375 0.234375 39 0.234375
    , p30 = vec4 0.2421875 0.2421875 40 0.2421875
    , p31 = vec4 0.25 0.25 41 0.25
    , p32 = vec4 0.2578125 0.2578125 42 0.2578125
    , p33 = vec4 0.265625 0.265625 43 0.265625
    , p34 = vec4 0.2734375 0.2734375 44 0.2734375
    , p35 = vec4 0.28125 0.28125 45 0.28125
    , p36 = vec4 0.2890625 0.2890625 46 0.2890625
    , p37 = vec4 0.296875 0.296875 47 0.296875
    , p38 = vec4 0.3046875 0.3046875 48 0.3046875
    , p39 = vec4 0.3125 0.3125 49 0.3125
    , p40 = vec4 0.3203125 0.3203125 50 0.3203125
    , p41 = vec4 0.328125 0.328125 51 0.328125
    , p42 = vec4 0.3359375 0.3359375 52 0.3359375
    , p43 = vec4 0.34375 0.34375 53 0.34375
    , p44 = vec4 0.3515625 0.3515625 54 0.3515625
    , p45 = vec4 0.359375 0.359375 55 0.359375
    , p46 = vec4 0.3671875 0.3671875 56 0.3671875
    , p47 = vec4 0.375 0.375 57 0.375
    , p48 = vec4 0.3828125 0.3828125 58 0.3828125
    , p49 = vec4 0.390625 0.390625 59 0.390625
    , p50 = vec4 0.3984375 0.3984375 60 0.3984375
    , p51 = vec4 0.40625 0.40625 61 0.40625
    , p52 = vec4 0.4140625 0.4140625 62 0.4140625
    , p53 = vec4 0.421875 0.421875 63 0.421875
    , p54 = vec4 0.4296875 0.4296875 64 0.4296875
    , p55 = vec4 0.4375 0.4375 65 0.4375
    , p56 = vec4 0.4453125 0.4453125 66 0.4453125
    , p57 = vec4 0.453125 0.453125 67 0.453125
    , p58 = vec4 0.4609375 0.4609375 68 0.4609375
    , p59 = vec4 0.46875 0.46875 69 0.46875
    , p60 = vec4 0.4765625 0.4765625 70 0.4765625
    , p61 = vec4 0.484375 0.484375 71 0.484375
    , p62 = vec4 0.4921875 0.4921875 72 0.4921875
    , p63 = vec4 0.5 0.5 73 0.5
    , p64 = vec4 0.5078125 0.5078125 74 0.5078125
    , p65 = vec4 0.515625 0.515625 75 0.515625
    , p66 = vec4 0.5234375 0.5234375 76 0.5234375
    , p67 = vec4 0.53125 0.53125 77 0.53125
    , p68 = vec4 0.5390625 0.5390625 78 0.5390625
    , p69 = vec4 0.546875 0.546875 79 0.546875
    , p70 = vec4 0.5546875 0.5546875 80 0.5546875
    , p71 = vec4 0.5625 0.5625 81 0.5625
    , p72 = vec4 0.5703125 0.5703125 82 0.5703125
    , p73 = vec4 0.578125 0.578125 83 0.578125
    , p74 = vec4 0.5859375 0.5859375 84 0.5859375
    , p75 = vec4 0.59375 0.59375 85 0.59375
    , p76 = vec4 0.6015625 0.6015625 86 0.6015625
    , p77 = vec4 0.609375 0.609375 87 0.609375
    , p78 = vec4 0.6171875 0.6171875 88 0.6171875
    , p79 = vec4 0.625 0.625 89 0.625
    , p80 = vec4 0.6328125 0.6328125 90 0.6328125
    , p81 = vec4 0.640625 0.640625 91 0.640625
    , p82 = vec4 0.6484375 0.6484375 92 0.6484375
    , p83 = vec4 0.65625 0.65625 93 0.65625
    , p84 = vec4 0.6640625 0.6640625 94 0.6640625
    , p85 = vec4 0.671875 0.671875 95 0.671875
    , p86 = vec4 0.6796875 0.6796875 96 0.6796875
    , p87 = vec4 0.6875 0.6875 97 0.6875
    , p88 = vec4 0.6953125 0.6953125 98 0.6953125
    , p89 = vec4 0.703125 0.703125 99 0.703125
    , p90 = vec4 0.7109375 0.7109375 100 0.7109375
    , p91 = vec4 0.71875 0.71875 101 0.71875
    , p92 = vec4 0.7265625 0.7265625 102 0.7265625
    , p93 = vec4 0.734375 0.734375 103 0.734375
    , p94 = vec4 0.7421875 0.7421875 104 0.7421875
    , p95 = vec4 0.75 0.75 105 0.75
    , p96 = vec4 0.7578125 0.7578125 106 0.7578125
    , p97 = vec4 0.765625 0.765625 107 0.765625
    , p98 = vec4 0.7734375 0.7734375 108 0.7734375
    , p99 = vec4 0.78125 0.78125 109 0.78125
    , p100 = vec4 0.7890625 0.7890625 110 0.7890625
    , p101 = vec4 0.796875 0.796875 111 0.796875
    , p102 = vec4 0.8046875 0.8046875 112 0.8046875
    , p103 = vec4 0.8125 0.8125 113 0.8125
    , p104 = vec4 0.8203125 0.8203125 114 0.8203125
    , p105 = vec4 0.828125 0.828125 115 0.828125
    , p106 = vec4 0.8359375 0.8359375 116 0.8359375
    , p107 = vec4 0.84375 0.84375 117 0.84375
    , p108 = vec4 0.8515625 0.8515625 118 0.8515625
    , p109 = vec4 0.859375 0.859375 119 0.859375
    , p110 = vec4 0.8671875 0.8671875 120 0.8671875
    , p111 = vec4 0.875 0.875 121 0.875
    , p112 = vec4 0.8828125 0.8828125 122 0.8828125
    , p113 = vec4 0.890625 0.890625 123 0.890625
    , p114 = vec4 0.8984375 0.8984375 124 0.8984375
    , p115 = vec4 0.90625 0.90625 125 0.90625
    , p116 = vec4 0.9140625 0.9140625 126 0.9140625
    , p117 = vec4 0.921875 0.921875 127 0.921875
    , p118 = vec4 0.9296875 0.9296875 128 0.9296875
    , p119 = vec4 0.9375 0.9375 129 0.9375
    , p120 = vec4 0.9453125 0.9453125 130 0.9453125
    , p121 = vec4 0.953125 0.953125 131 0.953125
    , p122 = vec4 0.9609375 0.9609375 132 0.9609375
    , p123 = vec4 0.96875 0.96875 133 0.96875
    , p124 = vec4 0.9765625 0.9765625 134 0.9765625
    , p125 = vec4 0.984375 0.984375 135 0.984375
    , p126 = vec4 0.9921875 0.9921875 136 0.9921875
    , p127 = vec4 1 1 137 1
    }


points : Mesh { index : Float }
points =
    WebGL.points
        [ { index = 0 }
        , { index = 1 }
        , { index = 2 }
        , { index = 3 }
        , { index = 4 }
        , { index = 5 }
        , { index = 6 }
        , { index = 7 }
        , { index = 8 }
        , { index = 9 }
        , { index = 10 }
        , { index = 11 }
        , { index = 12 }
        , { index = 13 }
        , { index = 14 }
        , { index = 15 }
        , { index = 16 }
        , { index = 17 }
        , { index = 18 }
        , { index = 19 }
        , { index = 20 }
        , { index = 21 }
        , { index = 22 }
        , { index = 23 }
        , { index = 24 }
        , { index = 25 }
        , { index = 26 }
        , { index = 27 }
        , { index = 28 }
        , { index = 29 }
        , { index = 30 }
        , { index = 31 }
        , { index = 32 }
        , { index = 33 }
        , { index = 34 }
        , { index = 35 }
        , { index = 36 }
        , { index = 37 }
        , { index = 38 }
        , { index = 39 }
        , { index = 40 }
        , { index = 41 }
        , { index = 42 }
        , { index = 43 }
        , { index = 44 }
        , { index = 45 }
        , { index = 46 }
        , { index = 47 }
        , { index = 48 }
        , { index = 49 }
        , { index = 50 }
        , { index = 51 }
        , { index = 52 }
        , { index = 53 }
        , { index = 54 }
        , { index = 55 }
        , { index = 56 }
        , { index = 57 }
        , { index = 58 }
        , { index = 59 }
        , { index = 60 }
        , { index = 61 }
        , { index = 62 }
        , { index = 63 }
        , { index = 64 }
        , { index = 65 }
        , { index = 66 }
        , { index = 67 }
        , { index = 68 }
        , { index = 69 }
        , { index = 70 }
        , { index = 71 }
        , { index = 72 }
        , { index = 73 }
        , { index = 74 }
        , { index = 75 }
        , { index = 76 }
        , { index = 77 }
        , { index = 78 }
        , { index = 79 }
        , { index = 80 }
        , { index = 81 }
        , { index = 82 }
        , { index = 83 }
        , { index = 84 }
        , { index = 85 }
        , { index = 86 }
        , { index = 87 }
        , { index = 88 }
        , { index = 89 }
        , { index = 90 }
        , { index = 91 }
        , { index = 92 }
        , { index = 93 }
        , { index = 94 }
        , { index = 95 }
        , { index = 96 }
        , { index = 97 }
        , { index = 98 }
        , { index = 99 }
        , { index = 100 }
        , { index = 101 }
        , { index = 102 }
        , { index = 103 }
        , { index = 104 }
        , { index = 105 }
        , { index = 106 }
        , { index = 107 }
        , { index = 108 }
        , { index = 109 }
        , { index = 110 }
        , { index = 111 }
        , { index = 112 }
        , { index = 113 }
        , { index = 114 }
        , { index = 115 }
        , { index = 116 }
        , { index = 117 }
        , { index = 118 }
        , { index = 119 }
        , { index = 120 }
        , { index = 121 }
        , { index = 122 }
        , { index = 123 }
        , { index = 124 }
        , { index = 125 }
        , { index = 126 }
        , { index = 127 }
        ]


updateShaderData : Int -> Vec4 -> Particles -> Particles
updateShaderData i data allParticles =
    case i of
        0 ->
            { allParticles | p0 = data }

        1 ->
            { allParticles | p1 = data }

        2 ->
            { allParticles | p2 = data }

        3 ->
            { allParticles | p3 = data }

        4 ->
            { allParticles | p4 = data }

        5 ->
            { allParticles | p5 = data }

        6 ->
            { allParticles | p6 = data }

        7 ->
            { allParticles | p7 = data }

        8 ->
            { allParticles | p8 = data }

        9 ->
            { allParticles | p9 = data }

        10 ->
            { allParticles | p10 = data }

        11 ->
            { allParticles | p11 = data }

        12 ->
            { allParticles | p12 = data }

        13 ->
            { allParticles | p13 = data }

        14 ->
            { allParticles | p14 = data }

        15 ->
            { allParticles | p15 = data }

        16 ->
            { allParticles | p16 = data }

        17 ->
            { allParticles | p17 = data }

        18 ->
            { allParticles | p18 = data }

        19 ->
            { allParticles | p19 = data }

        20 ->
            { allParticles | p20 = data }

        21 ->
            { allParticles | p21 = data }

        22 ->
            { allParticles | p22 = data }

        23 ->
            { allParticles | p23 = data }

        24 ->
            { allParticles | p24 = data }

        25 ->
            { allParticles | p25 = data }

        26 ->
            { allParticles | p26 = data }

        27 ->
            { allParticles | p27 = data }

        28 ->
            { allParticles | p28 = data }

        29 ->
            { allParticles | p29 = data }

        30 ->
            { allParticles | p30 = data }

        31 ->
            { allParticles | p31 = data }

        32 ->
            { allParticles | p32 = data }

        33 ->
            { allParticles | p33 = data }

        34 ->
            { allParticles | p34 = data }

        35 ->
            { allParticles | p35 = data }

        36 ->
            { allParticles | p36 = data }

        37 ->
            { allParticles | p37 = data }

        38 ->
            { allParticles | p38 = data }

        39 ->
            { allParticles | p39 = data }

        40 ->
            { allParticles | p40 = data }

        41 ->
            { allParticles | p41 = data }

        42 ->
            { allParticles | p42 = data }

        43 ->
            { allParticles | p43 = data }

        44 ->
            { allParticles | p44 = data }

        45 ->
            { allParticles | p45 = data }

        46 ->
            { allParticles | p46 = data }

        47 ->
            { allParticles | p47 = data }

        48 ->
            { allParticles | p48 = data }

        49 ->
            { allParticles | p49 = data }

        50 ->
            { allParticles | p50 = data }

        51 ->
            { allParticles | p51 = data }

        52 ->
            { allParticles | p52 = data }

        53 ->
            { allParticles | p53 = data }

        54 ->
            { allParticles | p54 = data }

        55 ->
            { allParticles | p55 = data }

        56 ->
            { allParticles | p56 = data }

        57 ->
            { allParticles | p57 = data }

        58 ->
            { allParticles | p58 = data }

        59 ->
            { allParticles | p59 = data }

        60 ->
            { allParticles | p60 = data }

        61 ->
            { allParticles | p61 = data }

        62 ->
            { allParticles | p62 = data }

        63 ->
            { allParticles | p63 = data }

        64 ->
            { allParticles | p64 = data }

        65 ->
            { allParticles | p65 = data }

        66 ->
            { allParticles | p66 = data }

        67 ->
            { allParticles | p67 = data }

        68 ->
            { allParticles | p68 = data }

        69 ->
            { allParticles | p69 = data }

        70 ->
            { allParticles | p70 = data }

        71 ->
            { allParticles | p71 = data }

        72 ->
            { allParticles | p72 = data }

        73 ->
            { allParticles | p73 = data }

        74 ->
            { allParticles | p74 = data }

        75 ->
            { allParticles | p75 = data }

        76 ->
            { allParticles | p76 = data }

        77 ->
            { allParticles | p77 = data }

        78 ->
            { allParticles | p78 = data }

        79 ->
            { allParticles | p79 = data }

        80 ->
            { allParticles | p80 = data }

        81 ->
            { allParticles | p81 = data }

        82 ->
            { allParticles | p82 = data }

        83 ->
            { allParticles | p83 = data }

        84 ->
            { allParticles | p84 = data }

        85 ->
            { allParticles | p85 = data }

        86 ->
            { allParticles | p86 = data }

        87 ->
            { allParticles | p87 = data }

        88 ->
            { allParticles | p88 = data }

        89 ->
            { allParticles | p89 = data }

        90 ->
            { allParticles | p90 = data }

        91 ->
            { allParticles | p91 = data }

        92 ->
            { allParticles | p92 = data }

        93 ->
            { allParticles | p93 = data }

        94 ->
            { allParticles | p94 = data }

        95 ->
            { allParticles | p95 = data }

        96 ->
            { allParticles | p96 = data }

        97 ->
            { allParticles | p97 = data }

        98 ->
            { allParticles | p98 = data }

        99 ->
            { allParticles | p99 = data }

        100 ->
            { allParticles | p100 = data }

        101 ->
            { allParticles | p101 = data }

        102 ->
            { allParticles | p102 = data }

        103 ->
            { allParticles | p103 = data }

        104 ->
            { allParticles | p104 = data }

        105 ->
            { allParticles | p105 = data }

        106 ->
            { allParticles | p106 = data }

        107 ->
            { allParticles | p107 = data }

        108 ->
            { allParticles | p108 = data }

        109 ->
            { allParticles | p109 = data }

        110 ->
            { allParticles | p110 = data }

        111 ->
            { allParticles | p111 = data }

        112 ->
            { allParticles | p112 = data }

        113 ->
            { allParticles | p113 = data }

        114 ->
            { allParticles | p114 = data }

        115 ->
            { allParticles | p115 = data }

        116 ->
            { allParticles | p116 = data }

        117 ->
            { allParticles | p117 = data }

        118 ->
            { allParticles | p118 = data }

        119 ->
            { allParticles | p119 = data }

        120 ->
            { allParticles | p120 = data }

        121 ->
            { allParticles | p121 = data }

        122 ->
            { allParticles | p122 = data }

        123 ->
            { allParticles | p123 = data }

        124 ->
            { allParticles | p124 = data }

        125 ->
            { allParticles | p125 = data }

        126 ->
            { allParticles | p126 = data }

        127 ->
            { allParticles | p127 = data }

        _ ->
            allParticles


vertexShader : WebGL.Shader { index : Float } Particles { data : Vec4 }
vertexShader =
    [glsl|
precision mediump float;
attribute float index;
uniform float aspectRatio;
uniform vec4 p0;
uniform vec4 p1;
uniform vec4 p2;
uniform vec4 p3;
uniform vec4 p4;
uniform vec4 p5;
uniform vec4 p6;
uniform vec4 p7;
uniform vec4 p8;
uniform vec4 p9;
uniform vec4 p10;
uniform vec4 p11;
uniform vec4 p12;
uniform vec4 p13;
uniform vec4 p14;
uniform vec4 p15;
uniform vec4 p16;
uniform vec4 p17;
uniform vec4 p18;
uniform vec4 p19;
uniform vec4 p20;
uniform vec4 p21;
uniform vec4 p22;
uniform vec4 p23;
uniform vec4 p24;
uniform vec4 p25;
uniform vec4 p26;
uniform vec4 p27;
uniform vec4 p28;
uniform vec4 p29;
uniform vec4 p30;
uniform vec4 p31;
uniform vec4 p32;
uniform vec4 p33;
uniform vec4 p34;
uniform vec4 p35;
uniform vec4 p36;
uniform vec4 p37;
uniform vec4 p38;
uniform vec4 p39;
uniform vec4 p40;
uniform vec4 p41;
uniform vec4 p42;
uniform vec4 p43;
uniform vec4 p44;
uniform vec4 p45;
uniform vec4 p46;
uniform vec4 p47;
uniform vec4 p48;
uniform vec4 p49;
uniform vec4 p50;
uniform vec4 p51;
uniform vec4 p52;
uniform vec4 p53;
uniform vec4 p54;
uniform vec4 p55;
uniform vec4 p56;
uniform vec4 p57;
uniform vec4 p58;
uniform vec4 p59;
uniform vec4 p60;
uniform vec4 p61;
uniform vec4 p62;
uniform vec4 p63;
uniform vec4 p64;
uniform vec4 p65;
uniform vec4 p66;
uniform vec4 p67;
uniform vec4 p68;
uniform vec4 p69;
uniform vec4 p70;
uniform vec4 p71;
uniform vec4 p72;
uniform vec4 p73;
uniform vec4 p74;
uniform vec4 p75;
uniform vec4 p76;
uniform vec4 p77;
uniform vec4 p78;
uniform vec4 p79;
uniform vec4 p80;
uniform vec4 p81;
uniform vec4 p82;
uniform vec4 p83;
uniform vec4 p84;
uniform vec4 p85;
uniform vec4 p86;
uniform vec4 p87;
uniform vec4 p88;
uniform vec4 p89;
uniform vec4 p90;
uniform vec4 p91;
uniform vec4 p92;
uniform vec4 p93;
uniform vec4 p94;
uniform vec4 p95;
uniform vec4 p96;
uniform vec4 p97;
uniform vec4 p98;
uniform vec4 p99;
uniform vec4 p100;
uniform vec4 p101;
uniform vec4 p102;
uniform vec4 p103;
uniform vec4 p104;
uniform vec4 p105;
uniform vec4 p106;
uniform vec4 p107;
uniform vec4 p108;
uniform vec4 p109;
uniform vec4 p110;
uniform vec4 p111;
uniform vec4 p112;
uniform vec4 p113;
uniform vec4 p114;
uniform vec4 p115;
uniform vec4 p116;
uniform vec4 p117;
uniform vec4 p118;
uniform vec4 p119;
uniform vec4 p120;
uniform vec4 p121;
uniform vec4 p122;
uniform vec4 p123;
uniform vec4 p124;
uniform vec4 p125;
uniform vec4 p126;
uniform vec4 p127;
varying vec4 data;
mat4 viewport = mat4((2.0 / aspectRatio), 0, 0, 0, 0, 2, 0, 0, 0, 0, -1, 0, -1, -1, 0, 1);
void main() {
    data = vec4(0., 0., 0., 0.);
    if(index == 0.) { data = p0; };
    if(index == 1.) { data = p1; };
    if(index == 2.) { data = p2; };
    if(index == 3.) { data = p3; };
    if(index == 4.) { data = p4; };
    if(index == 5.) { data = p5; };
    if(index == 6.) { data = p6; };
    if(index == 7.) { data = p7; };
    if(index == 8.) { data = p8; };
    if(index == 9.) { data = p9; };
    if(index == 10.) { data = p10; };
    if(index == 11.) { data = p11; };
    if(index == 12.) { data = p12; };
    if(index == 13.) { data = p13; };
    if(index == 14.) { data = p14; };
    if(index == 15.) { data = p15; };
    if(index == 16.) { data = p16; };
    if(index == 17.) { data = p17; };
    if(index == 18.) { data = p18; };
    if(index == 19.) { data = p19; };
    if(index == 20.) { data = p20; };
    if(index == 21.) { data = p21; };
    if(index == 22.) { data = p22; };
    if(index == 23.) { data = p23; };
    if(index == 24.) { data = p24; };
    if(index == 25.) { data = p25; };
    if(index == 26.) { data = p26; };
    if(index == 27.) { data = p27; };
    if(index == 28.) { data = p28; };
    if(index == 29.) { data = p29; };
    if(index == 30.) { data = p30; };
    if(index == 31.) { data = p31; };
    if(index == 32.) { data = p32; };
    if(index == 33.) { data = p33; };
    if(index == 34.) { data = p34; };
    if(index == 35.) { data = p35; };
    if(index == 36.) { data = p36; };
    if(index == 37.) { data = p37; };
    if(index == 38.) { data = p38; };
    if(index == 39.) { data = p39; };
    if(index == 40.) { data = p40; };
    if(index == 41.) { data = p41; };
    if(index == 42.) { data = p42; };
    if(index == 43.) { data = p43; };
    if(index == 44.) { data = p44; };
    if(index == 45.) { data = p45; };
    if(index == 46.) { data = p46; };
    if(index == 47.) { data = p47; };
    if(index == 48.) { data = p48; };
    if(index == 49.) { data = p49; };
    if(index == 50.) { data = p50; };
    if(index == 51.) { data = p51; };
    if(index == 52.) { data = p52; };
    if(index == 53.) { data = p53; };
    if(index == 54.) { data = p54; };
    if(index == 55.) { data = p55; };
    if(index == 56.) { data = p56; };
    if(index == 57.) { data = p57; };
    if(index == 58.) { data = p58; };
    if(index == 59.) { data = p59; };
    if(index == 60.) { data = p60; };
    if(index == 61.) { data = p61; };
    if(index == 62.) { data = p62; };
    if(index == 63.) { data = p63; };
    if(index == 64.) { data = p64; };
    if(index == 65.) { data = p65; };
    if(index == 66.) { data = p66; };
    if(index == 67.) { data = p67; };
    if(index == 68.) { data = p68; };
    if(index == 69.) { data = p69; };
    if(index == 70.) { data = p70; };
    if(index == 71.) { data = p71; };
    if(index == 72.) { data = p72; };
    if(index == 73.) { data = p73; };
    if(index == 74.) { data = p74; };
    if(index == 75.) { data = p75; };
    if(index == 76.) { data = p76; };
    if(index == 77.) { data = p77; };
    if(index == 78.) { data = p78; };
    if(index == 79.) { data = p79; };
    if(index == 80.) { data = p80; };
    if(index == 81.) { data = p81; };
    if(index == 82.) { data = p82; };
    if(index == 83.) { data = p83; };
    if(index == 84.) { data = p84; };
    if(index == 85.) { data = p85; };
    if(index == 86.) { data = p86; };
    if(index == 87.) { data = p87; };
    if(index == 88.) { data = p88; };
    if(index == 89.) { data = p89; };
    if(index == 90.) { data = p90; };
    if(index == 91.) { data = p91; };
    if(index == 92.) { data = p92; };
    if(index == 93.) { data = p93; };
    if(index == 94.) { data = p94; };
    if(index == 95.) { data = p95; };
    if(index == 96.) { data = p96; };
    if(index == 97.) { data = p97; };
    if(index == 98.) { data = p98; };
    if(index == 99.) { data = p99; };
    if(index == 100.) { data = p100; };
    if(index == 101.) { data = p101; };
    if(index == 102.) { data = p102; };
    if(index == 103.) { data = p103; };
    if(index == 104.) { data = p104; };
    if(index == 105.) { data = p105; };
    if(index == 106.) { data = p106; };
    if(index == 107.) { data = p107; };
    if(index == 108.) { data = p108; };
    if(index == 109.) { data = p109; };
    if(index == 110.) { data = p110; };
    if(index == 111.) { data = p111; };
    if(index == 112.) { data = p112; };
    if(index == 113.) { data = p113; };
    if(index == 114.) { data = p114; };
    if(index == 115.) { data = p115; };
    if(index == 116.) { data = p116; };
    if(index == 117.) { data = p117; };
    if(index == 118.) { data = p118; };
    if(index == 119.) { data = p119; };
    if(index == 120.) { data = p120; };
    if(index == 121.) { data = p121; };
    if(index == 122.) { data = p122; };
    if(index == 123.) { data = p123; };
    if(index == 124.) { data = p124; };
    if(index == 125.) { data = p125; };
    if(index == 126.) { data = p126; };
    if(index == 127.) { data = p127; };
    gl_Position = viewport * vec4(data.xy, 0, 1.0);
    gl_PointSize = data.z;
}
    |]
