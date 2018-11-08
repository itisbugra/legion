defmodule Legion.Identity.Telephony.PhoneNumber.NeglectionTraitTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Telephony.PhoneNumber.NeglectionTrait

  @valid_params %{phone_number_id: 1, authority_id: 1}

  test "changeset with valid attrs" do
    changeset =
      NeglectionTrait.changeset(
        %NeglectionTrait{},
        @valid_params
      )

    assert changeset.valid?
  end

  test "changeset without phone number identifier" do
    changeset =
      NeglectionTrait.changeset(
        %NeglectionTrait{},
        omit_param(:phone_number_id)
      )

    refute changeset.valid?
  end

  test "changeset without authority passphrase identifier" do
    changeset =
      NeglectionTrait.changeset(
        %NeglectionTrait{},
        omit_param(:authority_id)
      )

    refute changeset.valid?
  end

  test "changeset with default params" do
    changeset = NeglectionTrait.changeset(%NeglectionTrait{})

    refute changeset.valid?
  end

  defp omit_param(field), do: Map.delete(@valid_params, field)
end
