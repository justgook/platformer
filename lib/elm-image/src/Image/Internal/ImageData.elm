module Image.Internal.ImageData exposing
    ( Image(..)
    , Order(..)
    , PixelFormat(..)
    , defaultOptions
    , options
    , setOptions
    , toArray
    , toArray2d
    , toList
    , toList2d
    , width_
    )

import Array exposing (Array)
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as D exposing (Decoder, Step(..))
import Image.Internal.Array2D as Array2D


type Image
    = List Options Int (List Int)
    | List2d Options (List (List Int))
    | Array Options Int (Array Int)
    | Array2d Options (Array (Array Int))
    | Bytes Options (Decoder Image) Bytes


type alias Options =
    { format : PixelFormat
    , defaultColor : Int
    , order : Order
    }


type PixelFormat
    = RGBA
    | RGB
    | LUMINANCE_ALPHA
    | ALPHA


{-| Pixel render order in image
-}
type Order
    = RightDown
    | RightUp
    | LeftDown
    | LeftUp


{-| -}
defaultOptions : Options
defaultOptions =
    { format = RGBA
    , defaultColor = 0xFFFFFFFF
    , order = RightDown
    }


options : Image -> Options
options image =
    case image of
        List opt _ _ ->
            opt

        List2d opt _ ->
            opt

        Array opt _ _ ->
            opt

        Array2d opt _ ->
            opt

        Bytes opt _ _ ->
            opt


setOptions : Options -> Image -> Image
setOptions opt image =
    case image of
        List _ a b ->
            List opt a b

        List2d _ a ->
            List2d opt a

        Array _ a b ->
            Array opt a b

        Array2d _ a ->
            Array2d opt a

        Bytes _ a b ->
            Bytes opt a b


toList : Image -> List Int
toList info =
    case info of
        List _ _ l ->
            l

        List2d _ l ->
            List.concat l

        Array _ _ arr ->
            Array.toList arr

        Array2d _ arr ->
            Array.foldr (\line acc1 -> Array.foldr (\px acc2 -> px :: acc2) acc1 line) [] arr

        Bytes _ d b ->
            case D.decode d b of
                Just (Bytes _ _ _) ->
                    []

                Just newData ->
                    toList newData

                Nothing ->
                    []


toList2d : Image -> List (List Int)
toList2d info =
    case info of
        List _ w l ->
            greedyGroupsOf w l

        List2d _ l ->
            l

        Array _ w arr ->
            Array.toList arr |> greedyGroupsOf w

        Array2d _ arr ->
            Array.foldr
                (\line acc1 ->
                    Array.foldr (\px acc2 -> px :: acc2) [] line
                        |> (\l -> l :: acc1)
                )
                []
                arr

        Bytes _ d b ->
            case D.decode d b of
                Just (Bytes _ _ _) ->
                    []

                Just newData ->
                    toList2d newData

                Nothing ->
                    []


toArray : Image -> Array Int
toArray image =
    case image of
        List _ _ l ->
            Array.fromList l

        List2d _ l ->
            List.foldl (Array.fromList >> Array.append) Array.empty l

        Array _ _ arr ->
            arr

        Array2d _ arr ->
            Array.foldl Array.append Array.empty arr

        Bytes _ d b ->
            case D.decode d b of
                Just (Bytes _ _ _) ->
                    Array.empty

                Just newData ->
                    toArray newData

                Nothing ->
                    Array.empty


toArray2d : Image -> Array (Array Int)
toArray2d image =
    let
        fromList w l acc =
            case l of
                a :: rest ->
                    let
                        newAcc =
                            applyIf (Array2D.lastLength acc >= w) (Array.push Array.empty) acc
                    in
                    fromList w rest (Array2D.push a newAcc)

                [] ->
                    acc

        fromArray : Int -> Array a -> Array (Array a) -> Array (Array a)
        fromArray w arr acc =
            if Array.length arr > w then
                let
                    ( a1, a2 ) =
                        splitAt w arr
                in
                fromArray w a2 (Array.push a1 acc)

            else
                Array.push arr acc
    in
    case image of
        List _ w l ->
            fromList w l (Array.fromList [ Array.empty ])

        List2d _ l ->
            List.foldl (Array.fromList >> Array.push) Array.empty l

        Array _ w arr ->
            fromArray w arr Array.empty

        Array2d _ arr ->
            arr

        Bytes _ d b ->
            case D.decode d b of
                Just (Bytes _ _ _) ->
                    Array.empty

                Just newData ->
                    toArray2d newData

                Nothing ->
                    Array.empty


width_ : Image -> Int
width_ info =
    case info of
        Bytes _ _ _ ->
            0

        Array2d _ arr ->
            Array.get 0 arr |> Maybe.map Array.length |> Maybe.withDefault 0

        _ ->
            0


applyIf : Bool -> (a -> a) -> a -> a
applyIf bool f a =
    if bool then
        f a

    else
        a


splitAt : Int -> Array a -> ( Array a, Array a )
splitAt index xs =
    let
        len =
            Array.length xs
    in
    case ( index > 0, index < len ) of
        ( True, True ) ->
            ( Array.slice 0 index xs, Array.slice index len xs )

        ( True, False ) ->
            ( xs, Array.empty )

        ( False, True ) ->
            ( Array.empty, xs )

        ( False, False ) ->
            ( Array.empty, Array.empty )


greedyGroupsOf : Int -> List a -> List (List a)
greedyGroupsOf size xs =
    greedyGroupsOfWithStep size size xs


greedyGroupsOfWithStep : Int -> Int -> List a -> List (List a)
greedyGroupsOfWithStep size step xs =
    let
        xs_ =
            List.drop step xs

        okayArgs =
            size > 0 && step > 0

        okayXs =
            List.length xs > 0
    in
    if okayArgs && okayXs then
        List.take size xs :: greedyGroupsOfWithStep size step xs_

    else
        []
