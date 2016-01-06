module PhotoAlbums.View where

import Signal exposing (Address)

import Html as H exposing (Html, Attribute)
import Html.Attributes as A
import Html.Events as E

import Credentials as C
import PhotoAlbums.Update as Update
import PhotoAlbums.Model exposing (Model, PhotoAlbum)


view : Address Update.Action -> C.Credentials -> Model -> Html
view address credentials model =
 H.div
  [ A.class "expanded row" ]
  [ content model
  , troopSelection address credentials
  ]


troopSelection : Address Update.Action -> C.Credentials -> Html
troopSelection address credentials =
  H.div
    [ A.class "medium-3 large-2 medium-pull-9 large-pull-10 columns troop-menu"
    , troopSelectionStyles
    ]
    [ H.br [] []
    , H.div [] [ H.text "Select a Troop" ]
    , H.hr [] []
    , troopMenu address credentials
    ]


troopSelectionStyles : Attribute
troopSelectionStyles =
  A.style
    [ ( "background", "#f7f7f7" ) ]

content : Model -> Html
content model =
  H.div
    [ A.class "medium-9 large-10 medium-push-3 large-push-2 columns" ]
    [ H.br [] []
    , thumbnails model
    ]


troopMenu : Address Update.Action -> C.Credentials -> Html
troopMenu address credentials =
  H.ul
    [ A.class "menu vertical" ]
    <| List.map (menuItem address) credentials.users


menuItem : Address Update.Action -> C.User -> Html
menuItem address user =
  H.li
    []
    [ H.a
      [ A.href "#"
      , E.onClick address <| Update.LoadPhotoAlbums user
      ]
      [ H.text user.troop ] ]


thumbnails : Model -> Html
thumbnails model =
  H.div
    [ A.class "row small-up-2 medium-up-3 large-up-4" ]
    <| List.map thumbnail model.photoAlbums


thumbnail : PhotoAlbum -> Html
thumbnail album =
  let
    photoUrl =
      List.head album.photos
        |> Maybe.map .photoUrl
        |> Maybe.withDefault "http://placehold.it/550x550"
  in
    H.div
      [ A.class "column" ]
      [ H.img
        [ A.class "thumbnail"
        , A.src photoUrl
        ]
        []
      , H.h5
        []
        [ H.text <| albumName album ]
      ]

albumName : PhotoAlbum -> String
albumName album =
  album.name ++ " (" ++ album.takenOn ++ ")"