module PhotoAlbums.View where

import String
import Dict

import Signal exposing (Address)

import Html as H exposing (Html, Attribute)
import Html.Attributes as A
import Html.Events as E

import Credentials as C
import PhotoAlbums.Update as Update
import PhotoAlbums.Model exposing (Model, PhotoAlbum, Photo)


view : Address Update.Action -> C.Credentials -> Model -> Html
view address credentials model =
 H.div
  [ A.class "content" ]
  [ leftSide
    [ troopSelection address credentials
    , albumSelection address model
    ]
  , content address model
  ]


leftSide : List Html -> Html
leftSide =
  H.div
    [ A.id "leftnav"
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
          [ A.id "gallery" ]
          [ H.h1
            [ A.class "text-center" ]
            [ H.text troopName ]
          , H.br [] []
          , albumThumbnails address model
          ]

    Just anAlbum ->
      H.div
        [ A.id "gallery" ]
        [ H.h1
          [ A.class "text-center" ]
          [ H.text anAlbum.name ]
        , H.h5
          [ A.class "text-center"
          , nowrapText
          ]
          [ H.text "[ "
          , downloadAllButton address anAlbum model
          , H.text " ]"
          ]
        , H.br [] []
        , photoThumbnails address anAlbum model
        ]


albumThumbnails : Address Update.Action -> Model -> Html
albumThumbnails address model =
  H.div
    [ A.class "gallery-items"]
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
      [ A.class "gallery-item" ]
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


downloadAllButton : Address Update.Action -> PhotoAlbum -> Model -> Html
downloadAllButton address album model =
  let
    isDownloading photo =
      Dict.member photo.photoId model.photoDownloads

    activeDownloads =
      List.filter isDownloading album.photos

    theButton =
      H.a
        [ A.href "#"
        , E.onClick address <| Update.DownloadAlbum album
        ]
        [ H.text "Download All"
        ]

    theMessage =
      String.concat
        [ "Downloading "
        , toString <| List.length activeDownloads
        , " of "
        , toString <| List.length album.photos
        ]
        |> H.text
  in
    if List.length activeDownloads > 0
      then theMessage
      else theButton



photoThumbnails : Address Update.Action -> PhotoAlbum -> Model -> Html
photoThumbnails address album model =
  H.div
    [ A.class "gallery-items" ]
    <| List.map (photoThumbnail address model) album.photos


photoThumbnail : Address Update.Action -> Model -> Photo -> Html
photoThumbnail address model photo =
  let
    photoName =
      photo.path
        |> List.reverse
        |> List.head
        |> Maybe.withDefault "{ Unnamed }"

    maybeDownload =
      Dict.get photo.photoId model.photoDownloads

    downloadButton =
      case maybeDownload of

        Nothing ->
          H.a
            [ A.href "#"
            , E.onClick address (Update.DownloadPhoto photo)
            ]
            [ H.text "Download" ]

        Just percentage ->
          H.progress
            [ A.max "1"
            , A.value <| toString percentage
            ]
            []

  in
    H.div
      [ A.class "gallery-item" ]
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
          , downloadButton
          , H.text " ]"
          ]
        ]
      ]