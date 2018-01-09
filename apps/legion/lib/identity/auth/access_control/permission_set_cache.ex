defmodule Legion.Identity.Auth.AccessControl.PermissionSetCache do
  @moduledoc """
  Caching-related functions for permission sets of users.

  ## Motivation
  Calculating permission set of a user on current time is pretty common in the lifetime of an
  application. However, despite its straightforwardness, its a time-taking task to do since there
  might be lots of data involved. The resulting data could be cached and reused in further queries.

  ## Materialization of the calculation
  Permission set caching is implemented with the technical background utilizing MOSI, MOESI and
  Illinois protocols, one-legged MOSI might be a reference. After current permission set is 
  calculated for a user, it is written to the database in **Original** state. On a change affecting
  the cache, it is invalidated by changing the state to **Invalid**.
  """
  alias Legion.Identity.Auth.AccessControl.PermissionSetCacheEntry
  alias Legion.Repo

  @doc """
  Fetches the cached entry for the user with given identifier.
  """
  @spec fetch(number) :: 
    {:ok, PermissionSetCacheEntry} |
    {:error, :enoent}
  def fetch(user_id) do
    case Repo.get_by(:user_id, user_id) do
      nil ->
        {:error, :enoent}
      entry ->
        {:ok, entry}
    end
  end
end
