defmodule OnCourse.FakeTest do
  use OnCourse.DataCase

  alias OnCourse.Fake

  describe "fakes" do
    alias OnCourse.Fake.Fakes

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def fakes_fixture(attrs \\ %{}) do
      {:ok, fakes} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Fake.create_fakes()

      fakes
    end

    test "list_fakes/0 returns all fakes" do
      fakes = fakes_fixture()
      assert Fake.list_fakes() == [fakes]
    end

    test "get_fakes!/1 returns the fakes with given id" do
      fakes = fakes_fixture()
      assert Fake.get_fakes!(fakes.id) == fakes
    end

    test "create_fakes/1 with valid data creates a fakes" do
      assert {:ok, %Fakes{} = fakes} = Fake.create_fakes(@valid_attrs)
      assert fakes.name == "some name"
    end

    test "create_fakes/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fake.create_fakes(@invalid_attrs)
    end

    test "update_fakes/2 with valid data updates the fakes" do
      fakes = fakes_fixture()
      assert {:ok, fakes} = Fake.update_fakes(fakes, @update_attrs)
      assert %Fakes{} = fakes
      assert fakes.name == "some updated name"
    end

    test "update_fakes/2 with invalid data returns error changeset" do
      fakes = fakes_fixture()
      assert {:error, %Ecto.Changeset{}} = Fake.update_fakes(fakes, @invalid_attrs)
      assert fakes == Fake.get_fakes!(fakes.id)
    end

    test "delete_fakes/1 deletes the fakes" do
      fakes = fakes_fixture()
      assert {:ok, %Fakes{}} = Fake.delete_fakes(fakes)
      assert_raise Ecto.NoResultsError, fn -> Fake.get_fakes!(fakes.id) end
    end

    test "change_fakes/1 returns a fakes changeset" do
      fakes = fakes_fixture()
      assert %Ecto.Changeset{} = Fake.change_fakes(fakes)
    end
  end
end
