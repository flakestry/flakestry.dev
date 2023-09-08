module Pages.Home_ exposing (Model, Msg, page)

import Api
import Api.Data as Api
import Api.Request.Default as Api
import Components.FlakeCard
import Components.Search as Search
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
import Svg
import Svg.Attributes as SvgAttr
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { searchState : Search.Model
    , latestFlakesResponse : WebData Api.FlakesResponse
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { searchState = Search.init
      , latestFlakesResponse = RemoteData.NotAsked
      }
    , Effect.sendCmd <|
        Api.send HandleFlakesResponse (Api.getFlakesFlakeGet Nothing)
    )



-- UPDATE


type Msg
    = HandleSearch Search.Msg
    | HandleFlakesResponse (Result Http.Error Api.FlakesResponse)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        HandleSearch searchMsg ->
            let
                ( newSearchState, newSearchEffect ) =
                    Search.update searchMsg model.searchState
            in
            ( { model | searchState = newSearchState }, Effect.map HandleSearch newSearchEffect )

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
    { title = "flakestry"
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
                    , if RemoteData.isSuccess model.searchState.searchResponse then
                        div []
                            [ h2 [ class "max-w-3xl flex items-center pt-12 text-xl text-slate-900 font-semibold" ]
                                [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline h-5 w-5" |> Octicons.search
                                , span [ class "ml-2" ] [ text "Search results" ]
                                ]
                            , viewFlakeResults model.searchState.searchResponse
                            ]

                      else
                        div []
                            [ h2 [ class "max-w-3xl flex items-center pt-12 text-xl text-slate-900 font-semibold" ]
                                [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline h-5 w-5" |> Octicons.clock
                                , span [ class "ml-2" ] [ text "Recently released flakes" ]
                                ]
                            , viewFlakeResults model.latestFlakesResponse
                            ]
                    ]
                ]
            , Flakestry.Layout.viewFooter
            ]
    }


viewFlakeResults : WebData Api.FlakesResponse -> Html msg
viewFlakeResults response =
    case response of
        RemoteData.Success flakes ->
            let
                viewFlakes =
                    if List.isEmpty flakes.releases then
                        [ div [ class "mt-12" ] [ text "No flakes found" ] ]

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
