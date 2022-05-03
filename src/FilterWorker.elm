port module FilterWorker exposing (..)

import Json.Decode
import Json.Encode
import Option exposing (Option)
import OptionSearcher
import Platform
import SearchString
import SelectionMode


type Msg
    = UpdateOptions Json.Decode.Value
    | UpdateSearchString String


init : () -> ( List Option, Cmd msg )
init _ =
    ( [], Cmd.none )


update : Msg -> List Option -> ( List Option, Cmd msg )
update msg options =
    case msg of
        UpdateOptions optionsJson ->
            case Json.Decode.decodeValue (Option.optionsDecoder SelectionMode.CustomHtml) optionsJson of
                Ok newOptions ->
                    ( newOptions, Cmd.none )

                Err _ ->
                    ( [], Cmd.none )

        UpdateSearchString searchString ->
            ( options
                |> List.map (OptionSearcher.updateSearchResultInOption (SearchString.new searchString))
            , Cmd.none
            )


subscriptions : List Option -> Sub Msg
subscriptions _ =
    Sub.batch
        [ receiveOptions UpdateOptions
        , receiveSearchString UpdateSearchString
        ]


main : Program () (List Option) Msg
main =
    Platform.worker { init = init, update = update, subscriptions = subscriptions }


port receiveOptions : (Json.Decode.Value -> msg) -> Sub msg


port receiveSearchString : (String -> msg) -> Sub msg


port sendSearchResults : Json.Encode.Value -> Cmd msg
