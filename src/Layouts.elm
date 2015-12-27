module Layouts where

import Html exposing (Html, div, h1, h2, text)
import Html.Attributes exposing (class, type', src)

centered : List Html -> Html
centered content =
  div []
    [ div [ class "callout large primary" ]
        [ div [ class "row column text-center" ]
            [ h1 [] [ text "Trooptrack" ]
            , h2 [ class "subheader" ] [ text "Photo Album Manager" ]
            ]
        ]

    , div [ class "row medium-8 large-7 columns" ]
        [ div [ class "row" ]
            [ div
                [ class "medium-6 medium-centered large-4 large-centered columns" ]
                content
            ]
        ]

    ]
