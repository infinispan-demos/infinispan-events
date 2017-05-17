module Events exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode
import Json.Decode exposing (field)
import Json.Decode.Pipeline exposing (decode)
import List exposing (append)
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
    Json.Decode.decodeString talkDecoder event


talksDecoder : Json.Decode.Decoder (List ConferenceTalk)
talksDecoder =
    Json.Decode.list talkDecoder


appendTalk : Maybe (List ConferenceTalk) -> String -> Maybe (List ConferenceTalk)
appendTalk talks t =
    let
        res =
            decodeTalk t
    in
        case res of
            Ok decoded ->
                Maybe.map (\ts -> append ts [ decoded ]) talks

            Err err ->
                Debug.log ("Decode error in new event" ++ err) Nothing


talkDecoder : Json.Decode.Decoder ConferenceTalk
talkDecoder =
    Json.Decode.Pipeline.decode ConferenceTalk
    |> Json.Decode.Pipeline.required "speaker" Json.Decode.string
    |> Json.Decode.Pipeline.required "slug" Json.Decode.string
    |> Json.Decode.Pipeline.required "location" Json.Decode.string
    |> Json.Decode.Pipeline.required "date" Json.Decode.string
    |> Json.Decode.Pipeline.required "talkTitle" (Json.Decode.maybe Json.Decode.string)
    |> Json.Decode.Pipeline.required "conferenceName" Json.Decode.string
    |> Json.Decode.Pipeline.required "conferenceLink" Json.Decode.string
    |> Json.Decode.Pipeline.required "speakerPhotoFilename" Json.Decode.string
    |> Json.Decode.Pipeline.required "conferenceLogoFilename" Json.Decode.string
