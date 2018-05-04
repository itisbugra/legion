defmodule Mix.Tasks.Legion.Gen.Registry do
  @shortdoc "Synchronizes registry entries found in files system with database."

  @moduledoc """
  Synchronizes registry entries found in files system with database.

  ## Examples

  To synchronize all registries declared in folder:

      mix legion.gen.registry

  You may also synchronize registries specified with module:

      mix legion.gen.registry --only Legion.Repo.Registry.Messaging

  ## Command-line options

    * `-o`, `--only` - the module that declares the registries
  """

  def run(args) do
    
  end
end
