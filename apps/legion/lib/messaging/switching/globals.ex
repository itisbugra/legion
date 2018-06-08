defmodule Legion.Messaging.Switching.Globals do
  @moduledoc """
  Provides functions for altering/retrieving global switches to messaging.

  **This module is NOT transactionally safe.**

  ## Enabling/disabling mediums

  Suppose you need to disable the a medium globally. You might use `enable_medium/2` and
  `disable_medium/2` functions to alter the runtime configuration.

      enable_medium(some_user_or_id, :apm)
      disable_medium(some_user_or_id, :apm)

  Or, rather you can use convenience macros if you `require` them in your module.

      require Legion.Messaging.Switching.Globals

      enable_apm_medium(some_user_or_id)
      disable_apm_medium(some_user_or_id)

  Notice that, the underlying implementation will not insert a new registry entry if value for the
  setting has not changed. Hence, calling those functions multiple times will not perform any write
  operation.

  ## Redirecting a medium to another medium

  Sometimes you may want to redirect a messaging medium to another medium, probably due to cost
  reduction and integration maintenance.

  You can redirect a medium to another medium with the following call.

      redirect_medium(some_user_or_id, :mailing, :apm, for: 3_600)

  The above API call will redirect all mailing messages to APM medium.
  However, while sending a message, you might opt for restricting redirections on such operations.

      send_sms_message(some_user_or_id, "this is the message", redirection: :restrict)

  The message will not be sent to the user no matter what, what is more, it will throw an error to the user.

  Some messages, like one-time-codes, should not be redirected to another medium.
  The user of the messaging API can also force the actual medium to be run instead of redirection.

      send_sms_message(some_user_or_id, "some pretty otc", redirection: :ignore)

  If there was a redirection, it will be ignored, although the same rules for enabling/disabling medium for the actual
  medium will be still applied.
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

  @env Application.get_env(:legion, Legion.Messaging.Switching.Globals)
  @history_buffer_len Keyword.fetch!(@env, :history_buffer_length)

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
  @spec enable_medium(User.user_or_id(), Medium.t()) ::
    :ok |
    :error
  def enable_medium(user_or_id, medium) when is_medium(medium),
    do: set_medium_availability(user_or_id, medium, true)

  @doc """
  Disables given medium globally.
  """
  @spec disable_medium(User.user_or_id(), Medium.t()) ::
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

  @doc """
  Redirects a medium to another medium.

  ## Examples

      redirect_medium(user_id, :apm, :push) # redirects APM medium to push medium
      redirect_medium(user_id, :apm, :platform) # redirects APM medium to platform medium

  ## Timed redirections

  You may also redirect a medium to another medium for a given amount of time.

      redirect_medium(user_id, :apm, :push, for: 3_600) # redirects APM medium to push medium for an hour

  ## Deferring redirections

  Redirections could be also deferred for a given amount of time.

      redirect_medium(user_id, :apm, :push, after: 3_600) # redirects APM medium to push medium after an hour

  Redirections could be both deferred and timed.
  The following usage implies both applications.

      redirect_medium(user_id, :apm, :push, after: 3_600, for: 6_400) # same redirection, but active after an hour for two hours

  Note that redirections can override each other.
  The user interface for performing redirections should prompt whether the user is aware of overriding an existing redirection.

      redirect_medium(user_id, :apm, :push) # redirects APM medium to push medium
      redirect_medium(user_id, :apm, :mailing, for: 3_600) # redirects APM medium to mailing medium for an hour, afterwards push redirection will be active until further cancellation

  See `cancel_redirection_for_medium/3` for cancelling redirections.
  """
  @spec redirect_medium(User.user_or_id(), Medium.t(), Medium.t(), Keyword.t()) ::
    :ok |
    {:error, :invalid_duration} |
    {:error, :invalid_deferral} |
    {:error, :unavailable}
  def redirect_medium(user_or_id, from, to, options \\ [])
  when is_medium(from) and is_medium(to) do
    key = medium_redirection_key(from)
    valid_for = Keyword.get(options, :for, nil)
    valid_after = Keyword.get(options, :after, 0)

    cond do
      valid_for < 0 ->
        {:error, :invalid_duration}
      valid_after < 0 ->
        {:error, :invalid_deferral}
      true ->
        put(user_or_id, key, %{action: :redirect, to: to, valid_for: valid_for, valid_after: valid_after})
    end
  end

  @doc """
  Cancels redirection setting currently applied for specified medium.

  ## Examples

      redirect_medium(user_or_id, :apm, :mailing, for: 3_600) # redirects APM medium to mailing medium for an hour
      cancel_redirection_for_medium(user_or_id, :apm) # all redirections for the APM medium are now cancelled

  See `redirect_medium/4` for making redirections.
  """
  @spec cancel_redirection_for_medium(User.user_or_id(), Medium.t()) ::
    :ok |
    {:error, :no_entry} |
    {:error, :unavailable}
  def cancel_redirection_for_medium(user_or_id, medium)
  when is_medium(medium) do
    if is_medium_redirected?(medium) do
      key = medium_redirection_key(medium)

      put(user_or_id, key, %{action: :cancel})
    else
      {:error, :no_entry}
    end
  end

  @doc """
  Returns true if given medium is redirected currently, otherwise false.
  """
  @spec is_medium_redirected?(Medium.t) :: boolean()
  def is_medium_redirected?(medium)
  when is_medium(medium) do
    redirection_for_medium(medium) != nil
  end

  @doc """
  Returns the redirection medium for the medium in given timestamp, if it is redirected.
  Otherwise, returns `nil`.
  """
  @spec redirection_for_medium(Medium.t, NaiveDateTime.t) :: Medium.t() | nil
  def redirection_for_medium(medium, timestamp \\ NaiveDateTime.utc_now())
  when is_medium(medium) do
    key = medium_redirection_key(medium)

    entries = take(key, @history_buffer_len)

    case find_affecting_redirection(entries, timestamp) do
      nil ->
        nil
      {%{"to" => medium}, _inserted_at} ->
        String.to_existing_atom(medium)
    end
  end

  defp find_affecting_redirection([head | tail], timestamp) do
    if is_redirection_active(head, timestamp),
      do: head,
    else: find_affecting_redirection(tail, timestamp)
  end
  defp find_affecting_redirection([], _), do: nil

  defp is_redirection_active({entry, inserted_at}, timestamp) do
    valid_for = Map.get(entry, "valid_for")
    valid_after = Map.get(entry, "valid_after", 0)

    activation_time = NaiveDateTime.add(inserted_at, valid_after)

    if NaiveDateTime.compare(timestamp, activation_time) in [:gt, :eq] do
      if valid_for do
        valid_until = NaiveDateTime.add(activation_time, valid_for)
        NaiveDateTime.compare(timestamp, valid_until) == :lt
      else
        true
      end
    else
      false
    end
  end

  defp medium_availability_key(medium) when is_medium(medium),
    do: "Messaging.Switching.Globals.is_#{Atom.to_string(medium)}_enabled?"

  defp medium_redirection_key(medium) when is_medium(medium),
    do: "Messaging.Switching.Globals.#{Atom.to_string(medium)}_redirection"
end
