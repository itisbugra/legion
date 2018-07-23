defmodule Legion.Identity.Auth.Insecure.AuthInfo do
  @moduledoc """
  A struct for processing authentication process during insecure challange.
  """
  alias Legion.Identity.Information.Registration, as: User

  defstruct [
    :user_id,
    :password_digest,
    :digestion_algorithm,
    :authentication_scheme
  ]

  
  @type t :: %__MODULE__{
    user_id: User.id(),
    password_digest: binary(),
    digestion_algorithm: Pair.digestion_algorithm(),
    authentication_scheme: :insecure
  }

  @doc """
  Checks if authentication schema is supported, returns error otherwise
  """
  @spec check_authentication_schema(__MODULE__.t()) :: 
    :ok |
    {:error, :unsupported_scheme}
  def check_authentication_schema(auth_info) do
    if auth_info.authentication_scheme == :insecure do
      :ok
    else
      {:error, :unsupported_scheme}
    end
  end
end