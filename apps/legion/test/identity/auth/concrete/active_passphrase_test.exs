defmodule Legion.Identity.Auth.Concrete.ActivePassphraseTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Auth.Concrete.ActivePassphrase

  # those counts had better not equal to each other
  @active_passphrases_count 3
  @inactive_passphrases_count 2

  setup do
    user = Factory.insert(:user)
    active_passphrases = Factory.insert_list(@active_passphrases_count, :passphrase, user: user)
    inactive_passphrases = Factory.insert_list(@inactive_passphrases_count, :passphrase, user: user)

    inactive_passphrases
    |> Enum.each(&Factory.insert(:passphrase_invalidation, 
                                 target_passphrase: &1, 
                                 source_passphrase: List.first(active_passphrases)))

    %{user: user, 
      active_passphrases: active_passphrases, 
      inactive_passphrases: inactive_passphrases}
  end

  test "fetches active passphrases", %{user: u, active_passphrases: ap, inactive_passphrases: ip} do
    ftor = &(Map.fetch!(&1, :id))/1
    result_ids = ActivePassphrase.list_for_user(u.id) |> Enum.map(ftor)
    ap_ids = Enum.map(ap, ftor)
    ip_ids = Enum.map(ip, ftor)

    assert length(result_ids) == @active_passphrases_count
    assert Enum.all?(ap_ids, &Enum.member?(result_ids, &1))    # assert that every element in ap is also in result
    refute Enum.any?(ip_ids, &Enum.member?(result_ids, &1))    # refute to any element of ip be in result
  end

  test "count is equal to length of the list", %{user: u} do
    result = ActivePassphrase.count_for_user(u.id)

    assert result == @active_passphrases_count
    refute result == @inactive_passphrases_count
  end
end