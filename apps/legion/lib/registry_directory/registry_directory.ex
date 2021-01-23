defmodule Legion.RegistryDirectory do
  @moduledoc """
  Provides metaprogramming tools to register singleton directories.

  ### Motivation

  Global settings directories can be used to gather runtime
  configuration.
  One can create a configuration to change the behavior of
  some modules, or enable/disable it through utility functions.

  Suppose you have a function, `enable_some_feature/0`, to enable
  a feature at the runtime of the application. To define a backend
  for this feature in persistence layer, you can leverage registry
  directories.

  ## Registries

  To create a registry directory with a module named `SomeSettings`,
  one may use the `defregdir/2` provided by this module.

  ```elixir
  import Legion.RegistryDirectory

  defregdir SomeSettings, "messaging_settings"
  ```

  Upon that call, the macro resolves for defining three modules, namely
  1. `SomeSettings.Register`,
  2. `SomeSettings.RegistryEntry` and
  3. `SomeSettings`.

  The first two modules are valid Ecto schemas, you can query them directly.

  ```elixir
  Repo.all(SomeSettings.Register) # returns all of the register keys
  ```

  Although it is strictly discouraged, you are also able to query the
  `SomeSettings.RegistryEntry` schema.

  ### Retrieving/manipulating settings

  The main module, `SomeSettings` (which was provided to the macro),
  exports functions for retrieving and manipulating the settings.
  The functionality expects an authenticated user, or its identifier
  to perform a manipulation settings (i.e. creating a new entry).
  The settings do not override each other, but bucketed as an event
  source, hence you may provide additional features (i.e. deferral,
  duration), which might likely need more than the last entry
  created.

  ## Adding registers

  Registers can be added at build time, and can be constantly
  referenced by the other tables. The macro does not perform
  a migration for the database, indeed, but you can prepare
  migrations for both key registration and table creation.

  For synchronization of the keys, see `Legion.RegistryDirectory.Synchronization`.
  """

  @doc """
  Defines a registration directory, resolving to several modules.

  - `{namespace}.Register`: An Ecto schema using string keys to
  refer to the registers.
  - `{namespace}.RegistryEntry`: An Ecto schema holds JSON data
  for a specific key.
  - `{namespace}`: Module providing utility functions for manipulating
  the registry.

  The macro also makes use of a base table name, provided by the
  second parameter, which will resolve to two table names in
  database, `"{namespace}_registers"` and
  `"{namespace}_registry_entries"`, for the two Ecto schemas,
  respectively.
  """
  defmacro defregdir(namespace, dirname) do
    quote do
      defmodule :"#{unquote(namespace)}.Register" do
        @moduledoc """
        Defines a settings register.
        """
        use Ecto.Schema

        import Ecto
        import Ecto.Changeset
        import Ecto.Query

        alias Legion.Repo

        @primary_key false

        schema unquote("#{dirname}_registers") do
          field :key, :string, primary_key: true, source: "key"
        end

        def changeset(struct, _params) do
          struct
          |> cast(%{}, [])
          |> add_error(:key, "cannot add register at runtime")
        end
      end

      defmodule :"#{unquote(namespace)}.RegistryEntry" do
        @moduledoc """
        Configures runtime configurable settings.
        """
        use Ecto.Schema

        import Ecto
        import Ecto.Changeset
        import Ecto.Query

        alias Legion.Repo

        alias Legion.Identity.Information.Registration, as: User

        schema unquote("#{dirname}_registry_entries") do
          belongs_to :register, :"#{unquote(namespace)}.Register", primary_key: true, foreign_key: :key, type: :string, references: :key
          field :value, :map
          belongs_to :authority, User
          field :inserted_at, :naive_datetime_usec, read_after_writes: true
        end

        def changeset(struct, params \\ %{}) do
          struct
          |> cast(params, [:key, :value, :authority_id])
          |> validate_required([:key, :value, :authority_id])
          |> foreign_key_constraint(:authority_id)
          |> foreign_key_constraint(:key)
        end
      end

      defmodule unquote(namespace) do
        @moduledoc """
        Manages global settings for registry modules.

        ## Caveats

        Instead of using functions of this module directly, to retrieve or alter the
        settings at runtime, use delegating functions supplied by relevant modules.
        """
        import Ecto
        import Ecto.Changeset
        import Ecto.Query

        alias Legion.Repo

        alias Legion.Identity.Information.Registration, as: User

        @registry_entry_schema :"#{unquote(namespace)}.RegistryEntry"
        @registry_entry_table_name "#{unquote(dirname)}_registry_entries"

        @doc """
        Changes the value of the setting identified by given `key`, to the new value
        `value`, on behalf of `user` authority.
        """
        @spec put(User.id() | User, String.t(), map()) ::
          :ok |
          :error
        def put(user = %User{}, key, value), do: put(user.id, key, value)
        def put(user_id, key, value) when is_binary(key) do
          changeset =
            @registry_entry_schema.changeset(%@registry_entry_schema{},
                                             %{key: key,
                                               authority_id: user_id,
                                               value: value})

          case Repo.insert(changeset) do
            {:ok, _setting} ->
              :ok
            {:error, _changeset} ->
              {:error, :unavailable}
          end
        end

        @doc """
        Retrieves the value of the setting identified by given `key`, or returns
        `default` if there was no value registered (yet).
        """
        @spec get(String.t(), term()) ::
          term()
        def get(key, default \\ nil) when is_binary(key) do
          query =
            from re1 in @registry_entry_table_name,
            left_join: re2 in @registry_entry_table_name,
              on: re1.key == re2.key and re1.id < re2.id,
            where: is_nil(re2.id) and
                   re1.key == ^key,
            select: re1.value

          if value = Repo.one(query), do: value, else: default
        end

        @doc """
        Takes the last `quantity` entries for the given `key`.
        """
        @spec take(String.t, pos_integer()) ::
          term()
        def take(key, quantity) when is_binary(key) do
          query =
            from re in @registry_entry_table_name,
            where: re.key == ^key,
            limit: ^quantity,
            order_by: [desc: re.id],
            select: {re.value, re.inserted_at}

          Repo.all(query)
        end
      end
    end
  end
end
