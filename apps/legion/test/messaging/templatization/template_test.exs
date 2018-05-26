defmodule Legion.Messaging.Templatization.TemplateTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Messaging.Templatization.Template

  @name "nice template"
  @valid_params %{user_id: 1,
                  name: @name,
                  is_available_for_apm?: true,
                  is_available_for_push?: true,
                  is_available_for_mailing?: true,
                  is_available_for_sms?: true,
                  is_available_for_platform?: true}

  test "changeset with valid params" do
    changeset = Template.changeset(%Template{}, @valid_params)

    assert changeset.valid?
  end

  test "changeset without user identifier" do
    changeset =
      Template.changeset(%Template{}, params_without_field(:user_id))

    refute changeset.valid?
  end

  test "changeset without name" do
    changeset =
      Template.changeset(%Template{}, params_without_field(:name))

    refute changeset.valid?
  end

  test "changeset without availability for apm" do
    changeset =
      Template.changeset(%Template{}, params_without_field(:is_available_for_apm?))

    assert changeset.valid?
  end

  test "changeset without availability for push" do
    changeset =
      Template.changeset(%Template{}, params_without_field(:is_available_for_push?))

    assert changeset.valid?
  end

  test "changeset without availability for mailing" do
    changeset =
      Template.changeset(%Template{}, params_without_field(:is_available_for_mailing?))

    assert changeset.valid?
  end

  test "changeset without availability for sms" do
    changeset =
      Template.changeset(%Template{}, params_without_field(:is_available_for_sms?))

    assert changeset.valid?
  end

  test "changeset without availability for platform" do
    changeset =
      Template.changeset(%Template{}, params_without_field(:is_available_for_platform))

    assert changeset.valid?
  end

  test "changeset with no availability" do
    changeset =
      Template.changeset(%Template{},
                         %{user_id: 1,
                           name: @name,
                           is_available_for_apm?: false,
                           is_available_for_push?: false,
                           is_available_for_mailing?: false,
                           is_available_for_sms?: false,
                           is_available_for_platform?: false})

    refute changeset.valid?
  end

  test "changeset with such availability" do
    changeset =
      Template.changeset(%Template{},
                         %{user_id: 1,
                           name: @name,
                           is_available_for_apm?: true,
                           is_available_for_push?: false,
                           is_available_for_mailing?: false,
                           is_available_for_sms?: false,
                           is_available_for_platform?: false})

    assert changeset.valid?
  end

  defp params_without_field(field), do: Map.delete(@valid_params, field)
end
