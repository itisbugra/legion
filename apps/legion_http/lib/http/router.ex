defmodule Legion.HTTP.Router do
  use Legion.HTTP, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Legion.HTTP do
    pipe_through :api

    scope "/users" do
      resources "/sign_in", Identity.Auth.SignIn.InstantiationController, only: [:create]
      resources "/sign_up", Identity.Auth.SignUp.RegistrationController, only: [:create]
    end
  end
end
