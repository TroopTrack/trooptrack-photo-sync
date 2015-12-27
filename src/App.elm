module App where

import StartApp
import Task
import Effects exposing (Effects)

import App.Model exposing (Model)
import App.View exposing (view)
import App.Update exposing (update, init)

app : StartApp.App Model
app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks