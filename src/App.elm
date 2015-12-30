module App where

import StartApp
import Task
import Effects exposing (Effects)

import App.Model exposing (Model)
import App.View exposing (view)
import App.Update as AppU exposing (update, init, getCurrentUserBox)

import Login.Model as Login
import Login.Update exposing (storeUsersBox)

app : StartApp.App Model
app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [ setCurrentUserSignal
               ]
    }


main =
  app.html

-- Ports

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks

port storeUsersSignal : Signal Login.Credentials
port storeUsersSignal =
  storeUsersBox.signal

port getCurrentUserSignal : Signal ()
port getCurrentUserSignal =
  getCurrentUserBox.signal

port setCurrentUser : Signal (Maybe (Login.Credentials))

setCurrentUserSignal : Signal AppU.Action
setCurrentUserSignal =
  Signal.map AppU.CurrentUser setCurrentUser