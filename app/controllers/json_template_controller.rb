class JsonTemplateController < ApplicationController

  skip_load_and_authorize_resource only: [:index]

  def index
    @template = JsonTemplate.generate
    @schema = JsonSchema.generate(@template)
  end

end
