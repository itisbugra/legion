defmodule Legion.Identity.Auth.Concrete.ActivePassphrase do
  @moduledoc """
  A view for the passphrases showing currently active entries.
  """
  use Legion.Stereotype, :virtual

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Auth.Concrete.ActivePassphrase
  alias Legion.Identity.Auth.Concrete.Activity

  @concrete_env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @passphrase_lifetime Keyword.fetch!(@concrete_env, :passphrase_lifetime)

  schema "active_passphrases" do
    belongs_to :user, User
    field :passkey_digest, :binary
    field :ip_addr, Legion.Types.INET
    field :inserted_at, :naive_datetime, read_after_writes: true

    has_many :activities, Activity, foreign_key: :passphrase_id
  end

  def list_for_user(user_id) do
    query =
      from ap in ActivePassphrase,
      where: ap.user_id == ^user_id,
      select: ap

    Repo.all(query)
  end

  def count_for_user(user_id) do
    query =
      from ap in ActivePassphrase,
      where: ap.user_id == ^user_id,
      select: count(ap.id)

    Repo.one!(query)
  end

  def create_view do
    """
    CREATE OR REPLACE VIEW active_passphrases AS
      SELECT p.*
      FROM passphrases p
      LEFT OUTER JOIN passphrase_invalidations pi 
        ON p.id = pi.target_passphrase_id
      WHERE 
        pi.id IS NULL AND
        p.inserted_at > now()::timestamp without time zone - interval '#{@passphrase_lifetime} seconds';
    """
    |> Ecto.Migration.execute()
  end

  def drop_view do
    """
    DROP VIEW active_passphrases;
    """
    |> Ecto.Migration.execute()
  end
end