defmodule Legion.Identity.Auth.Insecure.Blacklist do
  @moduledoc """
  Provides functionality for blacklisting password hashes.
  """
  use Legion.Stereotype, :service

  alias Legion.Identity.Auth.Algorithm.Keccak
  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Auth.Insecure.Blacklist.Entry

  @doc """
  Inserts or updates a word to the blacklist with given authority identifier.

  This function should be used in runtime.
  """
  @spec upsert(String.t(), User.id()) ::
    {:ok, Entry} |
    {:error, Ecto.Changeset.t()}
  def upsert(word, user_id) do
    hash = Keccak.hash(word)

    case Repo.get_by(Entry, hash: hash) do
      nil ->
        params = %{authority_id: user_id,
                   hash: hash}

        changeset = Entry.changeset(%Entry{}, params)

        Repo.insert(changeset)
      entry ->
        {:ok, entry}
    end
  end

  @doc """
  Inserts or updates a word to the blacklist, without any authority identifier. 

  This functions is useful for development/migration purposes, for hardcoded
  seeding operations. It should not be used in production environment.
  """
  @spec upsert(String.t()) ::
    {:ok, Entry} |
    {:error, Ecto.Changeset.t()}
  def upsert(word),
    do: upsert(word, nil)

  @doc """
  Removes a hash entry from the blacklist.
  """
  @spec remove(Keccah.hash()) :: no_return()
  def remove(hash) do
    case Repo.get_by(Entry, hash: hash) do
      nil ->
        nil
      {:ok, entry} ->
        Repo.delete!(entry)
    end
  end

  @doc """
  Performs a binary comparison on hash table.

  Use this function to check if a particular password hash
  is blacklisted or not.
  """
  @spec lookup(Keccak.hash()) :: boolean()
  def lookup(hash) do
    Entry
    |> Repo.get_by(hash: hash)
    |> is_nil()
  end

  @doc """
  Checks whether a word is added to the blacklist.
  """
  @spec check(String.t()) :: boolean()
  def check(word) do
    word
    |> Keccak.hash()
    |> lookup()
  end
end