module Pages.Flake.Github.Org_ exposing (Model, Msg, page)

import Api
import Api.Data
import Api.Request.Default as Api
import Components.FlakeCard
import Effect exposing (Effect)
import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Octicons
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


page : Shared.Model -> Route { org : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init route.params.org
        , update = update
        , subscriptions = subscriptions
        , view = view route.params.org
        }



-- INIT


type alias Model =
    { repos : Api.Data.OwnerResponse }


init : String -> () -> ( Model, Effect Msg )
init org () =
    ( { repos = Api.Data.OwnerResponse [] }
    , Effect.sendCmd <|
        Api.send HandleGetOwnerResponse <|
            Api.readOwnerFlakeGithubOwnerGet org
    )



-- UPDATE


type Msg
    = HandleGetOwnerResponse (Result Http.Error Api.Data.OwnerResponse)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        HandleGetOwnerResponse result ->
            ( { model | repos = result |> Result.withDefault (Api.Data.OwnerResponse []) }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : String -> Model -> View Msg
view org model =
    { title = org
    , body =
        [ Flakestry.Layout.viewNav
        , div [ class "container max-w-5xl px-4 min-h-100vh" ]
            [ h2 [ class "inline-flex items-center font-semibold text-2xl py-16" ]
                [ img [ class "inline h-7 w-7 rounded border border-slate-300", src ("https://github.com/" ++ org ++ ".png?size=128") ] []
                , span [ class "ml-2" ] [ text org ]
                ]
            , viewRepoCard model.repos.repos
            ]
        , Flakestry.Layout.viewFooter
        ]
    }


viewRepoCard : List Api.Data.FlakeReleaseCompact -> Html Msg
viewRepoCard repos =
    div [ class "space-y-4" ]
        (List.map
            (\repo ->
                Components.FlakeCard.view
                    { username = repo.owner
                    , repo = repo.repo
                    , version = repo.version
                    , description = repo.description
                    }
            )
            repos
        )
