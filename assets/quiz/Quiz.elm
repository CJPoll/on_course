module Quiz exposing (main, init, subscriptions, update, view)

import Html exposing (text, Html)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode
import Task
import String


type Msg
    = Noop
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | JoinChannel String
    | GetCurrentQuestion


type alias Question =
    { prompt : String
    }


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , quizId : String
    , question : Maybe Question
    }


main : Program String Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


quizRoom quizId =
    String.concat [ "quiz:", quizId ]


init : String -> ( Model, Cmd Msg )
init quizId =
    ( { socket = Phoenix.Socket.init "ws://on_course.dev:4000/socket/websocket"
      , quizId = quizId
      , question = Nothing
      }
    , String.concat [ "quiz:", quizId ]
        |> Task.succeed
        |> Task.perform JoinChannel
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            Debug.log "Noop"
                ( model, Cmd.none )

        PhoenixMsg msg ->
            let
                ( phoenixSocket, cmd ) =
                    Phoenix.Socket.update msg model.socket
            in
                ( { model | socket = phoenixSocket }
                , Cmd.map PhoenixMsg cmd
                )

        GetCurrentQuestion ->
            let
                push_ =
                    model.quizId
                        |> quizRoom
                        |> Phoenix.Push.init "current_question"
                        |> Phoenix.Push.withPayload (Json.Encode.object [ ( "quiz_id", Json.Encode.string model.quizId ) ])

                ( socket, cmd ) =
                    Phoenix.Socket.push push_ model.socket
            in
                Debug.log "This is the current question"
                    ( { model | socket = socket }, Cmd.map PhoenixMsg cmd )

        JoinChannel channelName ->
            let
                channel =
                    Phoenix.Channel.init channelName
                        |> Phoenix.Channel.withPayload (Json.Encode.object [])
                        |> Phoenix.Channel.onJoin (always GetCurrentQuestion)
                        |> Phoenix.Channel.onClose (always Noop)

                ( socket, cmd ) =
                    Phoenix.Socket.join channel model.socket
            in
                ( { model | socket = socket }, Cmd.map PhoenixMsg cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.socket PhoenixMsg


view : Model -> Html Msg
view model =
    text "Hi"
