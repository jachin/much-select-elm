port module Ports exposing (valueChanged)


port valueChanged : List ( String, String ) -> Cmd msg
