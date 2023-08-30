module Components.FlakeCard exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Octicons
import Route.Path


type alias FlakeCard =
    { username : String
    , repo : String
    , version : String
    , description : String
    }


view : FlakeCard -> Html msg
view card =
    a
        [ class "relative mx-auto w-full overflow-hidden text-lg block bg-white rounded-md shadow-sm border border-slate-150 transition hover:border-transparent hover:ring-sky-500 hover:ring-2"
        , Route.Path.href (Route.Path.Flake_Github_Org__Repo__Version_ { org = card.username, repo = card.repo, version = card.version })
        ]
        [ div
            [ class "relative px-4 pt-4 pb-6 md:px-8" ]
            [ div []
                [ div [ class "inline-flex items-center flex-wrap" ]
                    [ span [ class "inline-flex items-center mr-4" ]
                        [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline" |> Octicons.markGithub
                        , h3 [ class "ml-2 font-semibold truncate" ]
                            [ span [] [ text card.username ]
                            , span [ class "mx-1" ] [ text "/" ]
                            , span [] [ text card.repo ]
                            ]
                        ]
                    , span [ class "my-2 whitespace-nowrap bg-slate-100 rounded p-1 text-sm font-medium" ]
                        [ span [] [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.size 14 |> Octicons.class "inline" |> Octicons.tag ]
                        , span [ class "ml-1" ] [ text card.version ]
                        ]
                    ]
                ]
            , p [ class "mt-2 truncate" ] [ text card.description ]
            ]
        ]
