module Main exposing (..)

import Events
    exposing
        ( ConferenceTalk
        , appendTalk
        , talksDecoder
        , viewTalk
        , viewTalkLabel
        )
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Http
import Json.Encode
import Json.Decode
import Misc exposing (viewRelatedWebsites, githubForkRibbon)
import Result exposing (Result)
import String
import Task
import WebSocket


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { -- Iterate talks state
      talks : Maybe (List ConferenceTalk)
    , talksError :
        ( String, String )
        -- Insert talks state
    , talkTitle : String
    , talkSpeaker : String
    , talkConf : String
    , talkLoc : String
    , talkDate : String
    , talkLink : String
    , insertResult :
        ( String, String )
        -- Query talks state
    , query : String
    , queryResults : Maybe (List ConferenceTalk)
    , queryError : ( String, String )
    }


model : Model
model =
    { -- Iterate talks state
      talks = Nothing
    , talksError =
        ( "", "" )
        -- Insert talk state
    , talkTitle = "One ORM to rule them all"
    , talkSpeaker = "Sanne Grinovero"
    , talkConf = "JDK IO"
    , talkLoc = "Copenhagen, Denmark"
    , talkDate = "2017-06-19 00:00"
    , talkLink =
        "https://jdk.io/talks/183-one-orm-to-rule-them-all"
    , insertResult =
        ( "", "" )
        -- Query talks state
    , query = ""
    , queryResults = Nothing
    , queryError = ( "", "" )
    }


init =
    model
        ! [ getTalksCmd
          ]


getTalksCmd : Cmd Msg
getTalksCmd =
  -- Demo 1: implement method
  Cmd.none


type Msg
    = NoOp
      -- Iterate talks messages
    | Talks (Result Http.Error (List ConferenceTalk))
      -- Insert talk messages
    | TalkTitle String
    | TalkSpeaker String
    | TalkConference String
    | TalkLocation String
    | TalkDate String
    | TalkLink String
    | InsertTalkClick
    | InsertTalk (Result Http.Error Bool)
      -- New talk message
    | NewTalk String
      -- Query talk messages
    | QueryTalk String
    | QueryTalkClick
    | QueryResult (Result Http.Error (List ConferenceTalk))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        Talks (Ok talks) ->
            { model | talks = Just talks } ! []

        Talks (Err httpErr) ->
            { model | talksError = errorMapper httpErr } ! []

        TalkTitle title ->
            { model | talkTitle = title } ! []

        TalkSpeaker speaker ->
            { model | talkSpeaker = speaker } ! []

        TalkConference conf ->
            { model | talkConf = conf } ! []

        TalkLocation loc ->
            { model | talkLoc = loc } ! []

        TalkDate date ->
            { model | talkDate = date } ! []

        TalkLink link ->
            { model | talkLink = link } ! []

        InsertTalkClick ->
            -- Demo 2.2: Implement sending a command to insert talk
            model ! [ performInsertTalk (insertTalkAsJson model) ]
            
        InsertTalk (Ok _) ->
            { model | insertResult = ( "green", "Event inserted" ) } ! []

        InsertTalk (Err httpErr) ->
            { model | insertResult = errorMapper httpErr } ! []

        NewTalk t ->
            -- Demo 2.4: Implement showing new talks
            model ! []

        QueryTalk q ->
            -- Demo 3.1: Implement updating the query field (html effect)
            model ! []

        QueryTalkClick ->
            model ! [ performQueryTalk model.query ]

        QueryResult (Ok events) ->
            { model | queryResults = Just events } ! []

        QueryResult (Err httpErr) ->
            { model | queryError = errorMapper httpErr } ! []


errorMapper : Http.Error -> ( String, String )
errorMapper err =
    case err of
        Http.Timeout ->
            ( "red", "Http request timed out" )

        Http.NetworkError ->
            ( "red", "Network error" )

        Http.BadUrl _ ->
            ( "red", "Bad url" )

        Http.BadStatus _ ->
            ( "red", "Bad status" )

        Http.BadPayload _ _ ->
            ( "red", "Bad payload" )


performInsertTalk : Http.Body -> Cmd Msg
performInsertTalk talk =
    let
        url =
            "http://localhost:3000/events"
    in
        Http.send InsertTalk
            (Http.post url talk decodeInsertedTalk)


decodeInsertedTalk : Json.Decode.Decoder Bool
decodeInsertedTalk =
    Json.Decode.at [ "succeed" ] Json.Decode.bool


insertTalkAsJson : Model -> Http.Body
insertTalkAsJson model =
    let
        talkAsJson =
            Json.Encode.object
                [ ( "speaker", Json.Encode.string model.talkSpeaker )
                , ( "slug", Json.Encode.string "" )
                , ( "location", Json.Encode.string model.talkLoc )
                , ( "date", Json.Encode.string model.talkDate )
                , ( "talkTitle", Json.Encode.string model.talkTitle )
                , ( "conferenceName", Json.Encode.string model.talkConf )
                , ( "conferenceLink", Json.Encode.string model.talkLink )
                , ( "speakerPhotoFilename", Json.Encode.string "" )
                , ( "conferenceLogoFilename", Json.Encode.string "" )
                ]
    in
        Http.jsonBody talkAsJson


-- Http.string (Debug.log "newEvent" (Json.Encode.encode 0 newEventJson))


performQueryTalk : String -> Cmd Msg
performQueryTalk q =
    let
        url =
            "http://localhost:3000/search?q=" ++ q
    in
        Http.send QueryResult (Http.get url talksDecoder)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    -- Demo 2.3: Implement listening for new talks
    WebSocket.listen "ws://localhost:3000/events" NewTalk


-- VIEW


viewEventsUpcoming : Model -> Html msg
viewEventsUpcoming model =
    case model.talks of
        Just talks ->
            let
                talkViews =
                    List.map viewTalk talks
            in
                div [ class "upcoming-talks" ]
                    [ h2 [] [ text "Upcoming Talks and Workshops" ]
                    , div [ class "talks" ]
                        talkViews
                    ]

        Nothing ->
            let
                ( color, message ) =
                    model.talksError
            in
                if not (String.isEmpty message) then
                    div [ style [ ( "color", color ) ] ] [ text message ]
                else
                    div [] []


viewTalkDialog : Model -> Html Msg
viewTalkDialog model =
    div [ class (cssCenter ++ "insert-new-event") ]
        [ h2 [] [ text "Insert New Talk" ]
        , viewTalkRow "Talk title" TalkTitle model.talkTitle
        , viewTalkRow "Speaker name" TalkSpeaker model.talkSpeaker
        , viewTalkRow "Conference" TalkConference model.talkConf
        , viewTalkRow "Location" TalkLocation model.talkLoc
        , viewTalkRow "Date" TalkDate model.talkDate
        , viewTalkRow "Talk link" TalkLink model.talkLink
        , div [ class "row" ]
            [ viewTalkLabel ""
            , button
                [ class "button"
                , onClick InsertTalkClick
                ]
                [ text "Insert" ]
            ]
        , viewInsertResult model
        ]


viewTalkRow : String -> (String -> Msg) -> String -> Html Msg
viewTalkRow lbl msg v =
    div [ class "row" ]
        [ viewTalkLabel lbl
        , viewTalkField
            lbl
            msg
            v
        ]


viewTalkField : String -> (String -> Msg) -> String -> Html Msg
viewTalkField desc msg v =
    div [ class "small-9 columns" ]
        [ input
            [ type_ "text"
            , id "right-label"
            , placeholder desc
            , onInput msg
            , value v
            ]
            []
        ]


viewInsertResult : Model -> Html Msg
viewInsertResult model =
    let
        ( color, message ) =
            model.insertResult
    in
        if not (String.isEmpty message) then
            div [ style [ ( "color", color ) ] ] [ text message ]
        else
            div [] []


viewQueryTalk : Model -> Html Msg
viewQueryTalk model =
    div [ class cssCenter ]
        [ h2 [] [ text "Search Talk" ]
        , div [ class "input-group" ]
            [ input
                [ type_ "text"
                , class "input-group-field"
                , placeholder "Query"
                , onInput QueryTalk
                ]
                []
            , div [ class "input-group-button" ]
                [ input
                    [ type_ "submit"
                    , class "button"
                    , value "Search"
                    , onClick QueryTalkClick
                    ]
                    []
                ]
            ]
        ]


viewQueryResult : Model -> Html Msg
viewQueryResult model =
    case model.queryResults of
        Just talks ->
            let
                talkViews =
                    List.map viewTalk talks
            in
                if (List.isEmpty talkViews) then
                    div [ class (cssCenter ++ "search-talks-empty") ]
                        [ text "No events found" ]
                else
                    div [ class "upcoming-talks" ]
                        [ div [ class "talks" ] talkViews ]

        Nothing ->
            let
                ( color, message ) =
                    model.queryError
            in
                if not (String.isEmpty message) then
                    div [ class (cssCenter ++ "search-talks-error") ]
                        [ text message ]
                else
                    div [ class "search-talks-empty" ] []


view : Model -> Html Msg
view model =
    div []
        [ githubForkRibbon
        , header []
            [ h1 [] [ text "Infinispan Events" ]
            ]
        , viewEventsUpcoming model
        -- Demo 2.1: Uncomment dialog to insert new event
        --, viewTalkDialog model
        -- Demo 3.2: Uncomment dialog to search event
        -- , viewQueryTalk model
        -- , viewQueryResult model
        , viewRelatedWebsites
        ]



-- CSS STYLES


cssCenter =
    "row small-6 large-centered columns text-center "
