defmodule Legion.Identity.Information do
  @moduledoc """
  Delegates contextual functions to use the identity APIs.
  """

  defdelegate get_user(id), to: Legion.Identity.Information.User
end
