defmodule Legion.Identity.Information.User do
  @moduledoc """
  Provides repository functionality for the users.
  """
  use Legion.Stereotype, :service

  alias Legion.Identity.Information.Registration, as: User

  @doc """
  Retrieves the user with the given identifier.

  ## Parameters

    - `id`: Designating identifier value for the user.

  ## Return values

    - `{:ok, user}`: Query succeeded, contains the user.
    - `{:error, :not_found}`: Query succeeded but user not found.
    - `{:error, :einval}`: Query failed, invalid parameter.
  """
  @spec get_user(integer()) :: {:error, :einval | :not_found} | {:ok, User.t()}
  def get_user(id) when is_integer(id) do
    case Repo.get_by(User, id) do
      nil ->
        {:error, :not_found}

      user ->
        {:ok, user}
    end
  end

  def get_user(_id), do: {:error, :einval}

  @doc """
  Lists users with the provided pagination parameters.

  ## Parameters

    - `limit`: Limits the number of the users by the given number. Default is 10, maximum allowed value is 20.
    - `offset`: Skips the given number of preceding entries in the query. Default is 0.

  ## Return values

    - `{:ok, users}`: Query succeeded, contains list of users.
    - `{:error, :einval}`: Query failed, invalid parameter.
  """
  @spec list_users(integer(), integer()) ::
          {:ok, list(User.t())}
          | {:error, :einval}
  def list_users(limit \\ 10, offset \\ 0)

  def list_users(limit, offset) when limit < 20 and offset >= 0 do
    query =
      from u1 in User,
        limit: ^limit,
        offset: ^offset

    {:ok, Repo.all(query)}
  end

  def list_users(_limit, _offset), do: {:error, :einval}
end
