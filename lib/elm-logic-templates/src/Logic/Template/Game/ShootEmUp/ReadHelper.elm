module Logic.Template.Game.ShootEmUp.ReadHelper exposing (aiTargets)

import AltMath.Vector2 as Vec2
import Dict exposing (Dict)
import Logic.Template.Component.AI as AI exposing (AiTargets)
import Logic.Template.SaveLoad.Internal.Util as Util
import Parser exposing ((|.), (|=), Parser)
import Tiled.Level
import Tiled.Object exposing (Object)
import Tiled.Properties exposing (Property(..))


aiTargets :
    Tiled.Level.Level
    -> Dict String Property
    -> List Object
    -> AiTargets
aiTargets level props objList =
    props
        |> Dict.foldl (addItem (yInvert level) objList) Dict.empty
        |> Dict.values
        |> (\l ->
                case l of
                    target :: rest ->
                        { waiting = target.wait
                        , prev = [ target ]
                        , target = target
                        , next = rest
                        }

                    [] ->
                        { waiting = 0
                        , prev = []
                        , target = AI.emptySpot
                        , next = []
                        }
           )


addItem yInvert_ objList key value acc =
    let
        setPos pos mValue =
            let
                spot =
                    Maybe.withDefault AI.emptySpot mValue
            in
            Just { spot | position = pos }

        setAction action mValue =
            let
                spot =
                    Maybe.withDefault AI.emptySpot mValue
            in
            Just { spot | action = action :: spot.action }

        setWait wait mValue =
            let
                spot =
                    Maybe.withDefault AI.emptySpot mValue
            in
            Just { spot | wait = wait }

        setInvSteps steps mValue =
            let
                spot =
                    Maybe.withDefault AI.emptySpot mValue
            in
            Just { spot | invSteps = 1 / toFloat steps }
    in
    case ( Parser.run aiKeyParser key, value ) of
        ( Ok ( Index, index ), PropInt id ) ->
            Util.objectById id objList
                |> Maybe.map (yInvert_ >> Util.objectPosition >> Vec2.fromRecord)
                |> Maybe.map (\pos -> Dict.update index (setPos pos) acc)
                |> Maybe.withDefault acc

        ( Ok ( Action, index ), PropString action ) ->
            Dict.update index (setAction action) acc

        ( Ok ( Wait, index ), PropInt wait ) ->
            Dict.update index (setWait wait) acc

        ( Ok ( Steps, index ), PropInt steps ) ->
            Dict.update index (setInvSteps steps) acc

        _ ->
            acc


type AiKey
    = Wait
    | Index
    | Action
    | Steps


aiKeyParser : Parser ( AiKey, Int )
aiKeyParser =
    Parser.succeed
        (\index key ->
            ( key, index )
        )
        |. Parser.keyword "ai.target"
        |= Parser.oneOf
            [ Parser.succeed identity |. Parser.symbol "[" |= Parser.int |. Parser.symbol "]"
            , Parser.succeed 0
            ]
        |= Parser.oneOf
            [ Parser.succeed Index |. Parser.end
            , Parser.succeed Wait |. Parser.symbol ".wait" |. Parser.end
            , Parser.succeed Action |. Parser.symbol ".action" |. Parser.end
            , Parser.succeed Steps |. Parser.symbol ".steps" |. Parser.end
            ]


yInvert : Tiled.Level.Level -> Tiled.Object.Object -> Tiled.Object.Object
yInvert level =
    let
        levelCommon =
            Util.levelCommon level

        levelWidth =
            toFloat (levelCommon.tilewidth * levelCommon.width)

        levelHeight =
            toFloat (levelCommon.tileheight * levelCommon.height)
    in
    Util.objFix levelHeight
