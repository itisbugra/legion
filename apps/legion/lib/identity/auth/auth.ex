defmodule Legion.Identity.Auth do
  @moduledoc """
  Defines contextual functions to use the authentication/authorization APIs.
  """
  use Legion.Stereotype, :service

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Auth.Insecure.Pair
  alias Legion.Identity.Auth.Concrete.Passkey
  alias Legion.Identity.Auth.Concrete.Passphrase
  alias Legion.Identity.Auth.Algorithm.Keccak

  @insecure_env Application.get_env(:legion, Legion.Identity.Auth.Insecure)
  @password_digestion Keyword.fetch!(@insecure_env, :password_digestion)

  @concrete_env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @passphrase_lifetime Keyword.fetch!(@concrete_env, :passphrase_lifetime)
  @maximum_allowed_passphrases Keyword.fetch!(@concrete_env, :maximum_allowed_passphrases)

  @doc """
  Registers an internal user with given username and password.

  ### Caveats
  The new user will have the insecure authentication scheme set initially,
  client-side implementations are expected to ask whether user prefers
  another authentication scheme or not at the time of the completion of this
  action.
  """
  @spec register_internal_user(String.t(), String.t()) ::
    {:ok, User.id(), User.username()} |
    {:error, :already_registered}
  def register_internal_user(username, password) do
    case Repo.transaction(fn ->
      query =
        from p1 in Pair,
        left_join: p2 in Pair,
          on: p1.id < p2.id and
              p1.user_id == p2.user_id,
        where: is_nil(p2.id) and
               p1.username == ^username,
        select: count(p1.id)

      unless Repo.one!(query) == 0,
        do: Repo.rollback(:already_registered)

      registration =
        %User{}
        |> User.changeset(%{})
        |> Repo.insert!()

      pair_params = %{user_id: registration.id,
                      username: username,
                      password: password}

      pair = 
        %Pair{}
          |> Pair.changeset(pair_params)
          |> Repo.insert()
      case pair do
        {:ok, pair} ->
          pair
        {:error, changeset} ->
          Repo.rollback(changeset)    # rollback with the name of the field
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

  With a valid digest for the user, this function should return a
  `{:ok, Passkey.t()}` passkey, which should be transferred to the
  client-side device to be persisted on its secure storage. However,
  these errors can also be returned from the function:

  - `{:error, :no_user_verify}`: User cannot be found with given
  username.
  - `{:error, :unsupported_scheme}`: The authentication scheme 
  of the user is not supported (in implementation). This is
  subject to change without a notice on further releases.
  - `{:error, :wrong_password}`: The password hash is wrong.
  - `{:error, :maximum_passphrases_exceeded}`: The number of the
  passphrases (#{@maximum_allowed_passphrases}) are exceeded.
  User might either reset his/her password, authentication will
  not proceed.
  """
  @spec generate_passphrase(User.username(), Keccak.hash(), Passphrase.inet(), Keyword.t()) ::
    {:ok, Passkey.t()} |
    {:error, :no_user_verify} |
    {:error, :unsupported_scheme} |
    {:error, :wrong_password} |
    {:error, :maximum_passphrases_exceeded}
  def generate_passphrase(username, password, ip_addr, opts \\ []) do
    # TODO: Should generate the token directly
    one_shot = Keyword.get(opts, :one_shot, true)

    Repo.transaction(fn ->
      # Query the possessor user of the given username
      query =
        from p1 in Pair,
        left_join: p2 in Pair,
          on: p1.id < p2.id and p1.user_id == p2.user_id,
        join: u in User,
          on: p1.user_id == u.id,
        where: is_nil(p2.id) and
               p1.username == ^username,
        select: %{user_id: u.id,   
                  password_digest: p1.password_digest, 
                  digestion_algorithm: p1.digestion_algorithm,
                  authentication_scheme: u.authentication_scheme}

      case Repo.one(query) do
        nil ->
          dummy_checkpw(@password_digestion)

          Repo.rollback(:no_user_verify)
        result ->
          unless result.authentication_scheme == :insecure,
            do: Repo.rollback(:unsupported_scheme)

          unless checkpw(password, result.password_digest, result.digestion_algorithm),
            do: Repo.rollback(:wrong_password)

          # Check the current number of passphrases belonging to the user
          time_offset = -1 * @passphrase_lifetime
          query =
            from p in Passphrase,
            where: p.user_id == ^result.user_id and
                   p.inserted_at > from_now(^time_offset, "second"),
            select: count(p.id)

          unless Repo.one!(query) < @maximum_allowed_passphrases,
            do: Repo.rollback(:maximum_passphrases_exceeded)

          {passkey, changeset} = Passphrase.create_changeset(result.user_id, ip_addr)

          Repo.insert!(changeset)

          passkey
      end
    end)
  end

  defp checkpw(password, hash, alg) do
    case alg do
      :argon2 ->
        Comeonin.Argon2.checkpw(password, hash)
      :bcrypt ->
        Comeonin.Bcrypt.checkpw(password, hash)
      :pbkdf2 ->
        Comeonin.Pbkdf2.checkpw(password, hash)
    end
  end

  defp dummy_checkpw(alg) do
    case alg do
      :argon2 ->
        Comeonin.Argon2.dummy_checkpw()
      :bcrypt ->
        Comeonin.Bcrypt.dummy_checkpw()
      :pbkdf2 ->
        Comeonin.Pbkdf2.dummy_checkpw()
    end
  end
end