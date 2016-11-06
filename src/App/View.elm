module App.View exposing (..)

import Html as H exposing (Html)
import Html.App
import App.Model exposing (Model)
import App.Update as Update
import Login.View as Login
import PhotoAlbums.View as PhotoAlbums
import Loading.View as Loading
import Pages


view : Model -> Html Update.Action
view model =
    case model.page of
        Pages.LoadingPage ->
            Loading.view

        Pages.LoginPage ->
            Login.view model.loginInfo
                |> Html.App.map Update.Authentication

        Pages.PhotoAlbumsPage ->
            PhotoAlbums.view model.troopTypes
                model.loginInfo.credentials
                model.photoAlbums
                |> Html.App.map Update.PhotoAlbums
