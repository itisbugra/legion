defmodule Legion.Identity.Auth.Insecure.Blacklist.Entry do
  @moduledoc """
  Represents a password blacklisting entry.

  ## Schema fields

  - `:authority_id`: The identifier of the authority added the entry. *Nullable*. Entries containing this attribute are known to be generated at runtime.
  - `:hash`: The hash ought to be blacklisted.
  - `:inserted_at`: The time of the blacklisting. 
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration, as: User

  schema "password_blacklist_entries" do
    belongs_to(:authority, User)
    field(:hash, :binary)
    field(:inserted_at, :naive_datetime, read_after_writes: true)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:authority_id, :hash])
    |> validate_required([:hash])
    |> foreign_key_constraint(:authority_id)
    |> unique_constraint(:hash)
  end
end
