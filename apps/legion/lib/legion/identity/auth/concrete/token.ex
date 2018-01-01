defmodule Legion.Identity.Auth.Concrete.Token do
  @moduledoc """
  Defines credential-based authentication functions in order to authenticate users.
  """
  alias Legion.Identity.Information.Registration
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
  """
  @spec issue_token(Registration, Passphrase) :: __MODULE__.t
  def issue_token(user, passphrase) do
    env = Application.get_env(:legion, Legion.Identity.Auth.Concrete.JOSE)
    issuer = Keyword.fetch!(env, :issuer)
    expires_after = :os.system_time(:seconds) + Keyword.fetch!(env, :lifetime)
    sub = Keyword.fetch!(env, :sub)

    payload = generate_payload(user, passphrase, issuer, expires_after, sub)

    {_, token} =
      @jwk
      |> JOSE.JWT.sign(@jws, payload)
      |> JOSE.JWS.compact()

    %__MODULE__{header_value: token,
                expires_after: expires_after,
                jwk: @jwk,
                jws: @jws}
  end

  defp generate_payload(user, passphrase, issuer, expire, sub) do
    payload = %{user_id: user.id,
                passphrase_id: passphrase.id,
                iss: issuer,
                exp: expire,
                sub: sub}

    Poison.encode(payload)
  end
end
