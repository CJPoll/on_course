module Quiz.Session exposing (Session, answerSelected, newSession, joined, joinQuiz, loadCurrentQuestion)

import Quiz.Msg exposing (..)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode


type SessionState
    = Disconnected
    | Joining
    | Connected
    | InSession


type alias Session =
    { quizId : String
    , state : SessionState
    , socket : Phoenix.Socket.Socket Msg
    }


newSession : String -> Session
newSession quizId =
    let
        socket =
            "ws://on_course.dev:4000/socket/websocket"
                |> Phoenix.Socket.init
                |> Phoenix.Socket.withDebug
    in
        { state = Disconnected
        , quizId = quizId
        , socket = socket
        }


quizRoom quizId =
    String.concat [ "quiz:", quizId ]


answerSelected :
    String
    -> Session
    -> ( Session, Cmd (Phoenix.Socket.Msg Msg) )
answerSelected answer session =
    sendMessage
        "answer_selected"
        (Json.Encode.object [ ( "answer", Json.Encode.string answer ) ])
        (Just ReviewAnswer)
        session


joinQuiz :
    String
    -> Session
    -> ( Session, Cmd (Phoenix.Socket.Msg Msg) )
joinQuiz userId session =
    case session.state of
        Disconnected ->
            let
                channel =
                    session.quizId
                        |> quizRoom
                        |> Phoenix.Channel.init
                        |> Phoenix.Channel.withPayload
                            (Json.Encode.object
                                [ ( "userId"
                                  , Json.Encode.string userId
                                  )
                                ]
                            )
                        |> Phoenix.Channel.onJoin (always SessionJoined)
                        |> Phoenix.Channel.onClose (always Noop)

                ( newSocket, cmd ) =
                    Phoenix.Socket.join channel session.socket
            in
                ( { session | state = Joining, socket = newSocket }, cmd )

        Joining ->
            ( session, Cmd.none )

        Connected ->
            ( session, Cmd.none )

        InSession ->
            ( session, Cmd.none )


joined : Session -> Session
joined session =
    { session | state = Connected }


loadCurrentQuestion : Session -> ( Session, Cmd (Phoenix.Socket.Msg Msg) )
loadCurrentQuestion session =
    case session.state of
        Disconnected ->
            ( session, Cmd.none )

        Joining ->
            ( session, Cmd.none )

        Connected ->
            getQuestion
                session.quizId
                session

        InSession ->
            getQuestion
                session.quizId
                session


getQuestion : String -> Session -> ( Session, Cmd (Phoenix.Socket.Msg Msg) )
getQuestion quizId session =
    sendMessage
        "current_question"
        (Json.Encode.object [ ( "quiz_id", Json.Encode.string session.quizId ) ])
        (Just QuestionAsked)
        session


sendMessage :
    String
    -> Json.Encode.Value
    -> Maybe (Json.Encode.Value -> Msg)
    -> Session
    -> ( Session, Cmd (Phoenix.Socket.Msg Msg) )
sendMessage message payload onSuccess session =
    case onSuccess of
        Nothing ->
            let
                pusher =
                    session.quizId
                        |> quizRoom
                        |> Phoenix.Push.init message
                        |> Phoenix.Push.withPayload payload

                ( newSocket, cmd ) =
                    Phoenix.Socket.push pusher session.socket
            in
                ( { session | state = Connected, socket = newSocket }, cmd )

        Just msg ->
            let
                pusher =
                    session.quizId
                        |> quizRoom
                        |> Phoenix.Push.init message
                        |> Phoenix.Push.withPayload payload
                        |> Phoenix.Push.onOk msg

                ( newSocket, cmd ) =
                    Phoenix.Socket.push pusher session.socket
            in
                ( { session | state = Connected, socket = newSocket }, cmd )
