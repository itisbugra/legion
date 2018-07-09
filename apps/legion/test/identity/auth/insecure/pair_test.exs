defmodule Legion.Identity.Auth.Insecure.PairTest do
  @moduledoc false
  use Legion.DataCase
  
  import Ecto.Changeset, only: [get_change: 3]

  alias Legion.Identity.Auth.Insecure.Pair

  @valid_attrs %{user_id: 1,
                 username: "username",
                 password: "password"}

  test "changeset with valid attributes" do
    changeset = Pair.changeset(%Pair{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset without user identifier" do
    params = params_by_dropping_key(@valid_attrs, :user_id)
    changeset = Pair.changeset(%Pair{}, params)

    refute changeset.valid?
  end

  test "changeset without username" do
    params = params_by_dropping_key(@valid_attrs, :username)
    changeset = Pair.changeset(%Pair{}, params)

    refute changeset.valid?
  end

  test "changeset without password" do
    params = params_by_dropping_key(@valid_attrs, :password)
    changeset = Pair.changeset(%Pair{}, params)

    refute changeset.valid?
  end

  test "hashes password with a digestion algorithm" do
    changeset = Pair.changeset(%Pair{}, @valid_attrs)

    assert get_change(changeset, :password_digest, false)
  end

  defp params_by_dropping_key(attrs, key),
    do: Map.delete(attrs, key)
end