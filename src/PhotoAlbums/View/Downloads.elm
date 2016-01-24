module PhotoAlbums.View.Downloads where

import Html as H exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Signal exposing (Address)
import Dict


import PhotoAlbums.Update as Update
import PhotoAlbums.Model as Model exposing (Model, PhotoAlbum)
import PhotoAlbums.View.Helpers exposing (fontAwesome)

downloadAlbumButton : Address Update.Action -> PhotoAlbum -> Model -> Html
downloadAlbumButton address album model =
  let
    photoCount =
      albumPhotoCount album

    downloads =
      downloadCount album model

    progressCount =
      photoCount - downloads

    theButton =
      H.a
        [ A.href "#"
        , A.title "Download All"
        , E.onClick address <| Update.DownloadAlbum album
        ]
        [ fontAwesome "download"
        ]

    theProgress =
      H.progress
        [ A.max (toString photoCount)
        , A.value (toString progressCount)
        ]
        []

  in
    if downloads > 0
      then theProgress
      else theButton


albumPhotoCount : PhotoAlbum -> Int
albumPhotoCount album =
  List.length album.photos


downloadCount : PhotoAlbum -> Model -> Int
downloadCount album model =
  let
    isDownloading photo =
      Dict.member photo.photoId model.photoDownloads

    activeDownloads =
      List.filter isDownloading album.photos
  in
    List.length activeDownloads
