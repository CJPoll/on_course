defmodule OnCourse.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  require Logger

  using do
    quote do
      alias OnCourse.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import OnCourse.DataCase
      alias OnCourse.Model
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(OnCourse.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(OnCourse.Repo, {:shared, self()})
    end

    :ok
  end

  defmacro valid_params! do
    quote do
      test "valid params are valid", context do
        cs = @test_module.changeset(context.valid_params)
        assert cs.valid?, "valid_params in #{__MODULE__} weren't valid: #{inspect cs}"

        case @repo_module.insert(cs) do
          {:ok, _} -> :ok
          {:error, cs} ->
            flunk("valid_params in #{__MODULE__} weren't valid: #{inspect cs}")
        end
      end
    end
  end

  defmacro optional(field) do
    quote do
      test "#{unquote(field)} is required", context do
        cs =
          context
          |> OnCourse.Model.delete_field(unquote(field))
          |> @test_module.changeset

        assert cs.valid?
      end
    end
  end

  defmacro required(field) do
    quote do
      test "#{unquote(field)} is required", context do
        cs =
          context
          |> OnCourse.Model.delete_field(unquote(field))
          |> @test_module.changeset

        refute cs.valid?
        assert {:prompt, "can't be blank"} in Ectoplasm.errors_on(cs)
      end
    end
  end
end
