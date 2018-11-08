defmodule Legion.Messaging.Message.RecipientTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Messaging.Message.Recipient

  @valid_attrs %{message_id: 1, recipient_id: 1}

  test "changeset with valid attributes" do
    changeset = Recipient.changeset(%Recipient{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset without message identifier" do
    changeset = Recipient.changeset(%Recipient{}, attrs_drop_key(:message_id))

    refute changeset.valid?
  end

  test "changeset without recipient identifier" do
    changeset = Recipient.changeset(%Recipient{}, attrs_drop_key(:recipient_id))

    refute changeset.valid?
  end

  test "changeset is invalid with default params either" do
    refute Recipient.changeset(%Recipient{}).valid?
  end

  def attrs_drop_key(key) do
    Map.delete(@valid_attrs, key)
  end
end
