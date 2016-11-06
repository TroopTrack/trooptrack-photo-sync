port module Ports exposing (..)

import PhotoAlbums.Model as PhotoAlbum
import Credentials
import Notifications


port downloadPhoto : PhotoAlbum.Photo -> Cmd a


port downloadAlbum : PhotoAlbum.PhotoAlbum -> Cmd a


port downloadProgress : (( Float, PhotoAlbum.Photo ) -> msg) -> Sub msg


port cancelledDownloads : (PhotoAlbum.Photo -> msg) -> Sub msg


port logout : () -> Cmd a


errorNotification : String -> Cmd a
errorNotification msg =
    Notifications.error msg |> notifications


port notifications : Notifications.Notification -> Cmd a


port errorNotifications : (String -> msg) -> Sub msg


port storeCurrentUser : Credentials.Credentials -> Cmd a


port getCurrentUser : () -> Cmd a


port setCurrentUser : (Maybe Credentials.Credentials -> msg) -> Sub msg


port sessionEnded : (Maybe Credentials.Credentials -> msg) -> Sub msg
