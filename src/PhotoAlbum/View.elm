module PhotoAlbum.View where

import Html as H exposing (Html, Attribute)
import Html.Attributes as A


view : Html
view =
 H.div
  [ A.class "expanded row" ]
  [ content
  , troopSelection
  ]


troopSelection : Html
troopSelection =
  H.div
    [ A.class "medium-3 large-2 medium-pull-9 large-pull-10 columns troop-menu"
    , troopSelectionStyles
    ]
    [ H.br [] []
    , H.div [] [ H.text "Select a Troop" ]
    , H.hr [] []
    , troopMenu
    ]


troopSelectionStyles : Attribute
troopSelectionStyles =
  A.style
    [ ( "background", "#f7f7f7" ) ]

content : Html
content =
  H.div
    [ A.class "medium-9 large-10 medium-push-3 large-push-2 columns" ]
    [ H.br [] []
    , thumbnails
    ]


troopMenu : Html
troopMenu =
  H.ul
    [ A.class "menu vertical" ]
    [ menuItem "Troop1"
    , menuItem "Troop2"
    , menuItem "Troop3"
    , menuItem "Troop124"
    ]


menuItem : String -> Html
menuItem name =
  H.li
    []
    [ H.a [ A.href "#" ] [ H.text name ] ]


thumbnails : Html
thumbnails =
  H.div
    [ A.class "row small-up-2 medium-up-3 large-up-4" ]
    [ thumbnail
    , thumbnail
    , thumbnail
    , thumbnail
    , thumbnail
    ]


thumbnail : Html
thumbnail =
  H.div
    [ A.class "column" ]
    [ H.img
      [ A.class "thumbnail"
      , A.src "http://placehold.it/550x550"
      ]
      []
    , H.h5
      []
      [ H.text "A Photo Album" ]
    ]
