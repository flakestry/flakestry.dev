module Pages.Flake.Github.Org_.Repo_.Version_ exposing
    ( Model
    , Msg
    , init
    , page
    , subscriptions
    , update
    , view
    )

import Api
import Api.Data as Api
import Api.Request.Default as Api
import Api.Time as ApiTime
import Components.File as File
import Effect exposing (Effect)
import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Octicons
import Page exposing (Page)
import RemoteData exposing (WebData)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


page : Shared.Model -> Route { org : String, repo : String, version : String } -> Page Model Msg
page _ route =
    Page.new
        { init = init route.params.org route.params.repo route.params.version
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { repoResponse : WebData Api.RepoResponse }


init : String -> String -> String -> () -> ( Model, Effect Msg )
init org repo version _ =
    ( { repoResponse = RemoteData.NotAsked }
    , Effect.sendCmd <|
        Api.send HandleGetRepoResponse <|
            Api.readRepoFlakeGithubOwnerRepoGet org repo
    )



-- UPDATE


type Msg
    = HandleGetRepoResponse (Result Http.Error Api.RepoResponse)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        HandleGetRepoResponse response ->
            ( { model | repoResponse = RemoteData.fromResult response }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> View Msg
view model =
    let
        latestRelease =
            model.repoResponse |> RemoteData.toMaybe |> Maybe.andThen .latest

        title =
            latestRelease
                |> Maybe.map (\release -> "Flake " ++ release.owner ++ "/" ++ release.repo)
                |> Maybe.withDefault ""

        releaseBody =
            latestRelease
                |> Maybe.map viewRelease
                |> Maybe.withDefault (div [] [])
    in
    { title = title
    , body =
        [ Flakestry.Layout.viewNav
        , releaseBody
        , Flakestry.Layout.viewFooter
        ]
    }


viewRelease : Api.FlakeRelease -> Html Msg
viewRelease release =
    div [ class "container max-w-5xl px-4" ]
        [ div [ class "py-16 leading-6" ]
            [ h2 [ class "inline-flex items-center font-semibold text-2xl" ]
                [ img [ class "inline h-7 w-7 rounded border border-slate-300", src ("https://github.com/" ++ release.owner ++ ".png?size=128") ] []
                , a
                    [ class "ml-2 hover:text-sky-500"
                    , Route.Path.href (Route.Path.Flake_Github_Org_ { org = release.owner })
                    ]
                    [ text release.owner ]
                , span [ class "mx-2" ] [ text "/" ]
                , a
                    [ class "hover:text-sky-500"
                    , Route.Path.href (Route.Path.Flake_Github_Org__Repo_ { org = release.owner, repo = release.repo })
                    ]
                    [ text release.repo ]
                ]
            , p [ class "mt-3 text-lg" ] [ text release.description ]
            , p [ class "mt-3 text-sm inline-flex items-center" ]
                [ Octicons.defaultOptions
                    |> Octicons.color "currentColor"
                    |> Octicons.class "inline"
                    |> Octicons.clock
                , span [ class "ml-1" ]
                    [ text <|
                        ApiTime.dateTimeToString release.createdAt
                    ]
                ]
            , button
                [ class "flex items-center justify-between mt-6 pl-2 pr-3 py-2 border rounded shadow-sm text-slate-900 bg-slate-100"
                , type_ "button"
                , attribute "aria-label" "Version"
                ]
                [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline" |> Octicons.tag
                , span [ class "ml-2" ] [ text release.version ]

                -- TODO: add a latest tag to the latest version
                -- , span [ class "ml-2 text-slate-600" ] [ text "(latest)" ]
                , Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline ml-3" |> Octicons.chevronDown
                ]
            ]
        , File.defaultOptions
            |> File.fileName "README"
            |> File.class "markdown-body"
            |> File.contents release.readme
            |> File.view
        ]
