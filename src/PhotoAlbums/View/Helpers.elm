module PhotoAlbums.View.Helpers exposing (..)

import Html as H exposing (Html, Attribute)
import Html.Attributes as A


fontAwesome : String -> Html a
fontAwesome iconName =
    let
        className =
            "fa fa-" ++ iconName
    in
        H.i [ A.class className ] []


nowrapText : Attribute a
nowrapText =
    A.style
        [ ( "white-space", "nowrap" )
        , ( "overflow", "hidden" )
        , ( "text-overflow", "ellipsis" )
        ]
