defmodule Legion.Messaging.Templatization.TemplateTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Messaging.Templatization.Template

  @name "nice template"
  @base_path Path.join(__DIR__, "resources")
  @subject_template File.read!(Path.join(@base_path, "subject_template.liquid"))
  @body_template File.read!(Path.join(@base_path, "body_template.liquid"))
  @subject_params ["surname"]
  @body_params ["cool_products", "all_products", "section", "description"]
  @valid_params %{user_id: 1,
                  name: @name,
                  engine: :liquid,
                  subject_template: @subject_template,
                  body_template: @body_template,
                  subject_params: @subject_params,
                  body_params: @body_params,
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

  test "changeset without engine" do
    changeset =
      Template.changeset(%Template{}, params_without_field(:engine))

    refute changeset.valid?
  end

  test "changeset without subject params" do
    changeset =
      Template.changeset(%Template{}, params_without_field(:subject_params))

    assert changeset.valid?
  end

  test "changeset without body template" do
    changeset =
      Template.changeset(%Template{}, params_without_field(:body_template))

    refute changeset.valid?
  end

  test "changeset without body params" do
    changeset =
      Template.changeset(%Template{}, params_without_field(:body_params))

    assert changeset.valid?
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

  test "changeset with some availability other than sms and nil subject template" do
    changeset =
      Template.changeset(%Template{},
                         %{user_id: 1,
                           name: @name,
                           engine: :liquid,
                           body_template: @body_template,
                           subject_params: @subject_params,
                           body_params: @body_params,
                           is_available_for_apm?: true,
                           is_available_for_push?: true,
                           is_available_for_mailing?: true,
                           is_available_for_sms?: true})

    refute changeset.valid?
  end

  test "changeset with only sms availabily and nil subject template" do
    changeset =
      Template.changeset(%Template{},
                         %{user_id: 1,
                           name: @name,
                           engine: :liquid,
                           body_template: @body_template,
                           subject_params: @subject_params,
                           body_params: @body_params,
                           is_available_for_apm?: false,
                           is_available_for_push?: false,
                           is_available_for_mailing?: false,
                           is_available_for_sms?: true,
                           is_available_for_platform?: false})

    assert changeset.valid?
  end

  test "changeset with no availability" do
    changeset =
      Template.changeset(%Template{},
                         %{user_id: 1,
                           name: @name,
                           engine: :liquid,
                           subject_template: @subject_template,
                           body_template: @body_template,
                           subject_params: @subject_params,
                           body_params: @body_params,
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
                           engine: :liquid,
                           subject_template: @subject_template,
                           body_template: @body_template,
                           subject_params: @subject_params,
                           body_params: @body_params,
                           is_available_for_apm?: true,
                           is_available_for_push?: false,
                           is_available_for_mailing?: false,
                           is_available_for_sms?: false,
                           is_available_for_platform?: false})

    assert changeset.valid?
  end

  defp params_without_field(field), do: Map.delete(@valid_params, field)
end
