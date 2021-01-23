defmodule Legion.Identity.Telephony.PhoneNumber.FiniteStateMachine do
  @moduledoc """
  Manages phone numbers of users, performs redirections of phone calls.

  **This module is NOT transaction-safe.**
  """
  use Legion.Stereotype, :service

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Auth.Concrete.Passphrase
  alias Legion.Identity.Telephony.PhoneNumber
  alias Legion.Identity.Telephony.PhoneNumber.{SafetyTrait, PrioritizationTrait, NeglectionTrait}

  @env Application.get_env(:legion, Legion.Identity.Telephony.PhoneNumber)
  @default_safe_duration Keyword.fetch!(@env, :default_safe_duration)

  @doc """
  Returns a struct representing safety status of the phone number.

  Raises `Ecto.NoResultsError` if no phone number was found with given identifier.
  """
  @spec safe_until(PhoneNumber.id()) ::
          DateTime.t()
          | :unsafe
  def safe_until(phone_number_id)
      when is_integer(phone_number_id) do
    query =
      from pn in PhoneNumber,
        preload: :valid_safety_traits,
        where: pn.id == ^phone_number_id

    preload = Repo.one!(query)
    safety_traits = preload.valid_safety_traits

    if Enum.empty?(safety_traits) do
      :unsafe
    else
      # Here we are using epochs to compare the times.
      # I know, this is not an elegant way to compare timestamps.
      # Or, at least, it is not a -modern- way.
      # But `Enum.max_by/2` does really great job shrinking the code
      # size here.
      #
      # Someday, we might change this implementation, who knows?
      trait_in_effect =
        Enum.max_by(safety_traits, fn e ->
          e.inserted_at
          |> NaiveDateTime.add(e.valid_for)
          # to retrieve epoch time
          |> NaiveDateTime.diff(~N[1970-01-01 00:00:00])
        end)

      trait_in_effect.inserted_at
      |> NaiveDateTime.add(trait_in_effect.valid_for)
      |> DateTime.from_naive!("Etc/UTC")
    end
  end

  @doc """
  Returns a boolean value indicating whether the phone number exists.
  """
  @spec exists?(PhoneNumber.id()) :: boolean()
  def exists?(phone_number_id) when is_integer(phone_number_id) do
    not is_nil(Repo.get_by(PhoneNumber, id: phone_number_id))
  end

  @doc """
  Returns a boolean value indicating whether the phone number is marked as safe.

  Raises `Ecto.NoResultsError` if no phone number was found with given identifier.
  """
  @spec safe?(PhoneNumber.id()) :: boolean()
  def safe?(phone_number_id) when is_integer(phone_number_id) do
    safe_until(phone_number_id) != :unsafe
  end

  @doc """
  Returns a boolean value showing whether the phone number is ignored.

  Raises `Ecto.NoResultsError` if no phone number was found with given identifier.
  """
  def ignored?(phone_number_id) when is_integer(phone_number_id) do
    query =
      from pn in PhoneNumber,
        preload: :neglection_trait,
        where: pn.id == ^phone_number_id

    query
    |> Repo.one!()
    |> Map.get(:neglection_trait)
    |> Kernel.is_nil()
    |> Kernel.not()
  end

  @doc """
  Returns a boolean value showing whether the phone number is primary.
  """
  def primary?(phone_number_id) when is_integer(phone_number_id) do
    query =
      from pn in PhoneNumber,
        preload: :valid_prioritization_trait,
        where: pn.id == ^phone_number_id

    query
    |> Repo.one!()
    |> Map.get(:valid_prioritization_trait)
    |> Kernel.is_nil()
    |> Kernel.not()
  end

  @doc """
  Adds a phone number entry to the user.

  To get more information about the fields, see `Legion.Identity.Telephony.PhoneNumber`.
  """
  @spec create_phone_number(User.id(), PhoneNumber.phone_type(), String.t()) ::
          {:ok, PhoneNumber}
          | {:error, :no_user}
          | {:error, :invalid}
          | {:error, :unknown_type}
  def create_phone_number(user_id, type, number) do
    changeset =
      PhoneNumber.changeset(
        %PhoneNumber{},
        %{user_id: user_id, type: type, number: number}
      )

    case Repo.insert(changeset) do
      {:error, changeset} ->
        translate_changeset_for_phone_number(changeset)

      any ->
        any
    end
  end

  @doc """
  Updates the type and number of a phone number entry.
  """
  @spec update_phone_number(PhoneNumber.id(), PhoneNumber.phone_type(), String.t()) ::
          {:ok, PhoneNumber}
          | {:error, :not_found}
          | {:error, :invalid}
          | {:error, :unknown_type}
  def update_phone_number(phone_number_id, type, number) do
    if phone_number = Repo.get_by(PhoneNumber, id: phone_number_id) do
      changeset =
        PhoneNumber.changeset(
          phone_number,
          %{type: type, number: number}
        )

      case Repo.update(changeset) do
        {:error, changeset} ->
          translate_changeset_for_phone_number(changeset)

        any ->
          any
      end
    else
      {:error, :not_found}
    end
  end

  @doc """
  Removes a phone number.
  """
  @spec remove_phone_number(PhoneNumber.id()) ::
          :ok
          | {:error, :not_found}
  def remove_phone_number(phone_number_id) do
    if phone_number = Repo.get_by(PhoneNumber, id: phone_number_id) do
      Repo.delete!(phone_number)

      :ok
    else
      {:error, :not_found}
    end
  end

  defp translate_changeset_for_phone_number(changeset) do
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

  defmacrop validate_passphrase_id(passphrase_id, do: expression) do
    quote do
      with :ok <- Passphrase.validate_id(unquote(passphrase_id)) do
        unquote(expression)
      else
        {:error, passphrase_error} ->
          {:error, :passphrase, passphrase_error}
      end
    end
  end

  @doc """
  Makes a phone number primary.

  ## Return values

  On successful operation, the function will return `{:ok, phone_number}`.

  Otherwise, it returns
  - `{:ok, :noop}`, if phone number was already safe,
  - `{:error, :ignored}`, if the phone number was marked as ignored,
  - `{:error, :unsafe}`, if the phone number was not marked as safe,
  - `{:error, :not_found}`, if there was no phone number with given identifier,
  - `{:error, :no_passphrase}`, if there was no passphrase with given identifier.

  To provide an idempotent interface, you can match this function to
  `{:ok, _}`, which will cover all successful flows.
  """
  @spec make_primary(Passphrase.id(), PhoneNumber.id()) ::
          {:ok, PrioritizationTrait}
          | {:ok, :noop}
          | {:error, :phone_number, :ignored}
          | {:error, :phone_number, :unsafe}
          | {:error, :phone_number, :not_found}
          | {:error, :passphrase, :not_found}
          | {:error, :passphrase, :invalid}
          | {:error, :passphrase, :timed_out}
  def make_primary(passphrase_id, phone_number_id)
      when is_integer(passphrase_id) and is_integer(phone_number_id) do
    validate_passphrase_id passphrase_id do
      cond do
        not exists?(phone_number_id) ->
          {:error, :phone_number, :not_found}

        primary?(phone_number_id) ->
          {:ok, :noop}

        ignored?(phone_number_id) ->
          {:error, :phone_number, :ignored}

        not safe?(phone_number_id) ->
          {:error, :phone_number, :unsafe}

        true ->
          params = %{authority_id: passphrase_id, phone_number_id: phone_number_id}

          changeset = PrioritizationTrait.changeset(%PrioritizationTrait{}, params)

          {:ok, Repo.insert!(changeset)}
      end
    end
  end

  @doc """
  Ignores given phone number.

  ## Return values

  On successful operation, this will return `{:ok, neglection_trait}`.

  Otherwise,  
  - `{:ok, :noop}`, if the phone number was already ignored,
  - `{:error, :not_found}`, if there was no phone number with given identifier.

  To provide an idempotent interface, you can match this function to
  `{:ok, _}`, which will cover all successful flows.
  """
  @spec ignore_phone_number(Passphrase.id(), PhoneNumber.id()) ::
          {:ok, NeglectionTrait}
          | {:ok, :noop}
          | {:error, :primary}
          | {:error, :no_passphrase}
          | {:error, :not_found}
  def ignore_phone_number(passphrase_id, phone_number_id) do
    validate_passphrase_id passphrase_id do
      cond do
        not exists?(phone_number_id) ->
          {:error, :phone_number, :not_found}

        ignored?(phone_number_id) ->
          {:ok, :noop}

        primary?(phone_number_id) ->
          {:error, :phone_number, :primary}

        not safe?(phone_number_id) ->
          {:error, :phone_number, :unsafe}

        true ->
          params = %{authority_id: passphrase_id, phone_number_id: phone_number_id}

          changeset = NeglectionTrait.changeset(%NeglectionTrait{}, params)

          {:ok, Repo.insert!(changeset)}
      end
    end
  end

  @doc """
  Acknowledges phone number. Returns the removed neglection trait.

  Same as `ignore_phone_number/1`, but works opposite.
  """
  @spec acknowledge_phone_number(PhoneNumber.id()) ::
          {:ok, NeglectionTrait}
          | {:ok, :noop}
          | {:error, :not_found}
  def acknowledge_phone_number(phone_number_id) do
    cond do
      not ignored?(phone_number_id) ->
        {:ok, :noop}

      true ->
        neglection_trait = Repo.get_by!(NeglectionTrait, phone_number_id: phone_number_id)

        {:ok, Repo.delete!(neglection_trait)}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, :not_found}
  end

  @doc """
  Marks a phone number safe.

  ## Options

  `:valid_for`: The duration of the new safety trait.

  ## Return values

  On successful operation, this will return `{:ok, phone_number}`.

  Otherwise,
  - `{:ok, :noop}`, if the phone number was already marked as safe,
  - `{:error, :not_found}`, if there was no phone number with given identifier.

  To provide an idempotent interface, you can match this function to
  `{:ok, _}`, which will cover all successful flows.
  """
  @spec mark_phone_number_safe(Passphrase.id(), PhoneNumber.id(), Keyword.t()) ::
          {:ok, SafetyTrait}
          | {:ok, :noop}
          | {:error, :no_passphrase}
          | {:error, :not_found}
          | {:error, :not_found}
          | {:error, :invalid}
          | {:error, :timed_out}
  def mark_phone_number_safe(passphrase_id, phone_number_id, opts \\ []) do
    validate_passphrase_id passphrase_id do
      cond do
        not exists?(phone_number_id) ->
          {:error, :phone_number, :not_found}

        safe?(phone_number_id) ->
          {:ok, :noop}

        true ->
          valid_for = Keyword.get(opts, :valid_for, @default_safe_duration)

          params = %{
            authority_id: passphrase_id,
            phone_number_id: phone_number_id,
            valid_for: valid_for
          }

          changeset = SafetyTrait.changeset(%SafetyTrait{}, params)

          {:ok, Repo.insert!(changeset)}
      end
    end
  end

  @doc """
  Marks a phone number unsafe.

  Same as `mark_phone_number_safe/1`, but works opposite.
  """
  @spec mark_phone_number_unsafe(Passphrase.id(), PhoneNumber.id()) ::
          {:ok, [Invalidation]}
          | {:ok, :noop}
          | {:error, :not_found}
          | {:error, :passphrase_not_found}
          | {:error, :passphrase_invalid}
          | {:error, :passphrase_timed_out}
  def mark_phone_number_unsafe(passphrase_id, phone_number_id) do
    alias SafetyTrait.Invalidation

    validate_passphrase_id passphrase_id do
      cond do
        not exists?(phone_number_id) ->
          {:error, :phone_number, :not_found}

        not safe?(phone_number_id) ->
          {:ok, :noop}

        true ->
          query =
            from pn in PhoneNumber,
              preload: :valid_safety_traits,
              where: pn.id == ^phone_number_id

          invalidations =
            query
            |> Repo.one!()
            |> Map.get(:valid_safety_traits)
            |> Enum.map(fn trait ->
              params = %{safety_trait_id: trait.id, authority_id: passphrase_id}

              changeset = Invalidation.changeset(%Invalidation{}, params)

              Repo.insert!(changeset)
            end)

          {:ok, invalidations}
      end
    end
  end
end
