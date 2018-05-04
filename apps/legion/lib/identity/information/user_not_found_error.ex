defmodule Legion.Identity.Information.UserNotFoundError do
  defexception message: "user with given identifier cannot be found",
               user_id: nil
end
