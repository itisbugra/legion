defmodule Legion.Messaging.Message.SuccessInformationTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Messaging.Message.SuccessInformation

  @valid_params %{message_id: 1}

  test "changeset with valid attributes" do
    changeset = SuccessInformation.changeset(%SuccessInformation{}, @valid_params)

    assert changeset.valid?
  end

  test "changeset without message identifier" do
    changeset = SuccessInformation.changeset(%SuccessInformation{}, %{})

    refute changeset.valid?
  end

  test "changeset is invalid with default params either" do
    refute SuccessInformation.changeset(%SuccessInformation{}).valid?
  end
end
