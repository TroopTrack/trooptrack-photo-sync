module PhotoAlbums.View.Helpers where

import Html as H exposing (Html, Attribute)
import Html.Attributes as A

fontAwesome : String -> Html
fontAwesome iconName =
  let
    className = "fa fa-" ++ iconName
  in
    H.i [ A.class className ] []


nowrapText : Attribute
nowrapText =
  A.style
    [ ( "white-space", "nowrap" )
    , ( "overflow", "hidden" )
    , ( "text-overflow", "ellipsis" )
    ]
