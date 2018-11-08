defmodule Legion.Identity.Auth.AccessControl.PermissionSetCacheEntry do
  @moduledoc """
  Represents an entity for the permission set cache.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Auth.AccessControl.PermissionSetCacheEntry
  alias Legion.Identity.Information.Registration
  alias Legion.Identity.Auth.AccessControl.PermissionSet

  schema "permission_set_cache_entries" do
    belongs_to(:user, Registration)
    belongs_to(:permission_set, PermissionSet)
    field(:valid_until, :naive_datetime)
    field(:updated_at, :naive_datetime, read_after_writes: true)
  end

  @spec changeset(PermissionSetCacheEntry, map) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :permission_set_id, :valid_until])
    |> validate_required([:user_id, :permission_set_id])
    |> validate_coherence_timeout()
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:permission_set_id)
  end

  defp validate_coherence_timeout(changeset) do
    env = Application.get_env(:legion, Legion.Identity.Auth.AccessControl)
    allow_infinite_lifetime = Keyword.fetch!(env, :allow_infinite_lifetime)

    if allow_infinite_lifetime do
      changeset
    else
      changeset
      |> validate_required([:valid_until])
    end
  end
end
