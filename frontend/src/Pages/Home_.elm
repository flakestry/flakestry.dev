module Pages.Home_ exposing (Model, Msg, page)

import Api
import Api.Data as Api
import Api.Request.Api as Api
import Components.FlakeCard
import Components.Search as Search
import Dict
import Effect exposing (Effect)
import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Octicons
import Page exposing (Page)
import RemoteData exposing (WebData)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init route
        , update = update route
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { searchState : Search.Model
    , latestFlakesResponse : WebData Api.GetFlakeResponse
    }


init : Route () -> () -> ( Model, Effect Msg )
init route () =
    let
        newSearchState =
            Search.init (Dict.get "q" route.query)

        newModel =
            { searchState = newSearchState
            , latestFlakesResponse = RemoteData.NotAsked
            }

        newEffect =
            Effect.batch
                [ -- Load the latest flakes
                  Effect.sendCmd <|
                    Api.send HandleFlakesResponse (Api.getFlake Nothing)

                -- Search for flakes based on the query in the url
                , case newSearchState.query of
                    Nothing ->
                        Effect.none

                    Just _ ->
                        Effect.sendMsg (HandleSearch Search.Search)
                ]
    in
    ( newModel
    , newEffect
    )



-- UPDATE


type Msg
    = HandleSearch Search.Msg
    | HandleFlakesResponse (Result Http.Error Api.GetFlakeResponse)


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        HandleSearch searchMsg ->
            let
                ( newSearchState, newSearchEffect ) =
                    Search.update searchMsg model.searchState
            in
            ( { model | searchState = newSearchState }
            , Effect.batch
                [ Effect.map HandleSearch newSearchEffect
                , pushQueryToRoute model.searchState searchMsg route "q"
                ]
            )

        HandleFlakesResponse response ->
            let
                newModel =
                    { model | latestFlakesResponse = RemoteData.fromResult response }
            in
            ( newModel
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    let
        newTitle =
            case model.searchState.query of
                Nothing ->
                    "flakestry: find, install, and publish Nix Flakes"

                Just query ->
                    query ++ ": flakestry search"
    in
    { title = newTitle
    , body =
        Flakestry.Layout.viewBody
            [ Flakestry.Layout.viewNav
            , {- Content -}
              main_ []
                [ div
                    [ class "container px-4 py-24 max-w-3xl" ]
                    [ h1
                        [ class "text-4xl md:text-center font-semibold"
                        ]
                        [ text "Find, Install, and Publish ", a [ href "https://nix.dev/concepts/flakes/", class "text-blue-900 hover:text-sky-500" ] [ text "Nix Flakes" ], text "." ]
                    , Search.view { onSearch = HandleSearch } model.searchState

                    -- , hr [ class "mt-36 border-t border-slate-200" ] []
                    , viewSearchResults model.latestFlakesResponse model.searchState
                    ]
                ]
            , Flakestry.Layout.viewFooter
            ]
    }


viewSearchResults : WebData Api.GetFlakeResponse -> Search.Model -> Html msg
viewSearchResults latestFlakesResponse searchState =
    if searchState.query == Nothing then
        viewLatestFlakes latestFlakesResponse

    else
        div []
            [ h2 [ class "max-w-3xl flex items-center pt-12 text-xl text-slate-900 font-semibold" ]
                [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline h-5 w-5" |> Octicons.search
                , span [ class "ml-2" ] [ text "Search results" ]
                ]
            , p [ class "mt-6 text-sm text-slate-600" ]
                [ span [] [ text <| "Found " ++ String.fromInt (getSearchCount searchState.searchResponse) ++ " flakes that match " ]
                , span [ class "font-semibold" ] [ text <| Maybe.withDefault "" searchState.query ]
                , text "."
                ]
            , viewFlakeResults searchState.searchResponse
            ]


viewLatestFlakes : WebData Api.GetFlakeResponse -> Html msg
viewLatestFlakes latestFlakesResponse =
    div []
        [ h2 [ class "max-w-3xl flex items-center pt-12 text-xl text-slate-900 font-semibold" ]
            [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline h-5 w-5" |> Octicons.clock
            , span [ class "ml-2" ] [ text "Recently released flakes" ]
            ]
        , viewFlakeResults latestFlakesResponse
        ]


viewFlakeResults : WebData Api.GetFlakeResponse -> Html msg
viewFlakeResults response =
    case response of
        RemoteData.Success flakes ->
            let
                viewFlakes =
                    if flakes.count == 0 then
                        [ div [ class "mt-12" ] [] ]

                    else
                        List.map
                            (\flake ->
                                Components.FlakeCard.view
                                    { username = flake.owner
                                    , repo = flake.repo
                                    , version = flake.version
                                    , description = flake.description
                                    }
                            )
                            flakes.releases
            in
            div [ class "flex flex-col space-y-4 mt-12" ] viewFlakes

        RemoteData.Failure _ ->
            div [ class "mt-12" ] [ text "Failed to load flakes" ]

        _ ->
            div [ class "mt-12" ] [ text "Loading..." ]


getSearchCount : WebData Api.GetFlakeResponse -> Int
getSearchCount response =
    case response of
        RemoteData.Success flakes ->
            flakes.count

        _ ->
            0


pushQueryToRoute : Search.Model -> Search.Msg -> Route r -> String -> Effect msg
pushQueryToRoute searchState msg route queryParam =
    let
        newQuery =
            case msg of
                Search.Search ->
                    case searchState.query of
                        Nothing ->
                            Dict.remove queryParam route.query

                        Just q ->
                            Dict.insert queryParam q route.query

                _ ->
                    route.query
    in
    Effect.pushRoute { path = route.path, query = newQuery, hash = route.hash }
