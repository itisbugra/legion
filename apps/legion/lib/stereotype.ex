defmodule Legion.Stereotype do
  @moduledoc """
  Defines stereotypes for the modules of the application.
  """
  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias Legion.Repo
    end
  end

  def virtual do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Query

      alias Legion.Repo
    end
  end

  def singleton do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias Legion.Repo
    end
  end

  def service do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias Legion.Repo
    end
  end

  @doc """
  When used, dispatch to the appropriate stereotype.
  """
  defmacro __using__(which) when is_atom(which),
    do: apply(__MODULE__, which, [])
end
