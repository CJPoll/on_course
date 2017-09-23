module Quiz.Msg exposing (Msg(..))

import Json.Encode
import Phoenix.Socket


type Msg
    = Noop
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | QuestionAsked Json.Encode.Value
    | AnswerSelected String
    | SessionJoined
