module Pages.Flake.Github.Org_ exposing (Model, Msg, page)

import Api
import Api.Request.Default
import Components.FlakeCard
import Effect exposing (Effect)
import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import Octicons
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import Url
import View exposing (View)


page : Shared.Model -> Route { org : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init route
        , update = update
        , subscriptions = subscriptions
        , view = view route.params.org
        }



-- INIT


type alias Model =
    {}


init : Route { org : String } -> () -> ( Model, Effect Msg )
init route () =
    -- let
    --     toBaseName url =
    --         Url.toString { url | path = "", query = Nothing, fragment = Nothing }
    --
    --     host =
    --         toBaseName route.url
    -- in
    ( {}
    , Effect.sendCmd <|
        Api.send (\_ -> ExampleMsgReplaceMe)
            (Api.Request.Default.getOrgFlakeOrgGet "cachix"
             -- |> Api.withBasePath host
            )
    )



-- UPDATE


type Msg
    = ExampleMsgReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model
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
        [ Flakestry.Layout.viewNav
        , div [ class "container max-w-5xl px-4" ]
            [ h2 [ class "inline-flex items-center font-semibold text-2xl py-16" ]
                [ img [ class "inline h-7 w-7 rounded border border-slate-300", src ("https://github.com/" ++ org ++ ".png?size=128") ] []
                , span [ class "ml-2" ] [ text org ]
                ]
            , Components.FlakeCard.view
                { username = "cachix"
                , repo = "devenv"
                , version = "v1.0"
                , description = "Some flake description."
                }
            ]
        , Flakestry.Layout.viewFooter
        ]
    }
