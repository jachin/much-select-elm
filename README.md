# \<much-select>

![Doge Meme](site/doge.jpg)

A web component - powered by Elm - that will create a powerful select menu.

## Prior Art, Inspiration, and Goals

The project draws heavy inspiration from the jquery based [selectize.js](https://selectize.github.io/selectize.js/).

The need for this project is that we want to use selectize.js however we need the over all app to be built in [Elm](https://elm-lang.org/). Elm needs to "own" the DOM and selectize is built in a way that's not compatible with that. 

The goal for this project to achieve near feature parity with selectize using web components. The API will be different, so it will not be a drop in replacement, but hopefully it will not be too hard to replace one with the other.

### Other Similar Projects

- [React Select](https://react-select.com/home)
- [inkuzmin/elm-multiselect](https://package.elm-lang.org/packages/inkuzmin/elm-multiselect/)

## Installation

```bash
npm i much-select-elm
```

## Usage

The npm package provides the class `MuchSelect` (which inherits from `HTMLElement`). To use it, use something like the following to define a custom element.

```javascript
import MuchSelect from "@getdrip/much-select-elm";

if (!customElements.get("much-select")) {
  // Putting guard rails around this because browsers do not like
  //  having the same custom element defined more than once.
  window.customElements.define("much-select", MuchSelect);
}
```

## Development

### Pre-requisites

#### devbox
This project manages its development enviornment with [devbox](https://www.jetify.com/devbox).

Some of the tools devbox will just take care of for you include
 - soupault, a static site generator
 - watchexec, for doing stuff automatically when files change

### Initial Setup

To work on this project, clone the repo to your machine then run the following:

```bash
devbox run npm-install
devbox run elm-tooling-install
```

That should set the table for you, then you can start all the fun stuff by running

```bash
devbox run start
```

### Watch and Develop

To run a webpack development server with the sandbox/demo page:

```bash
npm start
```

Now you can visit http://localhost:1234

### Production Build

To do a production build run

```bash
npm run build
```

## API

### DOM

#### Attributes

##### `allow-custom-options`

The `allow-custom-options` attribute will allow the user to add new options to the `<much-select>`, not just one of given ones. Of course, you will want to know when that's happened. You might be able to _just_ look at the value, but you might want to know when a custom option has been added too. For that there's the `customValueSelected` event.

This is a boolean attribute, so it's presents means it's true. It's absence means it's false. So the default value for allowing custom options is false.

##### `disabled`

The `disabled` attribute prevents the `<much-select>` from responding to user input. It is supposed to work like disabling any of the standard form elements.

This is a boolean attribute, so it's presents means it's true. It's absence means it's false. So the default is for a `<much-select>` to not be disabled.

##### `events-only`

The `events-only` attribute prevents the `<much-select>` from automatically updating its "light DOM". This is important for using `<much-select>` inside of an Elm app (and possibly other situations too).

This is a boolean attribute, so if the `events-only` attribute is present means it's true. It's absence means it's false. So the default is for a `<much-select>` to not be in events only mode, and it will try to update the light DOM to reflect it's internal state.

##### `max-dropdown-items`

The `max-dropdown-items` attribute sets the maximum number of items that `<much-select>` will attempt to render in the dropdown.

The default value is 1000.

The `max-dropdown-items` attribute needs a positive integer for its value.

This is also not enforced when a `<much-select>` is using the `datalist` `output-style`.

If you set the value of `max-dropdown-items` to `0` there will be no limit. Would  anyone want that? Should it even be allowed?.

##### `multi-select`

The `multi-select` attribute puts the `<much-select>` into multi select mode, which allows the user to select multiple values.

This is a boolean attribute, so if the `mulit-select` attribute is present, the `<much-select>` will be in multi select mode. If not, it will be in the default single select mode.

##### `multi-select-single-item-removal`

The `multi-select-single-item-removal` attribute adds buttons to remove individual selected options. This only works if the `<much-select>` is in multi select mode.

This is a boolean attribute, so if the `multi-select-single-item-removal` is present the `<much-select>` will have the selected option removal buttons visible. If not, the default behavior is to not show them. 

##### `option-sorting`

The `option-sorting` attribute allows you to specify what order the options should appear in the dropdown.

The options for this are:
 - `no-sorting` (default) respect the value the options are in already
 - `by-option-label` sort the options alphabetically by their label

##### `output-style`

The `output-style` attribute allows you to change the way a `<much-select>` is rendered, which give it a different look and feel. Hopefully you can find one that matches the user experience that best fits your circumstances.

The options for this are:
 - `custom-html` (default)
 - `datalist`

`custom-html` give you a lot of power to style the `<much-select>` but a lot of the markup in hand rolled and an attempt to feel like the user is expecting but even our best effort here will probably fall short.

`datalist` uses the datalist feature of the `<input>` element to render the dropdown part. This can work well if you want to allow the user to type in a text field in a more free form way, and you want to make it easy for them to select a value they might want. It also uses more native widgets. Multi select mode can take up a lot of vertical space though.

##### `placeholder`

The `placeholder` attribute is used to set the placeholder in the text input of the `<much-select>`. Just like in the `<input type="text">` it should only show up if the input is empty.

##### `search-string-minimum-length`

The `search-string-minimum-length` attribute is used to manage how many characters a user needs to type in the `#input-filter` before the options in the dropdown start being filtered.

##### `selected-option-goes-to-top`

The `selected-option-goes-to-top` attribute lets you change the behavior of `<much-select>`, so that when an option is selected it appears at the top of the dropdown menu. This only works when its `output-mode` is `custom-html` and it's in single select mode.

##### `selected-value`

The `selected-value` attribute is used to set the value of the `<much-select>`.

You should _not_ use this in combination with using `selected` attributes on the `<option>` tags in the `select-input` slot. You should just pick one place in the DOM to track the selected value.

##### `selected-value-encoding`

The `selected-value-encoding` attribute is used to change how the values work in the `selected-value` attribute.

The options for this attribute are:
 - `comma` (default) the selected options are comma delegated
 - `json` the selected options are encoded in json and `encodeURIComponent()`

`comma` is the most straight forward but if you allow values that have commas in them things are not going to go well. As far as I can tell `json` can handle any kinds of text values, however it is a bit harder to just look at and know what the selected value is.

`json` encoding is recommended.

##### `show-dropdown-footer`

The `show-dropdown-footer` attribute is used to show the footer in the dropdown of the `<much-select>`. The footer contains potentially useful information about how many options are really available but might not be visible because the results are being filter.

#### Options

### Events

##### `valueChanged`

This event fires any time the value changes.

##### `valueCleared`

This event fires if the `<much-select>` is cleared.

##### `optionSelected`

This event fires if the `<much-select>` is in single or multi select mode, but it's _mostly_ for multi select mode. It will just have the newly selected option in it (not all the selected options like the `valueChanged` event).

##### `optionDeselected`

This event fires if the `<much-select>` is in single or multi select mode, but it's _mostly_ for multi select mode. It will just have the newly deselected option in it. This is kinda of the inverse of the `optionSelected` event.

##### `inputKeyUp`

This event fires every time a user types in the `#input-filter` for filtering the options.

##### `inputKeyUpDebounced`

This event fires every time a user types in the `#input-filter` but is debounced by half a second. The idea here is if you want to hook a `<much-select>` up to an API you can use this event to kick off your API calls to add additional options based on what the user is has "searched" for.

##### `customValidateRequest`

This even is used when a custom validator is in play. All too often, in the real world validation is complicated. It might even be dependent on an API call, for example, ensure the value is unique. In these cases you have the option to just call a JavaScript function. Do whatever you need to validate the value and then send the results back to the `<much-select>` element.

**WARNING:** As I'm sure you can imagine this is fraught. If you do _not_ communicate back to much-select the result of validation much-select will hang in a state of limbo until it gets back the result of the validation. If this ends up taking a long time or fails, or times out, or fails in some other way, it's up _you_ to make sure something reasonable happens.

The even will have a couple of values in the `detail` that will be important:
 - `stringToValidate`: This is what the user typed in for the custom value that you'll be validating
 - `selectedValueIndex`: This is just a number and you just need to hang on to it to pass it back to when it is time to share the results of your validation with your much-select element.

The way you communicate the result of the validation is a little unconventional. You build a JavaScript object with the following fields: 
 - `isValid`: Boolean
 - `stringToValidate`: String
 - `selectedValueIndex`: Index
 - `errorMessages`: Array objects with they keys
   - `errorMessage`: String
   - `level` : String (could be `error`, `warning`, or `silent`)

`isValid` is pretty straight forward, if the value passed your custom validation is valid this should be true, otherwise it should be false.

`stringToValidate` is also something you _probably_ just want to send back as is. In theory though, you could "fix" it for the user if that makes sense, but maybe think carefully if you're going to do that. You don't want to surprise your users.

`errorMessages` are for giving the user feedback as to why the value then entered is invalid. You can have multiple messages in case there's more than one thing wrong. TODO What are the different levels for?

The final step is to encode this object as JSON and set it to the value of an element with a slot named `custom-validation-result`. You probably want to have that element be a `script` with a type of `application/json` to keep everything nice.  

```html
<script type="application/json" slot="custom-validation-result">
```

Here's an example code of what the JavaScript could look like:

```javascript
// Get the much-select element
const muchSelect = example.querySelector("much-select");

// Listen for event.
muchSelect.addEventListener("customValidateRequest", (event) => {
  const { stringToValidate, selectedValueIndex } = event.detail;
  let result;
  if (stringToValidate === "milk") {
    result = {
      isValid: false,
      value: stringToValidate,
      selectedValueIndex,
      errorMessages: [{ errorMessage: "No milk!", level: "error" }],
    };
  } else {
    result = {
      isValid: true,
      value: stringToValidate,
      selectedValueIndex,
    };
  }
  const customValidationResultSlot = muchSelect.querySelector(
    "[slot='custom-validation-result']"
  );
  customValidationResultSlot.innerText = JSON.stringify(result);
});
```

As you can see, this is a little awkward, if you find your self doing a lot of this you might want to write a library for much-select to make this easier. 

### Slots

There are a lot of special [slots](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/slot) that much-select uses for various purposes. They are all optional.

#### `select-input`

One of the easy ways to populate a much-select with values and even selected values is to use the `select-input` slot. This lets you use the `<select>` html element. It can be great if you're using `<much-select>` to enhance an existing `<select>`.  

```html
  <much-select multi-select="true" selected-value="Blue">
    <select slot="select-input">
      <option>Red</option>
      <option>Yellow</option>
      <option>Blue</option>
    </select>
  </much-select>
```

##### `clear-button`

If you want to drop in your own custom clear button, you can do that.

```html
  <much-select multi-select="true" selected-value="Blue">
    <div slot="clear-button">✿</div>
  </much-select>
```

##### `loading-indicator`

If you want to drop in your own custom loading indicator you can do that. Maybe a nice animated SVG.

##### `hidden-value-input`

If you need the value of a `<much-select>` work correctly in the middle of a plain old HTML form this slot is very useful. You put it on a hidden input value, and `<much-select>` will keep the hidden input value up to date with the value of the `<much-select>`.

The value for the input will respect whatever you set in the `selected-value-encoding` attribute.

This will _not_ work if the `events-only` attribute is set, because updating the value of hidden input would mean modifying the DOM (other than the Shadow DOM) so we won't do it. If you want this hidden input value to updated and the light DOM left alone you can just handle it your self in some sort of wrapping library where you listen for the relevant events.  

```
  <much-select selected-value-encoding="json">
    <input slot="hidden-value-input" type="hidden" name="my-special-value">
  </much-select>
</div>
```

##### `no-options`

If there are no options to display, show this message.

##### `no-filtered-options`

If the user has typed in a search filter that just does not have any good matches show this message.
```
<much-select>
 <div slot="no-filtered-options">
  What? You don't want that.
 </div>
</much-select>
```
#### `transformation-validation`

It would be great if the folks using our app always entered in information correctly, alas, they often do not, and we need to validate that information.

The first thing that could happen to the input is that you can "transform" it automatically. There are some cases (and becarful with this) where you can "just fix" the input. Maybe the most common example of this would be to trim trailing whitespace. If you have an input and there's just not good reason why anyone would want trailing whitespace you can just trim it up.

The transformations happen before the validations.

The built-in transformations are:
 - `lowercase`: make all the uppercase letters lowercase.
 - `trim-trailing-whitespace`: TODO

**WARNING:** These are all frontend, browser validations, the real validation should happen in a backend somewhere, but in browser validation can help improve the experience of your users by showing them problems right next to where they're trying to input something and hopefully give them some guidance for how to fix their errors.

This slot is a place where you can define how you would like the users input to be validated. The validators are all defined in JSON. much-select has some built in validators and in those don't do the job, there's an escape hatch to a custom validator.

The built-in validators are:
 - `no-white-space`
 - `minimum-length`
 - `custom`
 - _More to come_

Here's an example what the JSON can look like:

```json
{
  "transformers": [
    {
      "name": "lowercase"
    }
  ],
  "validators": [
    {
      "name": "no-white-space",
      "level": "silent",
      "message": "Spaces are not allow for custom fruit."
    },
    {
      "name": "minimum-length",
      "level": "silent",
      "minimum-length": 3,
      "message": "The minimum length is 3."
    }
  ]
}
```

The transformation and validation slot can be a pain to work with. If you need to do a lot of this you probably want a library that wraps much-select to make working with this easier.

#### `custom-validation-result`

This is an element where you can put the results of a custom validation.

```html
<script type="application/json" slot="custom-validation-result">
```

#### Custom Element Options

If you want to start putting custom markup per option in the dropdown, there's a way to do that, but well... buyer beware.

TODO Add a section on the custom elements that can go inside a `<much-select>`.
