defmodule Legion.Identity.Information.AddressBook do
  @moduledoc """
  Functions for using the address book.

  ## Shared options

  Functions `create_address/5` and `update_address/5` are subject to options below.

  - `:type`: The new type of the address.
  - `:name`: The new name of the address.
  - `:country_name`: The name of the country.
  - `:description`: The description of the address entry.
  - `:state`: The new name of the state.
  - `:city`: The new name of the city.
  - `:neighborhood`: The new name of the neighborhood.
  - `:zip_code`: The new zip code of the location.
  - `:location`: The new coordinates of the location.
  """
  use Legion.Stereotype, :service

  require Logger

  alias Legion.Identity.Information.AddressBook.Address
  alias Legion.Identity.Information.Registration, as: User

  @env Application.get_env(:legion, Legion.Identity.Information.AddressBook)
  @default_page_size Keyword.fetch!(@env, :listing_default_page_size)

  @doc """
  Adds an address entry to user.
  To get more information about the fields, see `Legion.Identity.Information.AddressBook.Address`.
  """
  @spec create_address(User.id(),
                       Address.address_type(),
                       String.t(),
                       String.t(),
                       Keyword.t()) ::
    {:ok, Address} |
    {:error, Ecto.Changeset.t()}
  def create_address(user_id, type, name, country_name, opts \\ [])
  when is_integer(user_id) do
    description = Keyword.get(opts, :description)
    state = Keyword.get(opts, :state)
    city = Keyword.get(opts, :city)
    neighborhood = Keyword.get(opts, :neighborhood)
    zip_code = Keyword.get(opts, :zip_code)
    location = Keyword.get(opts, :location)

    changeset = 
      Address.changeset(%Address{},
                        %{user_id: user_id,
                          type: type,
                          name: name,
                          description: description,
                          state: state,
                          city: city,
                          neighborhood: neighborhood,
                          zip_code: zip_code,
                          location: location,
                          country_name: country_name})

    Repo.insert(changeset)
  end

  @doc """
  Updates address with given attributes.

  ## Options

  See the "Shared options" section at the module documentation.
  """
  @spec update_address(Address.id(), Address.address_type(), String.t(), String.t(), Keyword.t()) ::
    {:ok, Address} |
    {:error | Ecto.Changeset.t()}
  def update_address(address_id, type, name, country_name, opts \\ [])
  when is_integer(address_id) do
    address = Repo.get_by!(Address, id: address_id)
    description = Keyword.get(opts, :description)
    state = Keyword.get(opts, :state)
    city = Keyword.get(opts, :city)
    neighborhood = Keyword.get(opts, :neighborhood)
    zip_code = Keyword.get(opts, :zip_code)
    location = Keyword.get(opts, :location)

    changeset =
      Address.changeset(address,
                        %{type: type,
                          name: name,
                          description: description,
                          state: state,
                          city: city,
                          neighborhood: neighborhood,
                          zip_code: zip_code,
                          location: location,
                          country_name: country_name})

    Repo.update(changeset)
  end

  @doc """
  Lists addresses of the user.
  """
  @spec list_addresses_of_user(User.id(), Keyword.t()) ::
    [Address]
  def list_addresses_of_user(user_id, opts \\ [])
  when is_integer(user_id) do
    offset = Keyword.get(opts, :offset, 0)
    given_limit = Keyword.get(opts, :limit, @default_page_size)
    limit = 
      [given_limit, @default_page_size]
      |> Enum.min()

    unless given_limit <= @default_page_size,
      do: Logger.warn(fn -> "Paging violation: Expected page size was #{given_limit}, fenced to its default value #{@default_page_size}." end)

    query = from a in Address,
            where: a.user_id == ^user_id,
            offset: ^offset,
            limit: ^limit,
            order_by: [asc: :id],
            select: a

    Repo.all(query)
  end

  @doc """
  Deletes an address with given identifier.
  """
  @spec delete_address!(Address.id()) ::
    Address |
    no_return()
  def delete_address!(address_id) do
    address = Repo.get_by!(Address, id: address_id)

    Repo.delete!(address)
  end
end