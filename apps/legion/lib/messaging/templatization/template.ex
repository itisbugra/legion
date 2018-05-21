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
    field :is_available_for_apm?, :boolean, default: true
    field :is_available_for_push?, :boolean, default: true
    field :is_available_for_mailing?, :boolean, default: true
    field :is_available_for_sms?, :boolean, default: false
    field :is_available_for_platform?, :boolean, default: true
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :engine, :name, :is_available_for_apm?,
                     :is_available_for_push?, :is_available_for_mailing?,
                     :is_available_for_sms?, :is_available_for_platform?])
    |> validate_required([:user_id, :engine, :name])
    |> validate_length(:name, min: Enum.min(@name_len), max: Enum.max(@name_len))
    |> validate_availability_constraint()
    |> foreign_key_constraint(:user_id)
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
