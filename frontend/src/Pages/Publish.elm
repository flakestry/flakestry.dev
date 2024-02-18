module Pages.Publish exposing (page)

import Components.File as File
import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import View exposing (View)


page : View msg
page =
    { title = "flakestry - Publish"
    , body =
        Flakestry.Layout.viewBody
            [ Flakestry.Layout.viewNav
            , main_ []
                [ div
                    [ class "container px-4 py-24 max-w-5xl" ]
                    [ h1
                        [ class "text-4xl font-semibold md:text-center" ]
                        [ text "Publish your Flake" ]
                    , p
                        [ class "mt-6 text-l text-slate-600" ]
                        [ text """
                            Currently it's possible to publish flakes via GitHub actions.
                            Here're a few examples on how to make use of it to release your very own flakes.
                        """ ]
                    , h2
                        [ class "max-w-3xl flex items-center pt-12 text-2xl text-slate-900 font-semibold py-4" ]
                        [ text "Publish your Flake for each tag" ]
                    , File.defaultOptions
                        |> File.fileName ".github/workflows/publish.yaml"
                        |> File.language "yaml"
                        |> File.contents publishTaggedFlakeYaml
                        |> File.setCopyableContents (Just publishTaggedFlakeYaml)
                        |> File.view
                    , h2
                        [ class "max-w-3xl flex items-center pt-12 text-2xl text-slate-900 font-semibold py-4" ]
                        [ text "Publish your Flake for each push to the default branch" ]
                    , File.defaultOptions
                        |> File.fileName ".github/workflows/publish.yaml"
                        |> File.language "yaml"
                        |> File.contents publishRollingFlakeYaml
                        |> File.setCopyableContents (Just publishRollingFlakeYaml)
                        |> File.view
                    ]
                ]
            , Flakestry.Layout.viewFooter
            ]
    }


publishTaggedFlakeYaml : String
publishTaggedFlakeYaml =
    """name: "Publish a flake to flakestry"
on:
    push:
        tags:
            - "v?[0-9]+.[0-9]+.[0-9]+"
            - "v?[0-9]+.[0-9]+"
    workflow_dispatch:
        inputs:
            tag:
                description: "The existing tag to publish"
                type: "string"
                required: true
jobs:
    publish-flake:
        runs-on: ubuntu-latest
        permissions:
            id-token: "write"
            contents: "read"
        steps:
            - uses: flakestry/flakestry-publish@main
              with:
                  version: "${{ inputs.tag || github.ref_name }}"
"""


publishRollingFlakeYaml : String
publishRollingFlakeYaml =
    """name: "Publish a flake to flakestry"
on:
    push:
        branches:
            - main
    workflow_dispatch:
        inputs:
            ref:
                description: "The existing reference to publish"
                type: "string"
                required: true
jobs:
    publish-flake:
        runs-on: ubuntu-latest
        permissions:
            id-token: "write"
            contents: "read"
        steps:
            - uses: flakestry/flakestry-publish@main
              with:
                ref: "${{ inputs.ref || github.ref }}"
"""
