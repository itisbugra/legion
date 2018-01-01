defmodule Legion.Identity.Auth.Concrete.Activity do
  @moduledoc """
  Activities represent token generation from passphrases.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Auth.Concrete.Passphrase
  alias UAInspector, as: UserAgentParser
  alias FreeGeoIP.Search, as: IPReverseGeocoding

  @user_agent_len 160

  schema "passphrase_activities" do
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
    field :location, Legion.Types.Point
    field :metro_code, :integer
    field :region_code, :string
    field :region_name, :string
    field :time_zone, :string
    field :zip_code, :string
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:passphrase_id, :ip_addr, :country, :location,
                     :metro_code, :region_code, :region_name, :time_zone,
                     :zip_code, :user_agent])
    |> validate_required([:passphrase_id, :ip_addr, :country, :location,
                          :metro_code, :region_code, :region_name, :time_zone,
                          :zip_code, :user_agent])
    |> validate_length(:user_agent, max: @user_agent_len)
    |> foreign_key_constraint(:passphrase_id)
  end

  @doc """
  Creates a changeset with given passphrase, user agent string and IP address.
  """
  @spec create_changeset(Passphrase, binary, :inet.ip_address) ::
    {:ok, Ecto.Changeset.t} |
    {:error, any}
  def create_changeset(passphrase, user_agent, ip_addr) do
    ua_result = UserAgentParser.parse(user_agent)

    case IPReverseGeocoding.search(ip_addr) do
      {:ok, result} ->
        params =
          %{passphrase_id: passphrase.id,
            user_agent: user_agent,
            engine: ua_result.client.engine,
            engine_version: ua_result.client.engine_version,
            client_name: ua_result.client.name,
            client_type: ua_result.client.type,
            client_version: ua_result.client.version,
            device_brand: ua_result.device.brand,
            device_model: ua_result.device.model,
            device_type: ua_result.device.type,
            os_name: ua_result.os.name,
            os_platform: ua_result.os.platform,
            os_version: ua_result.os.version,
            ip_addr: ip_addr,
            country_name: result["country_name"],
            country_code: result["country_code"],
            location: {result["latitude"], result["longitude"]},
            metro_code: result["metro_code"],
            region_code: result["region_code"],
            region_name: result["region_name"],
            time_zone: result["time_zone"],
            zip_code: result["zip_code"]}

        {:ok, changeset(%__MODULE__{}, params)}
      {:error, description} ->
        {:error, description}
    end
  end
end
