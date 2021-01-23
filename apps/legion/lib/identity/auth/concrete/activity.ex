defmodule Legion.Identity.Auth.Concrete.Activity do
  @moduledoc """
  Activities represent token generation from passphrases.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Auth.Concrete.Activity
  alias Legion.Identity.Auth.Concrete.Passphrase
  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Networking.INET
  alias Legion.Networking.HTTP.UserAgent
  alias Legion.Networking.INET.Geocoding
  alias Legion.Location.Geocode

  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @user_agent_len Keyword.fetch!(@env, :user_agent_length)
  @allow_failsafe_reverse_geocoding Keyword.get(@env, :allow_failsafe_reverse_geocoding, false)

  schema "activities" do
    belongs_to :passphrase, Passphrase
    field :user_agent, :string
    field :engine, :string
    field :engine_version, :string
    field :client_name, :string
    field :client_type, :string
    field :client_version, :string
    field :device_brand, :string
    field :device_model, :string
    field :device_type, :string
    field :os_name, :string
    field :os_platform, :string
    field :os_version, :string
    field :ip_addr, Legion.Types.INET
    field :country_name, :string
    field :country_code, :string
    field :ip_location, Legion.Types.Point
    field :metro_code, :integer
    field :region_code, :string
    field :region_name, :string
    field :time_zone, :string
    field :zip_code, :string
    field :gps_location, Legion.Types.Point
    field :inserted_at, :naive_datetime_usec, read_after_writes: true
  end

  @doc """
  Creates a changeset with given parameters.
  """
  @spec changeset(Activity, map) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :passphrase_id,
      :ip_addr,
      :country_name,
      :country_code,
      :ip_location,
      :metro_code,
      :region_code,
      :region_name,
      :time_zone,
      :zip_code,
      :user_agent,
      :gps_location,
      :engine,
      :engine_version,
      :client_name,
      :client_type,
      :client_version,
      :device_brand,
      :device_model,
      :device_type,
      :os_name,
      :os_platform,
      :os_version
    ])
    |> validate_required([:passphrase_id, :user_agent, :ip_addr])
    |> validate_length(:user_agent, max: @user_agent_len)
    |> foreign_key_constraint(:passphrase_id)
  end

  @doc """
  Creates a changeset with given passphrase, user agent string and IP address.
  """
  @spec create_changeset(Passphrase.id(), UserAgent.t(), INET.t(), Postgrex.Point.t()) ::
          {:ok, Ecto.Changeset.t()}
          | {:error, any}
  def create_changeset(passphrase_id, user_agent_string, ip_addr, gps_location) do
    with user_agent <- UserAgent.parse(user_agent_string),
         {:ok, geocode} <- perform_reverse_geocoding_trace(ip_addr) do
      params = %{
        passphrase_id: passphrase_id,
        user_agent: user_agent_string,
        engine: user_agent.client.engine,
        engine_version: user_agent.client.engine_version,
        client_name: user_agent.client.name,
        client_type: user_agent.client.type,
        client_version: user_agent.client.version,
        device_brand: user_agent.device.brand,
        device_model: user_agent.device.model,
        device_type: user_agent.device.type,
        os_name: user_agent.os.name,
        os_platform: user_agent.os.platform,
        os_version: user_agent.os.version,
        ip_addr: %Postgrex.INET{address: ip_addr},
        country_name: geocode.country_name,
        country_code: geocode.country_code,
        ip_location: geocode.location,
        metro_code: geocode.metro_code,
        region_code: geocode.region_code,
        region_name: geocode.region_name,
        time_zone: geocode.time_zone,
        zip_code: geocode.zip_code,
        gps_location: gps_location
      }

      {:ok, changeset(%__MODULE__{}, params)}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  @spec generate_activity(Passphrase, binary, INET.t(), Postgrex.Point.t()) ::
          {:ok, Activity}
          | {:error, Ecto.Changeset.t()}
  def generate_activity(passphrase, user_agent, ip_addr, gps_location) do
    with {:ok, changeset} <- create_changeset(passphrase, user_agent, ip_addr, gps_location),
         {:ok, activity} <- Repo.insert(changeset) do
      {:ok, activity}
    else
      {:error, _error} = any ->
        any
    end
  end

  @doc """
  Fetches last activity of the user from the database. One can supply either `User` struct or
  user identifier as an integer as a parameter.
  """
  @spec last_activity(User | integer) ::
          Activity
          | nil
  def last_activity(user = %User{}) do
    last_activity(user.id)
  end

  def last_activity(user_id) when is_integer(user_id) do
    query =
      from u in User,
        join: p in Passphrase,
        on: u.id == p.user_id,
        join: a1 in Activity,
        on: a1.passphrase_id == p.id,
        left_join: a2 in Activity,
        on: a2.passphrase_id == p.id and a2.id > a1.id,
        where: u.id == ^user_id and is_nil(a2.id),
        order_by: [desc: a2.id],
        limit: 1,
        select: a1

    Repo.one(query)
  end

  defp perform_reverse_geocoding_trace(ip_addr) do
    result = Geocoding.trace(ip_addr)

    case result do
      {:error, :incorrect_ip_range} ->
        {:error, :incorrect_ip_range}

      {:error, error} ->
        if @allow_failsafe_reverse_geocoding, do: {:ok, Geocode.new()}, else: {:error, error}

      any ->
        any
    end
  end
end
