defmodule Legion.Identity.Auth do
  @moduledoc """
  Delegates contextual functions to use the authentication/authorization APIs.
  """
  defdelegate register_internal_user(username, password_hash),
    to: Legion.Identity.Auth.Concrete

  defdelegate generate_passphrase(username, password_hash, ip_addr, opts \\ []),
    to: Legion.Identity.Auth.Concrete

  defdelegate authenticate(user_or_id, passkey, user_agent, ip_addr, geo_location),
    to: Legion.Identity.Auth.Abstract
end
