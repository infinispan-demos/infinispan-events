module Misc exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


viewRelatedWebsites : Html msg
viewRelatedWebsites =
    div [ class "related-websites" ]
        [ h2 [] [ text "Related Websites" ]
        , h3 []
            [ a [ href "http://infinispan.org" ]
                [ text "Infinispan" ]
            ]
        , p []
            [ text "Learn about Infinispan, the community project behind JBoss Data Grid, by downloading latest releases, checking its documentation, asking questions on the public forums or trying out the simple tutorials."
            ]
        , h3 []
            [ a [ href "http://blog.infinispan.org" ]
                [ text "Infinispan Blog" ]
            ]
        , p []
            [ text "Find out first about the new features going into Infinispan and about upcoming meetups and talks in this blog."
            ]
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
        ]


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
