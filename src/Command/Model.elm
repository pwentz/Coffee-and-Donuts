module Command.Model exposing (CommandResult, apply, init)

import App.Model exposing (Model)
import Msg exposing (Msg, Success)


type CommandResult
    = Successful ( Success, App.Model.Data )
    | Failure Model


apply : (( Success, App.Model.Data ) -> ( Model, Cmd Msg )) -> CommandResult -> ( Model, Cmd Msg )
apply f commandRes =
    case commandRes of
        Successful data ->
            f data

        Failure model ->
            model ! []


init : Msg -> Model -> CommandResult
init msg model =
    let
        onData data =
            let
                success succ =
                    Successful ( succ, data )
            in
            Msg.applyWithDefault success (Failure << App.Model.initWithError) msg
    in
    App.Model.applyWithDefault onData (\_ -> Failure model) model
