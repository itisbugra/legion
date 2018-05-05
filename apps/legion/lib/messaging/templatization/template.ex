defmodule Legion.Messaging.Templatization.Template do
  @moduledoc """
  Provides persistence logic for templatization of parametric messages sent to the platform users.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration, as: User

  @env Application.get_env(:legion, Legion.Messaging.Templatization)
  @name_len Keyword.fetch!(@env, :template_name_length)

  schema "messaging_templates" do
    belongs_to :user, User
    field :name, :string
    field :subject_template, :string
    field :subject_params, {:array, :string}, default: []
    field :body_template, :string
    field :body_params, {:array, :string}, default: []
    field :is_available_for_apm?, :boolean, default: true
    field :is_available_for_push?, :boolean, default: true
    field :is_available_for_mailing?, :boolean, default: true
    field :is_available_for_sms?, :boolean, default: false
    field :is_available_for_platform?, :boolean, default: true
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :name, :subject_template, :subject_params,
                     :body_template, :body_params, :is_available_for_apm?,
                     :is_available_for_push?, :is_available_for_mailing?,
                     :is_available_for_sms?, :is_available_for_platform?])
    |> validate_required([:user_id, :name, :body_template])
    |> validate_length(:name, min: Enum.min(@name_len), max: Enum.max(@name_len))
    |> validate_sms_constraint()
    |> validate_availability_constraint()
    |> foreign_key_constraint(:user_id)
  end

  defp validate_sms_constraint(changeset) do
    is_available_for_apm? = get_field(changeset, :is_available_for_apm?)
    is_available_for_push? = get_field(changeset, :is_available_for_push?)
    is_available_for_mailing? = get_field(changeset, :is_available_for_mailing?)
    is_available_for_platform? = get_field(changeset, :is_available_for_platform?)

    if is_available_for_apm? or
       is_available_for_mailing? or
       is_available_for_push? or
       is_available_for_platform?,
      do: validate_required(changeset, [:subject_template]),
    else: changeset
  end

  defp validate_availability_constraint(changeset) do
    is_available_for_apm? = get_field(changeset, :is_available_for_apm?)
    is_available_for_sms? = get_field(changeset, :is_available_for_sms?)
    is_available_for_push? = get_field(changeset, :is_available_for_push?)
    is_available_for_mailing? = get_field(changeset, :is_available_for_mailing?)
    is_available_for_platform? = get_field(changeset, :is_available_for_platform?)

    if is_available_for_apm? or
       is_available_for_sms? or
       is_available_for_push? or
       is_available_for_mailing? or
       is_available_for_platform?,
      do: changeset,
    else: add_error(changeset, :is_available_for_apm, "at least one medium should be available")
  end
end
