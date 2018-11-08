defmodule Legion.Identity.Auth.Concrete do
  @moduledoc """
  Functions for performing concrete authentication.
  """
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  use Legion.Stereotype, :service

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Auth.Insecure.Pair
  alias Legion.Identity.Auth.Insecure.AuthInfo
  alias Legion.Identity.Auth.Concrete.{Passkey, Passphrase}
  alias Legion.Identity.Auth.Abstract.Token
  alias Legion.Identity.Auth.Algorithm.Keccak
  alias Legion.Networking.INET

  @concrete_env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @maximum_allowed_passphrases Keyword.fetch!(@concrete_env, :maximum_allowed_passphrases)

  @doc """
  Registers an internal user with given username and password hash.

  ## Caveats

  The new user will have the insecure authentication scheme set initially,
  client-side implementations are expected to ask whether user prefers
  another authentication scheme or not at the time of the completion of this
  action.
  """
  @spec register_internal_user(String.t(), String.t()) ::
          {:ok, User.id(), User.username()}
          | {:error, :already_registered}
  def register_internal_user(username, password_hash) do
    case Repo.transaction(fn ->
           query =
             from(p1 in Pair,
               left_join: p2 in Pair,
               on: p1.id < p2.id and p1.user_id == p2.user_id,
               where: is_nil(p2.id) and p1.username == ^username,
               select: count(p1.id)
             )

           unless Repo.one!(query) == 0,
             do: Repo.rollback(:already_registered)

           registration =
             %User{}
             |> User.changeset(%{})
             |> Repo.insert!()

           pair_params = %{
             user_id: registration.id,
             username: username,
             password_hash: password_hash
           }

           pair =
             %Pair{}
             |> Pair.changeset(pair_params)
             |> Repo.insert()

           case pair do
             {:ok, pair} ->
               pair

             {:error, changeset} ->
               # rollback with the name of the field
               Repo.rollback(changeset)
           end
         end) do
      {:ok, pair} ->
        {:ok, pair.user_id, pair.inserted_at}

      {:error, field} ->
        {:error, field}
    end
  end

  @doc """
  Performs concrete authentication for the user with given username,
  and client-side produced hash. Note that password *hash* is not
  password *digest*, where digest is a time-variant, salted hash of
  the client-side produced hash.

  ## Options

  - `:one_shot`: If `true`, the authentication will be fallthrough,
  it will not generate any passphrases, but return a token without
  requiring any further abstract authentication. This is useful
  when user does not need to store the passphrase in the
  authenticating device. The lifetime of the token is determined
  seperately from the regular abstract authentication flow.
  Defaults to `false`.

  ## Return types

  With a valid digest for the user, this function should either 
  return a 

  - `{:ok, :require, passkey}` tuple containing the passkey which 
  should be transferred to the client-side device to be persisted on 
  its secure storage, or 

  - `{:ok, :access, jwt}` tuple containing the JSON Web Token
   [*(RFC 7159)*] to perform stealth authentication directly, or

  - `{:ok, :advance, advance_artifact}` tuple containing the artifact
  information for proceeding to the next mandatory step of users
  preferred multi-factor-authentication method.

  In such circumstances, these errors can also be returned from the 
  function:

  - `{:error, :no_user_verify}`: User cannot be found with given
  username.
  - `{:error, :unsupported_scheme}`: The authentication scheme 
  of the user is not supported (in implementation). This is
  subject to change without a notice on further releases and
  left here for the regression of provisioning services.
  - `{:error, :wrong_password_hash}`: The password hash is wrong.
  - `{:error, :maximum_passphrases_exceeded}`: The number of the
  passphrases (#{@maximum_allowed_passphrases}) are exceeded.
  User might either reset his/her password, authentication will
  not proceed.
  - `{:error, :bad_host, :reserve_reason}`: The IP address provided
  is reserved by IETF (IANA).
  - `{:error, :blacklist, "reason"}`: The IP address provided is
  blacklisted by server authority.

  ## Applied configuration values

  If `:one_shot` option is enabled, the function takes
  `Legion.Identity.Auth.Concrete.JOSE.extended_lifetime`
  configuration value to provide an expiration time to the token
  issuer.

  [*(RFC 7159)*]: https://tools.ietf.org/html/rfc7519
  [*(RFC 5735)*]: https://tools.ietf.org/html/rfc5735#section-4
  """
  @spec generate_passphrase(User.username(), Keccak.hash(), INET.t(), Keyword.t()) ::
          {:ok, :access, Token.t()}
          | {:ok, :require, Passkey.t()}
          | {:ok, :advance, Advance.t()}
          | {:error, :no_user_verify}
          | {:error, :unsupported_scheme}
          | {:error, :wrong_password}
          | {:error, :maximum_passphrases_exceeded}
          | {:error, INET.error_type()}
  def generate_passphrase(username, password_hash, ip_addr, opts \\ []) do
    case Repo.transaction(fn ->
           with :ok <- INET.validate_addr(ip_addr),
                {:ok, auth_info} <- Pair.retrieve_auth_info(username),
                :ok <- AuthInfo.check_authentication_schema(auth_info),
                :ok <-
                  Pair.checkpw(
                    password_hash,
                    auth_info.password_digest,
                    auth_info.digestion_algorithm
                  ),
                :ok <- Passphrase.check_passphrase_quota(auth_info.user_id),
                passkey <- Passphrase.create(auth_info.user_id, ip_addr) do
             {:require, passkey}
           else
             {:error, error} ->
               Repo.rollback(error)
           end
         end) do
      {:ok, {atom, struct}} ->
        {:ok, atom, struct}

      any ->
        any
    end
  end
end
