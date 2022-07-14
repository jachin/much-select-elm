port module FilterWorker exposing (..)

import Json.Decode
import Json.Encode
import Option exposing (Option)
import OptionDisplay
import OptionSearcher exposing (decodeSearchParams)
import OptionsUtilities exposing (filterOptionsToShowInDropdownBySearchScore)
import Platform
import SelectionMode exposing (SelectionConfig)


type Msg
    = UpdateOptions Json.Decode.Value
    | UpdateSearchString Json.Decode.Value


init : () -> ( List Option, Cmd msg )
init _ =
    ( [], Cmd.none )


update : Msg -> List Option -> ( List Option, Cmd msg )
update msg options =
    case msg of
        UpdateOptions optionsJson ->
            case Json.Decode.decodeValue (Option.optionsDecoder OptionDisplay.MatureOption SelectionMode.CustomHtml) optionsJson of
                Ok newOptions ->
                    ( newOptions, Cmd.none )

                Err error ->
                    ( [], sendErrorMessage (Json.Decode.errorToString error) )

        UpdateSearchString jsonSearchParams ->
            case Json.Decode.decodeValue decodeSearchParams jsonSearchParams of
                Ok searchParams ->
                    let
                        newOptions =
                            OptionSearcher.updateOptionsWithSearchString searchParams.searchString
                                searchParams.searchStringMinimumLength
                                options

                        optionsToSend =
                            filterOptionsToShowInDropdownBySearchScore newOptions
                                -- TODO this number is arbitrary.
                                |> List.take 100
                    in
                    ( newOptions
                    , sendSearchResults
                        (Option.encodeSearchResults optionsToSend
                            searchParams.searchNonce
                            searchParams.clearingSearch
                        )
                    )

                Err error ->
                    ( options, sendErrorMessage (Json.Decode.errorToString error) )


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


port receiveSearchString : (Json.Decode.Value -> msg) -> Sub msg


port sendSearchResults : Json.Encode.Value -> Cmd msg


port sendErrorMessage : String -> Cmd msg
