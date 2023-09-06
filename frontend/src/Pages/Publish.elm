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
        [ Flakestry.Layout.viewNav
        , main_ []
            [ div
                [ class "container px-4 max-w-5xl" ]
                [ h1
                    [ class "py-24 text-4xl font-semibold md:text-center"
                    ]
                    [ text "Publish your Flake for each tag" ]
                , File.defaultOptions
                    |> File.fileName ".github/workflows/publish.yaml"
                    |> File.contents publishFlakeMarkdown
                    |> File.setCopyableContents (Just publishFlakeYaml)
                    |> File.view
                ]
            ]
        , Flakestry.Layout.viewFooter
        ]
    }


publishFlakeMarkdown : String
publishFlakeMarkdown =
    "```yaml\n" ++ publishFlakeYaml ++ "\n```"


publishFlakeYaml : String
publishFlakeYaml =
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
