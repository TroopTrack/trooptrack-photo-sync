module App.Model where

import Login.Model as Login

type alias Model =
  { page : Page
  , loginInfo : Login.Model
  }

type Page
  = LoginPage
  | PhotoAlbumPage


initialModel : Model
initialModel =
  { page = LoginPage
  , loginInfo = Login.initialModel
  }