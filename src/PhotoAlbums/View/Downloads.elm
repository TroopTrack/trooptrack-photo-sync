module PhotoAlbums.View.Downloads where


import Html as H exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Signal exposing (Address)
import Dict


import PhotoAlbums.Update as Update
import PhotoAlbums.Model as Model exposing (Model, PhotoAlbum)
import PhotoAlbums.View.Helpers exposing (fontAwesome)

downloadAllButton : Address Update.Action -> PhotoAlbum -> Model -> Html
downloadAllButton address album model =
  let
    isDownloading photo =
      Dict.member photo.photoId model.photoDownloads

    activeDownloads =
      List.filter isDownloading album.photos

    photoCount =
      List.length album.photos

    downloadCount =
      List.length activeDownloads

    progressCount =
      photoCount - downloadCount

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
    if List.length activeDownloads > 0
      then theProgress
      else theButton
