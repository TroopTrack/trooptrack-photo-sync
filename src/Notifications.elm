module Notifications exposing (..)


type alias Notification =
    { msgType : String
    , message : String
    }


empty : Notification
empty =
    Notification "" ""


error : String -> Notification
error =
    Notification "error"


info : String -> Notification
info =
    Notification "info"
