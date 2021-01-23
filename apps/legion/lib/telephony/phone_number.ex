defmodule Legion.Telephony.PhoneNumber do
  @moduledoc """
  Declares types and utility functions for working with phone numbers.
  """

  @typedoc """
  Describes the type of the phone number.
  """
  @type host_type() :: :fixed_line |
                       :mobile |
                       :fixed_line_or_mobile |
                       :toll_free |
                       :premium_rate |
                       :shared_cost |
                       :voip |
                       :personal_number |
                       :pager |
                       :uan |
                       :voicemail |
                       :unknown

  @typedoc """
  Type for the phone number.
  """
  @type t() :: String.t()

  @doc ~S"""
  Returns the type of the phone number.

  ## Examples

      iex> Legion.Telephony.PhoneNumber.get_number_type("+90 532 111 1111")
      {:ok, :mobile}

      iex> Legion.Telephony.PhoneNumber.get_number_type("+90 216 111 1111")
      {:ok, :fixed_line}

      iex> Legion.Telephony.PhoneNumber.get_number_type("test")
      {:error, :invalid}
  """
  @spec get_number_type(t()) ::
    {:ok, host_type()} |
    {:error, :invalid}
  def get_number_type(number) when is_binary(number) do
    case ExPhoneNumber.parse(number, nil) do
      {:ok, phone_number} ->
        number_type = ExPhoneNumber.get_number_type(phone_number)

        {:ok, number_type}
      {:error, _} ->
        {:error, :invalid}
    end
  end

  @doc """
  Determines validity of the given phone number.

      iex> Legion.Telephony.PhoneNumber.is_valid_number?("+905321111111")
      true

      iex> Legion.Telephony.PhoneNumber.is_valid_number?("test")
      false
  """
  @spec is_valid_number?(t()) :: boolean()
  def is_valid_number?(number) when is_binary(number) do
    case ExPhoneNumber.parse(number, nil) do
      {:ok, phone_number} ->
        ExPhoneNumber.is_valid_number?(phone_number)
      {:error, _} ->
        false
    end
  end

  @doc ~S"""
  Returns a boolean value indicating the possibility of validity of the given phone number.
  Unlike `is_valid_number/2`, this function validates the phone number by bare lookup of
  its length.

      iex> Legion.Telephony.PhoneNumber.is_possible_number?("+905321111111")
      true

      iex> Legion.Telephony.PhoneNumber.is_possible_number?("test")
      false
  """
  @spec is_possible_number?(t()) :: boolean()
  def is_possible_number?(number) when is_binary(number), 
    do: ExPhoneNumber.is_possible_number?(number, "")

  @doc ~S"""
  Converts given number to RFC 3966-formatted string.

      iex> Legion.Telephony.PhoneNumber.to_rfc3966("+90 532 111 1111")
      {:ok, "tel:+90-532-111-11-11"}

      iex> Legion.Telephony.PhoneNumber.to_rfc3966("test")
      {:error, :invalid}
  """
  @spec to_rfc3966(t()) ::
    {:ok, String.t()} |
    {:error, :invalid}
  def to_rfc3966(number) do
    case ExPhoneNumber.parse(number, nil) do
      {:ok, phone_number} ->
        rfc3966 = ExPhoneNumber.format(phone_number, :rfc3966)

        {:ok, rfc3966}
      {:error, _} ->
        {:error, :invalid}
    end
  end

  @doc ~S"""
  Converts given number to E164-formatted string.

  ## Examples

      iex> Legion.Telephony.PhoneNumber.to_e164("+90 532 111 1111")
      {:ok, "+905321111111"}

      iex> Legion.Telephony.PhoneNumber.to_e164("test")
      {:error, :invalid}
  """
  def to_e164(number) when is_binary(number) do
    case ExPhoneNumber.parse(number, nil) do
      {:ok, phone_number} ->
        e164 = ExPhoneNumber.format(phone_number, :e164)

        {:ok, e164}
      {:error, _} ->
        {:error, :invalid}
    end
  end

  @doc """
  Humanizes the phone number in given format. `format` parameter can be either
  `:international` or `:national`, determining the existence of country code in
  resulting phone number.

  ## Examples

      iex> Legion.Telephony.PhoneNumber.humanize("+905321111111", :international)
      {:ok, "+90 532 111 11 11"}

      iex> Legion.Telephony.PhoneNumber.humanize("+905321111111", :national)
      {:ok, "0532 111 11 11"}

      iex> Legion.Telephony.PhoneNumber.humanize("test", :national)
      {:error, :invalid}
  """
  def humanize(number, format) when is_binary(number) and format in [:international, :national] do
    case ExPhoneNumber.parse(number, nil) do
      {:ok, phone_number} ->
        humanized = ExPhoneNumber.format(phone_number, format)

        {:ok, humanized}
      {:error, _} ->
        {:error, :invalid}
    end
  end

  @doc """
  Same as `humanize/2`, but uses `:international` formatting as default.

  ## Examples

      iex> Legion.Telephony.PhoneNumber.humanize("+905321111111")
      {:ok, "+90 532 111 11 11"}

      iex> Legion.Telephony.PhoneNumber.humanize("test")
      {:error, :invalid}
  """
  def humanize(number) when is_binary(number),
    do: humanize(number, :international)
end