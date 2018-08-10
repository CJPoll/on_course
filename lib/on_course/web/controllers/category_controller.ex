defmodule OnCourse.Web.Category.Controller do
  use OnCourse.Web, :controller

  alias OnCourse.{Courses, Quizzes}
  alias OnCourse.Quizzes.{Category, CategoryItem}
  alias OnCourse.Web.Router.Helpers, as: Path
  alias OnCourse.Web.Endpoint

  plug Guardian.Plug.EnsureResource

  def create(%Plug.Conn{} = conn, %{"category" => category_params, "topic_id" => topic_id}) do
    topic = Courses.topic(topic_id)

    if Permission.can?(conn.assigns.current_user, :create, {topic, Category}) do
      case Quizzes.add_category(topic, category_params) do
        {:ok, %Category{}} ->
          conn
          |> put_flash(:success, "Category created!")
          |> redirect(to: Path.topic_path(Endpoint, :show, topic.id))
        {:error, cs} ->
          conn
          |> put_flash(:error, "Creating category failed: #{inspect Ectoplasm.errors_on(cs)}")
          |> redirect(to: Path.topic_path(Endpoint, :show, topic.id))
      end
    end
  end

  def create(%Plug.Conn{} = conn, %{"category_item" => category_item_params, "category_id" => category_id}) do
    category = Quizzes.category(category_id)

    if Permission.can?(conn.assigns.current_user, :create, {category, CategoryItem}) do
      case Quizzes.add_category_item(category, category_item_params) do
        {:ok, %CategoryItem{}} ->
          conn
          |> put_flash(:success, "category_item created!")
          |> redirect(to: Path.category_path(Endpoint, :show, category.id))
        {:error, cs} ->
          conn
          |> put_flash(:error, "Creating category_item failed: #{inspect Ectoplasm.errors_on(cs)}")
          |> redirect(to: Path.category_path(Endpoint, :show, category.id))
      end
    end
  end

  def delete(%Plug.Conn{} = conn, %{"category_id" => category_id}) do
    category =
      category_id
      |> Quizzes.category
      |> Quizzes.with_topic

    if Permission.can?(conn.assigns.current_user, :delete, category) do
      case Quizzes.delete(category) do
        {:ok, %Category{}} ->
          conn
          |> put_flash(:success, "Category deleted!")
          |> redirect(to: Path.topic_path(Endpoint, :show, category.topic.id))
        {:error, cs} ->
          conn
          |> put_flash(:error, "Couldn't delete category: #{inspect Ectoplasm.errors_on(cs)}")
          |> redirect(to: Path.topic_path(Endpoint, :show, category.topic.id))
      end
    end
  end

  def show(%Plug.Conn{} = conn, %{"category_id" => category_id}) do
    category =
      category_id
      |> Quizzes.category
      |> Quizzes.with_category_items

    if Permission.can?(conn.assigns.current_user, :view, category) do
      render(conn, "show.html", category: category)
    end
  end
end
