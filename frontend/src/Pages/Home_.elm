module Pages.Home_ exposing (page)

import Html exposing (..)
import Html.Attributes exposing (..)
import Svg
import Svg.Attributes as SvgAttr
import View exposing (View)


page : View msg
page =
    { title = "flakestry"
    , body =
        [ viewNav
        , {- Content -}
          main_
            [ class ""
            ]
            [ div
                [ class "container py-24 max-w-4xl" ]
                [ h1
                    [ class "text-4xl font-semibold mb-4"
                    ]
                    [ text "Find, Install, and Publish Nix Flakes" ]
                , p [ class "pb-8" ]
                    [ text "Here goes flakes ..." ]
                , label [ class "relative block" ]
                    [ span [ class "sr-only" ] [ text "Search" ]
                    , span [ class "absolute inset-y-0 left-0 flex items-center pl-4" ]
                        [ Svg.svg
                            [ SvgAttr.viewBox "0 0 20 20"
                            , SvgAttr.class "h-6 w-6 fill-slate-300"
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
                        [ class "placeholder:text-slate-400 text-lg block bg-white w-full border border-slate-300 rounded-md py-4 pl-14 pr-3 shadow-sm focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1"
                        , placeholder "⌘ K to search for flakes..."
                        , type_ "text"
                        , name "search"
                        ]
                        []
                    ]
                ]
            ]
        , viewFooter
        ]
    }


viewNav : Html msg
viewNav =
    nav
        [ class "py-4"
        ]
        [ div
            [ class "container max-w-4xl"
            ]
            [ div
                [ class "flex justify-between items-center"
                ]
                [ div [ class "flex space-x-2" ]
                    [ img [ src "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake.svg", class "w-7" ] []
                    , a
                        [ href "/"
                        , class "text-xl font-bold tracking-tight"
                        ]
                        [ text "Flakestry" ]
                    ]
                , div [ class "flex" ]
                    [ ul
                        [ class "flex items-center space-x-6 mr-6 text-sm leading-6 font-semibold"
                        ]
                        [ li [ class "hover:text-sky-500" ]
                            [ a
                                [ href "#" ]
                                [ text "About" ]
                            ]
                        , li [ class "hover:text-sky-500" ]
                            [ a [ href "#" ]
                                [ text "Docs" ]
                            ]
                        ]
                    , div [ class "flex items-center space-x-2" ]
                        [ button [ class "bg-blue-950 text-white text-sm font-bold py-1 px-4 rounded hover:bg-blue-600 inline-flex items-center py-2" ]
                            [ Svg.svg
                                [ SvgAttr.fill "none"
                                , SvgAttr.viewBox "0 0 24 24"
                                , SvgAttr.strokeWidth "2"
                                , SvgAttr.stroke "currentColor"
                                , SvgAttr.class "w-5 h-5 mr-2"
                                ]
                                [ Svg.path
                                    [ SvgAttr.strokeLinecap "round"
                                    , SvgAttr.strokeLinejoin "round"
                                    , SvgAttr.d "M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5"
                                    ]
                                    []
                                ]
                            , span [] [ text "Publish" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


viewFooter : Html msg
viewFooter =
    footer
        [ class "bg-blue-950 text-white p-4 fixed w-full bottom-0"
        ]
        [ div
            [ class "container max-w-4xl"
            ]
            [ p []
                [ text "Read more about this project <here>." ]
            ]
        ]
