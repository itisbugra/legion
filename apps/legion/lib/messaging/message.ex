defmodule Legion.Messaging.Message do
  @moduledoc """
  Represents a message requested to be sent to user(s) using a messaging medium.
  """
  use Legion.Stereotype, :model

  import EctoEnum, only: [defenum: 3]

  alias Legion.Messaging.Medium
  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Messaging.Message.SuccessInformation

  @apm_env Application.get_env(:legion, Legion.Messaging.Medium.APM)
  @apm_subject_len Keyword.fetch!(@apm_env, :subject_length)
  @apm_body_len Keyword.fetch!(@apm_env, :body_length)

  @push_env Application.get_env(:legion, Legion.Messaging.Medium.Push)
  @push_subject_len Keyword.fetch!(@push_env, :subject_length)
  @push_body_len Keyword.fetch!(@push_env, :body_length)

  @mailing_env Application.get_env(:legion, Legion.Messaging.Medium.Mailing)
  @mailing_subject_len Keyword.fetch!(@mailing_env, :subject_length)
  @mailing_body_len Keyword.fetch!(@mailing_env, :body_length)

  @sms_env Application.get_env(:legion, Legion.Messaging.Medium.SMS)
  @sms_body_len Keyword.fetch!(@sms_env, :body_length)

  @platform_env Application.get_env(:legion, Legion.Messaging.Medium.Platform)
  @platform_subject_len Keyword.fetch!(@platform_env, :subject_length)
  @platform_body_len Keyword.fetch!(@platform_env, :body_length)

  @zero 0

  @typedoc """
  A medium to send the message by.

  ## Values
  - `:apm`: Platform-native push services (i.e. Apple Push Notification Service - APNS, Google Cloud
  Messaging - GCM, Microsoft Push Notification Service - MPNS, Windows Push Notification Services -
  WPN). See `Legion.Messaging.Medium.APM` for more information.
  - `:push`: Pseudo-push using local push APIs of devices. Might not be supported on all devices.
  - `:mailing`: Sends email using email services.
  - `:sms`: Push using Smart Message Service (SMS).
  - `:platform`: Sends message using real-time messaging system.
  """
  @type medium() :: :apm | :push | :mailing | :sms | :platform

  defenum Medium, :messaging_medium,
    [:apm, :push, :mailing, :sms, :platform]

  @available_pushes Medium.__enum_map__()

  @doc """
  Returns `true` if `term` is a medium atom (i.e. `:apm`, `:push`).

  Allowed in guard tests. Inlined by the compiler.

  ## Examples

      iex> Legion.Messaging.Message.is_medium(:apm)
      true

      iex> Legion.Messaging.Message.is_medium(:platform)
      true

      iex> Legion.Messaging.Message.is_medium(<<1::3>>)
      false

      iex> Legion.Messaging.Message.is_medium("apm")
      false
  """
  defguard is_medium(term) when term in @available_pushes

  defmodule Recipient do
    @moduledoc """
    Defines a recipient relationship of a message.
    """
    use Legion.Stereotype, :model

    alias Legion.Messaging.Message
    alias Legion.Identity.Information.Registration, as: User

    @primary_key false

    schema "message_recipients" do
      belongs_to :message, Message
      belongs_to :recipient, User
    end

    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [:message_id, :recipient_id])
      |> validate_required([:message_id, :recipient_id])
      |> foreign_key_constraint(:message_id)
      |> foreign_key_constraint(:recipient_id)
      |> unique_constraint(:message_id, name: :message_recipients_message_id_recipient_id_index)
    end
  end

  defmodule TemplateUsage do
    @moduledoc """
    Represents a template usage reference.
    """
    use Legion.Stereotype, :model

    alias Legion.Messaging.Templatization.Template
    alias Legion.Messaging.Message

    @primary_key {:message_id, :id, autogenerate: false}

    schema "message_template_usages" do
      belongs_to :message, Message, define_field: false
      belongs_to :template, Template
      field :subject_params, :map, default: %{}
      field :body_params, :map, default: %{}
    end

    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [:template_id, :message_id, :subject_params, :body_params])
      |> validate_required([:template_id, :message_id])
      |> foreign_key_constraint(:template_id)
      |> foreign_key_constraint(:message_id)
      |> unique_constraint(:message_id)
    end
  end

  schema "messages" do
    belongs_to :sender, User
    many_to_many :recipients, User, join_through: Recipient
    field :subject, :string
    field :body, :string
    field :medium, Medium
    field :send_after, :integer, default: 0, read_after_writes: true
    field :inserted_at, :naive_datetime, read_after_writes: true

    has_one :success_information, SuccessInformation
    has_one :template_usage, TemplateUsage
  end

  @doc """
  Validates changeset with given params.

  ## Caveats
  - `:body` and `:medium` fields are required to build a valid changeset.
  - `:subject` is required if selected `:medium` is not `:sms`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:subject, :body, :medium, :send_after])
    |> validate_required([:body, :medium, :send_after])
    |> validate_subject()
    |> validate_body()
    |> validate_number(:send_after, greater_than_or_equal_to: @zero)
  end

  defp validate_subject(changeset) do
    medium = get_field(changeset, :medium, nil)

    if medium == :sms,
      do: changeset,
    else: validate_subject_for_medium(changeset, medium)
  end

  for type <- List.delete(@available_pushes, :sms) do
    defp validate_subject_for_medium(changeset, unquote(type)) do
      min = unquote(Enum.min(Module.get_attribute(__MODULE__, :"#{Atom.to_string(type)}_subject_len")))
      max = unquote(Enum.max(Module.get_attribute(__MODULE__, :"#{Atom.to_string(type)}_subject_len")))

      validate_subject_for_min_max_length(changeset, unquote(type), min, max)
    end
  end

  defp validate_subject_for_min_max_length(changeset, medium, min, max) do
    changeset
    |> validate_required([:subject])
    |> validate_length(:subject, min: min, max: max)
  end

  defp validate_body(changeset) do
    medium = get_field(changeset, :medium, nil)

    validate_body_for_medium(changeset, medium)
  end

  for type <- @available_pushes do
    defp validate_body_for_medium(changeset, unquote(type)) do
      min = unquote(Enum.min(Module.get_attribute(__MODULE__, :"#{Atom.to_string(type)}_body_len")))
      max = unquote(Enum.max(Module.get_attribute(__MODULE__, :"#{Atom.to_string(type)}_body_len")))

      validate_length(changeset, :body, min: min, max: max)
    end
  end
end
