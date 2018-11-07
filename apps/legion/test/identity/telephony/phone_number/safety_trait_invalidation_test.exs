defmodule Legion.Identity.Telephony.PhoneNumber.SafetyTraitInvalidationTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Telephony.PhoneNumber.SafetyTrait

  @valid_params %{phone_number_id: 1,
                  authority_id: 1,
                  valid_for: 1}

  test "changeset with valid attrs" do
    changeset =   
      SafetyTrait.changeset(%SafetyTrait{},
                            @valid_params)

    assert changeset.valid?
  end

  test "changeset without phone number identifier" do
    changeset =
      SafetyTrait.changeset(%SafetyTrait{},
                            omit_param(:phone_number_id))

    refute changeset.valid?
  end

  test "changeset without authority identifier" do
    changeset =
      SafetyTrait.changeset(%SafetyTrait{},
                            omit_param(:authority_id))

    refute changeset.valid?
  end

  test "changeset without validity duration" do
    changeset =
      SafetyTrait.changeset(%SafetyTrait{},
                            omit_param(:valid_for))

    assert changeset.valid?
  end

  test "changeset with default params" do
    changeset = SafetyTrait.changeset(%SafetyTrait{})

    refute changeset.valid?
  end

  defp omit_param(field), do:
    Map.delete(@valid_params, field)
end