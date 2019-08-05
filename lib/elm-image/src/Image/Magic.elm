module Image.Magic exposing (mirror)

{-|

@docs mirror

-}

import Image.Internal.ImageData as ImageData exposing (Image, Order(..))


{-| -}
mirror : Bool -> Bool -> Image -> Image
mirror horizontally vertically image =
    let
        opt =
            ImageData.options image

        order =
            opt.order
                |> applyIf horizontally flipHorizontally
                |> applyIf vertically flipVertically
    in
    ImageData.setOptions { opt | order = order } image


flipHorizontally : Order -> Order
flipHorizontally a =
    case a of
        RightDown ->
            LeftDown

        RightUp ->
            LeftUp

        LeftDown ->
            RightDown

        LeftUp ->
            RightUp


flipVertically : Order -> Order
flipVertically a =
    case a of
        RightDown ->
            RightUp

        RightUp ->
            RightDown

        LeftDown ->
            LeftUp

        LeftUp ->
            LeftDown


applyIf : Bool -> (a -> a) -> a -> a
applyIf bool f a =
    if bool then
        f a

    else
        a
