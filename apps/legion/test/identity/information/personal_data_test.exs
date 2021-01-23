defmodule Legion.Identity.Information.PersonalDataTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Information.PersonalData

  @valid_params %{user_id: 1,
                  given_name: "given",
                  middle_name: "middle",
                  family_name: "family",
                  name_prefix: "prefix",
                  name_postfix: "postfix",
                  nickname: "nickname",
                  phonetic_representation: "phonetic",
                  gender: :male,
                  nationality: "en"}

  test "changeset with English attributes" do
    assert PersonalData.changeset(%PersonalData{}, @valid_params).valid?
  end

  test "changeset with Arabic attributes" do
    assert PersonalData.changeset(%PersonalData{},
                                  %{user_id: 1,
                                    given_name: " الجملة الاسمية",
                                    middle_name: " الجملة الاسمية",
                                    family_name: " الجملة الاسمية",
                                    name_prefix: " الجملة الاسمية",
                                    name_postfix: " الجملة الاسمية",
                                    nickname: " الجملة الاسمية",
                                    phonetic_representation: " الجملة الاسمية",
                                    gender: :male,
                                    nationality: "sa"}).valid?
  end

  test "changeset with Korean attributes" do
    assert PersonalData.changeset(%PersonalData{},
                                  %{user_id: 1,
                                    given_name: "한국 사람",
                                    middle_name: "한국 사람",
                                    family_name: "한국 사람",
                                    name_prefix: "한국 사람",
                                    name_postfix: "한국 사람",
                                    nickname: "한국 사람",
                                    phonetic_representation: "한국 사람",
                                    gender: :male,
                                    nationality: "sa"}).valid?
  end

  test "changeset without given name" do
    assert PersonalData.changeset(%PersonalData{}, omit_param(:given_name)).valid?
  end

  test "changeset without middle name" do
    assert PersonalData.changeset(%PersonalData{}, omit_param(:middle_name)).valid?
  end

  test "changeset without family name" do
    assert PersonalData.changeset(%PersonalData{}, omit_param(:family_name)).valid?
  end

  test "changeset without name prefix" do
    assert PersonalData.changeset(%PersonalData{}, omit_param(:name_prefix)).valid?
  end

  test "changeset without name postfix" do
    assert PersonalData.changeset(%PersonalData{}, omit_param(:name_postfix)).valid?
  end

  test "changeset without nickname" do
    assert PersonalData.changeset(%PersonalData{}, omit_param(:nickname)).valid?
  end

  test "changeset without phonetic_representation" do
    assert PersonalData.changeset(%PersonalData{}, omit_param(:phonetic_representation)).valid?
  end

  test "changeset with default params" do
    refute PersonalData.changeset(%PersonalData{}).valid?
  end

  defp omit_param(param) do
    Map.delete(@valid_params, param)
  end
end