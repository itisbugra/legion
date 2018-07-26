defmodule Legion.Identity.Auth.Concrete.ActivePassphrase.ViewDecl do
  @moduledoc false
  @concrete_env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @passphrase_lifetime Keyword.fetch!(@concrete_env, :passphrase_lifetime)

  def migrate do
    Ecto.Migration.execute create_view(), drop_view()
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
  end

  def drop_view do
    """
    DROP VIEW active_passphrases;
    """
  end
end