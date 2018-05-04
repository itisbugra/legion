defmodule Legion.Messaging.Templatization.Render do
  @moduledoc """
  Represents the rendering result of templatized text.
  """
  @enforce_keys ~w(subject body)a
  defstruct [
    :subject,
    :body
  ]

  @typedoc """
  The rendering result of templatization.

  ## Fields
  - `:subject`: Subject rendering of the message.
  - `:body`: Body rendering of the message.
  """
  @type t :: %__MODULE__{
    subject: binary,
    body: binary
  }
end
