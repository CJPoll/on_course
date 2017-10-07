module Quiz.Review exposing (Review)


type Review
    = Correct
    | Incorrect (List String)
