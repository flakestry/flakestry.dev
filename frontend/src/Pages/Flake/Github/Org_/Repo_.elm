module Pages.Flake.Github.Org_.Repo_ exposing (Model, Msg, page)

import Page exposing (Page)
import Pages.Flake.Github.Org_.Repo_.Version_ as Repo
import Route exposing (Route)
import Shared


page : Shared.Model -> Route { org : String, repo : String } -> Page Model Msg
page _ route =
    Page.new
        { init = Repo.init route.params.org route.params.repo Nothing route.hash
        , subscriptions = Repo.subscriptions
        , view = Repo.view
        , update = Repo.update
        }


type alias Model =
    Repo.Model


type alias Msg =
    Repo.Msg
