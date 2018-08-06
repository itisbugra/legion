defmodule Legion.Identity.Auth.Abstract do
  @moduledoc """
  Functions for performing abstract (stealth) authentication.
  """
  use Legion.Stereotype, :service

  alias Legion.Identity.Auth.Abstract.Token
  alias Legion.Identity.Auth.Concrete.Passphrase
  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Auth.Concrete.Activity
  alias Legion.Networking.INET
  alias Legion.Networking.HTTP.UserAgent
  alias Legion.Location.Coordinate

  @doc """
  Performs abstract authentication for the user with given passkey.
  """
  @spec authenticate(User.user_or_id(), Passkey.t(), UserAgent.t(), INET.t(), Coordinate.t()) ::
    {:ok, Token.t()} |
    {:error, :not_found} |
    {:error, :invalid} |
    {:error, :timed_out} |
    {:error, :untrackable}
  def authenticate(user_id, passkey, user_agent, ip_addr, geo_location) when is_integer(user_id) do
    Repo.transaction(fn ->
      with {:ok, passphrase_id} <- Passphrase.find_passphrase_matching(user_id, passkey),
           {:ok, token} <- Token.issue_token(user_id, passphrase_id),
           {:ok, _activity} <- Activity.generate_activity(passphrase_id, user_agent, ip_addr, geo_location)
      do
        token
      else
        {:error, error} when is_atom(error) ->
          Repo.rollback(error)
      end
    end)
  end
  def authenticate(user, passkey, user_agent, ip_addr, geo_location) when is_map(user),
    do: authenticate(user.id, passkey, user_agent, ip_addr, geo_location)
end