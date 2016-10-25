module Events exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode
import Json.Decode exposing ((:=))
import Maybe exposing (withDefault)


type alias ConferenceTalk =
    { speaker : String
    , slug : String
    , location : String
    , date : String
    , talkTitle : Maybe String
    , conferenceName : String
    , conferenceLink : String
    , speakerPhotoFilename : String
    , conferenceLogoFilename : String
    }


viewTalk : ConferenceTalk -> Html msg
viewTalk record =
    a [ class "event-card meetup grow", href record.conferenceLink ]
        [ div [ class "meetup-header" ]
            [ h3 []
                [ text (withDefault "Talk title to be announced" record.talkTitle) ]
            ]
        , div [ class "meetup-footer" ]
            [ h4 []
                [ text ("by " ++ record.speaker) ]
            , div [] [ text record.date ]
            , div [ class "location" ] [ text record.location ]
            ]
        ]


viewTalkLabel : String -> Html msg
viewTalkLabel v =
    div [ class "small-3 columns" ]
        [ label
            [ for "right-label"
            , class "text-right middle"
            ]
            [ text v ]
        ]


decodeTalk : String -> Result String ConferenceTalk
decodeTalk event =
    Json.Decode.decodeString eventDecoder event


talksDecoder : Json.Decode.Decoder (List ConferenceTalk)
talksDecoder =
    Json.Decode.list eventDecoder


appendTalk : Maybe (List ConferenceTalk) -> String -> Maybe (List ConferenceTalk)
appendTalk talks t =
    let
        res =
            decodeTalk t
    in
        case res of
            Ok decoded ->
                Maybe.map (\ts -> decoded :: ts) talks

            Err err ->
                Debug.log ("Decode error in new event" ++ err) Nothing


eventDecoder : Json.Decode.Decoder ConferenceTalk
eventDecoder =
    Json.Decode.map ConferenceTalk
        ("speaker" := Json.Decode.string)
        `jsonApply` ("slug" := Json.Decode.string)
        `jsonApply` ("location" := Json.Decode.string)
        `jsonApply` ("date" := Json.Decode.string)
        `jsonApply` ("talkTitle" := Json.Decode.maybe Json.Decode.string)
        `jsonApply` ("conferenceName" := Json.Decode.string)
        `jsonApply` ("conferenceLink" := Json.Decode.string)
        `jsonApply` ("speakerPhotoFilename" := Json.Decode.string)
        `jsonApply` ("conferenceLogoFilename" := Json.Decode.string)


jsonApply : Json.Decode.Decoder (a -> b) -> Json.Decode.Decoder a -> Json.Decode.Decoder b
jsonApply func value =
    Json.Decode.object2 (<|) func value
