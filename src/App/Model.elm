module App.Model where

import Login.Model as Login
import PhotoAlbum.Model as PhotoAlbum

type alias Model =
  { page : Page
  , loginInfo : Login.Model
  , photoAlbum : PhotoAlbum.Model
  }

type Page
  = LoginPage
  | PhotoAlbumPage
  | LoadingPage


initialModel : Model
initialModel =
  { page = LoadingPage
  , loginInfo = Login.initialModel
  , photoAlbum = PhotoAlbum.initialModel
  }