module Game.Update exposing (update)

import Game.Logic.Update as Logic
import Game.Message as Message exposing (Message)
import Game.Model as Model exposing (LoaderData(..), Model)
import Game.TextureLoader as Texture


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case ( msg, model.renderData ) of
        ( Message.Logic msg, Success ({ world } as renderData) ) ->
            Logic.update msg world
                |> Tuple.mapFirst (\world_ -> { model | renderData = Success { renderData | world = world_ } })
                |> Tuple.mapSecond (Cmd.map Message.Logic)

        ( Message.Logic msg, _ ) ->
            ( model, Cmd.none )

        ( Message.LevelLoaded (Ok { layersData, commands, properties, collisionMap }), _ ) ->
            { model
                | renderData =
                    Loading
                        { data = layersData
                        , textures = Texture.init
                        , properties = properties
                        , collisionMap = collisionMap
                        }
            }
                ! (commands |> List.map (uncurry Texture.load >> Cmd.map Message.Texture))

        ( Message.LevelLoaded (Err data), _ ) ->
            let
                _ =
                    Debug.log "Message.LoadMetadata ERROR" data
            in
            ( model, Cmd.none )

        ( Message.Texture m, Loading data ) ->
            let
                textures =
                    Texture.update m data.textures
            in
            ( { model
                | renderData = Model.loadingToSuccess { data | textures = textures }
              }
            , Cmd.none
            )

        ( Message.Texture m, _ ) ->
            let
                _ =
                    Debug.log "Texture Loaded after game start" m
            in
            ( model, Cmd.none )
