defmodule LegionWeb.Router do
  use LegionWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LegionWeb do
    pipe_through :api
  end
end
