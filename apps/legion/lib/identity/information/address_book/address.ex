defmodule Legion.Identity.Information.AddressBook.Address do
  @moduledoc """
  Represents an entry found in address book.

  ## Schema fields

  - `:user_id`: The identifier of the user that address belongs to.
  - `:type`: Type of the address, e.g. "home", "work".
  - `:name`: Name of the address, e.g. "Home at Rotterdam".
  - `:description`: Description of the address. Most of the time this is a short
  explanation of the address in a particular language to help to navigate the
  readers of the address properly.
  - `:state`: Name of the state, e.g. "Kansas". Some countries might not respect
  the political divisions to this type of attribute.
  - `:city`: Name of the city, e.g. "Rotterdam".
  - `:neighborhood`: Name of the neighborhood, e.g. "Beukelsdijk".
  - `:zip_code`: Zip code of the location.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Information.AddressBook.AddressType
  alias Legion.Identity.Information.Political.Country
  alias Legion.Types.Point

  @typedoc """
  Unique identifier for the address.
  """
  @type id() :: pos_integer()

  @typedoc """
  Represents a polymorphic type, containing either the struct itself or a unique identifier.
  """
  @type address_or_id() :: Address.id() | Address

  @typedoc """
  Shows the type of the address.
  """
  @type address_type() :: :home | :work | :other

  @env Application.get_env(:legion, Legion.Identity.Information.AddressBook)
  @name_len Keyword.fetch!(@env, :name_length)
  @description_len Keyword.fetch!(@env, :description_length)
  @state_len Keyword.fetch!(@env, :state_length)
  @city_len Keyword.fetch!(@env, :city_length)
  @neighborhood_len Keyword.fetch!(@env, :neighborhood_length)
  @zip_code_len Keyword.fetch!(@env, :zip_code_length)

  schema "user_addresses" do
    belongs_to(:user, User)
    field(:type, AddressType)
    field(:name, :string)
    field(:description, :string)
    field(:state, :string)
    field(:city, :string)
    field(:neighborhood, :string)
    field(:zip_code, :string)
    field(:location, Point)
    belongs_to(:country, Country, foreign_key: :country_name, references: :name, type: :string)
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :user_id,
      :type,
      :name,
      :description,
      :state,
      :city,
      :neighborhood,
      :zip_code,
      :country_name,
      :location
    ])
    |> validate_required([:user_id, :type, :name, :country_name])
    |> validate_length(:name, min: Enum.min(@name_len), max: Enum.max(@name_len))
    |> validate_length(:description,
      min: Enum.min(@description_len),
      max: Enum.max(@description_len)
    )
    |> validate_length(:state, min: Enum.min(@state_len), max: Enum.max(@state_len))
    |> validate_length(:city, min: Enum.min(@city_len), max: Enum.max(@city_len))
    |> validate_length(:neighborhood,
      min: Enum.min(@neighborhood_len),
      max: Enum.max(@neighborhood_len)
    )
    |> validate_length(:zip_code, min: Enum.min(@zip_code_len), max: Enum.max(@zip_code_len))
    |> validate_geo_inclusion()
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:country_name)
  end

  defp validate_geo_inclusion(changeset) do
    country_name = get_field(changeset, :country_name)
    location = get_change(changeset, :location)

    if not is_nil(country_name) and not is_nil(location) do
      country = Repo.get_by!(Country, name: country_name)

      if Country.does_contain_point?(country, location) do
        changeset
      else
        add_error(changeset, :location, "is not contained by the country")
      end
    else
      changeset
    end
  end
end
