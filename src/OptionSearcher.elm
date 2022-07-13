module OptionSearcher exposing (decodeSearchParams, doesSearchStringFindNothing, encodeSearchParams, simpleMatch, updateOptionsWithSearchString, updateOptionsWithSearchStringAndCustomOption, updateOrAddCustomOption, updateSearchResultInOption)

import Fuzzy exposing (Result, match)
import Json.Decode
import Json.Encode
import Option exposing (Option(..))
import OptionLabel exposing (optionLabelToSearchString, optionLabelToString)
import OptionPresentor exposing (tokenize)
import OptionSearchFilter exposing (OptionSearchFilter, OptionSearchResult, descriptionHandicap, groupHandicap)
import OptionsUtilities exposing (prependCustomOption, removeUnselectedCustomOptions)
import OutputStyle exposing (CustomOptions(..), SearchStringMinimumLength(..), decodeSearchStringMinimumLength)
import PositiveInt exposing (PositiveInt)
import SearchString exposing (SearchString)
import SelectionMode exposing (SelectionConfig, getCustomOptionHint, getSearchStringMinimumLength)
import TransformAndValidate


updateOptionsWithSearchStringAndCustomOption : SelectionConfig -> SearchString -> List Option -> List Option
updateOptionsWithSearchStringAndCustomOption selectionConfig searchString options =
    options
        |> updateOrAddCustomOption searchString selectionConfig
        |> updateOptionsWithSearchString searchString (selectionConfig |> getSearchStringMinimumLength)


simpleMatch : String -> String -> Result
simpleMatch needle hay =
    match [] [ " " ] needle hay



{- This matcher is for the option groups. We add a penalty of 50 points because we want matches on the label and
   description to show up first.
-}


groupMatch : String -> String -> Result
groupMatch needle hay =
    match [] [ " " ] needle hay


search : String -> Option -> OptionSearchResult
search string option =
    { labelMatch =
        simpleMatch
            (string |> String.toLower)
            (option
                |> Option.getOptionLabel
                |> optionLabelToSearchString
            )
    , descriptionMatch =
        simpleMatch
            (string |> String.toLower)
            (option
                |> Option.getOptionDescription
                |> Option.optionDescriptionToSearchString
            )
    , groupMatch =
        groupMatch
            (string |> String.toLower)
            (option
                |> Option.getOptionGroup
                |> Option.optionGroupToSearchString
            )
    }


updateSearchResultInOption : SearchString -> Option -> Option
updateSearchResultInOption searchString option =
    let
        searchResult : OptionSearchResult
        searchResult =
            search (SearchString.toString searchString) option

        labelTokens =
            tokenize (option |> Option.getOptionLabel |> optionLabelToString) searchResult.labelMatch

        descriptionTokens =
            tokenize (option |> Option.getOptionDescription |> Option.optionDescriptionToString) searchResult.descriptionMatch

        groupTokens =
            tokenize (option |> Option.getOptionGroup |> Option.optionGroupToString) searchResult.groupMatch

        bestScore =
            Maybe.withDefault OptionSearchFilter.impossiblyLowScore
                (List.minimum
                    [ searchResult.labelMatch.score
                    , descriptionHandicap searchResult.descriptionMatch.score
                    , groupHandicap searchResult.groupMatch.score
                    ]
                )

        totalScore =
            List.sum
                [ searchResult.labelMatch.score
                , descriptionHandicap searchResult.descriptionMatch.score
                , groupHandicap searchResult.groupMatch.score
                ]

        cappedBestScore =
            -- Just putting our thumb on the scale here for the sake of substring matches
            if bestScore > 100 then
                if String.contains (SearchString.toString searchString |> String.toLower) (option |> Option.getOptionLabel |> OptionLabel.optionLabelToSearchString |> String.toLower) then
                    if String.length (SearchString.toString searchString) < 2 then
                        bestScore

                    else if String.length (SearchString.toString searchString) < 3 then
                        50

                    else if String.length (SearchString.toString searchString) < 4 then
                        20

                    else if String.length (SearchString.toString searchString) < 5 then
                        15

                    else if String.length (SearchString.toString searchString) < 6 then
                        10

                    else if String.length (SearchString.toString searchString) >= 6 then
                        10

                    else
                        bestScore

                else
                    bestScore

            else
                bestScore
    in
    Option.setOptionSearchFilter
        (Just
            (OptionSearchFilter.new
                totalScore
                cappedBestScore
                labelTokens
                descriptionTokens
                groupTokens
            )
        )
        option


updateOrAddCustomOption : SearchString -> SelectionConfig -> List Option -> List Option
updateOrAddCustomOption searchString selectionMode options =
    let
        ( showCustomOption, newSearchString ) =
            if SearchString.length searchString > 0 then
                case SelectionMode.getCustomOptions selectionMode of
                    AllowCustomOptions _ transformAndValidate ->
                        case TransformAndValidate.transformAndValidateSearchString transformAndValidate searchString of
                            TransformAndValidate.ValidationPass str _ ->
                                ( True, SearchString.new str )

                            TransformAndValidate.ValidationFailed _ _ _ ->
                                ( False, searchString )

                            TransformAndValidate.ValidationPending _ _ ->
                                ( False, searchString )

                    NoCustomOptions ->
                        ( False, searchString )

            else
                ( False, searchString )

        -- If we have an exact match with an existing option don't show the custom
        --  option.
        noExactOptionLabelMatch =
            options
                |> List.any
                    (\option_ ->
                        (option_
                            |> Option.getOptionLabel
                            |> optionLabelToSearchString
                        )
                            == SearchString.toLower searchString
                            && not (Option.isCustomOption option_)
                    )
                |> not
    in
    if showCustomOption && noExactOptionLabelMatch then
        prependCustomOption
            (selectionMode |> getCustomOptionHint)
            newSearchString
            (removeUnselectedCustomOptions options)

    else
        removeUnselectedCustomOptions options


updateOptionsWithSearchString : SearchString -> SearchStringMinimumLength -> List Option -> List Option
updateOptionsWithSearchString searchString searchStringMinimumLength options =
    let
        doOptionFiltering =
            case searchStringMinimumLength of
                FixedSearchStringMinimumLength positiveInt ->
                    PositiveInt.lessThanOrEqualTo positiveInt (SearchString.length searchString)

                NoMinimumToSearchStringLength ->
                    True
    in
    if doOptionFiltering then
        options
            |> List.map
                (updateSearchResultInOption searchString)

    else
        options
            |> List.map
                (\option ->
                    Option.setOptionSearchFilter
                        Nothing
                        option
                )


doesSearchStringFindNothing : SearchString -> SearchStringMinimumLength -> List Option -> Bool
doesSearchStringFindNothing searchString searchStringMinimumLength options =
    case searchStringMinimumLength of
        NoMinimumToSearchStringLength ->
            True

        FixedSearchStringMinimumLength num ->
            if SearchString.length searchString <= PositiveInt.toInt num then
                False

            else
                List.all
                    (\option ->
                        case Option.getMaybeOptionSearchFilter option of
                            Just optionSearchFilter ->
                                optionSearchFilter.bestScore > 1000

                            Nothing ->
                                False
                    )
                    options


encodeSearchParams : SearchString -> SearchStringMinimumLength -> Int -> Bool -> Json.Encode.Value
encodeSearchParams searchString searchStringMinimumLength searchNonce isClearingSearch =
    Json.Encode.object
        [ ( "searchString", SearchString.encode searchString )
        , ( "searchStringMinimumLength", OutputStyle.encodeSearchStringMinimumLength searchStringMinimumLength )
        , ( "searchNonce", Json.Encode.int searchNonce )
        , ( "isClearingSearch", Json.Encode.bool isClearingSearch )
        ]


type alias SearchParams =
    { searchString : SearchString
    , searchStringMinimumLength : SearchStringMinimumLength
    , searchNonce : Int
    , clearingSearch : Bool
    }


decodeSearchParams : Json.Decode.Decoder SearchParams
decodeSearchParams =
    Json.Decode.map4
        SearchParams
        (Json.Decode.field "searchString" SearchString.decode)
        (Json.Decode.field "searchStringMinimumLength" decodeSearchStringMinimumLength)
        (Json.Decode.field "searchNonce" Json.Decode.int)
        (Json.Decode.field "isClearingSearch" Json.Decode.bool)
