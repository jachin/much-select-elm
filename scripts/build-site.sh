#!/usr/bin/env bash
npx parcel build \
  --out-dir build/site/public \
  public/404.html \
  public/clear-button.html \
  public/custom-options.html \
  public/dropdown-options.html \
  public/empty-options.html \
  public/events.html \
  public/fancy-characters.html \
  public/index.html \
  public/initial-value.html \
  public/option-api.html
