module Quiz.Question exposing (Question(..), decode)

import Json.Decode as Decode
import Json.Encode as Encode
import Html


type Question
    = TrueFalse String
    | MultipleChoice (List String) String
    | TextInput String


type Intermediate
    = IntermediateQuestion String String
    | IntermediateMult (List String) String


jsonSchema =
    Decode.oneOf
        [ Decode.map2 IntermediateMult
            (Decode.field "choices" (Decode.list Decode.string))
            (Decode.field "prompt" Decode.string)
        , Decode.map2 IntermediateQuestion
            (Decode.field "prompt" Decode.string)
            (Decode.field "question_type" Decode.string)
        ]


decode : Encode.Value -> Result String Question
decode body =
    case Decode.decodeValue jsonSchema body of
        Ok (IntermediateMult options prompt) ->
            Ok (MultipleChoice options prompt)

        Ok (IntermediateQuestion prompt "text_input") ->
            Ok (TextInput prompt)

        Ok (IntermediateQuestion prompt "true_false") ->
            Ok (TrueFalse prompt)

        Ok _ ->
            Debug.crash "Not sure what happened here"

        Err reason ->
            Err reason
