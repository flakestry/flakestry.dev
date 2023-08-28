module Pages.Publish exposing (page)

import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown
import View exposing (View)


page : View msg
page =
    { title = "flakestry - Publish"
    , body =
        [ Flakestry.Layout.viewNav
        , main_ []
            [ div
                [ class "container py-24 max-w-5xl" ]
                [ h1
                    [ class "text-4xl font-semibold md:text-center"
                    ]
                    [ text "Publish your Flake for each tag:" ]
                , h2
                    [ class "text-2xl md:text-center mt-12 mb-4 "
                    ]
                    [ span [ class "text-white bg-black p-2" ] [ text ".github/workflows/publish.yaml" ] ]
                , pre [] [ Markdown.toHtml [ class "content  p-4 bg-black" ] """
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
                """ ]
                ]
            ]
        , Flakestry.Layout.viewFooter
        ]
    }
