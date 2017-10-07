module Quiz exposing (main, init, subscriptions, update, view)

import Html exposing (text, Html, span, div, br)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode
import Json.Decode
import Task
import String
import Quiz.Question as Question
import Quiz.Session as Session
import Quiz.Msg exposing (..)


type alias Flags =
    { userId : String
    , quizId : String
    }


type alias Model =
    { session : Session.Session
    , quizId : String
    , userId : String
    , question : Maybe Question.Question
    , reviewing : Bool
    }


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


quizRoom quizId =
    String.concat [ "quiz:", quizId ]


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( session, cmd ) =
            flags.quizId
                |> Session.newSession
                |> Session.joinQuiz flags.userId
    in
        ( { session = session
          , quizId = flags.quizId
          , question = Nothing
          , userId = flags.userId
          , reviewing = False
          }
        , Cmd.map PhoenixMsg cmd
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            Debug.log "Noop"
                ( model, Cmd.none )

        AnswerSelected answer ->
            let
                ( session, cmd ) =
                    Session.answerSelected answer model.session
            in
                ( model, Cmd.map PhoenixMsg cmd )

        ReviewAnswer json_val ->
            ( model, Cmd.none )

        QuestionAsked body ->
            case Question.decode body of
                Ok question ->
                    ( { model | question = Just question }, Cmd.none )

                Err reason ->
                    ( model, Cmd.none )

        PhoenixMsg msg ->
            let
                ( phoenixSocket, cmd ) =
                    Phoenix.Socket.update msg model.session.socket

                oldSession =
                    model.session

                session =
                    { oldSession | socket = phoenixSocket }
            in
                ( { model | session = session }
                , Cmd.map PhoenixMsg cmd
                )

        SessionJoined ->
            let
                ( session, cmd ) =
                    model.session
                        |> Session.joined
                        |> Session.loadCurrentQuestion
            in
                ( { model | session = session }, Cmd.map PhoenixMsg cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.session.socket PhoenixMsg


view : Model -> Html Msg
view model =
    case model.question of
        Nothing ->
            text "Loading question..."

        Just question ->
            Question.render model.reviewing question []
