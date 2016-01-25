module PhotoAlbums.View.Gallery where

import Signal exposing (Address)
import Html as H exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Dict

import PhotoAlbums.Update as Update
import PhotoAlbums.Model as Model exposing (Model, PhotoAlbum, Photo)
import PhotoAlbums.View.Helpers exposing (nowrapText, fontAwesome)
import Credentials as C

content : Address Update.Action
       -> C.TroopTypes
       -> C.Credentials
       -> Model
       -> Html
content address troopTypes credentials model =
  case model.user of

    Nothing ->
      troopSelection address troopTypes credentials model

    Just user ->
      albumContent address model


troopSelection : Address Update.Action
              -> C.TroopTypes
              -> C.Credentials
              -> Model
              -> Html
troopSelection address troopTypes credentials model =
  H.div
    [ A.class "gallery-items" ]
    <| List.map (troopThumb address troopTypes) credentials.users


troopThumb : Signal.Address Update.Action -> C.TroopTypes -> C.User -> H.Html
troopThumb address troopTypes user =
  H.div
    [ A.class "gallery-item" ]
    [ H.a
      [ A.href "#"
      , E.onClick address <| Update.LoadPhotoAlbums user
      ]
      [ H.text user.troop ]
    , H.br [] []
    , H.a
      [ A.href "#"
      , E.onClick address <| Update.LoadPhotoAlbums user
      ]
      [ troopImage troopTypes user ]
    ]


troopImage : C.TroopTypes -> C.User -> H.Html
troopImage troopTypes user =
  let
    troopType =
      Dict.get user.troop_type_id troopTypes
        |> Maybe.withDefault C.UnknownTroopType

  in
    case troopType of

      C.BsaTroop ->
        H.img [ A.src "img/bsa_share.png" ] []

      C.GsaTroop ->
        H.img [ A.src "img/gsa_share.png" ] []

      C.AhgTroop ->
        H.img [ A.src "img/ahg_share.png" ] []

      C.BsaCubs ->
        H.img [ A.src "img/pack_share.png" ] []

      C.BsaClub ->
        H.img [ A.src "img/bsa_share.png" ] []

      C.BsaCrew ->
        H.img [ A.src "img/bsa_share.png" ] []

      C.AuPack ->
        H.img [ A.src "img/bsa_share.png" ] []

      C.TlTroop ->
        H.img [ A.src "img/tl_share.png" ] []

      C.BadenPowell ->
        H.img [ A.src "img/bsa_share.png" ] []

      C.NzGrp ->
        H.img [ A.src "img/bsa_share.png" ] []

      C.BsaTeam ->
        H.img [ A.src "img/bsa_share.png" ] []

      C.Cap ->
        H.img [ A.src "img/cap_share.png" ] []

      C.SeaScouts ->
        H.img [ A.src "img/ship_share.png" ] []

      C.UnknownTroopType ->
        H.img [ A.src "img/bsa_share.png" ] []


albumContent : Address Update.Action -> Model -> Html
albumContent address model =
  case model.currentAlbum of

    Nothing ->
      H.div
        [ A.id "gallery" ]
        [ albumThumbnails address model
        ]

    Just anAlbum ->
      H.div
        [ A.id "gallery" ]
        [ photoThumbnails address anAlbum model
        ]




albumName : PhotoAlbum -> String
albumName album =
  album.name ++ " (" ++ album.takenOn ++ ")"


albumThumbnails : Address Update.Action -> Model -> Html
albumThumbnails address model =
  H.div
    [ A.class "gallery-items"]
    <| List.map (albumThumbnail address) model.photoAlbums


albumThumbnail : Address Update.Action -> PhotoAlbum -> Html
albumThumbnail address album =
  let
    thumbUrl =
      List.head album.photos
        |> Maybe.map .thumbUrl
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
          , A.src thumbUrl
          ]
          []
        ]
      ]


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

    downloadButtonStyle =
      A.style
        [ ( "font-size", "1.2em" )
        , ( "padding", "10px" )
        ]

    downloadButton =
      case maybeDownload of

        Nothing ->
          H.a
            [ A.href "#"
            , A.title "Download Photo"
            , E.onClick address (Update.DownloadPhoto photo)
            ]
            [ fontAwesome "download" ]

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
        , A.src photo.thumbUrl
        , A.title photoName
        ]
        []
      , H.div
        [ downloadButtonStyle ]
        [ downloadButton
        ]
      ]
