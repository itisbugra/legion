defmodule Legion.Messaging.Localization.EntryTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Messaging.Localization.Entry

  @valid_attrs %{user_id: 1,
                 template_id: 1,
                 engine: :liquid,
                 subject_template: random_string(25),
                 body_template: random_string(25)}

  test "changeset with valid attributes" do
    changeset = Entry.changeset(%Entry{}, @valid_attrs)

    assert changeset.valid?
  end

  for attr <- [:user_id, :template_id, :engine, :body_template] do
    test "changeset without #{Atom.to_string(attr)} param" do
      changeset = Entry.changeset(%Entry{}, attrs_drop_key(unquote(attr)))

      refute changeset.valid?
    end
  end

  test "changeset without subject_template param" do
    changeset = Entry.changeset(%Entry{}, attrs_drop_key(:subject_template))

    assert changeset.valid?
  end

  def attrs_drop_key(key) do
    Map.delete(@valid_attrs, key)
  end
end
