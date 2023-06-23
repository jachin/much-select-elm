module GroupedDropdownOptions exposing (DropdownOptionsGroup, GroupedDropdownOptions, dropdownOptionsToDatalistHtml, getOptions, getOptionsGroup, groupOptionsInOrder, optionGroupsToHtml)

import DropdownOptions exposing (DropdownItemEventListeners, DropdownOptions, dropdownOptionsToDatalistOption, optionsToCustomHtml)
import Html exposing (Html, div, optgroup, span, text)
import Html.Attributes exposing (class)
import Option exposing (OptionGroup)
import OptionPresentor exposing (tokensToHtml)
import SelectionMode exposing (SelectionConfig)


type DropdownOptionsGroup
    = DropdownOptionsGroup OptionGroup DropdownOptions


type alias GroupedDropdownOptions =
    List DropdownOptionsGroup


groupOptionsInOrder : DropdownOptions -> GroupedDropdownOptions
groupOptionsInOrder options =
    DropdownOptions.groupInOrder options
        |> List.map (\( group, options_ ) -> DropdownOptionsGroup group options_)


getOptions : DropdownOptionsGroup -> DropdownOptions
getOptions group =
    case group of
        DropdownOptionsGroup _ dropdownOptions ->
            dropdownOptions


getOptionsGroup : DropdownOptionsGroup -> OptionGroup
getOptionsGroup dropdownOptionsGroup =
    case dropdownOptionsGroup of
        DropdownOptionsGroup optionGroup _ ->
            optionGroup


optionGroupsToHtml : DropdownItemEventListeners msg -> SelectionConfig -> GroupedDropdownOptions -> List (Html msg)
optionGroupsToHtml dropdownItemEventListeners selectionConfig groupedDropdownOptions =
    List.concatMap (optionGroupToHtml dropdownItemEventListeners selectionConfig) groupedDropdownOptions


optionGroupToHtml : DropdownItemEventListeners msg -> SelectionConfig -> DropdownOptionsGroup -> List (Html msg)
optionGroupToHtml dropdownItemEventListeners selectionMode dropdownOptionsGroup =
    let
        optionGroupHtml =
            case dropdownOptionsGroup |> getOptions |> DropdownOptions.maybeFirstOptionSearchFilter of
                Just optionSearchFilter ->
                    case dropdownOptionsGroup |> getOptionsGroup |> Option.optionGroupToString of
                        "" ->
                            text ""

                        _ ->
                            div
                                [ class "optgroup"
                                , Html.Attributes.attribute "part" "dropdown-optgroup"
                                ]
                                [ span [ class "optgroup-header" ]
                                    (tokensToHtml optionSearchFilter.groupTokens)
                                ]

                Nothing ->
                    case dropdownOptionsGroup |> getOptionsGroup |> Option.optionGroupToString of
                        "" ->
                            text ""

                        optionGroupAsString ->
                            div
                                [ class "optgroup"
                                , Html.Attributes.attribute "part" "dropdown-optgroup"
                                ]
                                [ span [ class "optgroup-header" ]
                                    [ text
                                        optionGroupAsString
                                    ]
                                ]
    in
    optionGroupHtml :: optionsToCustomHtml dropdownItemEventListeners selectionMode (getOptions dropdownOptionsGroup)


dropdownOptionsToDatalistHtml : DropdownOptions -> Html msg
dropdownOptionsToDatalistHtml options =
    Html.datalist
        [ Html.Attributes.id "datalist-options" ]
        (dataListOptionGroupToHtml
            (groupOptionsInOrder options)
        )


dataListOptionGroupToHtml : GroupedDropdownOptions -> List (Html msg)
dataListOptionGroupToHtml groupedDropdownOptions =
    List.concatMap
        (\(DropdownOptionsGroup optionGroup dropdownOptions) ->
            case Option.optionGroupToString optionGroup of
                "" ->
                    dropdownOptionsToDatalistOption dropdownOptions

                optionGroupAsString ->
                    [ optgroup
                        [ Html.Attributes.attribute "label" optionGroupAsString ]
                        (dropdownOptionsToDatalistOption dropdownOptions)
                    ]
        )
        groupedDropdownOptions
