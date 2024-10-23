module Pages.Flake.Github.Org_ exposing (Model, Msg, page)

import Api
import Api.Data
import Api.Request.Api as Api
import Components.FlakeCard
import Effect exposing (Effect)
import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Page exposing (Page)
import RemoteData exposing (WebData)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route { org : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init route.params.org
        , update = update
        , subscriptions = subscriptions
        , view = view route.params.org
        }



-- INIT


type alias Model =
    { ownerResponse : WebData Api.Data.GetOwnerResponse }


init : String -> () -> ( Model, Effect Msg )
init org () =
    ( { ownerResponse = RemoteData.NotAsked }
    , Effect.sendCmd <|
        Api.send HandleGetOwnerResponse <|
            Api.getOwner org
    )



-- UPDATE


type Msg
    = HandleGetOwnerResponse (Result Http.Error Api.Data.GetOwnerResponse)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        HandleGetOwnerResponse result ->
            ( { model | ownerResponse = RemoteData.fromResult result }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : String -> Model -> View Msg
view org model =
    { title = org
    , body =
        Flakestry.Layout.viewBody
            [ Flakestry.Layout.viewNav
            , div [ class "container max-w-5xl px-4" ]
                [ h2 [ class "inline-flex items-center font-semibold text-2xl py-16" ]
                    [ img [ class "inline h-7 w-7 rounded border border-slate-300", src ("https://github.com/" ++ org ++ ".png?size=128") ] []
                    , span [ class "ml-2" ] [ text org ]
                    ]
                , RemoteData.unwrap
                    (div [] [])
                    (\response -> response |> .repos |> viewRepoCard)
                    model.ownerResponse
                ]
            , Flakestry.Layout.viewFooter
            ]
    }


viewRepoCard : List Api.Data.FlakeRelease -> Html Msg
viewRepoCard repos =
    div [ class "space-y-4" ]
        (List.map
            (\repo ->
                Components.FlakeCard.view
                    { username = repo.owner
                    , repo = repo.repo
                    , version = repo.version
                    , description = repo.description
                    }
            )
            repos
        )
