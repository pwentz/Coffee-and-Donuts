module Command.Model exposing (CommandResult, applyUpdate, init)

import App.Model exposing (Model)
import App.Msg as Msg exposing (Msg, Success)
import Error.Model exposing (Err)


type CommandResult
    = Failure Err
    | Successful ( Success, App.Model.Data )


applyUpdate : (( Success, App.Model.Data ) -> ( Model, Cmd Msg )) -> CommandResult -> ( Model, Cmd Msg )
applyUpdate f commandRes =
    case commandRes of
        Successful data ->
            f data

        Failure err ->
            App.Model.initWithError err ! []


init : Msg -> Model -> CommandResult
init msg model =
    let
        onData data =
            let
                success succ =
                    Successful ( succ, data )
            in
            Msg.applyWithDefault success Failure msg
    in
    App.Model.applyWithDefault onData Failure model
