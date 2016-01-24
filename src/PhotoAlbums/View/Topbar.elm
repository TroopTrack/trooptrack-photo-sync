module PhotoAlbums.View.Topbar where

import Html as H exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Signal exposing (Address)

import PhotoAlbums.Update as Update
import PhotoAlbums.Model as Model exposing (Model)
import PhotoAlbums.View.Downloads exposing (downloadAlbumButton)

topbar : Address Update.Action -> Model -> Html
topbar address model =
  let
    item content =
      H.div
        [ A.class "top-bar-item" ]
        content

    button =
      H.a
        [ A.href "#"
        , E.onClick address <| Update.SetMenuState Model.MenuOn
        ]
        [ hamburger ]

    download =
      case model.currentAlbum of
        Nothing -> H.text ""

        Just album ->
          item [ downloadAlbumButton address album model ]

    hamburger =
      H.i [ A.class "fa fa-bars" ] []
  in
    H.div
      [ A.id "top-bar" ]
      [ item [ button ]
      , download
      ]
