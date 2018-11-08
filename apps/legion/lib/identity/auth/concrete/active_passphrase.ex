defmodule Legion.Identity.Auth.Concrete.ActivePassphrase do
  @moduledoc """
  A view for the passphrases showing currently active entries.
  """
  use Legion.Stereotype, :virtual

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Auth.Concrete.{ActivePassphrase, Passphrase, Activity}

  schema "active_passphrases" do
    belongs_to(:user, User)
    field(:passkey_digest, :binary)
    field(:ip_addr, Legion.Types.INET)
    field(:inserted_at, :naive_datetime, read_after_writes: true)

    has_many(:activities, Activity, foreign_key: :passphrase_id)
  end

  @doc """
  Lists active passphrase entries for given user.
  """
  @spec list_for_user(User.user_or_id()) :: [Passphrase]
  def list_for_user(user_id) do
    query =
      from(ap in ActivePassphrase,
        where: ap.user_id == ^user_id,
        select: ap
      )

    Repo.all(query)
  end

  def count_for_user(user_id) do
    query =
      from(ap in ActivePassphrase,
        where: ap.user_id == ^user_id,
        select: count(ap.id)
      )

    Repo.one!(query)
  end
end
