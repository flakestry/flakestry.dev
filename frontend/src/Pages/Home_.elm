module Pages.Home_ exposing (Model, Msg, page)

import Api
import Api.Data as Api
import Api.Request.Default as Api
import Components.FlakeCard
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
    { latestFlakesResponse : WebData Api.FlakesResponse }


init : () -> ( Model, Effect Msg )
init () =
    ( { latestFlakesResponse = RemoteData.NotAsked }
    , Effect.sendCmd <|
        Api.send HandleFlakesResponse (Api.getFlakesFlakeGet Nothing)
    )



-- UPDATE


type Msg
    = HandleFlakesResponse (Result Http.Error Api.FlakesResponse)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
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


view : Model -> View msg
view model =
    { title = "flakestry"
    , body =
        [ Flakestry.Layout.viewNav
        , {- Content -}
          main_ []
            [ div
                [ class "container px-4 py-24 max-w-3xl" ]
                [ h1
                    [ class "text-4xl md:text-center font-semibold"
                    ]
                    [ text "Find, Install, and Publish ", a [ href "https://nix.dev/concepts/flakes/", class "text-blue-900 hover:text-sky-500" ] [ text "Nix Flakes" ], text "." ]
                , label [ class "max-w-3xl mx-auto relative block mt-8" ]
                    [ span [ class "sr-only" ] [ text "Search" ]
                    , span [ class "absolute inset-y-0 left-0 flex items-center pl-4" ]
                        [ Svg.svg
                            [ SvgAttr.viewBox "0 0 20 20"
                            , SvgAttr.class "h-6 w-6 fill-slate-400"
                            ]
                            [ Svg.path
                                [ SvgAttr.fillRule "evenodd"
                                , SvgAttr.clipRule "evenodd"
                                , SvgAttr.d "M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                                ]
                                []
                            ]
                        ]
                    , input
                        [ class "placeholder:text-slate-400 text-lg block bg-white w-full border border-slate-300 rounded-md py-4 pl-14 pr-3 shadow-md focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1"
                        , placeholder "Search for flakes..."
                        , type_ "text"
                        , name "search"
                        ]
                        []
                    ]
                , hr [ class "mt-36 border-t border-slate-200" ] []
                , h2 [ class "max-w-3xl flex items-center pt-12 text-xl text-slate-900 font-semibold" ]
                    [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline h-5 w-5" |> Octicons.clock
                    , span [ class "ml-2" ] [ text "Recently released flakes" ]
                    ]
                , viewLatestFlakes model.latestFlakesResponse
                ]
            ]
        , Flakestry.Layout.viewFooter
        ]
    }


viewLatestFlakes : WebData Api.FlakesResponse -> Html msg
viewLatestFlakes response =
    case response of
        RemoteData.Success flakes ->
            div [ class "flex flex-col space-y-4 mt-12" ] <|
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

        RemoteData.Failure _ ->
            div [ class "mt-12" ] [ text "Failed to load flakes" ]

        _ ->
            div [ class "mt-12" ] [ text "Loading..." ]
