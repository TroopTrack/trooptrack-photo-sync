module PhotoAlbums.View.Menu where

import Html as H exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Signal exposing (Address)

import PhotoAlbums.Update as Update
import PhotoAlbums.Model as Model exposing (Model, PhotoAlbum)
import PhotoAlbums.View.Helpers exposing (fontAwesome, nowrapText)

import PhotoAlbums.View.Downloads exposing (albumPhotoCount, downloadCount)

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
              (fontAwesome "angle-down")
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

    item album =
      albumMenuItem
        address
        (isCurrent album)
        model
        album
  in
    H.ul
      [ A.class "menu-items" ]
      <| List.map item model.photoAlbums


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
      [ A.class class
      , nowrapText
      ]
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


albumMenuItem : Address Update.Action
             -> Bool
             -> Model
             -> PhotoAlbum
             -> Html
albumMenuItem address current model album =
  let
    class =
      if current
        then "menu-item current"
        else "menu-item"

    totalCount =
      albumPhotoCount album

    totalPhotos =
      toString totalCount ++ " photos"

    downloads =
      downloadCount album model

    downloadingMessage =
      "Downloading " ++ toString downloads ++ " of " ++ totalPhotos

    photoCount =
      if downloads > 0
        then downloadingMessage
        else totalPhotos

  in
    H.li
      [ A.class class
      , nowrapText
      ]
      [ H.a
        [ A.href "#"
        , E.onClick address <| Update.CurrentAlbum (Just album)
        , A.class "menu-link"
        ]
        [ H.span
          [ A.class "album-icon" ]
          [ fontAwesome "picture-o" ]
        , H.div
          [ A.class "name" ]
          [ H.text album.name ]
        , H.div
          [ A.class "count" ]
          [ H.text photoCount ]
        ]
      ]


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
