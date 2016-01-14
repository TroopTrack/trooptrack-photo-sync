module Layouts where

import Html as H exposing (Html)
import Html.Attributes as A

centered : Html -> Html
centered content =
  H.div
    [ A.id "login-page"]
    [ H.div
      [ A.id "login-container" ]
      [ H.h1 [] [ H.text "Trooptrack" ]
      , H.h2 [ A.class "subheader" ] [ H.text "Photo Album Manager" ]
      , content
      ]
    ]
