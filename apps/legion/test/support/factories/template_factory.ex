defmodule Legion.TemplateFactory do
  @moduledoc false
  use ExMachina.Ecto, repo: Legion.Repo

  defmacro __using__(_opts) do
    quote do
      def template_factory do
        alias Legion.Messaging.Templatization.Template

        %Template{
          user: build(:user),
          name: sequence(:template_name, &"the-template-#{&1}"),
          engine: :liquid,
          subject_template: sequence(:subject_template, &"subject-template-#{&1}"),
          body_template: sequence(:body_template, &"body-template-#{&1}"),
          is_available_for_apm?: sequence(:medium_availability, [true, false]),
          is_available_for_push?: sequence(:medium_availability, [true, false]),
          is_available_for_mailing?: sequence(:medium_availability, [true, false]),
          is_available_for_platform?: sequence(:medium_availability, [true, false])
        }
      end
    end
  end
end
