module Logic.Template.Game.Presentation.Content2 exposing (Content, all, dimension, space, startPoint)

import Html exposing (..)
import Html.Attributes exposing (alt, attribute, class, height, href, src, style, target)
import Logic.Template.Game.Presentation.Slide as Slide exposing (Slide)


type alias Content msg =
    List (Html msg)


dimension =
    { x = 750, y = 345 }


startPoint =
    { x = 350, y = 180 }


space =
    700


slidePos i =
    { startPoint | x = startPoint.x + (dimension.x + space) * i }


all : List (Slide.Slide a msg)
all =
    [ intro
    , technologies
    , tiled
    , entityComponentSystem
    , webGL
    , tea
    , tileLayer
    , spaceShader
    , soundComponent
    , animationComponent
    , decodeKeyboard
    , virtualGamepad
    , collision
    , bullets
    , libraries
    , bytes
    , production
    , whatNext
    , epilogue
    ]
        |> List.indexedMap (\i -> Slide.slide (slidePos (toFloat i)) dimension)


epilogue : Content msg
epilogue =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "Epilogue" ]
        ]
    ]


whatNext : Content msg
whatNext =
    [ section []
        [ h1 [] [ text "What Next" ]
        , ul []
            [ li [] [ text "Isometric render" ]
            , li [] [ text "3D render" ]
            , li [] [ text "Multiplayer (ports - WS / WebRTC)" ]
            ]
        ]
    ]


production : Content msg
production =
    [ section []
        [ h1 [] [ text "Production" ]
        , ul [ style "font-size" "1.75em" ]
            [ li [] [ text "elm make --optimize" ]
            , li [] [ text "jscodeshift - concatenate glsl" ]
            , li [] [ text "uglifyjs" ]
            , li [] [ text "prepack" ]
            , li [] [ text "terser - uglifyjs for ES6+" ]
            , li [] [ text "posthtml" ]
            , li [] [ text "audiosprite" ]
            , li [] [ text "node build-assets.js" ]
            ]
        ]
    ]


bytes : Content msg
bytes =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "Bytes" ]
        , bytesCodeBock
        ]
    ]


libraries : Content msg
libraries =
    [ section []
        [ h1 [] [ text "Libraries" ]
        , ul []
            [ li [] [ text "Tiled Json Encode & Decode" ]
            , li [] [ text "Game Logic ECS" ]
            , li [] [ text "Image BMP Encode" ]
            , li [] [ text "Collision" ]
            ]
        ]
    ]


bullets : Content msg
bullets =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "Bullets" ]
        , img
            [ src "/2019/bullets.gif"
            , style "display" "block"
            , style "margin" "0 auto"
            , style "height" "100%"
            ]
            []
        ]
    ]


collision : Content msg
collision =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "Collision" ]
        , img
            [ src "/2019/collision.png"
            , style "display" "block"
            , style "margin" "0 auto"
            , style "height" "100%"
            ]
            []
        ]
    ]


virtualGamepad : Content msg
virtualGamepad =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "Virtual Gamepad" ]
        , img
            [ src "/2019/virtual.gif"
            , style "display" "block"
            , style "margin" "0 auto"
            , style "height" "100%"
            ]
            []

        --
        ]
    ]


decodeKeyboard : Content msg
decodeKeyboard =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "Decode.fail Keyboard" ]
        , keyboardCode
        ]
    ]


animationComponent : Content msg
animationComponent =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "Animation Component" ]
        ]
    ]


soundComponent : Content msg
soundComponent =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "Sound & virtual-DOM" ]
        , img
            [ src "/2019/sound.gif"
            , style "display" "block"
            , style "margin" "auto auto"
            , style "height" "70%"
            ]
            []
        ]
    ]


spaceShader : Content msg
spaceShader =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "Space" ]
        , img
            [ src "/2019/space.gif"
            , style "display" "block"
            , style "margin" "auto auto"
            , style "height" "70%"
            ]
            []
        ]
    ]


tileLayer : Content msg
tileLayer =
    [ section []
        [ h1 [] [ text "Tile Layer" ]
        , div [ style "display" "flex", style "padding-top" "1em" ]
            [ img
                [ src "/2019/spelunky0.png"
                , style "display" "block"
                , style "margin" "auto auto"
                , style "height" "70%"
                ]
                []
            , img
                [ src "/2019/spelunky-tiles.png"
                , style "display" "block"
                , style "margin" "auto auto"
                , style "height" "70%"
                ]
                []
            ]
        ]
    ]


tea : Content msg
tea =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "The Elm Architecture" ]
        , teaCode
        ]
    ]


webGL : Content msg
webGL =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "WebGL" ]
        , img
            [ src "/2019/pipeline.png"
            , style "display" "block"
            , style "margin" "0 auto"
            , style "height" "100%"
            ]
            []
        ]
    ]


entityComponentSystem : Content msg
entityComponentSystem =
    [ section []
        [ h1 [] [ text "Entity Component System" ]
        , ul []
            [ li [] [ text "Entity is a lie" ]
            , li [] [ text "System Scope" ]
            , li [] [ text "Reusable Components" ]
            ]
        ]
    ]


tiled : Content msg
tiled =
    [ section [ class "aligncenter" ]
        [ h1 [] [ text "Tiled" ]
        , img
            [ src "/2019/tiled.png"
            , style "display" "block"
            , style "margin" "0 auto"
            , style "height" "100%"
            ]
            []
        ]
    ]


technologies : Content msg
technologies =
    let
        u t =
            span [ style "text-decoration" "underline" ] [ text t ]
    in
    [ section []
        [ h1 [] [ text "Technologies" ]
        , ul []
            [ li [] [ text "Level Editor - JSON, XML, ", u "Tiled" ]
            , li [] [ text "Game logic - ", u "ECS", text ", Scene tree, Entities" ]
            , li [] [ text "Render - HTML, SVG, Canvas, ", u "WebGL" ]
            ]
        ]
    ]


intro : Content msg
intro =
    [ section []
        [ h1 [ style "font-size" "4em" ] [ text "Is performance enough in Elm to create full fledged video games" ]
        , ul
            [ class "bg-light description"
            , style "text-align" "left"
            , style "position" "absolute"
            , style "bottom" "0"
            , style "list-style" "none"
            ]
            [ li []
                [ span [ class "text-label" ]
                    [ text "" ]
                , text "Romāns Potašovs"
                ]
            , li []
                [ span [ class "text-label" ]
                    [ text "GitHub: " ]
                , a [ target "_blank", href "https://github.com/justgook/" ]
                    [ text "@justgook" ]
                ]
            , li []
                [ span [ class "text-label" ]
                    [ text "Twitter: " ]
                , a [ target "_blank", href "https://twitter.com/justgook" ]
                    [ text "@justgook" ]
                ]
            ]
        ]
    ]


bytesCodeBock =
    pre [ class "elmsh" ]
        [ code [ class "elmsh" ]
            [ br []
                []
            , span [ class "elmsh5 elmsh-elm-f" ]
                [ text "read" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ":" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "Logic.Component.Spec" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "Position" ]
            , text " world "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "Reader" ]
            , text " world"
            , br []
                []
            , span [ class "elmsh5 elmsh-elm-f" ]
                [ text "read" ]
            , text " spec "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "=" ]
            , br []
                []
            , text "   "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "{" ]
            , text " defaultRead"
            , br []
                []
            , text "       "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "|" ]
            , text " objectTile "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "=" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Sync" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(\\" ]
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "{" ]
            , text " x"
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "," ]
            , text " y "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "}" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Entity" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "with "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(" ]
            , text " spec"
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "," ]
            , text " vec2 x y "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "))" ]
            , br []
                []
            , text "   "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "}" ]
            , br []
                []
            , br []
                []
            , br []
                []
            , span [ class "elmsh5 elmsh-elm-f" ]
                [ text "encode" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ":" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "Spec" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "Position" ]
            , text " world "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " world "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "Encoder" ]
            , br []
                []
            , span [ class "elmsh5 elmsh-elm-f" ]
                [ text "encode" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "{" ]
            , text " get "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "}" ]
            , text " world "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "=" ]
            , br []
                []
            , text "   "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Entity" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "toList "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(" ]
            , text "get world"
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ")" ]
            , br []
                []
            , text "       "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "|>" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "E" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "list "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(\\(" ]
            , text " id"
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "," ]
            , text " item "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ")" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "E" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "sequence "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "[" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "E" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "id id"
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "," ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "E" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "xy item "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "]" ]
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ")" ]
            , br []
                []
            , br []
                []
            , br []
                []
            , span [ class "elmsh5 elmsh-elm-f" ]
                [ text "decode" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ":" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "Spec" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "Position" ]
            , text " world "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "WorldDecoder" ]
            , text " world"
            , br []
                []
            , span [ class "elmsh5 elmsh-elm-f" ]
                [ text "decode" ]
            , text " spec "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "=" ]
            , br []
                []
            , text "   "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "D" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "list "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(" ]
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "D" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "map2 "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Tuple" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "pair "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "D" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "id "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "D" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "xy"
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ")" ]
            , br []
                []
            , text "       "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "|>" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "D" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "map "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(\\" ]
            , text "list "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " spec"
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "set "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(" ]
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Entity" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "fromList list"
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "))" ]
            , br []
                []
            ]
        ]


keyboardCode =
    pre [ class "elmsh", style "font-size" "1.75em" ]
        [ code [ class "elmsh" ]
            [ span [ class "elmsh5 elmsh-elm-f" ]
                [ text "isKeyRegistered" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ":" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "Set" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "String" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "String" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "Decoder" ]
            , text " "
            , span [ class "elmsh4 elmsh-elm-ts" ]
                [ text "String" ]
            , br []
                []
            , span [ class "elmsh5 elmsh-elm-f" ]
                [ text "isKeyRegistered" ]
            , text " allowed key "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "=" ]
            , br []
                []
            , text "   "
            , span [ class "elmsh3 elmsh-elm-k" ]
                [ text "if" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Set" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "member key allowed "
            , span [ class "elmsh3 elmsh-elm-k" ]
                [ text "then" ]
            , br []
                []
            , text "       "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Decode" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "succeed key"
            , br []
                []
            , br []
                []
            , text "   "
            , span [ class "elmsh3 elmsh-elm-k" ]
                [ text "else" ]
            , br []
                []
            , text "       "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Decode" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , text "fail "
            , span [ class "elmsh2 elmsh-elm-s" ]
                [ text "\"key is ignored\"" ]
            ]
        ]


teaCode =
    pre [ style "font-size" "1.5em", class "elmsh" ]
        [ code [ class "elmsh" ]
            [ span [ class "elmsh3 elmsh-elm-k" ]
                [ text "type" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-k" ]
                [ text "alias" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Document" ]
            , text " flags world "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "=" ]
            , br []
                []
            , text "   "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "{" ]
            , text " init "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ":" ]
            , text " flags "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Task" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Task" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Error" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(" ]
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "World" ]
            , text " world"
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ")" ]
            , br []
                []
            , text "   "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "," ]
            , text " subscriptions "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ":" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "World" ]
            , text " world "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Sub" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(" ]
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "World" ]
            , text " world"
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ")" ]
            , br []
                []
            , text "   "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "," ]
            , text " update "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ":" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "World" ]
            , text " world "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "World" ]
            , text " world"
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "," ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Cmd" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(" ]
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Message" ]
            , text " world"
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ")" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ")" ]
            , br []
                []
            , text "   "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "," ]
            , text " view "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text ":" ]
            , br []
                []
            , text "       "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "World" ]
            , text " world"
            , br []
                []
            , text "       "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "List" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(" ]
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "VirtualDom" ]
            , span [ class "elmsh1 elmsh-elm-n" ]
                [ text "." ]
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "Node" ]
            , text " "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "(" ]
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "World" ]
            , text " world "
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "->" ]
            , text " "
            , span [ class "elmsh6 elmsh-elm-c" ]
                [ text "World" ]
            , text " world"
            , span [ class "elmsh3 elmsh-elm-bs" ]
                [ text "))" ]
            , br []
                []
            , text "   "
            , span [ class "elmsh4 elmsh-elm-gs" ]
                [ text "}" ]
            ]
        ]
