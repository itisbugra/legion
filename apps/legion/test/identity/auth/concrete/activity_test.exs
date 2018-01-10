defmodule Legion.Identity.Auth.Concrete.ActivityTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Auth.Concrete.Activity, only: [create_changeset: 4]
  import NaiveDateTime, only: [utc_now: 0, add: 2]

  alias Legion.Identity.Auth.Concrete.Activity
  alias Legion.Identity.Auth.Concrete.Passphrase

  @passkey_digest "$argon2i$v=19$m=65536,t=6,p=1$SoJWXxCYs6cTOW4PEZqJ6w$WQhD2UBB9fp2eA5PA2UOzXa7djroksasNNGgB8m0Nko"
  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_1) AppleWebKit/604.3.5 (KHTML, like Gecko) Version/11.0.1 Safari/604.3.5"
  @ipv4 %Postgrex.INET{address: {46, 196, 25, 86}}
  @valid_attrs %{passphrase_id: 2,
                 user_agent: @user_agent,
                 engine: "WebKit",
                 engine_version: "604.3.5",
                 client_name: "Safari",
                 client_type: "browser",
                 client_version: "11.0.1",
                 device_brand: "unknown",
                 device_model: "unknown",
                 device_type: "desktop",
                 os_name: "Mac",
                 os_platform: "unknown",
                 os_version: "10.13.1",
                 ip_addr: @ipv4,
                 country_name: "Turkey",
                 country_code: "TR",
                 ip_location: %Postgrex.Point{x: 41.0214,
                                              y: 28.9684},
                 metro_code: 0,
                 region_code: "34",
                 region_name: "Istanbul",
                 time_zone: "Europe/Istanbul",
                 zip_code: "",
                 gps_location: %Postgrex.Point{x: 41.4079,
                                               y: 29.0012}}

  test "changeset with valid attributes" do
    changeset = Activity.changeset(%Activity{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset without passphrase identifier" do
    attrs = Map.delete(@valid_attrs, :passphrase_id)
    changeset = Activity.changeset(%Activity{}, attrs)

    refute changeset.valid?
  end

  test "changeset without user agent" do
    attrs = Map.delete(@valid_attrs, :user_agent)
    changeset = Activity.changeset(%Activity{}, attrs)

    refute changeset.valid?
  end

  test "changeset without engine" do
    attrs = Map.delete(@valid_attrs, :engine)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without engine version" do
    attrs = Map.delete(@valid_attrs, :engine_version)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without client name" do
    attrs = Map.delete(@valid_attrs, :client_name)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without client type" do
    attrs = Map.delete(@valid_attrs, :client_type)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without client version" do
    attrs = Map.delete(@valid_attrs, :client_version)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without device brand" do
    attrs = Map.delete(@valid_attrs, :device_brand)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without device model" do
    attrs = Map.delete(@valid_attrs, :device_model)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without device type" do
    attrs = Map.delete(@valid_attrs, :device_type)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without operating system name" do
    attrs = Map.delete(@valid_attrs, :os_name)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without operating system platform" do
    attrs = Map.delete(@valid_attrs, :os_platform)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without operating system version" do
    attrs = Map.delete(@valid_attrs, :os_version)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without ip address" do
    attrs = Map.delete(@valid_attrs, :ip_addr)
    changeset = Activity.changeset(%Activity{}, attrs)

    refute changeset.valid?
  end

  test "changeset without country name" do
    attrs = Map.delete(@valid_attrs, :engine_version)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without country code" do
    attrs = Map.delete(@valid_attrs, :country_code)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without ip location" do
    attrs = Map.delete(@valid_attrs, :ip_location)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without metro code" do
    attrs = Map.delete(@valid_attrs, :metro_code)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without region code" do
    attrs = Map.delete(@valid_attrs, :region_code)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without region name" do
    attrs = Map.delete(@valid_attrs, :region_name)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without time zone" do
    attrs = Map.delete(@valid_attrs, :time_zone)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without zip code" do
    attrs = Map.delete(@valid_attrs, :zip_code)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  test "changeset without gps location" do
    attrs = Map.delete(@valid_attrs, :gps_location)
    changeset = Activity.changeset(%Activity{}, attrs)

    assert changeset.valid?
  end

  describe "create_changeset/4" do
    test "creates changeset with valid attrs" do
      passphrase = 
        %Passphrase{id: 1,
                    user_id: 1,
                    passkey_digest: @passkey_digest,
                    ip_addr: @ipv4}

      result = create_changeset(passphrase, 
                                @user_agent, 
                                @ipv4.address, 
                                %Postgrex.Point{x: 4.2, y: 6.1})

      assert elem(result, 0) == :ok
      assert elem(result, 1).valid?
    end

    test "creates changeset with loopback address" do
      passphrase = 
        %Passphrase{id: 1,
                    user_id: 1,
                    passkey_digest: @passkey_digest,
                    ip_addr: @ipv4}

      result = create_changeset(passphrase, 
                                @user_agent, 
                                {127, 0, 0, 1},
                                %Postgrex.Point{x: 4.2, y: 6.1})

      assert elem(result, 0) == :ok
      assert elem(result, 1).valid?
    end

    test "fails with improper ip address" do
      passphrase = 
        %Passphrase{id: 1,
                    user_id: 1,
                    passkey_digest: @passkey_digest,
                    ip_addr: @ipv4}

      result = create_changeset(passphrase, 
                                @user_agent, 
                                {500, 22, 1100, 34}, 
                                %Postgrex.Point{x: 4.2, y: 6.1})

      assert result == {:error, :incorrect_ip_range}
    end
  end

  describe "last_activity/1" do
    test "returns nil if user has no activity yet" do
      user = insert(:user)

      refute Activity.last_activity(user)
    end

    test "returns activity with highest timestamp" do
      user = insert(:user)
      passphrase = insert(:passphrase, user: user)
      _passed_activities = insert_list(5, :activity, passphrase: passphrase, inserted_at: add(utc_now(), -5))
      latest_activity = insert(:activity, passphrase: passphrase)

      assert Activity.last_activity(user).id == latest_activity.id
    end
  end
end
