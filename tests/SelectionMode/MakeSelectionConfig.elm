module SelectionMode.MakeSelectionConfig exposing (suite)

import Expect
import OutputStyle
    exposing
        ( CustomOptions(..)
        , DropdownState(..)
        , DropdownStyle(..)
        , EventsMode(..)
        , MaxDropdownItems(..)
        , MultiSelectOutputStyle(..)
        , SearchStringMinimumLength(..)
        , SingleItemRemoval(..)
        )
import PositiveInt
import SelectionMode
    exposing
        ( InteractionState(..)
        , SelectionConfig(..)
        , defaultMaxDropdownItems
        , makeSelectionConfig
        )
import Test exposing (Test, describe, test)
import TransformAndValidate


suite : Test
suite =
    describe "Making the initial selection config from flags"
        [ test "we should be able to make a multi select" <|
            \() ->
                Expect.equal
                    (makeSelectionConfig
                        False
                        False
                        True
                        False
                        ""
                        ( False, "" )
                        Nothing
                        False
                        defaultMaxDropdownItems
                        True
                        2
                        False
                        TransformAndValidate.empty
                    )
                    (Ok
                        (MultiSelectConfig
                            (MultiSelectCustomHtml
                                { customOptions = NoCustomOptions
                                , singleItemRemoval = DisableSingleItemRemoval
                                , maxDropdownItems = FixedMaxDropdownItems (PositiveInt.new 1000)
                                , searchStringMinimumLength = FixedSearchStringMinimumLength (PositiveInt.new 2)
                                , dropdownState = Collapsed
                                , dropdownStyle = NoFooter
                                , eventsMode = AllowLightDomChanges
                                }
                            )
                            ( False, "" )
                            Unfocused
                        )
                    )
        ]
