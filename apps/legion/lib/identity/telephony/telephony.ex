defmodule Legion.Identity.Telephony do
  @moduledoc """
  Manages phone numbers of users, performs redirections of phone calls.
  """
  use Legion.Stereotype, :service

  import NaiveDateTime, only: [utc_now: 0]

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Telephony.PhoneNumber

  @doc """
  Adds a phone number entry to the user.
  To get more information about the fields, see `Legion.Identity.Telephony.PhoneNumber`.
  """
  @spec create_phone_number(User.id(), PhoneNumber.phone_type(), String.t(), Keyword.t()) ::
    {:ok, PhoneNumber} |
    {:error, :no_user} |
    {:error, :invalid} |
    {:error, :unknown_type}
  def create_phone_number(user_id, type, number, opts \\ []) do
    ignored? = Keyword.get(opts, :ignored?, false)
    safe? = Keyword.get(opts, :safe?, true)

    changeset = 
      PhoneNumber.changeset(%PhoneNumber{},
                            %{user_id: user_id,
                              type: type,
                              number: number,
                              ignored?: ignored?,
                              safe?: safe?})

    case Repo.insert(changeset) do
      {:error, changeset} ->
        translate_changeset(changeset)
      any ->
        any
    end
  end

  defp translate_changeset(changeset) do
    errors = changeset.errors

    # We make assertive programming here.
    # If there was a problem with any of those expected keys,
    # just return the proper error.
    cond do
      Keyword.has_key?(errors, :user_id) ->
        {:error, :no_user}
      Keyword.has_key?(errors, :phone_number) ->
        {:error, :invalid}
      Keyword.has_key?(errors, :type) ->
        {:error, :unknown_type}
    end
  end

  @doc """
  Makes a phone number primary.
  """
  def make_primary(phone_number_id) when is_integer(phone_number_id) do
    if phone_number = Repo.get_by(PhoneNumber, id: phone_number_id) do
      ignored? = phone_number.ignored?
      safe? = phone_number.safe?

      cond do
        not ignored? and safe? ->
          changeset = PhoneNumber.changeset(phone_number, %{primed_at: utc_now()})

          {:ok, Repo.update!(changeset)}
        ignored? ->
          {:error, :ignored}
        not safe? ->
          {:error, :unsafe}
      end
    else
      {:error, :not_found}
    end
  end

  defmacrop set_phone_number_ignorance(phone_number_id, ignored?) do
    quote do
      if phone_number = Repo.get_by(PhoneNumber, id: unquote(phone_number_id)) do
        changeset = PhoneNumber.changeset(phone_number, %{ignored?: unquote(ignored?)})

        {:ok, Repo.update!(changeset)}
      else
        {:error, :not_found}
      end
    end
  end

  defmacrop set_phone_number_safeness(phone_number_id, safe?) do
    quote do
      if phone_number = Repo.get_by(PhoneNumber, id: unquote(phone_number_id)) do
        changeset = PhoneNumber.changeset(phone_number, %{safe?: unquote(safe?)})

        {:ok, Repo.update!(changeset)}
      else
        {:error, :not_found}
      end
    end
  end

  @doc """
  Ignores given phone number.

  This function updates the `:ignored?` attribute of phone number with given
  identifier with a truthy value.
  If the phone number is already ignored, this function is no-op.
  """
  @spec ignore_phone_number(PhoneNumber.id()) ::
    {:ok, PhoneNumber} |
    {:error, :not_found}
  def ignore_phone_number(phone_number_id),
    do: set_phone_number_ignorance(phone_number_id, true)

  @doc """
  Acknowledges phone number.

  This function updates the `:ignored?` attribute of phone number with given
  identifier with a falsy value.
  """
  @spec acknowledge_phone_number(PhoneNumber.id()) ::
    {:ok, PhoneNumber} |
    {:error, :not_found}
  def acknowledge_phone_number(phone_number_id),
    do: set_phone_number_ignorance(phone_number_id, false)

  @doc """
  Marks a phone number safe.

  This function updates the `:safe?` attribute of phone number with given
  identifier with a truthy value.
  """
  @spec mark_phone_number_safe(PhoneNumber.id()) ::
    {:ok, PhoneNumber} |
    {:error, :not_found}
  def mark_phone_number_safe(phone_number_id),
    do: set_phone_number_safeness(phone_number_id, true)

  @doc """
  Marks a phone number unsafe.

  This function updates the `:safe?` attribute of phone number with given
  identifier with a falsy value.
  """
  @spec mark_phone_number_unsafe(PhoneNumber.id()) ::
    {:ok, PhoneNumber} |
    {:error, :not_found}
  def mark_phone_number_unsafe(phone_number_id),
    do: set_phone_number_safeness(phone_number_id, false)
end