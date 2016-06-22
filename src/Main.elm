import Html exposing (..)
import Html.App exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Json.Encode
import Json.Decode
import Json.Decode exposing ((:=))
import Maybe exposing (withDefault)
import Date exposing (Date)
import Task
import Date.Extra.Compare exposing (Compare2 (SameOrAfter, SameOrBefore), is)
import Date.Extra.Duration
import Result exposing (Result)
import Http
import String
import Date.Format as DateFormat
import WebSocket


type alias ConferenceTalkR =
    { speaker : String
    , slug : String
    , location : String
    , date : String
    , talkTitle : Maybe String
    , conferenceName : String
    , conferenceLink : String
    , speakerPhotoFilename: String
    , conferenceLogoFilename: String
    }


type Event
    = ConferenceTalk ConferenceTalkR


getCurrentDateCmd : Cmd Msg
getCurrentDateCmd = Task.perform (\_ -> NoOp) TodayDateFetched Date.now



main =
  Html.App.program
    { init = init
    , view = mainView
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL


type alias Model =
  { dateToday : Maybe Date
  , newEventTitle : String
  , newEventSpeaker : String
  , newEventConf : String
  , newEventLoc: String
  , newEventDate: String
  , newEventLink: String
  , insertResult: (String, String)
  , events: Maybe (List ConferenceTalkR)
  , eventsError: (String, String)
  , searchEventQuery: String
  , searchResults: Maybe (List ConferenceTalkR)
  , searchError: (String, String)
  }

model : Model
model =
  { dateToday = Nothing
  , newEventTitle = "Scaling in-memory data grid automatically with Kubernetes"
  , newEventSpeaker = "Ray Tsang"
  , newEventConf = "DevNation"
  , newEventLoc = "San Francisco, USA"
  , newEventDate = "29 June 2016"
  , newEventLink = "http://www.devnation.org/#50856"
  -- , newEventTitle = ""
  -- , newEventSpeaker = ""
  -- , newEventConf = ""
  -- , newEventLoc = ""
  -- , newEventDate = ""
  -- , newEventLink = ""
  , insertResult = ("","")
  , events = Nothing
  , eventsError = ("", "")
  , searchEventQuery = ""
  , searchResults = Nothing
  , searchError = ("", "")
  }


init = model !
  [ getCurrentDateCmd
  , getEventsCmd
  ]


getEventsCmd : Cmd Msg
getEventsCmd =
  let
    url =
      "http://localhost:3000/events"
  in
    Task.perform GetEventsFail GetEventsSucceed (Http.get decodeGetEvents url)


jsonApply : Json.Decode.Decoder (a -> b) -> Json.Decode.Decoder a -> Json.Decode.Decoder b
jsonApply func value =
    Json.Decode.object2 (<|) func value


decodeGetEvents : Json.Decode.Decoder (List ConferenceTalkR)
decodeGetEvents =
  let
    event = Json.Decode.map ConferenceTalkR
            ("speaker" := Json.Decode.string) `jsonApply`
            ("slug" := Json.Decode.string) `jsonApply`
            ("location" := Json.Decode.string) `jsonApply`
            ("date" := Json.Decode.string) `jsonApply`
            ("talkTitle" := Json.Decode.maybe Json.Decode.string) `jsonApply`
            ("conferenceName" := Json.Decode.string) `jsonApply`
            ("conferenceLink" := Json.Decode.string) `jsonApply`
            ("speakerPhotoFilename" := Json.Decode.string) `jsonApply`
            ("conferenceLogoFilename" := Json.Decode.string)
  in
    Json.Decode.list event


decoderEvent : Json.Decode.Decoder ConferenceTalkR
decoderEvent =
  Json.Decode.map ConferenceTalkR
    ("speaker" := Json.Decode.string) `jsonApply`
    ("slug" := Json.Decode.string) `jsonApply`
    ("location" := Json.Decode.string) `jsonApply`
    ("date" := Json.Decode.string) `jsonApply`
    ("talkTitle" := Json.Decode.maybe Json.Decode.string) `jsonApply`
    ("conferenceName" := Json.Decode.string) `jsonApply`
    ("conferenceLink" := Json.Decode.string) `jsonApply`
    ("speakerPhotoFilename" := Json.Decode.string) `jsonApply`
    ("conferenceLogoFilename" := Json.Decode.string)


type Msg
  = NoOp
  | TodayDateFetched Date
  | NewEventTitle String
  | NewEventSpeaker String
  | NewEventConference String
  | NewEventLocation String
  | NewEventDate String
  | NewEventLink String
  | InsertEvent
  | InsertEventSucceed Bool
  | InsertEventFail Http.Error
  | GetEventsSucceed (List ConferenceTalkR)
  | GetEventsFail Http.Error
  | NewEvent String
  | SearchEventQuery String
  | SearchEvent
  | SearchEventFail Http.Error
  | SearchEventSucceed (List ConferenceTalkR)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (Debug.log "msg" msg) of
  -- case msg of
    TodayDateFetched date ->
      { model | dateToday = Just date } ! []

    NoOp ->
      model ! []

    NewEventTitle title ->
      { model | newEventTitle = title } ! []

    NewEventSpeaker speaker ->
      { model | newEventSpeaker = speaker } ! []

    NewEventConference conf ->
      { model | newEventConf = conf } ! []

    NewEventLocation loc ->
      { model | newEventLoc = loc } ! []

    NewEventDate date ->
      { model | newEventDate = date } ! []

    NewEventLink link ->
      { model | newEventLink = link } ! []

    InsertEvent ->
      model ! [ performInsertEvent (newEventAsJson model)]

    InsertEventSucceed _ ->
      { model | insertResult = ("green", "Event inserted") } ! []

    InsertEventFail httpErr ->
      { model | insertResult = errorMapper httpErr } ! []

    GetEventsSucceed events ->
      { model | events = Just events } ! []

    GetEventsFail httpErr ->
      { model | eventsError = errorMapper httpErr } ! []

    NewEvent event ->
      { model | events = appendEvent model event } ! []

    SearchEventQuery query ->
      { model | searchEventQuery = query } ! []

    SearchEvent ->
      model ! [ performSearchEvent model.searchEventQuery ]

    SearchEventSucceed events ->
      { model | searchResults = Just events } ! []

    SearchEventFail httpErr ->
      { model | searchError = errorMapper httpErr } ! []


errorMapper : Http.Error -> (String, String)
errorMapper err =
  case err of
    Http.Timeout -> ("red", "Http request timed out")

    Http.NetworkError -> ("red", "Network error")

    Http.UnexpectedPayload s -> ("red", s)

    Http.BadResponse status s -> ("red", "Bad response: " ++ toString status ++ " " ++ s)


performInsertEvent : Http.Body -> Cmd Msg
performInsertEvent event =
  let
    url =
      "http://localhost:3000/events"
  in
    Task.perform InsertEventFail InsertEventSucceed (Http.post decodeInsertedEvent url event)


decodeInsertedEvent : Json.Decode.Decoder Bool
decodeInsertedEvent =
  Json.Decode.at ["succeed"] Json.Decode.bool


newEventAsJson : Model -> Http.Body
newEventAsJson model =
  let
    newEventJson =
      Json.Encode.object
        [ ("speaker", Json.Encode.string model.newEventSpeaker)
        , ("slug", Json.Encode.string "")
        , ("location", Json.Encode.string model.newEventLoc)
        , ("date", Json.Encode.string model.newEventDate)
        , ("talkTitle", Json.Encode.string model.newEventTitle)
        , ("conferenceName", Json.Encode.string model.newEventConf)
        , ("conferenceLink", Json.Encode.string model.newEventLink)
        , ("speakerPhotoFilename", Json.Encode.string "")
        , ("conferenceLogoFilename", Json.Encode.string "")
        ]
  in
    Http.string (Json.Encode.encode 0 newEventJson)
    -- Http.string (Debug.log "newEvent" (Json.Encode.encode 0 newEventJson))


decodeEvent : String -> Result String ConferenceTalkR
decodeEvent event =
  Json.Decode.decodeString decoderEvent event


appendEvent : Model -> String -> Maybe (List ConferenceTalkR)
appendEvent model event =
  let
    decodeResult = decodeEvent event
  in
    case decodeResult of
      Ok decoded ->
        Maybe.map (\es -> decoded :: es) model.events
      Err err ->
        Debug.log ("Decode error in new event" ++ err) Nothing


performSearchEvent : String -> Cmd Msg
performSearchEvent q =
  let
    url =
      Http.url "http://localhost:3000/search" [("q", q)]
  in
    Task.perform SearchEventFail SearchEventSucceed (Http.get decodeGetEvents url)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:3000/events" NewEvent


-- VIEW


talkView : ConferenceTalkR -> Html Msg
talkView record =
  a [ class "event-card meetup grow", href record.conferenceLink]
      [ div [ class "meetup-header"]
          [ h3 []
              [text (withDefault "Talk title to be announced" record.talkTitle)]
          ]
      , div [ class "meetup-footer"]
          [ h4 []
             [text ("by " ++ record.speaker)]
          , div [] [text record.date]
          , div [ class "location"] [text record.location]
        ]
      ]


renderEvents : Model -> Html Msg
renderEvents model =
  case model.events of
    Just events ->
      let
          eventViews = List.map talkView events
      in
          div [ class "upcoming-talks"]
              [ h2 [] [ text "Upcoming Talks and Workshops" ]
              , div [ class "talks"]
                  eventViews
              ]
    Nothing ->
      let
        (color, message) = model.eventsError
      in
        if not (String.isEmpty message) then
          div [ style [("color", color)] ] [ text message ]
        else
          div [] []


renderRelatedWebsites : Html Msg
renderRelatedWebsites =
  div [ class "related-websites"]
    [ h2 [] [ text "Related Websites" ]
    , h3 []
        [ a [ href "https://www.redhat.com/en/technologies/jboss-middleware/data-grid" ]
            [ text "JBoss Data Grid" ]
        ]
    , p []
        [ text "Find out more about JBoss Data Grid, try the latest release and buy subscription that gives you access to professional support, patches...etc."
        ]
    , h3 []
        [ a [ href "http://middlewareblog.redhat.com/category/jboss-data-grid/" ]
            [ text "JBoss Data Grid Blog" ]
        ]
    , p []
        [ text "Upcoming JBoss Data Grid releases, features, meetups and talks straight to your inbox, and lots more!"
        ]
    , h3 []
        [ a [ href "http://infinispan.org" ]
            [ text "Infinispan" ]
        ]
    , p []
        [ text "Learn about Infinispan, the community project behind JBoss Data Grid, by downloading latest releases, checking its documentation, asking questions on the public forums or trying out the simple tutorials."
        ]
    ]


newEventView : Event -> Html Msg
newEventView event =
  tr []
      [ td [] [input [type' "text", placeholder "Talk title"] []]
      , td [] [input [type' "text", placeholder "Speaker name"] []]
      , td [] [input [type' "text", placeholder "Conference"] []]
      , td [] [input [type' "text", placeholder "Location"] []]
      , td [] [input [type' "text", placeholder "Date"] []]
      , td [] [input [type' "text", placeholder "Talk link"] []]
      ]


renderInsertEvent : Model -> Html Msg
renderInsertEvent model =
  div [ class "admin-talks"]
    [ h2 [] [ text "Insert New Event" ]
    , table []
      (
        [ thead [] []
        , tbody []
           [ tr []
               [ td [] [ text "Talk title"]
               , td [] [input [type' "text", placeholder "Talk title"
                              , onInput NewEventTitle
                              , value "Scaling in-memory data grid automatically with Kubernetes"
                              ] []]
               ]
             , tr []
               [ td [] [ text "Speaker name"]
               , td [] [input [type' "text", placeholder "Speaker name"
                              , onInput NewEventSpeaker
                              , value "Ray Tsang"
                              ] []]
               ]
             , tr []
               [ td [] [ text "Conference"]
               , td [] [input [type' "text", placeholder "Conference"
                              , onInput NewEventConference
                              , value "DevNation"
                              ] []]
               ]
             , tr []
               [ td [] [ text "Location"]
               , td [] [input [type' "text", placeholder "Location"
                              , onInput NewEventLocation
                              , value "San Francisco, USA"
                              ] []]
               ]
             , tr []
               [ td [] [ text "Date"]
               , td [] [input [type' "text", placeholder "Date"
                              , onInput NewEventDate
                              , value "29 June 2016"
                              ] []]
               ]
             , tr []
               [ td [] [ text "Talk link"]
               , td [] [input [type' "text", placeholder "Talk link"
                              , onInput NewEventLink
                              , value "http://www.devnation.org/#50856"
                              ] []]
               ]
             , tr []
               [ td [] []
               , td [] [button [ onClick InsertEvent ] [ text "Insert" ]]
               ]
           ]
        ]
      )
    , viewInsertResult model
    ]

viewInsertResult : Model -> Html Msg
viewInsertResult model =
  let
    (color, message) = model.insertResult
  in
    if not (String.isEmpty message) then
      div [ style [("color", color)] ] [ text message ]
    else
      div [] []


renderSearchEvent : Model -> Html Msg
renderSearchEvent model =
  div [ class cssCenter ]
    [ h2 [] [ text "Search Event" ]
    , div [ class "input-group" ]
        [ input
            [ type' "text"
            , class "input-group-field"
            , placeholder "Query"
            , onInput SearchEventQuery
            ] []
        , div [ class "input-group-button"]
            [ input
                [ type' "submit"
                , class "button"
                , value "Search"
                , onClick SearchEvent
                ] []
            ]
        ]
    ]


viewSearchResult : Model -> Html Msg
viewSearchResult model =
  case model.searchResults of
    Just events ->
      let
          eventViews = List.map talkView events
      in
        if (List.isEmpty eventViews) then
          div [ class (cssCenter ++ "search-talks-empty") ]
            [ text "No events found" ]
        else
          div [ class "upcoming-talks" ]
            [ div [ class "talks"] eventViews ]
    Nothing ->
      let
        (color, message) = model.searchError
      in
        if not (String.isEmpty message) then
          div [ class (cssCenter ++ "search-talks-error") ]
            [ text message ]
        else
          div [ class "search-talks-empty" ] []


mainView : Model -> Html Msg
mainView model =
  case model.dateToday of
    Just date ->
      div []
          [ githubForkRibbon
          , header []
              [ h1 [] [ text "JBoss Data Grid Events" ]
              ]
          , renderEvents model
          , renderInsertEvent model
          , renderSearchEvent model
          , viewSearchResult model
          , renderRelatedWebsites
          ]
    Nothing ->
      div [] []


githubForkRibbon : Html msg
githubForkRibbon =
    a
        [ href "https://github.com/galderz/infinispan-events/tree/june16" ]
        [ img
            [ alt "Fork me on GitHub"
            , src "https://camo.githubusercontent.com/a6677b08c955af8400f44c6298f40e7d19cc5b2d/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f677261795f3664366436642e706e67"
            , attribute "style" "position: absolute; top: 0; right: 0; border: 0; z-index: 100"
            ]
            []
        ]


-- CSS STYLES
styles =
  {
    wrapper =
      [
        ( "padding-top", "10px" ),
        ( "padding-bottom", "20px" ),
        ( "text-align", "center" )
      ]
  }


cssCenter = "row small-6 large-centered columns text-center "
