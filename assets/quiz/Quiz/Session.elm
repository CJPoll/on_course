module Quiz.Session exposing (Session, newSession, joined, joinQuiz, loadCurrentQuestion)

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
                    session.socket
                        |> Phoenix.Socket.on "current_question" (quizRoom session.quizId) QuestionAsked
                        |> Phoenix.Socket.join channel
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
    let
        pusher =
            session.quizId
                |> quizRoom
                |> Phoenix.Push.init "current_question"
                |> Phoenix.Push.withPayload (Json.Encode.object [ ( "quiz_id", Json.Encode.string session.quizId ) ])

        ( newSocket, cmd ) =
            Phoenix.Socket.push pusher session.socket
    in
        ( { session | state = Connected, socket = newSocket }, cmd )
