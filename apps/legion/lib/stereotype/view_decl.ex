defmodule Legion.Stereotype.ViewDecl do
  defmacro __using__(_) do
    quote do
      import Legion.Stereotype.ViewDecl

      def migrate do
        Ecto.Migration.execute create_view(), drop_view()
      end
    end
  end

  defmacro create(do: expression) do
    quote do
      def(create_view, do: unquote(expression))
    end
  end

  defmacro drop(do: expression) do
    quote do
      def(drop_view, do: unquote(expression))
    end
  end
end