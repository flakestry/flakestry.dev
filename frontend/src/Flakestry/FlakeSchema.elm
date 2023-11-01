module Flakestry.FlakeSchema exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, dict, field, maybe, string)
import Json.Decode.Pipeline as Pipeline



-- Type definitions


type alias Output =
    { type_ : String
    , description : Maybe String
    , name : Maybe String
    }


type alias OptionalOutput a =
    Maybe (Dict String a)



-- https://nixos.wiki/wiki/Flakes#Flake_schema


type alias Root =
    { checks : OptionalOutput (Dict String Output)
    , apps : OptionalOutput (Dict String Output)
    , packages : OptionalOutput (Dict String Output)
    , legacyPacakges : OptionalOutput (Dict String Output)
    , devShells : OptionalOutput (Dict String Output)
    , formatter : OptionalOutput Output
    , overlays : OptionalOutput Output
    , nixosModules : OptionalOutput Output
    , nixosConfigurations : OptionalOutput Output
    , templates : OptionalOutput Output
    }



-- Decoders


outputDecoder : Decoder Output
outputDecoder =
    Decode.map3 Output
        (field "type" string)
        (maybe (field "description" string))
        (maybe (field "name" string))


optionalMaybe name decoder =
    Pipeline.optional name (Decode.map Just decoder) Nothing


rootDecoder : Decoder Root
rootDecoder =
    Decode.succeed Root
        |> optionalMaybe "checks" (dict (dict outputDecoder))
        |> optionalMaybe "apps" (dict (dict outputDecoder))
        |> optionalMaybe "packages" (dict (dict outputDecoder))
        |> optionalMaybe "legacyPackages" (dict (dict outputDecoder))
        |> optionalMaybe "devShells" (dict (dict outputDecoder))
        |> optionalMaybe "formatter" (dict outputDecoder)
        |> optionalMaybe "overlays" (dict outputDecoder)
        |> optionalMaybe "nixosModules" (dict outputDecoder)
        |> optionalMaybe "nixosConfigurations" (dict outputDecoder)
        |> optionalMaybe "templates" (dict outputDecoder)


decodeJson : Decode.Value -> Result Decode.Error Root
decodeJson jsonString =
    Decode.decodeValue rootDecoder jsonString
