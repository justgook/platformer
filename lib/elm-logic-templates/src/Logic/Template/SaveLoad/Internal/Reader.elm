module Logic.Template.SaveLoad.Internal.Reader exposing
    ( GetTileset
    , Read(..)
    , Reader
    , ReaderTask
    , combine
    , defaultRead
    , getLevel
    , getTexture
    , getTileset
    , tileArgs
    , tileDataWith
    )

import Dict
import Logic.Entity exposing (EntityID)
import Logic.Launcher exposing (Error(..))
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask exposing (CacheTask, ResourceTask, getJson)
import Task
import Tiled exposing (GidInfo)
import Tiled.Layer
import Tiled.Level
import Tiled.Object exposing (Common, CommonDimension, CommonDimensionGid, CommonDimensionPolyPoints, Dimension, Gid, PolyPoints)
import Tiled.Properties
import Tiled.Tileset exposing (Tileset)
import WebGL.Texture exposing (linear, nonPowerOfTwoOptions)


type alias Reader world =
    { objectTile : Read world TileArg
    , objectPoint : Read world (Common {})
    , objectRectangle : Read world CommonDimension
    , objectEllipse : Read world CommonDimension
    , objectPolygon : Read world CommonDimensionPolyPoints
    , objectPolyLine : Read world CommonDimensionPolyPoints
    , layerTile : Read world TileDataWith
    , layerImage : Read world Tiled.Layer.ImageData
    , level : Read world Tiled.Level.Level
    }


type Response
    = Texture WebGL.Texture.Texture
    | Tileset Tiled.Tileset.Tileset
    | Level Tiled.Level.Level


type alias ReaderTask a =
    CacheTask Response -> ResourceTask a Response


type alias GetTileset =
    Int -> ReaderTask Tileset


type alias ReturnSync world =
    ( EntityID, world ) -> ( EntityID, world )


type alias ReturnAsync world =
    ReaderTask (( EntityID, world ) -> ( EntityID, world ))


type Read world a
    = Sync (a -> ReturnSync world)
    | Async (a -> ReturnAsync world)
    | None


defaultRead : Reader world
defaultRead =
    { objectTile = None
    , objectPoint = None
    , objectRectangle = None
    , objectEllipse = None
    , objectPolygon = None
    , objectPolyLine = None
    , layerTile = None
    , layerImage = None
    , level = None
    }


type alias TileArg =
    { fd : Bool
    , fh : Bool
    , fv : Bool
    , getTilesetByGid : GetTileset
    , gid : Int
    , height : Float
    , id : Int
    , kind : String
    , name : String
    , properties : Tiled.Properties.Properties
    , rotation : Float
    , visible : Bool
    , width : Float
    , x : Float
    , y : Float
    }


type alias TileDataWith =
    { getTilesetByGid : GetTileset
    , id : Int
    , data : List Int
    , name : String
    , opacity : Float
    , visible : Bool
    , width : Int
    , height : Int
    , x : Float
    , y : Float
    , properties : Tiled.Properties.Properties
    }


tileDataWith : GetTileset -> Tiled.Layer.TileData -> TileDataWith
tileDataWith getTilesetByGid tileData =
    { getTilesetByGid = getTilesetByGid
    , id = tileData.id
    , data = tileData.data
    , name = tileData.name
    , opacity = tileData.opacity
    , visible = tileData.visible
    , width = tileData.width
    , height = tileData.height
    , x = tileData.x
    , y = tileData.y
    , properties = tileData.properties
    }


tileArgs : CommonDimensionGid -> GidInfo -> GetTileset -> TileArg
tileArgs a c d =
    { id = a.id
    , name = a.name
    , kind = a.kind
    , visible = a.visible
    , x = a.x
    , y = a.y
    , rotation = a.rotation
    , properties = a.properties
    , width = a.width
    , height = a.height
    , getTilesetByGid = d
    , gid = c.gid
    , fh = c.fh
    , fv = c.fv
    , fd = c.fd
    }


combine :
    (reader -> Read world a)
    -> a
    -> List reader
    -> ( EntityID, world )
    -> CacheTask Response
    -> ResourceTask ( EntityID, world ) Response
combine getKey arg readers acc =
    case readers of
        item :: rest ->
            case getKey item of
                None ->
                    combine getKey arg rest acc

                Sync f ->
                    combine getKey arg rest (f arg acc)

                Async f ->
                    f arg >> ResourceTask.andThen (\f1 -> combine getKey arg rest (f1 acc))

        [] ->
            ResourceTask.succeed acc


getTileset : String -> Int -> CacheTask Response -> ResourceTask Tiled.Tileset.Tileset Response
getTileset url firstgid =
    Task.andThen
        (\d ->
            case Dict.get url d.dict of
                Just (Tileset r) ->
                    Task.succeed ( r, d )

                _ ->
                    getJson (d.url ++ url) (Tiled.Tileset.decodeFile firstgid) |> Task.map (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) ->
                ( resp, { d | dict = Dict.insert url (Tileset resp) d.dict } )
            )


getTexture : String -> CacheTask Response -> ResourceTask WebGL.Texture.Texture Response
getTexture url =
    Task.andThen
        (\d ->
            case Dict.get url d.dict of
                Just (Texture r) ->
                    Task.succeed ( r, d )

                _ ->
                    (if String.startsWith "data:image" url then
                        url

                     else
                        d.url ++ url
                    )
                        |> WebGL.Texture.loadWith textureOption
                        |> Task.mapError (textureError url)
                        |> Task.map (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) ->
                ( resp, { d | dict = Dict.insert url (Texture resp) d.dict } )
            )


textureOption : WebGL.Texture.Options
textureOption =
    { nonPowerOfTwoOptions
        | magnify = linear
        , minify = linear
    }


textureError : String -> WebGL.Texture.Error -> Error
textureError url e =
    case e of
        WebGL.Texture.LoadError ->
            Error 4005 ("Texture.LoadError: " ++ url)

        WebGL.Texture.SizeError a b ->
            Error 4006 ("Texture.SizeError: " ++ url)


getLevel : String -> CacheTask Response -> ResourceTask Tiled.Level.Level Response
getLevel url =
    Task.andThen
        (\d ->
            case Dict.get url d.dict of
                Just (Level r) ->
                    Task.succeed ( r, d )

                _ ->
                    getJson url Tiled.Level.decode |> Task.map (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) ->
                let
                    relUrl =
                        String.split "/" url
                            |> List.reverse
                            |> List.drop 1
                            |> (::) ""
                            |> List.reverse
                            |> String.join "/"
                in
                ( resp, { d | url = relUrl, dict = Dict.insert url (Level resp) d.dict } )
            )
