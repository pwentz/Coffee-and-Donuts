module Command.Model exposing (CommandResult, apply, init)

import Messages as Msg exposing (Msg, Success)
import Models exposing (AppData, Model)


type CommandResult
    = Successful ( Success, AppData )
    | Failure Model


apply : (( Success, AppData ) -> ( Model, Cmd Msg )) -> CommandResult -> ( Model, Cmd Msg )
apply f commandRes =
    case commandRes of
        Successful data ->
            f data

        Failure model ->
            model ! []


init : Msg -> Model -> CommandResult
init msg model =
    case model of
        Models.Error _ ->
            Failure model

        Models.Model appData ->
            let
                failure err =
                    Failure (Models.Error err)

                success succ =
                    Successful ( succ, appData )
            in
            Msg.applyWithDefault success failure msg
