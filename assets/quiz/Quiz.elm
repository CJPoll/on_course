module Quiz exposing (main, init, subscriptions, update, view)

import Html exposing (text, Html)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push


type Msg
    = Noop
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


type alias Model =
    { socket : Phoenix.Socket.Socket Msg }


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : ( Model, Cmd Msg )
init =
    ( { socket = Phoenix.Socket.init "ws://localhost:4000/socket/websocket" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        PhoenixMsg msg ->
            let
                ( phoenixSocket, cmd ) =
                    Phoenix.Socket.update msg model.socket
            in
                ( { model | socket = phoenixSocket }
                , Cmd.map PhoenixMsg cmd
                )


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.socket PhoenixMsg


view : Model -> Html Msg
view model =
    text "Hi"
