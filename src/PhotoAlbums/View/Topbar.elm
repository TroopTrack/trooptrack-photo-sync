module PhotoAlbums.View.Topbar exposing (..)

import Html as H exposing (Html)
import Html.Attributes as A
import Html.Events as E
import PhotoAlbums.Update as Update
import PhotoAlbums.Model as Model exposing (Model)
import PhotoAlbums.View.Downloads exposing (downloadAlbumButton)


topbar : Model -> Html Update.Action
topbar model =
    let
        item content =
            H.div [ A.class "top-bar-item" ]
                content

        button =
            H.a
                [ A.href "#"
                , E.onClick <| Update.SetMenuState Model.MenuOn
                ]
                [ hamburger ]

        download =
            case model.currentAlbum of
                Nothing ->
                    H.text ""

                Just album ->
                    item [ downloadAlbumButton album model ]

        hamburger =
            H.i [ A.class "fa fa-bars" ] []
    in
        H.div [ A.id "top-bar" ]
            [ item [ button ]
            , download
            ]
