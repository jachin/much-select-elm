// noinspection JSFileReferences

// eslint-disable-next-line import/no-unresolved
import { Elm } from "./much-select-elm-debug.js";

// eslint-disable-next-line import/no-unresolved
import getMuchSelectTemplate from "./much-select-template.js";

import asciiFold from "./ascii-fold.js";

const buildOptionsFromSelectElement = (selectElement) => {
  const options = [];
  const optionElements = selectElement.querySelectorAll("option");
  optionElements.forEach((optionElement, optionIndex) => {
    let value;
    if (optionElement.hasAttribute("value")) {
      value = optionElement.getAttribute("value");
    } else {
      value = optionElement.innerText;
    }
    const option = { value };
    option.label = optionElement.innerText;
    option.labelClean = asciiFold(optionElement.innerText);
    option.index = optionIndex;
    if (optionElement.hasAttribute("selected")) {
      const optionSelectedValue = optionElement.getAttribute("selected");
      option.selected = optionSelectedValue !== "false";
    }
    if (optionElement.parentElement.tagName === "OPTGROUP") {
      option.group = optionElement.parentElement.getAttribute("label");
    }
    if (optionElement.dataset.description) {
      option.description = optionElement.dataset.description;
      option.descriptionClean = asciiFold(option.description);
    }
    option.disabled = optionElement.hasAttribute("disabled");
    options.push(option);
  });
  return options;
};

const notNullOrUndefined = (thing) => thing !== null && thing !== undefined;

const stringToOptionObject = (str) => ({
  value: str,
  label: str,
  labelClean: asciiFold(str),
});

const numberToOptionObject = (num) => ({
  value: `${num}`,
  label: `${num}`,
  labelClean: `${num}`,
});

const cleanUpOption = (option) => {
  if (typeof option === "string") {
    return stringToOptionObject(option);
  }
  if (typeof option === "number") {
    return numberToOptionObject(option);
  }
  if (typeof option === "object") {
    const optionMap = new Map();
    if (notNullOrUndefined(option.value)) {
      optionMap.set("value", `${option.value}`);
    }

    if (notNullOrUndefined(option.label)) {
      optionMap.set("label", `${option.label}`);
    }

    if (notNullOrUndefined(option.description)) {
      optionMap.set("description", option.description);
    }

    if (notNullOrUndefined(option.disabled)) {
      optionMap.set("disabled", !!option.disabled);
    }

    if (notNullOrUndefined(option.index)) {
      if (typeof option.index === "number") {
        optionMap.set("index", Math.floor(option.index));
      } else {
        throw new TypeError("option index in not a valid value");
      }
    }

    if (optionMap.has("value") && !optionMap.has("label")) {
      return {
        label: optionMap.get("value"),
        labelClean: asciiFold(optionMap.get("value")),
        value: optionMap.get("value"),
        description: optionMap.get("description"),
        descriptionClean: asciiFold(optionMap.get("description")),
        disabled: optionMap.get("disabled"),
        index: optionMap.get("index"),
      };
    }
    if (optionMap.has("label") && !optionMap.has("value")) {
      return {
        label: optionMap.get("label"),
        labelClean: asciiFold(optionMap.get("label")),
        value: optionMap.get("label"),
        description: optionMap.get("description"),
        descriptionClean: asciiFold(optionMap.get("description")),
        disabled: optionMap.get("disabled"),
        index: optionMap.get("index"),
      };
    }
    return {
      label: optionMap.get("label"),
      labelClean: asciiFold(optionMap.get("label")),
      value: optionMap.get("value"),
      description: optionMap.get("description"),
      descriptionClean: asciiFold(optionMap.get("description")),
      disabled: optionMap.get("disabled"),
      index: optionMap.get("index"),
    };
  }

  throw new TypeError("Invalid option");
};

const cleanUpOptions = (options) => options.map(cleanUpOption);

const cleanUpSelectedValue = (selectedValue) => {
  let newSelectedValue;
  if (selectedValue === null) {
    newSelectedValue = null;
  } else if (selectedValue === undefined) {
    newSelectedValue = null;
  } else if (selectedValue === "") {
    newSelectedValue = "";
  } else {
    newSelectedValue = selectedValue;
  }
  return newSelectedValue;
};

const makeDebouncedFunc = (func, timeout = 500) => {
  let timer;
  const myThis = this;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      func.apply(myThis, args);
    }, timeout);
  };
};

const makeDebounceLeadingFunc = (func, delay = 250) => {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      timeoutId = null;
      func(...args);
    }, delay);
  };
};

/**
 * Takes a value from a getAttribute call and converts it to a boolean value.
 * @param value {string}
 * @returns {boolean}
 */
const booleanAttributeValueToBool = (value) => {
  if (value === "false") {
    return false;
  }
  if (value === "") {
    return true;
  }
  return !!value;
};

// adapted from https://github.com/thread/elm-web-components

class MuchSelect extends HTMLElement {
  constructor() {
    super();

    /**
     * Used in the CSS and elsewhere to determine what the
     *  minimum width should be.
     * TODO Perhaps this should be a property or attribute.
     * @type {number}
     * @private
     */
    this._minimumWidth = 200;

    this._minimumHeight = 20;

    /**
     * @type {null|object}
     * @private
     */
    this._app = null;

    /**
     * @type {null|Worker}
     * @private
     */
    this._filterWorker = null;

    /**
     * @type {null|Promise}
     * @private
     */
    this._filterWorkerPromise = null;

    /**
     * @type {boolean}
     * @private
     */
    this._connected = false;

    /**
     * Once we see a value change come through, set this to true, then
     * when the much-select blurs, emmit the event and set it to false.
     * @type {boolean}
     * @private
     */
    this._emitBlurOrUnfocusedValueChanged = false;

    /**
     * @type {null|MutationObserver}
     * @private
     */
    this._muchSelectObserver = null;

    /**
     * @type {null|MutationObserver}
     * @private
     */
    this._selectSlotObserver = null;

    /**
     * @type {null|MutationObserver}
     * @private
     */
    this._customValidationResultSlotObserver = null;

    /**
     * @type {null|MutationObserver}
     * @private
     */
    this._transformationValidationSlotObserver = null;

    /**
     * See the comment on updateFilterWorkerOptions() for what this is for.
     * @type {null|string}
     * @private
     */
    this._filterWorkerOptionsCache = null;

    this._inputKeypressDebounceHandler = makeDebouncedFunc((searchString) => {
      this.dispatchEvent(
        new CustomEvent("inputKeyUpDebounced", {
          bubbles: true,
          detail: { searchString },
        })
      );
    });

    this._callValueCasingWidthUpdate = makeDebounceLeadingFunc(
      (width, height) => {
        this.appPromise.then((app) => {
          // noinspection JSUnresolvedVariable
          app.ports.valueCasingDimensionsChangedReceiver.send({
            width,
            height,
          });
        });
      },
      5
    );

    this._callOptionChanged = makeDebounceLeadingFunc((optionsJson) => {
      this.appPromise.then((app) => {
        // noinspection JSUnresolvedVariable
        app.ports.optionsReplacedReceiver.send(optionsJson);
        this.updateDimensions();
      });
    }, 100);

    this._callValueChanged = makeDebounceLeadingFunc((newValue) => {
      this.appPromise.then((app) => {
        // noinspection JSUnresolvedVariable
        app.ports.valueChangedReceiver.send(newValue);
      });
    }, 5);

    this._callUpdateOptionsFromDom = makeDebounceLeadingFunc(() => {
      this.updateOptionsFromDom();
    }, 100);

    // noinspection JSUnresolvedFunction
    this._resizeObserver = new ResizeObserver(() => {
      // When the size changes we need to tell Elm, so it can
      //  adjust things like the width of the dropdown.
      this.updateDimensions();
    });
  }

  static get observedAttributes() {
    return [
      "allow-custom-options",
      "disabled",
      "events-only",
      "loading",
      "max-dropdown-items",
      "multi-select",
      "multi-select-single-item-removal",
      "option-sorting",
      "output-style",
      "placeholder",
      "search-string-minimum-length",
      "selected-option-goes-to-top",
      "selected-value",
      "selected-value-encoding",
      "show-dropdown-footer",
    ];
  }

  // noinspection JSUnusedGlobalSymbols
  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue !== newValue) {
      this.appPromise.then((app) => {
        if (newValue === null) {
          // noinspection JSUnresolvedVariable
          app.ports.attributeRemoved.send(name);
        } else {
          // noinspection JSUnresolvedVariable
          app.ports.attributeChanged.send([name, newValue]);
        }
      });
    }
  }

  // noinspection JSUnusedGlobalSymbols
  connectedCallback() {
    this.parentDivPromise.then((parentDiv) => {
      const wrapperDiv = parentDiv.querySelector("#wrapper");
      this._resizeObserver.observe(wrapperDiv);
    });

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.muchSelectIsReady.subscribe(() => {
        window.requestAnimationFrame(() => {
          this.dispatchEvent(new CustomEvent("ready", { bubbles: true }));
          this.dispatchEvent(new CustomEvent("muchSelectReady"));
        });
      })
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.errorMessage.subscribe(this.errorHandler.bind(this))
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.errorMessage.subscribe(this.errorHandler.bind(this))
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.lightDomChange.subscribe((lightDomChange) => {
        if (lightDomChange.changeType === "update-selected-value") {
          const selectInputSlot = this.querySelector("[slot='select-input']");

          this.stopMuchSelectObserver();
          this.stopSelectSlotObserver();

          if (this.hasAttribute("selected-value")) {
            this.setAttribute("selected-value", lightDomChange.data.rawValue);
          } else if (selectInputSlot) {
            if (lightDomChange.data.selectionMode === "single-select") {
              selectInputSlot.querySelectorAll("option").forEach((optionEl) => {
                if (optionEl.hasAttribute("selected")) {
                  if (lightDomChange.data.value !== optionEl.value) {
                    optionEl.removeAttribute("selected");
                  }
                } else if (lightDomChange.data.value === optionEl.value) {
                  optionEl.setAttribute("selected", "");
                }
              });
            } else if (lightDomChange.data.selectionMode === "multi-select") {
              selectInputSlot.querySelectorAll("option").forEach((optionEl) => {
                if (optionEl.selected) {
                  if (!lightDomChange.data.value.includes(optionEl.value)) {
                    optionEl.removeAttribute("selected");
                  }
                } else if (lightDomChange.data.value.includes(optionEl.value)) {
                  optionEl.setAttribute("selected", "");
                }
              });
            }
          }

          const hiddenValueInput = this.querySelector(
            "[slot='hidden-value-input']"
          );
          if (hiddenValueInput) {
            hiddenValueInput.setAttribute(
              "value",
              lightDomChange.data.rawValue
            );
          }

          this.startMuchSelectObserver();
          this.startSelectSlotObserver();
        } else if (lightDomChange.changeType === "remove-attribute") {
          this.removeAttribute(lightDomChange.name);
        } else if (lightDomChange.changeType === "add-update-attribute") {
          this.setAttribute(lightDomChange.name, lightDomChange.value);
        }
      })
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.valueChanged.subscribe(this.valueChangedHandler.bind(this))
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.invalidValue.subscribe((values) => {
        this.dispatchEvent(
          new CustomEvent("invalidValueChange", {
            bubbles: true,
            detail: {
              values,
            },
          })
        );
      })
    );

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.optionSelected.subscribe((valueLabelPair) => {
        this.dispatchEvent(
          new CustomEvent("optionSelected", {
            bubbles: true,
            detail: {
              value: valueLabelPair[0],
              label: valueLabelPair[1],
            },
          })
        );
        // The addItem event is for backwards compatibility.
        this.dispatchEvent(
          new CustomEvent("addItem", {
            bubbles: true,
            detail: {
              value: valueLabelPair[0],
              label: valueLabelPair[1],
            },
          })
        );
      })
    );

    this.appPromise.then((app) => {
      app.ports.optionsUpdated.subscribe((optionsReplaced) => {
        this.dispatchEvent(
          new CustomEvent("optionsUpdated", {
            bubbles: true,
            detail: {
              optionsReplaced,
              optionsUpdated: !optionsReplaced,
            },
          })
        );
      });
    });

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.inputKeyUp.subscribe(this._handleInputKeyUp.bind(this))
    );

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.valueCleared.subscribe(() => {
        this.dispatchEvent(
          new CustomEvent("valueCleared", {
            bubbles: true,
          })
        );
        // The cleared event is for backwards compatibility.
        this.dispatchEvent(
          new CustomEvent("cleared", {
            bubbles: true,
          })
        );
      })
    );

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.customOptionSelected.subscribe(
        this.customOptionSelected.bind(this)
      )
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.blurInput.subscribe(() => {
        // This port is called to "force" a blur.
        const inputFilterElement =
          this.shadowRoot.getElementById("input-filter");
        if (inputFilterElement) {
          inputFilterElement.blur();
        }
      })
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.inputBlurred.subscribe(() => {
        // This port is called AFTER the input has been blurred.
        if (this._emitBlurOrUnfocusedValueChanged) {
          this._emitBlurOrUnfocusedValueChanged = false;

          this.dispatchEvent(
            new CustomEvent("blurOrUnfocusedValueChanged", {
              bubbles: true,
              detail: {
                value: this.selectedValue,
              },
            })
          );
        }
        window.requestAnimationFrame(() => {
          this.dispatchEvent(
            new CustomEvent("muchSelectBlurred", {
              bubbles: true,
            })
          );
        });
      })
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.focusInput.subscribe(() => {
        // This port is here because we need to be able to call the focus method
        //  which is something we can not do from inside Elm.
        window.requestAnimationFrame(() => {
          const inputFilterElement =
            this.shadowRoot.getElementById("input-filter");
          if (inputFilterElement) {
            this.shadowRoot.getElementById("input-filter").focus();
          }
        });
      })
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.inputFocused.subscribe(() => {
        // Emit an even once the input has been focused. This might have other
        //  uses but this is helpful for writing automated tests.
        window.requestAnimationFrame(() => {
          this.dispatchEvent(
            new CustomEvent("muchSelectFocused", {
              bubbles: false,
            })
          );
        });
      })
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.optionDeselected.subscribe((deselectedValue) => {
        const formattedValue = {
          label: deselectedValue[0][1],
          value: deselectedValue[0][0],
        };
        this.dispatchEvent(
          new CustomEvent("optionDeselected", {
            bubbles: true,
            detail: formattedValue,
          })
        );
        this.dispatchEvent(
          new CustomEvent("deselectItem", {
            bubbles: true,
            detail: formattedValue,
          })
        );
      })
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.scrollDropdownToElement.subscribe(() => {
        const dropdown = this.shadowRoot.getElementById("dropdown");
        const highlightedOption = this.shadowRoot.querySelector(
          "#dropdown .option.highlighted"
        );

        // If we found the highlight option AND there are vertical scroll bars
        //  then scroll the dropdown to the highlighted option.
        if (highlightedOption) {
          if (dropdown.scrollHeight > dropdown.clientHeight) {
            const optionHeight = highlightedOption.clientHeight;
            // noinspection JSUnresolvedVariable
            const optionTop = highlightedOption.offsetTop - optionHeight;
            const optionBottom = optionTop + optionHeight + optionHeight;
            const dropdownTop = dropdown.scrollTop;
            const dropdownBottom = dropdownTop + dropdown.clientHeight;

            if (!(optionTop >= dropdownTop && optionBottom <= dropdownBottom)) {
              dropdown.scrollTop = optionTop;
            }
          }
        }
      })
    );

    this.appPromise.then((app) => {
      // noinspection JSUnresolvedVariable
      app.ports.searchOptionsWithWebWorker.subscribe((searchString) => {
        this.filterWorkerPromise.then((filterWorker) => {
          filterWorker.postMessage({
            portName: "receiveSearchString",
            jsonBlob: searchString,
          });
        });
      });
    });

    this.appPromise.then((app) => {
      // noinspection JSUnresolvedVariable
      app.ports.updateOptionsInWebWorker.subscribe(() => {
        // noinspection JSIgnoredPromiseFromCall
        this.updateFilterWorkerOptions();
      });
    });

    this.appPromise.then((app) => {
      app.ports.updateOptionsFromDom.subscribe(() => {
        this.updateOptionsFromDom();
      });
    });

    this.appPromise.then((app) => {
      // noinspection JSUnresolvedVariable
      app.ports.sendCustomValidationRequest.subscribe((valueData) => {
        const [stringToValidate, selectedValueIndex] = valueData;
        this.dispatchEvent(
          new CustomEvent("customValidateRequest", {
            bubbles: true,
            detail: {
              stringToValidate,
              selectedValueIndex,
            },
          })
        );
      });
    });

    this.startMuchSelectObserver();

    this.startSelectSlotObserver();

    this.startCustomValidationSlotObserver();

    this.startTransformationValidationSlotObserver();

    // Set up the hidden input slot (if it exists) with any initial values
    this.updateHiddenInputValueSlot();

    this._connected = true;
  }

  startMuchSelectObserver() {
    // Options for the observer (which mutations to observe)
    const muchSelectMutationObserverConfig = {
      attributes: true,
      childList: true,
      subtree: false,
      characterData: false,
    };

    this._muchSelectObserver = new MutationObserver((mutationsList) => {
      mutationsList.forEach((mutation) => {
        if (
          mutation.type === "attributes" &&
          mutation.attributeName === "placeholder"
        ) {
          // We do no need to update the options if we are updating the placeholder.
          return;
        }
        if (
          mutation.type === "attributes" &&
          mutation.attributeName === "loading"
        ) {
          // We do no need to update the options if we are updating the loading attribute.
          return;
        }
        this._callUpdateOptionsFromDom();
      });
    });
    this._muchSelectObserver.observe(this, muchSelectMutationObserverConfig);
  }

  stopMuchSelectObserver() {
    if (this._muchSelectObserver) {
      if (this._muchSelectObserver.disconnect) {
        this._muchSelectObserver.disconnect();
      }
    }
  }

  startSelectSlotObserver() {
    // Options for the observer (which mutations to observe)
    const selectSlotConfig = {
      attributes: true,
      childList: true,
      subtree: true,
      characterData: true,
    };

    this._selectSlotObserver = new MutationObserver((mutationsList) => {
      mutationsList.forEach((mutation) => {
        if (mutation.type === "childList") {
          this._callUpdateOptionsFromDom();
        } else if (mutation.type === "attributes") {
          this._callUpdateOptionsFromDom();
        }
      });
    });

    const selectElement = this.querySelector("select[slot='select-input']");
    if (selectElement) {
      this._selectSlotObserver.observe(
        this.querySelector("select[slot='select-input']"),
        selectSlotConfig
      );
    }
  }

  stopSelectSlotObserver() {
    if (this._selectSlotObserver) {
      if (this._selectSlotObserver.disconnect) {
        this._selectSlotObserver.disconnect();
      }
    }
  }

  startCustomValidationSlotObserver() {
    // Options for the observer (which mutations to observe)
    const customValidationResultSlotConfig = {
      attributes: true,
      childList: true,
      subtree: true,
      characterData: true,
    };

    this._customValidationResultSlotObserver = new MutationObserver(
      (mutationsList) => {
        mutationsList.forEach((mutation) => {
          if (
            mutation.type === "childList" ||
            mutation.type === "characterData"
          ) {
            const jsonData = JSON.parse(mutation.target.textContent);
            this.appPromise.then((app) => {
              // noinspection JSUnresolvedVariable
              app.ports.customValidationReceiver.send(jsonData);
            });
          }
        });
      }
    );

    const customValidationResultElement = this.querySelector(
      "[slot='custom-validation-result']"
    );

    if (customValidationResultElement) {
      this._customValidationResultSlotObserver.observe(
        customValidationResultElement,
        customValidationResultSlotConfig
      );
    }
  }

  stopCustomValidationSlotObserver() {
    if (this._customValidationResultSlotObserver) {
      if (this._customValidationResultSlotObserver.disconnect) {
        this._customValidationResultSlotObserver.disconnect();
      }
    }
  }

  startTransformationValidationSlotObserver() {
    // Options for the observer (which mutations to observe)
    const slotConfig = {
      attributes: false,
      childList: true,
      subtree: true,
      characterData: true,
    };

    this._transformationValidationSlotObserver = new MutationObserver(
      (mutationsList) => {
        mutationsList.forEach((mutation) => {
          if (mutation.type === "characterData") {
            this._updateTransformationValidationFromTheDom();
          }
        });
      }
    );

    const element = this.querySelector("[slot='transformation-validation']");
    if (element) {
      this._transformationValidationSlotObserver.observe(
        this.querySelector("[slot='transformation-validation']"),
        slotConfig
      );

      this._updateTransformationValidationFromTheDom();
    }
  }

  stopTransformationValidationSlotObserver() {
    if (this._transformationValidationSlotObserver) {
      if (this._transformationValidationSlotObserver.disconnect) {
        this._transformationValidationSlotObserver.disconnect();
      }
    }
  }

  _updateTransformationValidationFromTheDom() {
    const element = this.querySelector("[slot='transformation-validation']");
    if (element) {
      const jsonData = JSON.parse(element.textContent);
      this.appPromise.then((app) => {
        // noinspection JSUnresolvedVariable
        app.ports.transformationAndValidationReceiver.send(jsonData);
      });
    }
  }

  updateOptionsFromDom() {
    const selectElement = this.querySelector("select[slot='select-input']");
    if (selectElement) {
      const optionsJson = buildOptionsFromSelectElement(selectElement);
      this._callOptionChanged(optionsJson);
    }
  }

  // noinspection JSUnusedGlobalSymbols
  disconnectedCallback() {
    this._resizeObserver.disconnect();
    if (this._selectSlotObserver) {
      this._selectSlotObserver.disconnect();
    }

    this.stopCustomValidationSlotObserver();

    this.stopTransformationValidationSlotObserver();

    this._connected = false;
  }

  updateHiddenInputValueSlot() {
    if (!this.eventsOnlyMode) {
      const hiddenValueInput = this.querySelector(
        "[slot='hidden-value-input']"
      );
      if (hiddenValueInput) {
        if (this.selectedValue === null) {
          hiddenValueInput.setAttribute("value", "");
        } else if (this.selectedValue === undefined) {
          hiddenValueInput.setAttribute("value", "");
        } else {
          hiddenValueInput.setAttribute("value", this.selectedValue);
        }
      }
    }
  }

  /**
   * The idea with this method is that we need the selected input slot to mirror the internal state of the
   * much select, unless something else wants full control over the DOM (eventsOnlyMode is true), then we leave that
   * responsibility to them.
   *
   * One important thing that happens here is we need to pause the mutation observers so
   *  that we do not feed bad data back into the Elm app. Then, when we are done changing
   *  the DOM, turn the mutation observers back on.
   */
  // updateSelectInputSlot() {
  //   if (!this.eventsOnlyMode) {
  //     this.stopMuchSelectObserver();
  //     this.stopSelectSlotObserver();
  //     const selectInputSlot = this.querySelector("[slot='select-input']");
  //     if (selectInputSlot) {
  //       selectInputSlot.querySelectorAll("option").forEach((optionEl) => {
  //         if (optionEl.selected) {
  //           if (!this.isValueSelected(optionEl.value)) {
  //             optionEl.removeAttribute("selected");
  //           }
  //         } else if (this.isValueSelected(optionEl.value)) {
  //           optionEl.setAttribute("selected", "");
  //         }
  //       });
  //     }
  //     this.startMuchSelectObserver();
  //     this.startSelectSlotObserver();
  //   }
  // }

  // eslint-disable-next-line class-methods-use-this
  errorHandler(error) {
    // eslint-disable-next-line no-console
    console.error(error);
  }

  /**
   * This method updates the width this widget when it's not selected, so when
   *  it is selected it matches the input element.
   * This needs to be called very time the options or the values change or
   *  anything else that might change the height or width of the much-select.
   * It waits for 1 frame before doing calculating what the height and width
   *  should be.
   */
  updateDimensions() {
    window.requestAnimationFrame(() => {
      // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
      this.appPromise.then(() => {
        // We run this code in here because the shadow root won't be available until the
        //  elm app is ready.
        const valueCasingElement =
          this.shadowRoot.getElementById("value-casing");
        if (valueCasingElement) {
          let width = valueCasingElement.offsetWidth;
          let height = valueCasingElement.offsetHeight;

          // Prevent the width from falling below this threshold.
          if (width < this._minimumWidth) {
            width = this._minimumWidth;
          }

          // Prevent the height from falling below this threshold.
          if (height < this._minimumHeight) {
            height = this._minimumHeight;
          }

          this._callValueCasingWidthUpdate(width, height);
        }
      });
    });
  }

  buildFlags() {
    const flags = {};

    flags.isEventsOnly = booleanAttributeValueToBool(
      this.hasAttribute("events-only")
    );

    flags.allowMultiSelect = booleanAttributeValueToBool(
      this.hasAttribute("multi-select")
    );

    if (this.hasAttribute("multi-select-single-item-removal")) {
      flags.enableMultiSelectSingleItemRemoval =
        this.getAttribute("multi-select-single-item-removal").trim() === "true";
    } else {
      flags.enableMultiSelectSingleItemRemoval = false;
    }

    // flags.value = this.parsedSelectedValue;

    if (this.hasAttribute("placeholder")) {
      flags.placeholder = [true, this.getAttribute("placeholder").trim()];
    } else {
      flags.placeholder = [false, ""];
    }

    if (this.hasAttribute("size")) {
      flags.size = this.getAttribute("size").trim();
    } else {
      flags.size = "";
    }

    if (this.hasAttribute("search-string-minimum-length")) {
      flags.searchStringMinimumLength = parseInt(
        this.getAttribute("search-string-minimum-length").trim(),
        10
      );
    } else {
      // TODO This should only be in the Elm code.
      // The default value for the search string minimum length.
      flags.searchStringMinimumLength = 2;
    }

    if (this.hasAttribute("show-dropdown-footer")) {
      flags.showDropdownFooter = booleanAttributeValueToBool(
        this.getAttribute("show-dropdown-footer")
      );
    } else {
      flags.showDropdownFooter = false;
    }

    if (this.hasAttribute("option-sorting")) {
      flags.optionSort = this.getAttribute("option-sorting");
    } else {
      flags.optionSort = "no-sorting";
    }

    if (
      this.hasAttribute("output-style") &&
      MuchSelect.isValidOutputStyle(this.getAttribute("output-style"))
    ) {
      flags.outputStyle = this.getAttribute("output-style");
    } else {
      flags.outputStyle = "";
    }

    const transformationAndValidationSlot = this.querySelector(
      "[slot='transformation-validation']"
    );

    if (transformationAndValidationSlot) {
      flags.transformationAndValidationJson =
        transformationAndValidationSlot.textContent;
    } else {
      flags.transformationAndValidationJson = "";
    }

    flags.disabled = booleanAttributeValueToBool(this.getAttribute("disabled"));
    flags.loading = booleanAttributeValueToBool(this.getAttribute("loading"));

    // TODO let's get the verbage here aligned.
    flags.selectedItemStaysInPlace = !booleanAttributeValueToBool(
      this.getAttribute("selected-option-goes-to-top")
    );
    flags.maxDropdownItems = this.getAttribute("max-dropdown-items");

    if (this.hasAttribute("allow-custom-options")) {
      flags.customOptionHint = this.getAttribute("allow-custom-options");
      flags.allowCustomOptions = true;
    } else {
      flags.customOptionHint = null;
      flags.allowCustomOptions = false;
    }

    const selectElement = this.querySelector("select[slot='select-input']");
    if (this.hasAttribute("selected-value")) {
      if (selectElement && selectElement.querySelector("option[selected]")) {
        throw new Error(
          "MuchSelect does not support using the selected-value attribute and selected options in the selected-value slot."
        );
      }
      flags.selectedValue = this.getAttribute("selected-value");
    } else {
      flags.selectedValue = "";
    }

    flags.selectedValueEncoding = this.getAttribute("selected-value-encoding");

    if (selectElement) {
      flags.optionsJson = JSON.stringify(
        buildOptionsFromSelectElement(selectElement)
      );
    } else {
      flags.optionsJson = JSON.stringify([]);
    }

    return flags;
  }

  /**
   * This method gets called any time the Elm app changes the value of this much select.
   * An "outgoing port" if you will.
   *
   * The selected values always come in an array of tuples, the first part of the tuple
   * being the value, and the second part being the label.
   *
   * @param {array} valuesObjects
   * @param {boolean} isInitialValueChange - This prevents events from being emitted while things are getting setup.
   */
  valueChangedHandler(valuesObjects, isInitialValueChange = false) {
    const isValid = valuesObjects.filter((v) => !v.isValid).length === 0;

    if (isValid) {
      this._emitBlurOrUnfocusedValueChanged = true;
    }

    this.updateDimensions();
    if (
      this.hasAttribute("multi-select") &&
      this.getAttribute("multi-select") !== "false"
    ) {
      if (!isInitialValueChange) {
        this.dispatchEvent(
          new CustomEvent("valueChanged", {
            bubbles: true,
            detail: { values: valuesObjects, isValid },
          })
        );
        // The change event is for backwards compatibility.
        this.dispatchEvent(
          new CustomEvent("change", {
            bubbles: true,
            detail: { values: valuesObjects, isValid },
          })
        );
      }
    } else if (valuesObjects.length === 0) {
      if (!isInitialValueChange) {
        // If we are in single select mode and the value is empty.
        this.dispatchEvent(
          new CustomEvent("valueChanged", {
            bubbles: true,
            detail: { value: null, values: [], isValid },
          })
        );
        // The change event is for backwards compatibility.
        this.dispatchEvent(
          new CustomEvent("change", {
            bubbles: true,
            detail: { value: null, values: [], isValid },
          })
        );
      }
    } else if (valuesObjects.length === 1) {
      if (!isInitialValueChange) {
        // If we are in single select mode put the list of values in the event.
        this.dispatchEvent(
          new CustomEvent("valueChanged", {
            bubbles: true,
            detail: { value: valuesObjects[0], values: valuesObjects, isValid },
          })
        );
        // The change event is for backwards compatibility.
        this.dispatchEvent(
          new CustomEvent("changed", {
            bubbles: true,
            detail: { value: valuesObjects, isValid },
          })
        );
      }
    } else {
      // If we are in single select mode and there is more than one value then something is wrong.
      throw new TypeError(
        `In single select mode we are expecting a single value, instead we got ${valuesObjects.length}`
      );
    }
  }

  customOptionSelected(values) {
    if (
      this.hasAttribute("multi-select") &&
      this.getAttribute("multi-select") !== "false" &&
      values.length > 0
    ) {
      // If we are in multi select mode put the list of values in the event.
      this.dispatchEvent(
        new CustomEvent("customValueSelected", {
          bubbles: true,
          detail: {
            values,
          },
        })
      );
    } else if (values.length === 1) {
      // If we are in single select mode put the list of values in the event.
      this.dispatchEvent(
        new CustomEvent("customValueSelected", {
          bubbles: true,
          detail: {
            value: values[0],
          },
        })
      );
    } else {
      // If we are in single select mode and there is not one value then something is wrong.
      throw new TypeError(
        `In single select mode we are expecting a single custom option, instead we got ${values.length}`
      );
    }
  }

  _handleInputKeyUp(searchString) {
    this.dispatchEvent(
      new CustomEvent("inputKeyUp", {
        bubbles: true,
        detail: { searchString },
      })
    );

    this._inputKeypressDebounceHandler(searchString);
  }

  get appPromise() {
    if (this._appPromise) {
      return this._appPromise;
    }
    this._appPromise = new Promise((resolve, reject) => {
      if (this._app) {
        resolve(this._app);
      } else {
        try {
          const flags = this.buildFlags();

          // User shadow DOM.
          this._parentDiv = this.attachShadow({ mode: "open" });

          const html = getMuchSelectTemplate(this.styleTag).content.cloneNode(
            true
          );
          this._parentDiv.append(html);

          const elmDiv = this._parentDiv.querySelector("#mount-node");

          // noinspection JSUnresolvedVariable
          this._app = Elm.MuchSelect.init({
            flags,
            node: elmDiv,
          });
          resolve(this._app);
        } catch (error) {
          reject(error);
          this.errorHandler(error);
        }
      }
    });
    return this._appPromise;
  }

  async getConfigValuePromise(key) {
    const selectionConfig = await this.getSelectionConfig();
    if (Object.hasOwn(selectionConfig, key)) {
      return selectionConfig[key];
    }
    throw new Error(`Invalid config value: ${key}`);
  }

  /**
   * Allow the lazy setup of the filter worker. Until we actually do
   *  some filtering, let's just leave it.
   *
   * @returns {Promise}
   */
  get filterWorkerPromise() {
    if (this._filterWorkerPromise) {
      return this._filterWorkerPromise;
    }
    this._filterWorkerPromise = new Promise((resolve) => {
      if (this._filterWorker) {
        resolve(this._filterWorker);
      } else {
        this.setupFilterWorker().then(() => {
          resolve(this._filterWorker);
        });
      }
    });
    return this._filterWorkerPromise;
  }

  get parentDivPromise() {
    return this.appPromise.then(() => this._parentDiv);
  }

  get selectedValue() {
    return this.getSelectedValues();
  }

  set selectedValue(value) {
    const newSelectedValue = cleanUpSelectedValue(value);

    this._callValueChanged(newSelectedValue);

    // this.updateHiddenInputValueSlot();
  }

  get rawSelectedValue() {
    return this.getSelectedValues(true);
  }

  /**
   * This is a "sync" function, so this is kinda like a "set" function but the
   *  selected value(s) are coming from Elm. So we do not need to tell Elm about
   *  them.
   *
   * @param value
   * @private
   */
  // _syncSelectedValue(value) {
  //   const newSelectedValue = cleanUpSelectedValue(value);
  //
  //   if (newSelectedValue === this._selectedValue) {
  //     return;
  //   }
  //
  //   this._selectedValue = newSelectedValue;
  //
  //   if (!this.eventsOnlyMode) {
  //     this.setAttribute("selected-value", this._selectedValue);
  //   }
  // }

  // get parsedSelectedValue() {
  //   if (this.selectedValueEncoding === "comma") {
  //     if (this.selectedValue) {
  //       return this.selectedValue.split(",");
  //     }
  //     return [];
  //   }
  //   if (this.selectedValueEncoding === "json") {
  //     if (this.isInMultiSelectMode) {
  //       if (this.selectedValue === "") {
  //         // a special case because an empty string is not valid JSON.
  //         return [];
  //       }
  //       return JSON.parse(decodeURIComponent(this.selectedValue));
  //     }
  //     if (this.selectedValue === "") {
  //       // a special case because an empty string is not valid JSON.
  //       return "";
  //     }
  //     const val = JSON.parse(decodeURIComponent(this.selectedValue));
  //     if (Array.isArray(val)) {
  //       return val.shift();
  //     }
  //     if (val === undefined) {
  //       return null;
  //     }
  //     return val;
  //   }
  //   throw new Error(
  //     `Unknown selected value encoding, something is very wrong: ${this.selectedValueEncoding}`
  //   );
  // }

  // set parsedSelectedValue(values) {
  //   this.selectedValue = this._makeSelectedValue(values);
  // }

  /**
   * This method takes a selected value, and it returns a string of the "parsed"
   *  selected value.
   *
   * @param values
   * @returns {string|*}
   * @private
   */
  // _makeSelectedValue(values) {
  //   if (this.selectedValueEncoding === "comma") {
  //     if (Array.isArray(values)) {
  //       return values.join(",");
  //     }
  //     // This should be a string or possibly a null.
  //     return values;
  //   }
  //   if (this.selectedValueEncoding === "json") {
  //     if (values === "") {
  //       // The empty string here is a special case because we don't want to encode an empty string.
  //       return "";
  //     }
  //     return encodeURIComponent(JSON.stringify(values));
  //   }
  //   return "";
  // }

  /**
   * This is a "sync" function, so this is kinda like a "set" function but the
   *  selected value(s) are coming from Elm. So we do not need to tell Elm about
   *  them.
   *
   * @param values
   * @private
   */
  // _syncParseSelectedValue(values) {
  //   // this._syncSelectedValue(this._makeSelectedValue(values));
  // }

  get placeholder() {
    return this.getConfigValuePromise("placeholder");
  }

  set placeholder(placeholder) {
    this.appPromise.then((app) => {
      if (placeholder === null) {
        // noinspection JSUnresolvedVariable
        app.ports.placeholderChangedReceiver.send([false, ""]);
      } else {
        // noinspection JSUnresolvedVariable
        app.ports.placeholderChangedReceiver.send([true, placeholder]);
      }
    });
  }

  get disabled() {
    return this.getConfigValuePromise("disabled");
  }

  set disabled(value) {
    const disabled = booleanAttributeValueToBool(value);

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.disableChangedReceiver.send(disabled)
    );
  }

  get eventsOnlyMode() {
    return this.getConfigValuePromise("events-only");
  }

  set eventsOnlyMode(value) {
    this.appPromise.then((app) => {
      app.ports.attributeChanged.send(["events-only", value]);
    });
  }

  get maxDropdownItems() {
    return this.getConfigValuePromise("max-dropdown-items");
  }

  set maxDropdownItems(value) {
    let newValue;
    if (typeof value === "number") {
      newValue = Math.floor(value);
    } else if (typeof value === "string") {
      newValue = Math.floor(parseInt(value, 10));
    } else {
      throw new TypeError("Max dropdown items must be a number!");
    }

    // TODO Handle this floor in Elm.
    let maxDropdownItems = 3;

    if (newValue < 3) {
      maxDropdownItems = 3;
    } else {
      maxDropdownItems = newValue;
    }
    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.maxDropdownItemsChangedReceiver.send(maxDropdownItems)
    );
  }

  /**
   * @returns {Promise<boolean>}
   */
  get showDropdownFooter() {
    return this.getConfigValuePromise("show-dropdown-footer");
  }

  /**
   * @param value {boolean|string}
   */
  set showDropdownFooter(value) {
    const searchStringMinimumLength = booleanAttributeValueToBool(value);

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.showDropdownFooterChangedReceiver.send(
        searchStringMinimumLength
      )
    );
  }

  /**
   * Search String Minimum Length getter.
   *
   * @returns {Promise<number>}
   */
  get searchStringMinimumLength() {
    return this.getConfigValuePromise("search-string-minimum-length");
  }

  /**
   * Search String Minimum Length setter
   *
   * @param value {string|number}
   */
  set searchStringMinimumLength(value) {
    let searchStringMinimumLength;

    if (value === "false") {
      searchStringMinimumLength = 0;
    } else if (value === "") {
      searchStringMinimumLength = 0;
    } else if (Number.isInteger(value)) {
      if (value >= 0) {
        searchStringMinimumLength = value;
      } else {
        searchStringMinimumLength = 0;
      }
    } else if (typeof value === "string") {
      const intVal = parseInt(value, 10);
      if (intVal >= 0) {
        searchStringMinimumLength = intVal;
      } else {
        searchStringMinimumLength = 0;
      }
    }

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.searchStringMinimumLengthChangedReceiver.send(
        searchStringMinimumLength
      )
    );
  }

  /**
   * Get whether we are in multi-select mode.
   *
   * @returns {Promise<boolean>}
   */
  get isInMultiSelectMode() {
    return this.getConfigValuePromise("multi-select");
  }

  set isInMultiSelectMode(value) {
    let cleanValue;
    if (value === "false") {
      cleanValue = false;
    } else if (value === "") {
      cleanValue = true;
    } else {
      cleanValue = !!value;
    }

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.multiSelectChangedReceiver.send(cleanValue)
    );
  }

  // noinspection JSUnusedGlobalSymbols
  get isInMultiSelectModeWithSingleItemRemoval() {
    return this.getConfigValuePromise("single-item-removal");
  }

  set isInMultiSelectModeWithSingleItemRemoval(value) {
    const isInMultiSelectModeWithSingleItemRemoval =
      booleanAttributeValueToBool(value);

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.multiSelectSingleItemRemovalChangedReceiver.send(
        isInMultiSelectModeWithSingleItemRemoval
      )
    );
  }

  get loading() {
    return this.getConfigValuePromise("loading");
  }

  set loading(value) {
    let isLoading;
    if (value === "false") {
      isLoading = false;
    } else if (value === "") {
      isLoading = true;
    } else {
      isLoading = !!value;
    }
    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.loadingChangedReceiver.send(isLoading)
    );
  }

  /**
   * A promise that will resolve to a boolean that will be true if much-select
   * is allowing custom options and false if otherwise. It needs to be a promise
   * because it needs to get the answer from the Elm state.
   *
   * @returns Promise<boolean>
   */
  get allowCustomOptions() {
    // TODO ensure this is a boolean value
    return this.getConfigValuePromise("allows-custom-options");
  }

  set allowCustomOptions(value) {
    this.appPromise.then((app) => {
      if (value === null) {
        app.ports.allowCustomOptionsReceiver.send([true, ""]);
      } else if (value === undefined) {
        app.ports.allowCustomOptionsReceiver.send([true, ""]);
      } else if (value === true) {
        app.ports.allowCustomOptionsReceiver.send([true, ""]);
      } else if (value === false) {
        app.ports.allowCustomOptionsReceiver.send([false, ""]);
      } else {
        app.ports.allowCustomOptionsReceiver.send([true, value]);
      }
    });
  }

  get customOptionHint() {
    return this.getConfigValuePromise("custom-options-hint");
  }

  set customOptionHint(value) {
    if (
      value === "false" ||
      value === "true" ||
      value === null ||
      value === ""
    ) {
      // noinspection JSUnresolvedVariable
      this.appPromise.then((app) => {
        // noinspection JSUnresolvedVariable
        app.ports.clearCustomOptionHintReceiver.send();
      });
    } else if (typeof value === "string") {
      // noinspection JSUnresolvedVariable
      this.appPromise.then((app) => {
        // noinspection JSUnresolvedVariable
        app.ports.customOptionHintReceiver.send(value);
      });
    } else {
      throw new TypeError(
        `Unexpected type for the customOptionHint, it should be a string but instead it is a: ${typeof value}`
      );
    }
  }

  get selectedItemStaysInPlace() {
    return this.getConfigValuePromise("selected-item-stays-in-place");
  }

  set selectedItemStaysInPlace(value) {
    let selectedItemStaysInPlace;
    if (value === "false") {
      selectedItemStaysInPlace = false;
    } else {
      selectedItemStaysInPlace = !!value;
    }

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.selectedItemStaysInPlaceChangedReceiver.send(
        selectedItemStaysInPlace
      )
    );
  }

  /**
   * TODO What's the deal with the name, let's align this stuff better.
   * @param value
   */
  set selectedItemGOesToTop(value) {
    let selectedItemStaysInPlace;
    if (value === "") {
      selectedItemStaysInPlace = false;
    } else if (value === null) {
      selectedItemStaysInPlace = true;
    } else {
      selectedItemStaysInPlace = !value;
    }

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.selectedItemStaysInPlaceChangedReceiver.send(
        selectedItemStaysInPlace
      )
    );
  }

  get selectedValueEncoding() {
    return this.getConfigValuePromise("selected-value-encoding");
  }

  /**
   * Do not allow this value to be anything but:
   *  - json
   *  - comma (default)
   *
   * In addition to actually changing the private property, it also (re)encodes
   *  the current selected value, but ONLY IF the web component is connected,
   *  meaning the connected callback has been called, if that has not been called
   *  we are still initializing.
   * */
  set selectedValueEncoding(value) {
    const currentValue = this.parsedSelectedValue;
    let selectedValueEncoding;
    if (value === "json") {
      selectedValueEncoding = "json";
    } else if (value === "comma") {
      selectedValueEncoding = "comma";
    } else {
      throw new Error(`Invalid selected value encoding: ${value}`);
    }
    if (this._connected) {
      this.parsedSelectedValue = currentValue;
    }

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.selectedValueEncodingChangeReceiver.send(selectedValueEncoding)
    );
  }

  get optionSorting() {
    return this.getConfigValuePromise("option-sorting");
  }

  /**
   * Do not allow this value to be anything but:
   *  - no-sorting
   *  - by-option-label
   * */
  set optionSorting(value) {
    let optionSorting = "no-sorting";
    if (value === "no-sorting") {
      optionSorting = "no-sorting";
    } else if (value === "by-option-label") {
      optionSorting = "by-option-label";
    } else if (value === null) {
      optionSorting = "no-sorting";
    } else if (value === "") {
      optionSorting = "no-sorting";
    } else {
      throw new Error(`Unexpected value for option sorting: ${value}`);
    }

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.optionSortingChangedReceiver.send(optionSorting)
    );
  }

  /**
   * @param {string} outputStyle
   * @return boolean
   * */
  static isValidOutputStyle(outputStyle) {
    return ["customHtml", "custom-html", "datalist"].includes(outputStyle);
  }

  /**
   * @return {Promise<string>}
   * */
  get outputStyle() {
    return this.getConfigValuePromise("output-style");
  }

  set outputStyle(value) {
    // TODO Move this validation to Elm.
    if (MuchSelect.isValidOutputStyle(value)) {
      const outputStyle = value;

      this.appPromise.then((app) => {
        // noinspection JSUnresolvedVariable
        app.ports.outputStyleChangedReceiver.send(outputStyle);
        this._updateTransformationValidationFromTheDom();
      });
    } else {
      throw new Error(`Invalid output style: ${value}`);
    }
  }

  // eslint-disable-next-line class-methods-use-this
  get styleTag() {
    // noinspection CssInvalidPropertyValue
    return `<style>
      :host {
        /*
        This web components should take up some space on the page.

        TODO: Do we really have to set this by hand? Can't we do something so that
        this gets calculated automatically? If it must be set by hand we should probably
        do something a bit more clever here to not hard code these values so much.
        */

        min-height: 40px;
        min-width: ${this._minimumWidth}px;
      }

      /*
      If we are using a select element in the select-input slot to manage the
      the options do not show it.
      */
      slot[name='select-input'] {
        display: none;
      }

      #wrapper {
        min-width: ${this._minimumWidth}px;
        margin-top: auto;
        margin-bottom: auto;
        position: relative;
      }

      #value-casing {
        display: flex;
      }

      #value-casing.output-style-custom-html {
        border: 1px solid black;
        cursor: pointer;
      }

      #value-casing.output-style-custom-html #input-filter {
        flex-grow: 3;
        flex-shrink: 0;
        flex-basis: 10%;

        /* We don't want a border because the value-casing will supply the border for
          this input.
        */
        border: none;

        /*
        We do not want an outline on the input (filter) because we want everything
        inside of the #value-casing to (kinda) act like a text input.
        */
        outline: none;
        background: none;
      }

      #value-casing.output-style-custom-html.multi {
        /*
        In multi select mode, let's let the selected values line up on a row and then wrap.
        */
        flex-flow: row wrap;
      }

      #value-casing.output-style-custom-html.multi .value {
        border: 3px solid black;
        min-width: 10px;

        flex-grow: 0;
        flex-shrink: 1;
        flex-basis: auto;
      }

      .value .remove-option::after {
        content: "x";
        padding-left: 5px;
      }

      slot[name='loading-indicator'] {
        display: block;
        position: absolute;
        right: 5px;
        top: 10px;
      }

      #dropdown {
        visibility: hidden;
        position: absolute;
        left: 0;
        display: inline-block;
        z-index: 10;
        max-height: 300px;
        overflow-y: auto;
        cursor: default;

        background-color: white;
        border: 1px solid black;
      }

      #dropdown.showing {
        visibility: visible;
      }
      #dropdown.hiding {
        visibility: hidden;
      }

      .optgroup {
        background-color: gray;
      }

      .option {
        cursor: pointer;
      }

      .option.selected {
        font-weight: bold;
      }

      .option.highlighted {
        background-color: black;
        color: white;
      }

      .option.disabled {
        cursor: default;
        color: gray;
      }

      .description {
        font-size: 75%;
      }

      #add-remove-buttons {
        display: flex;
      }

      .highlight { color: blue }

      /* This loading indicator was copied (almost exactly)
        from this article.
        https://dev.to/devmount/learn-css-animation-by-creating-pure-css-loaders-3lm6

        It was chosen because it was so simple and short.
      */
      .default-loading-indicator {
        height: 18px;
        width: 18px;
        border: 5px solid rgba(150, 150, 150, 0.2);
        border-radius: 50%;
        border-top-color: rgb(150, 150, 150);
        animation: rotate 1s 0s infinite ease-in-out alternate;
      }
      @keyframes rotate {
        0%   { transform: rotate(0);      }
        100% { transform: rotate(360deg); }
      }
    </style>`;
  }

  /**
   * This should tell you if a value is selected or not, whether the much-select is in single or multi select mode.
   *
   * @param testValue
   * @returns {boolean}
   */
  isValueSelected(testValue) {
    return this.parsedSelectedValue.includes(testValue);
  }

  updateOptions(options) {
    const cleanedUpOptions = cleanUpOptions(options);
    this._callOptionChanged(cleanedUpOptions);
    this.updateDimensions();
  }

  addOption(option) {
    this.addOptions([option]);
  }

  addOptions(options) {
    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.addOptionsReceiver.send(cleanUpOptions(options))
    );
    this.updateDimensions();
  }

  selectOption(option) {
    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.selectOptionReceiver.send(cleanUpOption(option))
    );
  }

  deselectOption(option) {
    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.deselectOptionReceiver.send(cleanUpOption(option))
    );
  }

  async getAllOptions() {
    return new Promise((resolve) => {
      const callback = (allOptions) => {
        this.appPromise.then((app) => {
          // noinspection JSUnresolvedVariable
          app.ports.allOptions.unsubscribe(callback);
        });
        resolve(allOptions);
      };

      this.appPromise.then((app) => {
        // noinspection JSUnresolvedVariable
        app.ports.allOptions.subscribe(callback);
        // noinspection JSUnresolvedVariable
        app.ports.requestAllOptionsReceiver.send(null);
      });
    });
  }

  async getSelectionConfig() {
    return new Promise((resolve) => {
      const callback = (selectionConfig) => {
        this.appPromise.then((app) => {
          // noinspection JSUnresolvedVariable
          if (app.ports.requestConfigState.unsubscribe) {
            // noinspection JSUnresolvedVariable
            app.ports.requestConfigState.unsubscribe(callback);
          }
        });
        resolve(selectionConfig);
      };

      this.appPromise.then((app) => {
        // noinspection JSUnresolvedVariable
        app.ports.dumpConfigState.subscribe(callback);
        // noinspection JSUnresolvedVariable
        app.ports.requestConfigState.send(null);
      });
    });
  }

  async getSelectedValues(rawSelectedValue = false) {
    return new Promise((resolve) => {
      const callback = (selectedValues) => {
        this.appPromise.then((app) => {
          // noinspection JSUnresolvedVariable
          if (app.ports.requestSelectedValues.unsubscribe) {
            // noinspection JSUnresolvedVariable
            app.ports.requestSelectedValues.unsubscribe(callback);
          }
        });

        if (rawSelectedValue) {
          resolve(selectedValues.rawValue);
        } else {
          resolve(selectedValues.value);
        }
      };

      this.appPromise.then((app) => {
        // noinspection JSUnresolvedVariable
        app.ports.dumpSelectedValues.subscribe(callback);
        // noinspection JSUnresolvedVariable
        app.ports.requestSelectedValues.send(null);
      });
    });
  }

  /**
   * We want to lazy load the filter worker because we do not
   * really need it until the filtering actually happens.
   * So if the filter worker has not been created, just hang on to
   * our options for the filter worker until we really need them.
   *
   * @returns {Promise<void>}
   */
  async updateFilterWorkerOptions() {
    const options = await this.getAllOptions();
    if (this._filterWorker) {
      this.filterWorkerPromise.then((filterWorker) => {
        filterWorker.postMessage({
          portName: "receiveOptions",
          jsonBlob: options,
        });
      });
    } else {
      this._filterWorkerOptionsCache = options;
    }
  }

  setupFilterWorker() {
    return this.parentDivPromise.then((parentDiv) => {
      const code = parentDiv.querySelector("#filter-worker").textContent;
      const blob = new Blob([code], { type: "application/javascript" });

      this._filterWorker = new Worker(URL.createObjectURL(blob));

      this._filterWorker.onmessage = ({ data }) => {
        const { messageName, searchResultData, errorMessage } = data;
        if (messageName === "searchResults") {
          this.appPromise.then((app) => {
            // noinspection JSUnresolvedVariable
            app.ports.updateSearchResultDataWithWebWorkerReceiver.send(
              searchResultData
            );
          });
        } else if (messageName === "errorMessage") {
          this.errorHandler(errorMessage);
        } else {
          this.errorHandler(
            `Unknown message from filter worker: ${messageName}`
          );
        }
      };

      if (this._filterWorkerOptionsCache) {
        this._filterWorker.postMessage({
          portName: "receiveOptions",
          jsonBlob: this._filterWorkerOptionsCache,
        });

        // Maybe this can get garbage collected, we should not need it again.
        //  not that we have a filter worker we don't need any more.
        this._filterWorkerOptionsCache = null;
      }
    });
  }
}

// noinspection JSUnusedGlobalSymbols
export default MuchSelect;
