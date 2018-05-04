defmodule Legion.Messaging.Switching.Globals do
  @moduledoc """
  Provides functions for altering/retrieving global switches to messaging.

  ## Enabling/disabling mediums
  
  Suppose you need to disable the a medium globally. You might use `enable_medium/2` and
  `disable_medium/2` functions to alter the runtime configuration.

      enable_medium(some_user_or_id, :apm)
      disable_medium(some_user_or_id, :apm)

  Or, rather you can use convenience macros if `require` them in your module.

      require Legion.Messaging.Switching.Globals

      enable_apm_medium(some_user_or_id)
      disable_apm_medium(some_user_or_id)

  Notice that, the underlying implementation will not insert a new registry entry if value for the
  setting has not changed. Hence, calling those functions multiple times will not perform any write
  operations.
  """
  import Legion.Messaging.Message, only: :macros
  import Legion.Messaging.Settings

  alias Legion.Messaging.Message.Medium
  alias Legion.Identity.Information.Registration, as: User

  @apm_env Application.get_env(:legion, Legion.Messaging.Medium.APM)
  @apm_state Keyword.fetch!(@apm_env, :is_enabled?)

  @push_env Application.get_env(:legion, Legion.Messaging.Medium.Push)
  @push_state Keyword.fetch!(@push_env, :is_enabled?)

  @mailing_env Application.get_env(:legion, Legion.Messaging.Medium.Mailing)
  @mailing_state Keyword.fetch!(@mailing_env, :is_enabled?)

  @sms_env Application.get_env(:legion, Legion.Messaging.Medium.SMS)
  @sms_state Keyword.fetch!(@sms_env, :is_enabled?)

  @platform_env Application.get_env(:legion, Legion.Messaging.Medium.Platform)
  @platform_state Keyword.fetch!(@platform_env, :is_enabled?)

  @available_pushes Medium.__enum_map__()

  @doc """
  Enables APM medium.

  This macro curries the `enable_medium/2` function with corresponding medium.
  """
  defmacro enable_apm_medium(user_or_id),
    do: (quote do: enable_medium(unquote(user_or_id), :apm))

  @doc """
  Enables push medium.

  This macro curries the `enable_medium/2` function with corresponding medium.
  """
  defmacro enable_push_medium(user_or_id),
    do: (quote do: enable_medium(unquote(user_or_id), :push))

  @doc """
  Enables mailing medium.

  This macro curries the `enable_medium/2` function with corresponding medium.
  """
  defmacro enable_mailing_medium(user_or_id),
    do: (quote do: enable_medium(unquote(user_or_id), :mailing))

  @doc """
  Enables SMS medium.

  This macro curries the `enable_medium/2` function with corresponding medium.
  """
  defmacro enable_sms_medium(user_or_id),
    do: (quote do: enable_medium(unquote(user_or_id), :sms))

  @doc """
  Enables platform medium.

  This macro curries the `enable_medium/2` function with corresponding medium.
  """
  defmacro enable_platform_medium(user_or_id),
    do: (quote do: enable_medium(unquote(user_or_id), :platform))

  @doc """
  Disables in-platform messaging medium.

  This macro curries the `disable_medium/2` function with corresponding medium.
  """
  defmacro disable_apm_medium(user_or_id),
    do: (quote do: disable_medium(unquote(user_or_id), :apm))

  @doc """
  Disables push medium.

  This macro curries the `disable_medium/2` function with corresponding medium.
  """
  defmacro disable_push_medium(user_or_id),
    do: (quote do: disable_medium(unquote(user_or_id), :push))

  @doc """
  Disables mailing medium.

  This macro curries the `disable_medium/2` function with corresponding medium.
  """
  defmacro disable_mailing_medium(user_or_id),
    do: (quote do: disable_medium(unquote(user_or_id), :mailing))

  @doc """
  Disables SMS medium.

  This macro curries the `disable_medium/2` function with corresponding medium.
  """
  defmacro disable_sms_medium(user_or_id),
    do: (quote do: disable_medium(unquote(user_or_id), :sms))

  @doc """
  Disables in-platform messaging medium.

  This macro curries the `disable_medium/2` function with corresponding medium.
  """
  defmacro disable_platform_medium(user_or_id),
    do: (quote do: disable_medium(unquote(user_or_id), :platform))

  @doc """
  Enables given medium globally.
  """
  @spec enable_medium(User.id() | User, Medium.t()) ::
    :ok |
    :error
  def enable_medium(user_or_id, medium) when is_medium(medium),
    do: set_medium_availability(user_or_id, medium, true)

  @doc """
  Disables given medium globally.
  """
  @spec disable_medium(User.id() | User, Medium.t()) ::
    :ok |
    :error
  def disable_medium(user_or_id, medium) when is_medium(medium),
    do: set_medium_availability(user_or_id, medium, false)

  @doc """
  Returns a boolean value indicating if medium is enabled globally.
  """
  def is_medium_enabled?(medium) when is_medium(medium) do
    medium
    |> medium_availability_key()
    |> get(%{"next_value" => initial_availability(medium)})
    |> Map.get("next_value")
  end

  for type <- @available_pushes do
    defp initial_availability(unquote(type)) do
      unquote(Module.get_attribute(__MODULE__, :"#{Atom.to_string(type)}_state"))
    end
  end

  defp set_medium_availability(user, medium, availability)
    when is_boolean(availability) and is_medium(medium) do
    if is_medium_enabled?(medium) == availability do
      :ok
    else
      key = medium_availability_key(medium)

      put(user, key, %{next_value: availability})
    end
  end

  defp medium_availability_key(medium) when is_medium(medium),
    do: "Messaging.Switching.Globals.is_#{Atom.to_string(medium)}_enabled?"
end
