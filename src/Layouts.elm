module Layouts where

import Html as H exposing (Html)
import Html.Attributes as A

centered : List Html -> Html
centered content =
  H.div []
    [ H.div [ A.class "callout large primary" ]
        [ H.div [ A.class "row column text-center" ]
            [ H.h1 [] [ H.text "Trooptrack" ]
            , H.h2 [ A.class "subheader" ] [ H.text "Photo Album Manager" ]
            ]
        ]

    , H.div [ A.class "row medium-8 large-7 columns" ]
        [ H.div [ A.class "row" ]
            [ H.div
                [ A.class "medium-6 medium-centered large-4 large-centered columns" ]
                content
            ]
        ]

    ]
