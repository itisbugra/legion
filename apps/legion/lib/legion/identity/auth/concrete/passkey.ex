defmodule Legion.Identity.Auth.Concrete.Passkey do
  @moduledoc """
  Property representing the secure data of an access token.
  """

  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @scale Keyword.fetch!(@env, :passkey_scaling)

  @typedoc """
  A passkey is simply a concatenation of #{@scale} UUIDs (Version 4).
  """
  @type t :: binary

  @doc """
  Generates a string passkey with an absolute length of #{@scale * 22}.
  """
  @spec generate() :: String.t
  def generate() do
    Base.encode64(bingenerate(), padding: true)
  end

  @doc """
  Generates a binary passkey.
  """
  @spec bingenerate() :: binary
  def bingenerate() do
    Enum.map_join(1..@scale, fn(_) -> Ecto.UUID.bingenerate() end)
  end
end
