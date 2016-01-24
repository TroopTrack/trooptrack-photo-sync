module External where

import Task exposing (Task)

open : String -> Task a ()
open url =
  Signal.send openExternal.address url


openExternal : Signal.Mailbox String
openExternal =
  Signal.mailbox ""
