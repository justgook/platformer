module Logic.Template.SaveLoad.Internal.TexturesManager exposing
    ( BytesManager
    , DecoderWithTexture
    , GetTexture
    , Manager
    , Selector(..)
    , WorldDecoder
    , decoder
    , empty
    , encoder
    , get
    , loadTask
    , read
    , setLut
    , withTexture
    )

import Base64
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component.Singleton as Singleton exposing (Spec)
import Logic.Launcher exposing (Error(..))
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Loader as Loader
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask exposing (ResourceTask)
import Logic.Template.SaveLoad.Internal.Util as Util
import Tiled.Tileset as Tileset exposing (Tileset)
import WebGL.Texture as WebGL exposing (Texture)


type alias Manager a =
    List (Item a)


type Item a
    = Atlas_ { firstgid : Int, tilecount : Int, image : a }
    | Image_ { id : Int, image : a }
    | Lut_ { id : Int, w : Int, h : Int, image : a }


type Selector
    = Atlas
    | Image
    | Lut


type alias WorldDecoder world =
    Decoder (world -> world)


type alias DecoderWithTexture world =
    GetTexture -> Decoder (world -> world)


withTexture : GetTexture -> DecoderWithTexture world -> WorldDecoder world
withTexture getTexture decoder_ =
    decoder_ getTexture


type alias GetTexture =
    Selector -> Int -> Maybe WebGL.Texture


type alias BytesManager =
    Manager Bytes


type alias TextureManager =
    Manager Texture


setLut : Int -> Int -> Int -> a -> Manager a -> Manager a
setLut id w h image manager =
    Lut_
        { id = id
        , image = image
        , w = w
        , h = h
        }
        :: manager


get : Manager a -> Selector -> Int -> Maybe a
get m selector id_ =
    m
        |> find
            (\a_ ->
                case a_ of
                    Atlas_ a ->
                        if (selector == Atlas) && (a.firstgid <= id_) && (a.firstgid + a.tilecount > id_) then
                            Just a.image

                        else
                            Nothing

                    Image_ a ->
                        if (selector == Image) && (a.id == id_) then
                            Just a.image

                        else
                            Nothing

                    Lut_ a ->
                        if (selector == Lut) && (a.id == id_) then
                            Just a.image

                        else
                            Nothing
            )


empty : Manager a
empty =
    []


merge : Manager a -> Manager a -> Manager a
merge =
    (++)


encoder : BytesManager -> Encoder
encoder textures =
    let
        bytesEndode image =
            E.sequence
                [ E.unsignedInt32 BE (Bytes.width image)
                , E.bytes image
                ]

        itemEncoder item_ =
            case item_ of
                Atlas_ { firstgid, tilecount, image } ->
                    E.sequence
                        [ E.signedInt8 0
                        , E.id firstgid
                        , E.id tilecount
                        , bytesEndode image
                        ]

                Image_ { id, image } ->
                    E.sequence
                        [ E.signedInt8 1
                        , E.id id
                        , bytesEndode image
                        ]

                Lut_ { id, image, w, h } ->
                    E.sequence
                        [ E.signedInt8 2
                        , E.id id
                        , E.id w
                        , E.id h
                        , bytesEndode image
                        ]
    in
    textures
        |> E.list itemEncoder


decoder : Decoder BytesManager
decoder =
    let
        imageDecode =
            D.unsignedInt32 BE
                |> D.andThen D.bytes

        itemDecoder =
            D.signedInt8
                |> D.andThen
                    (\item_ ->
                        case item_ of
                            0 ->
                                D.map3
                                    (\firstgid tilecount image -> Atlas_ { firstgid = firstgid, tilecount = tilecount, image = image })
                                    D.id
                                    D.id
                                    imageDecode

                            1 ->
                                D.map2
                                    (\id image -> Image_ { id = id, image = image })
                                    D.id
                                    imageDecode

                            2 ->
                                D.map4
                                    (\id w h image ->
                                        Lut_
                                            { id = id
                                            , w = w
                                            , h = h
                                            , image = image
                                            }
                                    )
                                    D.id
                                    D.id
                                    D.id
                                    imageDecode

                            _ ->
                                D.fail
                    )
    in
    D.list itemDecoder


urlFromBytes : Bytes -> String
urlFromBytes bytes =
    Base64.fromBytes bytes
        |> Maybe.map ((++) "data:image/png;base64,")
        |> Maybe.withDefault ""


loadTask : BytesManager -> Loader.TaskBytes TextureManager
loadTask bytes =
    bytes
        |> List.map
            (\item_ ->
                case item_ of
                    Atlas_ item ->
                        Loader.getTexture (urlFromBytes item.image)
                            >> ResourceTask.map
                                (\image ->
                                    Atlas_
                                        { firstgid = item.firstgid
                                        , tilecount = item.tilecount
                                        , image = image
                                        }
                                )

                    Image_ item ->
                        Loader.getTexture (urlFromBytes item.image)
                            >> ResourceTask.map
                                (\image ->
                                    Image_
                                        { id = item.id
                                        , image = image
                                        }
                                )

                    Lut_ item ->
                        Loader.getLut item.id item.image
                            >> ResourceTask.map
                                (\image ->
                                    Lut_
                                        { id = item.id
                                        , w = item.w
                                        , h = item.h
                                        , image = image
                                        }
                                )
            )
        |> ResourceTask.sequence


read : Reader BytesManager
read =
    let
        spec_ =
            { get = identity
            , set = \c _ -> c
            }
    in
    { defaultRead
        | level =
            Async
                (\level ->
                    tilesetReader spec_ identity (Util.tilesets level)
                )
        , layerImage =
            Async
                (\image ->
                    imagesReader spec_ identity image
                )
    }


imagesReader mapper acc info =
    Loader.getBytesTiled info.image
        >> ResourceTask.map
            (\image ->
                let
                    newAcc =
                        acc >> (::) (Image_ { id = info.id, image = image })
                in
                Tuple.mapSecond (Singleton.update mapper newAcc)
            )


tilesetReader mapper acc l =
    case l of
        (Tileset.Source { source, firstgid }) :: rest ->
            Loader.getTileset source firstgid
                >> ResourceTask.andThen
                    (\tileset ->
                        case tileset of
                            Tileset.Source info ->
                                if info.source == source then
                                    ResourceTask.fail (Error 7001 "Downloading Tileset Source, and got back Source - Infinity recursion")

                                else
                                    tilesetReader mapper acc (tileset :: rest)

                            Tileset.Embedded _ ->
                                tilesetReader mapper acc (tileset :: rest)

                            Tileset.ImageCollection _ ->
                                ResourceTask.fail (Error 7102 "Tileset.ImageCollection not yet supported")
                    )

        (Tileset.Embedded info) :: rest ->
            Loader.getBytesTiled info.image
                >> ResourceTask.andThen
                    (\image ->
                        tilesetReader mapper
                            (acc
                                >> (\all ->
                                        let
                                            newItem =
                                                Atlas_
                                                    { firstgid = info.firstgid
                                                    , image = image
                                                    , tilecount = info.tilecount
                                                    }
                                        in
                                        newItem :: all
                                   )
                            )
                            rest
                    )

        (Tileset.ImageCollection _) :: _ ->
            ResourceTask.fail (Error 7003 "Tileset.ImageCollection not yet supported")

        [] ->
            ResourceTask.succeed (Tuple.mapSecond (Singleton.update mapper acc))


{-| Find the first element that satisfies a predicate and return
Just that element. If none match, return Nothing.
find (\\num -> num > 5) [ 2, 4, 6, 8 ]
--> Just 6
-}
find : (a -> Maybe b) -> List a -> Maybe b
find predicate list =
    case list of
        [] ->
            Nothing

        first :: rest ->
            case predicate first of
                Nothing ->
                    find predicate rest

                Just a ->
                    Just a
