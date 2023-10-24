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
import Dropdown
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
        { init = init route.params.org route.params.repo (Just route.params.version)
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { repoResponse : WebData Api.RepoResponse
    , versionDropdownIsOpen : Bool
    , version : Maybe String
    }


init : String -> String -> Maybe String -> () -> ( Model, Effect Msg )
init org repo version _ =
    ( { repoResponse = RemoteData.NotAsked
      , versionDropdownIsOpen = False
      , version = version
      }
    , Effect.sendCmd <|
        Api.send HandleGetRepoResponse <|
            Api.readRepoFlakeGithubOwnerRepoGet org repo
    )



-- UPDATE


type Msg
    = HandleGetRepoResponse (Result Http.Error Api.RepoResponse)
    | ToggleVersionDropdown Bool


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        HandleGetRepoResponse response ->
            ( { model | repoResponse = RemoteData.fromResult response }
            , Effect.none
            )

        ToggleVersionDropdown isOpen ->
            ( { model | versionDropdownIsOpen = isOpen }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


viewRemoteData : WebData a -> (a -> View Msg) -> View Msg
viewRemoteData webdata viewData =
    case webdata of
        RemoteData.NotAsked ->
            { title = "flakestry"
            , body =
                Flakestry.Layout.viewBody
                    [ Flakestry.Layout.viewNav
                    , Flakestry.Layout.viewFooter
                    ]
            }

        RemoteData.Loading ->
            { title = "flakestry - loading"
            , body =
                Flakestry.Layout.viewBody
                    [ Flakestry.Layout.viewNav
                    , text "loading ..."
                    , Flakestry.Layout.viewFooter
                    ]
            }

        RemoteData.Failure err ->
            { title = "flakestry - failed"
            , body =
                Flakestry.Layout.viewBody
                    [ Flakestry.Layout.viewNav
                    , text "failure loading flakes"
                    , Flakestry.Layout.viewFooter
                    ]
            }

        RemoteData.Success a ->
            viewData a


view : Model -> View Msg
view model =
    viewRemoteData model.repoResponse
        (\repo ->
            let
                maybeRelease =
                    case model.version of
                        Nothing ->
                            List.head repo.releases

                        Just version ->
                            List.filter (\release -> release.version == version) repo.releases |> List.head
            in
            case maybeRelease of
                Nothing ->
                    { title = "Flakestry - 404"
                    , body =
                        Flakestry.Layout.viewBody
                            [ Flakestry.Layout.viewNav
                            , text "No such release exists."
                            , Flakestry.Layout.viewFooter
                            ]
                    }

                Just release ->
                    { title = "Flake " ++ release.owner ++ "/" ++ release.repo
                    , body =
                        Flakestry.Layout.viewBody
                            [ Flakestry.Layout.viewNav
                            , viewRelease model repo.releases release
                            , Flakestry.Layout.viewFooter
                            ]
                    }
        )


viewRelease : Model -> List Api.FlakeRelease -> Api.FlakeRelease -> Html Msg
viewRelease model releases release =
    div [ class "container max-w-5xl px-4" ]
        [ div [ class "pt-16 pb-8 leading-6" ]
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
                , a [ href ("https://github.com/" ++ release.owner ++ "/" ++ release.repo) ] [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline m-4" |> Octicons.markGithub ]
                ]
            , viewVersionDropdown model releases release
            , p [ class "mt-3 text-sm items-center" ]
                [ Octicons.defaultOptions
                    |> Octicons.color "currentColor"
                    |> Octicons.class "inline"
                    |> Octicons.clock
                , span [ class "ml-1" ]
                    [ text <|
                        ApiTime.dateTimeToString release.createdAt
                    ]
                ]
            , p [ class "mt-3 text-lg" ] [ text release.description ]
            ]
        , let
            baseUrl =
                "https://github.com/" ++ release.owner ++ "/" ++ release.repo

            revision =
                if release.commit == "" then
                    "HEAD"

                else
                    release.commit
          in
          File.defaultOptions
            |> File.fileName "README"
            |> File.class "markdown-body"
            |> File.contents release.readme
            |> File.baseUrl (baseUrl ++ "/blob/" ++ revision ++ "/")
            |> File.rawBaseUrl (baseUrl ++ "/raw/" ++ revision ++ "/")
            |> File.view
        ]


viewVersionDropdown : Model -> List Api.FlakeRelease -> Api.FlakeRelease -> Html Msg
viewVersionDropdown model releases release =
    let
        tag =
            Octicons.defaultOptions
                |> Octicons.color "currentColor"
                |> Octicons.class "inline mr-2"
                |> Octicons.tag

        mkVersion =
            \r ->
                a
                    [ class "p-2 hover:underline hover:cursor-pointer"
                    , Route.Path.href (Route.Path.Flake_Github_Org__Repo__Version_ { org = r.owner, repo = r.repo, version = r.version })
                    ]
                    [ tag, text r.version ]
    in
    Dropdown.dropdown
        { identifier = "version-dropdown"
        , toggleEvent = Dropdown.OnClick
        , drawerVisibleAttribute = class "visible"
        , onToggle = ToggleVersionDropdown
        , layout =
            \{ toDropdown, toToggle, toDrawer } ->
                toDropdown div
                    [ class "ml-6" ]
                    [ toToggle button
                        [ class "flex items-center justify-between pl-2 pr-3 py-2 border rounded shadow-sm text-slate-900 bg-slate-100"
                        , type_ "button"
                        , attribute "aria-label" "Version"
                        ]
                        [ tag
                        , text release.version
                        , Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline ml-3" |> Octicons.chevronDown
                        ]
                    , toDrawer div
                        [ class "grid grid-cols-1 items-center justify-between pl-2 pr-3 py-2 border rounded shadow-sm text-slate-900 bg-slate-100" ]
                        (List.map mkVersion releases)
                    ]
        , isToggled = model.versionDropdownIsOpen
        }
