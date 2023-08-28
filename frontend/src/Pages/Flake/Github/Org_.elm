module Pages.Flake.Github.Org_ exposing (Model, Msg, page)

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
import View exposing (View)


page : Shared.Model -> Route { org : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view route.params.org
        }



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}
    , Effect.none
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
    { title = "Pages.Flake.Github.Org_"
    , body =
        [ Flakestry.Layout.viewNav
        , h2 [ class "font-semibold text-2xl mx-auto w-full h-28 px-8 py-6" ]
            [ img [ class "inline mx-2", src ("https://github.com/" ++ org ++ ".png?size=24") ] []
            , text "xxx"
            ]
        , Components.FlakeCard.view
            { username = "cachix"
            , repo = "devenv"
            , version = "v1.0"
            , description = "Some flake description."
            }
        , Flakestry.Layout.viewFooter
        ]
    }
