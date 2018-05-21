defmodule Legion.Messaging.Templatization.RendererTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Messaging.Templatization.{Template, RenderingResult}
  alias Legion.Messaging.Templatization.Renderer
  alias Legion.Factory

  @base_path Path.join(__DIR__, "resources")
  @subject_template File.read!(Path.join(@base_path, "subject_template.liquid"))
  @body_template File.read!(Path.join(@base_path, "body_template.liquid"))
  @valid_subject_params %{"surname" => "christina"}
  @valid_body_params %{"products" => [
                         %{"name" => "fanta",
                           "price" => "25.00 EUR",
                           "description" => "Are you a schweppes guy or fanta?"},
                         %{"name" => "schweppes",
                           "price" => "5.00 EUR",
                           "description" => "Cheap and better than fanta."}
                         ],
                       "description" => "asdasd",
                       "product.name" => "asd",
                       "product.price" => "asd",
                       "product.description" => "ac",
                       "section" => "sosnovka military base",
                       "cool_products" => true}



  def insert_template do
    Factory.insert(:template, subject_template: @subject_template, body_template: @body_template)
    |> Template.changeset()
    |> Repo.update!()
  end

  describe "generate_message/3" do
    test "generates rendering result with given template" do
      result = Renderer.generate_message(insert_template(), @valid_subject_params, @valid_body_params)

      IO.inspect result
    end
  end
end
