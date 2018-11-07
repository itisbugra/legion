defmodule Legion.Identity.Telephony.PhoneNumber.PrioritizationTraitTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Telephony.PhoneNumber.PrioritizationTrait

  @valid_params %{phone_number_id: 1,
                  authority_id: 1}

  test "changeset with valid attrs" do
    changeset = 
      PrioritizationTrait.changeset(%PrioritizationTrait{},
                                    @valid_params)

    assert changeset.valid?
  end 

  test "changeset without phone number identifier" do
    changeset =
      PrioritizationTrait.changeset(%PrioritizationTrait{},
                                    omit_param(:phone_number_id))

    refute changeset.valid?
  end

  test "changeset without authority identifier" do
    changeset =
      PrioritizationTrait.changeset(%PrioritizationTrait{},
                                    omit_param(:authority_id))

    refute changeset.valid?
  end

  test "changeset with default params" do
    changeset = PrioritizationTrait.changeset(%PrioritizationTrait{})

    refute changeset.valid?
  end

  defp omit_param(field), do:
    Map.delete(@valid_params, field)
end