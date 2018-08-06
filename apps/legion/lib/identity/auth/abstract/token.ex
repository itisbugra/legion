defmodule Legion.Identity.Auth.Abstract.Token do
  @moduledoc """
  Defines credential-based authentication functions in order to authenticate users.
  """
  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Auth.Concrete.Passphrase

  @typedoc """
  Data data structure representing issue result.
  """
  @enforce_keys ~w(header_value expires_after jwk jws)a
  defstruct [
    :header_value,
    :expires_after,
    :jwk,
    :jws
  ]

  @type t :: %__MODULE__{
    header_value: binary,
    expires_after: pos_integer,
    jwk: map,
    jws: map
  }

  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete.JOSE)
  @jwk %{"kty" => "oct",
         "k" => Keyword.fetch!(@env, :secret_key_base)}
  @jws %{"alg" => "HS256",
         "typ" => "JWT"}

  @doc """
  Issues a token to given user.

  ## Options

  - `:lifetime`: If supplied, the lifetime of the token will be changed
  to this value. This defaults to the configuration value.

  ## Applied configuration values
  On `Legion.Identity.Auth.Concrete.JOSE` domain,

  - `:issuer`: The issuer of the token, e.g. "legion".
  - `:sub`: The subsidiary of the token.
  
  If `:lifetime` is not supplied as an option, the value of the parameter
  will be applicable to:

  - `:lifetime`: The default lifetime of the token.
  """
  @spec issue_token(User.id(), Passphrase.id(), Keyword.t()) :: 
    {:ok, __MODULE__.t} |
    {:error, :invalid} |
    {:error, :timed_out}
  def issue_token(user_id, passphrase_id, opts \\ []) when is_integer(user_id) and is_integer(passphrase_id) do
    env = Application.get_env(:legion, Legion.Identity.Auth.Concrete.JOSE)
    issuer = Keyword.fetch!(env, :issuer)
    lifetime = Keyword.get(opts, :lifetime, Keyword.fetch!(env, :lifetime))
    expires_after = :os.system_time(:seconds) + lifetime
    sub = Keyword.fetch!(env, :sub)

    payload = generate_payload(user_id, passphrase_id, issuer, expires_after, sub)

    {_, token} =
      @jwk
      |> JOSE.JWT.sign(@jws, payload)
      |> JOSE.JWS.compact()

    {:ok, %__MODULE__{header_value: token,
                      expires_after: expires_after,
                      jwk: @jwk,
                      jws: @jws}}
  end

  defp generate_payload(user_id, passphrase_id, issuer, expire, sub) do
    payload = %{user_id: user_id,
                passphrase_id: passphrase_id,
                iss: issuer,
                exp: expire,
                sub: sub}

    Poison.encode!(payload)
  end
end
