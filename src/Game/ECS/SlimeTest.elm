module Game.ECS.SlimeTest exposing (..)

import Game.ECS.Component exposing (Dimension(Rectangle))
import Game.ECS.Entity as Entity
import Game.ECS.Message exposing (Message)
import Game.ECS.Subscriptions exposing (subscriptions)
import Game.ECS.Update exposing (update)
import Game.ECS.World as World exposing (World, world)
import Html exposing (div, text)
import Html.Attributes exposing (style)
import Slime
import Slime.Engine


render : { a | world : World } -> Html.Html msg
render ({ world } as model) =
    let
        result =
            (Slime.entities2 World.positions World.dimensions).getter world
    in
    result
        |> List.map
            (\{ a, b } ->
                let
                    (Rectangle { width, height }) =
                        b
                in
                div
                    [ style
                        [ ( "background", "blue" )
                        , ( "width", toString width ++ "px" )
                        , ( "height", toString height ++ "px" )
                        , ( "position", "absolute" )
                        , ( "left", toString a.x ++ "px" )
                        , ( "bottom", toString a.y ++ "px" )
                        ]
                    ]
                    []
            )
        |> div
            [ style
                [ ( "width", "100%" )
                , ( "height", "100%" )
                , ( "background", "red" )
                ]
            ]


main : Program Never { world : World } (Slime.Engine.Message Message)
main =
    Html.program
        { init = model ! []
        , subscriptions = subscriptions >> Slime.Engine.engineSubs
        , update = update
        , view = render
        }


model : { world : World }
model =
    { world =
        world
            |> Entity.spawnWall { x = 10, y = 0 } (Rectangle { width = 500, height = 15.0 })
            |> Entity.spawnPlayer { x = 50, y = 80 } (Rectangle { width = 10, height = 10 })
    }
