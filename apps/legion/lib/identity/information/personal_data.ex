defmodule Legion.Identity.Information.PersonalData do
  @moduledoc """
  Represents personal information of the user.

  ## Schema fields

  - `:given_name`: A name given to a individual to differentiate them from members of such group or family. May be referred as "family name" or "forename".
  - `:middle_name`: A name given to a individual to differentiate them from members of such group or family with members having same given name.
  - `:family_name`: A name given to a individual to represent its family or group.
  - `:name_prefix`: Prefix of the name to vocal the individual, such as "Mr.".
  - `:name_postfix`: Postfix of the name to vocal the individual, such as "-san", which may expand to something like "Suguro-san".
  - `:nickname`: A nick given to an individual, generally pronounced informally.
  - `:phonetic_representation`: Phonetic representation of the name of the user.
  - `:nationality_abbreviation`: Nationality of a user, e.g. "sa" for *Saudi Arabian*.
  - `:gender`: Gender of a user.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Information.{Gender, Nationality}

  @env Application.get_env(:legion, Legion.Identity.Information.PersonalData)
  @given_name_len Keyword.fetch!(@env, :given_name_length)
  @middle_name_len Keyword.fetch!(@env, :middle_name_length)
  @family_name_len Keyword.fetch!(@env, :family_name_length)
  @name_prefix_len Keyword.fetch!(@env, :name_prefix_length)
  @name_postfix_len Keyword.fetch!(@env, :name_postfix_length)
  @nickname_len Keyword.fetch!(@env, :nickname_length)
  @phonetic_representation_len Keyword.fetch!(@env, :phonetic_representation_length)

  @primary_key {:user_id, :integer, autogenerate: false}

  schema "user_personal_information" do
    belongs_to :user, User, define_field: false
    field :given_name, :string
    field :middle_name, :string
    field :family_name, :string
    field :name_prefix, :string
    field :name_postfix, :string
    field :nickname, :string
    field :phonetic_representation, :string
    field :gender, Gender
    belongs_to :nationality, Nationality, foreign_key: :nationality_abbreviation, references: :abbreviation, type: :binary
    timestamps inserted_at: false
  end

  def changeset(struct, params \\ []) do
    struct
    |> cast(params, [:user_id, :given_name, :middle_name, :family_name, :name_prefix, :name_postfix, :nickname, :phonetic_representation, :gender, :nationality_abbreviation])
    |> validate_required([:user_id])
    |> validate_range(:given_name, @given_name_len)
    |> validate_range(:middle_name, @middle_name_len)
    |> validate_range(:family_name, @family_name_len)
    |> validate_range(:name_postfix, @name_postfix_len)
    |> validate_range(:name_prefix, @name_prefix_len)
    |> validate_range(:nickname, @nickname_len)
    |> validate_range(:phonetic_representation, @phonetic_representation_len)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:nationality_abbreviation)
    |> unique_constraint(:user_id)
  end

  def validate_range(changeset, field, range),
    do: validate_length(changeset, field, min: Enum.min(range), max: Enum.max(range))
end