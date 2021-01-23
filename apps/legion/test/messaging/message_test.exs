defmodule Legion.Messaging.MessageTest do
  @moduledoc false
  use Legion.DataCase
  doctest Legion.Messaging.Message

  alias Legion.Messaging.Message

  @env Application.get_env(:legion, Legion.Messaging.Medium.APM)
  @subject_len Keyword.fetch!(@env, :subject_length)
  @body_len Keyword.fetch!(@env, :body_length)
  @subject random_string(@subject_len)
  @body random_string(@body_len)
  @valid_params %{sender_id: 1, subject: @subject, body: @body, medium: :apm, send_after: 0}

  test "changeset with valid params" do
    changeset = Message.changeset(%Message{}, @valid_params)

    assert changeset.valid?
  end

  test "changeset without subject but over sms" do
    params =
      @valid_params
      |> Map.delete(:subject)
      |> Map.put(:medium, :sms)

    changeset = Message.changeset(%Message{}, params)

    assert changeset.valid?
  end

  test "changeset without subject and not sms" do
    params =
      @valid_params
      |> Map.delete(:subject)
      |> Map.put(:medium, :push)

    changeset = Message.changeset(%Message{}, params)

    refute changeset.valid?
  end

  test "changeset with subject but too short" do
    params =
      @valid_params
      |> Map.put(:subject, random_string(Enum.min(@subject_len) - 1))

    changeset = Message.changeset(%Message{}, params)

    refute changeset.valid?
  end

  test "changeset with subject but too long" do
    params =
      @valid_params
      |> Map.put(:subject, random_string(Enum.max(@subject_len) + 1))

    changeset = Message.changeset(%Message{}, params)

    refute changeset.valid?
  end

  test "changeset with valid subject and sms" do
    params =
      @valid_params
      |> Map.put(:medium, :sms)

    changeset = Message.changeset(%Message{}, params)

    assert changeset.valid?
  end

  test "changeset without body" do
    changeset = Message.changeset(%Message{}, Map.delete(@valid_params, :body))

    refute changeset.valid?
  end

  test "changeset with too short body" do
    body = random_string(Enum.min(@body_len) - 1)
    changeset = Message.changeset(%Message{}, Map.put(@valid_params, :body, body))

    refute changeset.valid?
  end

  test "changeset with too long body" do
    body = random_string(Enum.max(@body_len) + 1)
    changeset = Message.changeset(%Message{}, Map.put(@valid_params, :body, body))

    refute changeset.valid?
  end

  test "changeset without send after" do
    changeset = Message.changeset(%Message{}, Map.delete(@valid_params, :send_after))

    assert changeset.valid?
  end

  test "changeset is invalid with default params either" do
    refute Message.changeset(%Message{}).valid?
  end
end
