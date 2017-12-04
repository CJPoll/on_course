alias OnCourse.Accounts.User
alias OnCourse.Courses.{Course, Module, Topic}
alias OnCourse.Quiz.{Category, CategoryItem, PromptQuestion}
alias OnCourse.Repo

admin =
  Repo.insert!(%User{
      avatar: "https://avatars2.githubusercontent.com/u/1310084?v=4",
      email: "CJPoll@gmail.com",
      handle: "CJPoll"
    })


course =
  Repo.insert!(%Course{
    name: "Social Skills",
    owner_id: admin.id
  })

module =
  Repo.insert!(%Module{
    name: "Coolness Module",
    course_id: course.id
  })

topic =
  Repo.insert!(%Topic{
    name: "Coolness",
    course_id: course.id,
    module_id: module.id
  })

category_1 =
  Repo.insert!(%Category{
    name: "Cool",
    topic_id: topic.id
  })

category_2 =
  Repo.insert!(%Category{
    name: "Uncool",
    topic_id: topic.id
  })

Repo.insert!(%CategoryItem{
  name: "Sunglasses",
  category_id: category_1.id
})

Repo.insert!(%CategoryItem{
  name: "Elixir",
  category_id: category_1.id
})

Repo.insert!(%CategoryItem{
  name: "Crocs",
  category_id: category_2.id
})

Repo.insert!(%CategoryItem{
  name: "Cargo Pants",
  category_id: category_2.id
})

Repo.insert!(%PromptQuestion{
  prompt: "What is the first letter of the alphabet?",
  correct_answer: "A",
  topic_id: topic.id
})
