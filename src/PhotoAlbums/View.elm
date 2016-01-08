module PhotoAlbums.View where

import Signal exposing (Address)

import Html as H exposing (Html, Attribute)
import Html.Attributes as A
import Html.Events as E

import Credentials as C
import PhotoAlbums.Update as Update
import PhotoAlbums.Model exposing (Model, PhotoAlbum, Photo)

import Erl


view : Address Update.Action -> C.Credentials -> Model -> Html
view address credentials model =
 H.div
  [ A.class "expanded row" ]
  [ content address model
  , leftSide
    [ troopSelection address credentials
    , albumSelection address model
    ]
  ]


leftSide : List Html -> Html
leftSide =
  H.div
    [ A.class "medium-3 large-2 medium-pull-9 large-pull-10 columns troop-menu"
    , leftSideStyles
    ]


troopSelection : Address Update.Action -> C.Credentials -> Html
troopSelection address credentials =
  H.div
    []
    [ H.br [] []
    , H.div [] [ H.text "Select a Troop" ]
    , H.hr [] []
    , troopMenu address credentials
    ]


albumSelection : Address Update.Action -> Model -> Html
albumSelection address model =
  if List.isEmpty model.photoAlbums
    then H.div [] []
    else
      H.div
        []
        [ H.br [] []
        , H.div [] [ H.text "Select a Photo Album" ]
        , H.hr [] []
        , albumMenu address model
        ]


leftSideStyles : Attribute
leftSideStyles =
  A.style
    [ ( "background", "#f7f7f7" ) ]


nowrapText : Attribute
nowrapText =
  A.style
    [ ( "white-space", "nowrap" )
    , ( "overflow", "hidden" )
    , ( "text-overflow", "ellipsis" )
    ]


troopMenu : Address Update.Action -> C.Credentials -> Html
troopMenu address credentials =
  H.ul
    [ A.class "menu vertical" ]
    <| List.map (troopMenuItem address) credentials.users


troopMenuItem : Address Update.Action -> C.User -> Html
troopMenuItem address user =
  H.li
    []
    [ H.a
      [ A.href "#"
      , E.onClick address <| Update.LoadPhotoAlbums user
      ]
      [ H.text user.troop ]
    ]


albumMenu : Address Update.Action -> Model -> Html
albumMenu address model =
  H.ul
    [ A.class "menu vertical" ]
    <| List.map (albumMenuItem address model.currentAlbum) model.photoAlbums


albumMenuItem : Address Update.Action -> Maybe PhotoAlbum -> PhotoAlbum -> Html
albumMenuItem address currentAlbum renderedAlbum =
  H.li
    []
    [ H.a
        [ A.href "#"
        , E.onClick address <| Update.CurrentAlbum (Just renderedAlbum)
        ]
        [ H.text renderedAlbum.name ]
    ]


content : Address Update.Action -> Model -> Html
content address model =
  case model.currentAlbum of

    Nothing ->
      let troopName =
        Maybe.map .troop model.user
          |> Maybe.withDefault ""
      in
        H.div
          [ A.class "medium-9 large-10 medium-push-3 large-push-2 columns" ]
          [ H.h1
              [ A.class "text-center" ]
              [ H.text troopName ]
          , H.br [] []
          , albumThumbnails address model
          ]

    Just anAlbum ->
      H.div
        [ A.class "medium-9 large-10 medium-push-3 large-push-2 columns" ]
        [ H.br [] []
        , photoThumbnails address anAlbum
        ]


albumThumbnails : Address Update.Action -> Model -> Html
albumThumbnails address model =
  H.div
    [ A.class "row small-up-2 medium-up-3 large-up-4" ]
    <| List.map (albumThumbnail address) model.photoAlbums


albumThumbnail : Address Update.Action -> PhotoAlbum -> Html
albumThumbnail address album =
  let
    photoUrl =
      List.head album.photos
        |> Maybe.map .photoUrl
        |> Maybe.withDefault "http://placehold.it/550x550"
  in
    H.div
      [ A.class "column" ]
      [ H.a
        [ A.href "#"
        , E.onClick address <| Update.CurrentAlbum (Just album)
        ]
        [ H.h5
          [ nowrapText ]
          [ H.text <| albumName album ]

        , H.img
          [ A.class "thumbnail"
          , A.src photoUrl
          ]
          []
        ]
      ]

albumName : PhotoAlbum -> String
albumName album =
  album.name ++ " (" ++ album.takenOn ++ ")"


photoThumbnails : Address Update.Action -> PhotoAlbum -> Html
photoThumbnails address album =
  H.div
    [ A.class "row small-up-2 medium-up-3 large-up-4" ]
    <| List.map (photoThumbnail address) album.photos


photoThumbnail : Address Update.Action -> Photo -> Html
photoThumbnail address photo =
  let
    photoName =
      Erl.parse photo.photoUrl
        |> .path
        |> List.reverse
        |> List.head
        |> Maybe.withDefault "[ No Name ]"
  in
    H.div
      [ A.class "column" ]
      [ H.h6
        [ nowrapText ]
        [ H.text photoName ]
      , H.img
        [ A.class "thumbnail"
        , A.src photo.photoUrl
        , A.title photoName
        ]
        []
      , H.div
        []
        [ H.h6
          [ nowrapText ]
          [ H.text "[ "
          , H.a
            [ A.href "#"
            , E.onClick address (Update.DownloadPhoto photo)
            ]
            [ H.text "Download" ]
          , H.text" ]"
          ]
        ]
      ]
