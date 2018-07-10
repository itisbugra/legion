defmodule Legion.Identity.Auth do
  @moduledoc """
  Defines contextual functions to use the authentication/authorization APIs.
  """
  use Legion.Stereotype, :service

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Auth.Insecure.Pair

  @doc """
  Registers an internal user with given username and password.

  ### Caveats
  The new user will have the insecure authentication scheme set initially,
  client-side implementations are expected to ask whether user prefers
  another authentication scheme or not at the time of the completion of this
  action.
  """
  @spec register_internal_user(String.t(), String.t()) ::
    {:ok, User.id(), User.username()} |
    {:error, :already_registered}
  def register_internal_user(username, password) do
    case Repo.transaction(fn ->
      registration =
        %User{}
        |> User.changeset(%{})
        |> Repo.insert!()

      pair_params = %{user_id: registration.id,
                      username: username,
                      password: password}

      pair = 
        %Pair{}
          |> Pair.changeset(pair_params)
          |> Repo.insert()
      case pair do
        {:ok, pair} ->
          pair
        {:error, changeset} ->
          Repo.rollback(changeset)    # rollback with the name of the field
      end
    end) do
      {:ok, pair} ->
        {:ok, pair.user_id} 
      {:error, field} ->
        {:error, field}
    end
  end
end