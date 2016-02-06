module Notifications where

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

-- Signals and Mailboxes

notifications : Signal.Mailbox Notification
notifications =
  Signal.mailbox empty
