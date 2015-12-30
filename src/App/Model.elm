module App.Model where

import Login.Model as Login

type alias Model =
  { page : Page
  , loginInfo : Login.Model
  }

type Page
  = LoginPage
  | PhotoAlbumPage
  | LoadingPage


initialModel : Model
initialModel =
  { page = LoadingPage
  , loginInfo = Login.initialModel
  }