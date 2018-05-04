defmodule Legion.Messaging.Medium.APM.Request do
  @moduledoc """
  Represents a message sending order using APM services.
  """
  use Legion.Stereotype, :model

  alias Legion.Messaging.Message

  schema "apm_requests" do
    belongs_to :message, Message
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:message_id])
    |> validate_required([:message_id])
    |> foreign_key_constraint(:message_id)
  end
end
