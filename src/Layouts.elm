module Layouts exposing (..)

import Html as H exposing (Html)
import Html.Attributes as A


centered : Html a -> Html a
centered content =
    H.div [ A.id "login-page" ]
        [ H.div [ A.id "login-container" ]
            [ H.img
                [ A.src "img/logo-large.png"
                , A.alt "TroopTrack"
                ]
                []
            , H.h2 [ A.class "subheader" ] [ H.text "Photo Album Manager" ]
            , content
            ]
        ]
