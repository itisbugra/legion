defmodule Legion.Messaging.Message.TemplateUsageTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Messaging.Message.TemplateUsage

  @valid_attrs %{message_id: 1,
                 template_id: 1,
                 subject_params: %{},
                 body_params: %{}}

  test "changeset with valid attributes" do
    changeset = TemplateUsage.changeset(%TemplateUsage{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset without message identifier" do
    changeset = TemplateUsage.changeset(%TemplateUsage{}, attrs_drop_key(:message_id))

    refute changeset.valid?
  end

  test "changeset without template identifier" do
    changeset = TemplateUsage.changeset(%TemplateUsage{}, attrs_drop_key(:template_id))

    refute changeset.valid?
  end

  test "changeset without subject params" do
    changeset = TemplateUsage.changeset(%TemplateUsage{}, attrs_drop_key(:subject_params))

    assert changeset.valid?
  end

  test "changeset without body params" do
    changeset = TemplateUsage.changeset(%TemplateUsage{}, attrs_drop_key(:body_params))

    assert changeset.valid?
  end

  def attrs_drop_key(key),
    do: Map.delete(@valid_attrs, key)
end
