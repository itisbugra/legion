defmodule Legion.Identity.Telephony.PhoneNumber.SafetyTraitTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Telephony.PhoneNumber.SafetyTrait

  @valid_attrs %{phone_number_id: 1, authority_id: 1, valid_for: 1}

  test "changeset with valid attrs" do
    assert SafetyTrait.changeset(%SafetyTrait{}, @valid_attrs).valid?
  end

  test "changeset without phone number identifier" do
    refute SafetyTrait.changeset(%SafetyTrait{}, omit_param(:phone_number_id)).valid?
  end

  test "changeset without authority identifier" do
    refute SafetyTrait.changeset(%SafetyTrait{}, omit_param(:authority_id)).valid?
  end

  test "changeset without valid duration" do
    assert SafetyTrait.changeset(%SafetyTrait{}, omit_param(:valid_for)).valid?
  end

  defp omit_param(param),
    do: Map.delete(@valid_attrs, param)
end
