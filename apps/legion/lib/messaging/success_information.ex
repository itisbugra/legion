defmodule Legion.Messaging.Message.SuccessInformation do
  @moduledoc """
  Bounded to a message upon receiving a success callback from the integrated service.
  """
  use Legion.Stereotype, :model

  alias Legion.Messaging.Message

  schema "message_success_informations" do
    belongs_to :message, Message, primary_key: true
    field :inserted_at, :naive_datetime_usec, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:message_id])
    |> validate_required([:message_id])
    |> foreign_key_constraint(:message_id)
  end
end
