module Pages.Home_ exposing (page)

import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import Octicons
import Svg
import Svg.Attributes as SvgAttr
import View exposing (View)


page : View msg
page =
    { title = "flakestry"
    , body =
        [ Flakestry.Layout.viewNav
        , {- Content -}
          main_
            [ class "h-screen"
            ]
            [ div
                [ class "container py-24 max-w-3xl" ]
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
                , div [ class "mt-12" ]
                    [ flakeResult
                        { username = "domenkozar"
                        , repo = "elm2nix"
                        , tag = "v2.2"
                        , description = "Some flake description."
                        }
                    , flakeResult
                        { username = "cachix"
                        , repo = "devenv"
                        , tag = "v1.0"
                        , description = "Some flake description."
                        }
                    ]
                ]
            ]
        , Flakestry.Layout.viewFooter
        ]
    }


type alias Flake =
    { username : String
    , repo : String
    , tag : String
    , description : String
    }


flakeResult : Flake -> Html msg
flakeResult flake =
    div [ class "mx-auto max-w-3xl text-lg block bg-white w-full h-32 rounded-md shadow-sm border border-slate-150 p-8 mb-4" ]
        [ div [ class "flex items-center" ]
            [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline" |> Octicons.markGithub
            , a [ href "/github", class "ml-2 hover:text-sky-500" ] [ span [ class "font-semibold" ] [ text flake.username ] ]
            , span [ class "mx-2" ] [ text "/" ]
            , a [ href "/github", class "hover:text-sky-500" ] [ span [ class "font-semibold" ] [ text flake.repo ] ]
            , span [ class "ml-3 mr-1" ] [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline" |> Octicons.tag ]
            , a [ href "/github", class "hover:text-sky-500" ] [ span [ class "font-semibold" ] [ text flake.tag ] ]
            ]
        , p [ class "mt-4" ] [ text flake.description ]
        ]
