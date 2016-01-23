module PhotoAlbums.View where

import String
import Dict

import Signal exposing (Address)

import Html as H exposing (Html, Attribute)
import Html.Attributes as A
import Html.Events as E

import Credentials as C
import PhotoAlbums.Update as Update
import PhotoAlbums.Model as Model exposing (Model, PhotoAlbum, Photo)


view : Address Update.Action -> C.TroopTypes -> C.Credentials -> Model -> Html
view address troopTypes credentials model =
 H.div
  []
  [ topbar address model
  , H.div
    [ A.class "content" ]
    [ content address troopTypes credentials model
    ]
  , menu address model
  , mask model
  ]


menu : Address Update.Action -> Model -> Html
menu address model =
  H.nav
    [ A.id "menu",
      A.class <| menuStateClass model
    ]
    [ H.ul
      [ A.class "menu-items"
      ]
      [ menuItem
          address
          (Update.SetMenuState Model.MenuOff)
          (fontAwesome "times")
          "Close Menu"
          False
      , menuItem
          address
          Update.Logout
          (fontAwesome "sign-out")
          "Sign out"
          False
      , menuItem
          address
          Update.DisplayTroopSelection
          (fontAwesome "users")
          "Troops"
          False
      ]
    , troopMenu address model
    , albumsMenu address model
    ]


troopMenu : Address Update.Action -> Model -> Html
troopMenu address model =
  case model.user of
    Nothing ->
      H.text ""

    Just user ->
      let
        isCurrent album =
          case album of
            Nothing -> True
            Just _ -> False
      in
        H.ul
          [ A.class "menu-items" ]
          [ menuItem
              address
              (Update.CurrentAlbum Nothing)
              (fontAwesome "caret-down")
              user.troop
              (isCurrent model.currentAlbum)
          ]


albumsMenu : Address Update.Action -> Model -> Html
albumsMenu address model =
  let
    isCurrent album =
      case model.currentAlbum of
        Nothing ->
          False

        Just current ->
          current.photoAlbumId == album.photoAlbumId

    albumMenuItem album =
      menuItem
        address
        (Update.CurrentAlbum (Just album))
        (fontAwesome "picture-o")
        album.name
        (isCurrent album)
  in
    H.ul
      [ A.class "menu-items" ]
      <| List.map albumMenuItem model.photoAlbums


menuItem : Address Update.Action
        -> Update.Action
        -> Html
        -> String
        -> Bool
        -> Html
menuItem address action icon text current =
  let
    class =
      if current
        then "menu-item current"
        else "menu-item"
  in
    H.li
      [ A.class class ]
      [ H.a
        [ A.href "#"
        , E.onClick address action
        , A.class "menu-link"
        ]
        [ icon
        , H.span
          [ A.class "title" ]
          [ H.text text ]
        ]
      ]


fontAwesome : String -> Html
fontAwesome iconName =
  let
    className = "fa fa-" ++ iconName
  in
    H.i [ A.class className ] []


mask : Model -> Html
mask model =
  H.div
    [ A.class <| "mask " ++ menuStateClass model
    , A.id "mask"
    ]
    []


menuStateClass : Model -> String
menuStateClass model =
  case model.menuState of
    Model.MenuOn ->
      "active"

    Model.MenuOff ->
      ""


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

    hamburger =
      H.i [ A.class "fa fa-bars" ] []
  in
    H.div
      [ A.id "top-bar" ]
      [ item [ button ]
      ]


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


nowrapText : Attribute
nowrapText =
  A.style
    [ ( "white-space", "nowrap" )
    , ( "overflow", "hidden" )
    , ( "text-overflow", "ellipsis" )
    ]


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
