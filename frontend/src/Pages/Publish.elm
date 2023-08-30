module Pages.Publish exposing (page)

import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown
import Octicons
import View exposing (View)


page : View msg
page =
    { title = "flakestry - Publish"
    , body =
        [ Flakestry.Layout.viewNav
        , main_ []
            [ div
                [ class "container px-4 max-w-5xl" ]
                [ h1
                    [ class "py-24 text-4xl font-semibold md:text-center"
                    ]
                    [ text "Publish your Flake for each tag" ]
                , div
                    [ class "border border-slate-300 rounded-md shadow-sm overflow-hidden" ]
                    [ div [ class "flex justify-between px-4 py-2 border-b border-slate-300 bg-slate-100" ]
                        [ h3
                            [ class "inline-flex items-center text-slate-900"
                            ]
                            [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.size 16 |> Octicons.class "inline" |> Octicons.file
                            , span [ class "ml-2" ] [ text ".github/workflows/publish.yaml" ]
                            ]
                        , button
                            [ class "inline-flex items-center text-sm text-white font-medium pl-2 pr-3 py-2 shadow-sm rounded bg-blue-900 hover:bg-blue-600"
                            ]
                            [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.size 15 |> Octicons.class "inline" |> Octicons.clippy
                            , span [ class "ml-2" ] [ text "Copy" ]
                            ]
                        ]
                    , pre []
                        [ Markdown.toHtml [ class "px-4 py-4 content overflow-x-scroll" ] publishFlakeTemplate
                        ]
                    ]
                ]
            ]
        , Flakestry.Layout.viewFooter
        ]
    }


publishFlakeTemplate : String
publishFlakeTemplate =
    """
```yaml
name: "Publish a flake to flakestry"
on:
    push:
        tags:
        - "v?[0-9]+.[0-9]+.[0-9]+*"
    workflow_dispatch:
        inputs:
            tag:
                description: "The existing tag to publish to FlakeHub"
                type: "string"
                required: true
jobs:
    publish-flake:
        runs-on: ubuntu-latest
        permissions:
            id-token: "write"
            contents: "read"
        steps:
        - uses: actions/checkout@v3
        - uses: flakestry/flakestry-publish@main
            with:
                version: "${{ inputs.tag }}"
```
    """
