defmodule OnCourse.Web.FakesControllerTest do
  use OnCourse.Web.ConnCase

  alias OnCourse.Fake

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:fakes) do
    {:ok, fakes} = Fake.create_fakes(@create_attrs)
    fakes
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, fakes_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing Fakes"
  end

  test "renders form for new fakes", %{conn: conn} do
    conn = get conn, fakes_path(conn, :new)
    assert html_response(conn, 200) =~ "New Fakes"
  end

  test "creates fakes and redirects to show when data is valid", %{conn: conn} do
    conn = post conn, fakes_path(conn, :create), fakes: @create_attrs

    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == fakes_path(conn, :show, id)

    conn = get conn, fakes_path(conn, :show, id)
    assert html_response(conn, 200) =~ "Show Fakes"
  end

  test "does not create fakes and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, fakes_path(conn, :create), fakes: @invalid_attrs
    assert html_response(conn, 200) =~ "New Fakes"
  end

  test "renders form for editing chosen fakes", %{conn: conn} do
    fakes = fixture(:fakes)
    conn = get conn, fakes_path(conn, :edit, fakes)
    assert html_response(conn, 200) =~ "Edit Fakes"
  end

  test "updates chosen fakes and redirects when data is valid", %{conn: conn} do
    fakes = fixture(:fakes)
    conn = put conn, fakes_path(conn, :update, fakes), fakes: @update_attrs
    assert redirected_to(conn) == fakes_path(conn, :show, fakes)

    conn = get conn, fakes_path(conn, :show, fakes)
    assert html_response(conn, 200) =~ "some updated name"
  end

  test "does not update chosen fakes and renders errors when data is invalid", %{conn: conn} do
    fakes = fixture(:fakes)
    conn = put conn, fakes_path(conn, :update, fakes), fakes: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Fakes"
  end

  test "deletes chosen fakes", %{conn: conn} do
    fakes = fixture(:fakes)
    conn = delete conn, fakes_path(conn, :delete, fakes)
    assert redirected_to(conn) == fakes_path(conn, :index)
    assert_error_sent 404, fn ->
      get conn, fakes_path(conn, :show, fakes)
    end
  end
end
