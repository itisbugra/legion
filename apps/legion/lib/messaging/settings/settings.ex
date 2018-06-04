defmodule Legion.Messaging.Settings do
  @moduledoc """
  Manages global settings for messaging modules.

  ## Caveats
  Instead of using functions of this module directly, to retrieve or alter the
  settings at runtime, use delegating functions supplied by relevant modules,
  for instance `Legion.Messaging.Switching.Globals`.
  """

  @doc """
  Changes the value of the setting identified by given `key`, to the new value
  `value`, on behalf of `user` authority.
  """
  use Legion.Stereotype, :service

  alias Legion.Messaging.Settings.RegistryEntry
  alias Legion.Identity.Information.Registration, as: User

  @spec put(User.id() | User, String.t(), map()) ::
    :ok |
    :error
  def put(user = %User{}, key, value), do: put(user.id, key, value)
  def put(user_id, key, value) when is_binary(key) do
    changeset =
      RegistryEntry.changeset(%RegistryEntry{},
                              %{key: key,
                                authority_id: user_id,
                                value: value})

    case Repo.insert(changeset) do
      {:ok, _setting} ->
        :ok
      {:error, _changeset} ->
        {:error, :unavailable}
    end
  end

  @doc """
  Retrieves the value of the setting identified by given `key`, or returns
  `default` if there was no value registered (yet).
  """
  @spec get(String.t(), term()) ::
    term()
  def get(key, default \\ nil) when is_binary(key) do
    query =
      from re1 in RegistryEntry,
      left_join: re2 in RegistryEntry,
        on: re1.key == re2.key and re1.id < re2.id,
      where: is_nil(re2.id) and
             re1.key == ^key,
      select: re1.value

    if value = Repo.one(query), do: value, else: default
  end

  @doc """
  Takes the last `quantity` entries for the given `key`.
  """
  @spec take(String.t, pos_integer()) ::
    term()
  def take(key, quantity) when is_binary(key) do
    query =
      from re in RegistryEntry,
      where: re.key == ^key,
      limit: ^quantity,
      order_by: [desc: re.id],
      select: {re.value, re.inserted_at}

    Repo.all(query)
  end
end
