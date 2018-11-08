defmodule Legion.Identity.Auth.AccessControl.PermissionSetGrant do
  @moduledoc """
  Represents grant of a permission set to a user.

  A grant action is formed with a permission set, a grantee and an authority.

  ## Time invariance
  A permission set might have `valid_after` and `valid_for` values in second units. The 
  `valid_after` field determines the time of activation in terms of seconds passed
  after creation of the grant. On the other hand, grants might be available for some time interval,
  which is determined with `valid_for` field.

  Briefly, the grant will be activated on `inserted_at + valid_after`. At the end, the grant will 
  be ceased on `inserted_at + valid_after + valid_for`.

  ## Caching coherence
  After a succesful insertion of permission set grant, the permission set retrieval cache will be
  invalidated, which will incur a performance penalty at the time of the initial grant resolution.
  """
  use Legion.Stereotype, :model

  import NaiveDateTime, only: [compare: 2, add: 2, utc_now: 0]

  alias Legion.Identity.Auth.AccessControl.PermissionSetGrant
  alias Legion.Identity.Auth.AccessControl.PermissionSetGrant.Invalidation
  alias Legion.Identity.Auth.AccessControl.PermissionSet
  alias Legion.Identity.Information.Registration

  @immediately 1

  schema "permission_set_grants" do
    belongs_to(:permission_set, PermissionSet)
    belongs_to(:grantee, Registration)
    belongs_to(:authority, Registration)
    field(:valid_after, :integer)
    field(:valid_for, :integer)
    field(:inserted_at, :naive_datetime, read_after_writes: true)

    has_one(:invalidation, Invalidation, foreign_key: :grant_id)
  end

  @spec changeset(PermissionSetGrant, map) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    env = Application.get_env(:legion, Legion.Identity.Auth.AccessControl)
    maximum_deferral = Keyword.fetch!(env, :maximum_granting_deferral)

    struct
    |> cast(params, [:permission_set_id, :grantee_id, :authority_id, :valid_after, :valid_for])
    |> validate_required([:permission_set_id, :grantee_id, :authority_id])
    |> validate_lifetime()
    |> validate_inclusion(:valid_after, @immediately..maximum_deferral)
    |> validate_inequality(:grantee_id, :authority_id)
    |> foreign_key_constraint(:permission_set_id)
    |> foreign_key_constraint(:grantee_id)
    |> foreign_key_constraint(:authority_id)
  end

  @spec validate(PermissionSetGrant) ::
          :ok
          | {:error, :invalid}
          | {:error, :inactive}
          | {:error, :timed_out}
  def validate(grant) do
    cond do
      invalidated?(grant) ->
        {:error, :invalid}

      not become_active?(grant) ->
        {:error, :inactive}

      timed_out?(grant) ->
        {:error, :timed_out}

      true ->
        :ok
    end
  end

  defp invalidated?(grant) do
    not is_nil(grant.invalidation)
  end

  defp become_active?(grant) do
    valid_after =
      case grant.valid_after do
        nil ->
          grant.inserted_at

        _ ->
          add(grant.inserted_at, grant.valid_after)
      end

    compare(utc_now(), valid_after) == :gt
  end

  defp timed_out?(grant) do
    case grant.valid_for do
      nil ->
        false

      _ ->
        valid_after =
          case grant.valid_after do
            nil ->
              grant.inserted_at

            _ ->
              add(grant.inserted_at, grant.valid_after)
          end

        compare(utc_now(), add(valid_after, grant.valid_for)) == :gt
    end
  end

  defp validate_lifetime(changeset) do
    env = Application.get_env(:legion, Legion.Identity.Auth.AccessControl)
    maximum_lifetime = Keyword.fetch!(env, :maximum_granting_lifetime)

    changeset
    |> validate_lifetime_existence()
    |> validate_inclusion(:valid_for, @immediately..maximum_lifetime)
  end

  defp validate_lifetime_existence(changeset) do
    env = Application.get_env(:legion, Legion.Identity.Auth.AccessControl)
    allow_infinite_lifetime = Keyword.fetch!(env, :allow_infinite_lifetime)

    if allow_infinite_lifetime do
      changeset
    else
      changeset
      |> validate_required([:valid_for])
    end
  end

  defp validate_inequality(changeset, first, second) do
    lhs = get_field(changeset, first)
    rhs = get_field(changeset, second)

    if lhs == rhs do
      changeset
      |> add_error(:second, "is equal to #{Atom.to_string(first)}", value: lhs)
    else
      changeset
    end
  end
end
