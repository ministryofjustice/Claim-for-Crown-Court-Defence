class JsonTemplateController < ApplicationController

  skip_load_and_authorize_resource only: [:index]

  def index
    @template = JsonTemplate.generate
    @schema = JSON::SchemaGenerator.generate 'Advocate Defense Payments - Claim Import', @template
  end

end
