import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )
import String
import Maybe exposing (withDefault)

-- official 'Elm Architecture' package
-- https://github.com/evancz/start-app
import StartApp.Simple as StartApp

-- component import example
import Components.Hello exposing ( hello )

-- TODO: Factor out to component
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
    -- , company: Maybe String
    }

--type alias MeetupEventR =
--    { meetupGroupName : String
--    , meetupTitle : String
--    , location : String
--    , date : String
--    , meetupPageLink : String
--    , logoUrl : Maybe String
--    }
--
--
--type alias SuggestedConferenceR =
--    { name : String
--    , date : String
--    , submissionDeadline: String
--    , link : String
--    , location : String
--    }
--
--type alias MeetupGroupR =
--    { name : String
--    , link : String
--    }

type Event
    = ConferenceTalk ConferenceTalkR

-- APP KICK OFF!
main =
  StartApp.start { model = model, view = mainView, update = update }


-- MODEL
model = 0



upcomingEvents : List Event
upcomingEvents =
    [
      ConferenceTalk
      { conferenceName = "Flourish! 2016"
      , slug = "flourish-2016"
      , conferenceLink = "http://flourishconf.com/2016/speakers.php?id=12"
      , talkTitle = Just "Friendly Functional Programming For The Web"
      , speaker = "Luke Westby"
      , date = "2 April 2016"
      , location = "Chicago, IL, USA"
      , conferenceLogoFilename = "flourish-2016.png"
      , speakerPhotoFilename = "luke-westby.jpg"
      }
    , ConferenceTalk
      { conferenceName = "ProgSCon"
      , slug = "progscon-2016"
      , conferenceLink = "http://progscon.co.uk/"
      , talkTitle = Just "Elm: Finding the Functional in Reactive Programming"
      , speaker = "Claudia Doppioslash"
      , date = "22 April 2016"
      , location = "London"
      , conferenceLogoFilename = "progscon.png"
      , speakerPhotoFilename = "claudia-doppioslash.jpg"
      }
    ]

--suggestedConferences : List SuggestedConferenceR
--suggestedConferences =
--    [
--        { name = "ReactEurope"
--        , date = "June 2-3, 2016"
--        , location = "Paris, France"
--        , submissionDeadline = "PAST"
--        , link = "https://www.react-europe.org/"
--        }
--    ,
--        { name = "LambdaConf"
--        , date = "May 26-19, 2016"
--        , location = "Boulder, CO, USA"
--        , submissionDeadline = "PAST"
--        , link = "http://lambdaconf.us/"
--        }
--    ,
--        { name = "Strange Loop"
--        , date = "Sept 15-17th, 2016"
--        , location = "St. Louis, USA"
--        , submissionDeadline = "TBA"
--        , link = "http://thestrangeloop.com/"
--        }
--    ]

--confImage : String -> String -> Html
--confImage filename idValue =
--    div
--        [ id idValue
--        , class "conference-image"
--        , style
--            [ ("background-image", "url(media/" ++ filename ++ ")") ]
--        ]
--        []
--
--speakerImage : String -> Html
--speakerImage filename =
--    img
--        [ src ("media/" ++ filename)
--        , style
--            [ ("display", "inline")
--            , ("width", "200px")
--            , ("height", "200px")
--            -- , ("height", "200px")
--            ]
--        ]
--        []

talkView : ConferenceTalkR -> Html
talkView record =
    tr []
        [ td [] [text (withDefault "Talk title to be announced" record.talkTitle)]
        , td [] [text record.speaker]
        , td []  [text record.location] -- TODO: div [ class "location"] ?
        , td [] [text record.date]
        ]
--    a [ class "event-card talk grow", href record.conferenceLink]
--        [ div
--            [ style [("display", "flex")]
--            ]
--            [ confImage record.conferenceLogoFilename (record.slug ++ "-conf-image")
--            , speakerImage record.speakerPhotoFilename
--            ]
--        , div [class "talk-content"]
--          [ h3 []
--               [text (withDefault "Talk title to be announced" record.talkTitle)]
--          , h4 [] [text ("by " ++ record.speaker)]
--          , div [] [text record.date]
--          , div [ class "location"] [text record.location]
--          ]
--        ]

--meetupView : MeetupEventR -> Html
--meetupView record =
--
--  let
--    logoEl =
--      case record.logoUrl of
--        Just url ->
--          img [ src url ] []
--        Nothing -> span [] []
--
--  in
--    a [ class "event-card meetup grow", href record.meetupPageLink]
--          [ div [ class "meetup-header"]
--            [ h3 []
--                [text record.meetupTitle]
--            , logoEl
--            ]
--          , div [ class "meetup-footer"]
--            [ h4 []
--                [text record.meetupGroupName]
--            , div [] [text record.date]
--            , div [ class "location"] [text record.location]
--            ]
--          ]

renderEvent : Event -> Html
renderEvent event =
    case event of
        ConferenceTalk record ->
            talkView record
--        Meetup record ->
--            meetupView record

renderEvents : List Event -> Html
renderEvents events =
    let
        eventViews = List.map renderEvent events
    in
        div [ class "upcoming-talks"]
            [ h2 [] [ text "Upcoming Conference Talks and Meetups" ]
            , table []
                (
                    [ thead []
                        [ tr []
                            [ th [] [ text "Talk Title"]
                            , th [] [ text "Speaker"]
                            , th [] [ text "Where"]
                            , th [] [ text "When"]
                            ]
                        ]
                    , tbody []
                        rows
                    ]
                )

--            , div [ class "talks"]
--                eventViews
            ]

--renderSuggestedConference : SuggestedConferenceR -> Html
--renderSuggestedConference conf =
--    tr []
--        [ td [] [text conf.name]
--        , td [] [text conf.location]
--        , td []  [text conf.date]
--        , td [] [text conf.submissionDeadline]
--        ]

--renderSuggestedConferences : List SuggestedConferenceR -> Html
--renderSuggestedConferences confs =
--    let
--        rows = List.map renderSuggestedConference confs
--    in
--        div [ class "suggested-conferences"]
--            [ h2 [] [text "Suggested Conferences"]
--            , p [] [text "Got some ideas or projects you want to tell people about?" ]
--            , p [] [ text "Here are some upcoming conferences you might want to submit an application for."]
--            , table []
--                (
--                    [ thead []
--                        [ tr []
--                            [ th [] [ text "Conference"]
--                            , th [] [ text "Where"]
--                            , th [] [ text "When"]
--                            , th [] [ text "Submission Deadline"]
--                            ]
--                        ]
--                    , tbody []
--                        rows
--                    ]
--                )
--            ]


-- mainView : Html
mainView address model =
    div []
        [ header []
            [ h1 [] [ text "Elm Events" ]
            ]
        , renderEvents upcomingEvents
        ]
-- VIEW
-- Examples of:
-- 1)  an externally defined component ('hello', takes 'model' as arg)
-- 2a) styling through CSS classes (external stylesheet)
-- 2b) styling using inlne style attribute (two variants)
view address model =
  div
    [ class "mt-palette-accent", style styles.wrapper ]
    [
      hello model,
      p [ style [( "color", "#FFF")] ] [ text ( "Elm Webpack Starter" ) ],
      button [ class "mt-button-sm", onClick address Increment ] [ text "FTW!" ]
    ]


-- UPDATE
type Action = Increment

update action model =
  case action of
    Increment -> model + 1


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
