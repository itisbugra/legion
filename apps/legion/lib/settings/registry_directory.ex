defmodule Legion.Settings.RegistryDirectory do
  @moduledoc """

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
          field :inserted_at, :naive_datetime, read_after_writes: true
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
        Manages global settings for messaging modules.

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

          query
          |> Repo.all()
          |> Enum.map(fn {x, {{ year, month, day }, { hour, minute, second, microsecond }}} ->
            {x, NaiveDateTime.from_erl!({ { year, month, day }, { hour, minute, second }}, { microsecond, 6 })}
          end) # Little hack to convert Postgrex date to Erlang date
        end
      end
    end
  end
end
