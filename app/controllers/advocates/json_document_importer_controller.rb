class Advocates::JsonDocumentImporterController < ApplicationController

  skip_load_and_authorize_resource only: [:create]
  before_action :set_schema

  def create
    if params[:json_file]
      file = params[:json_file].tempfile
      json_doc_importer = JsonDocumentImporter.new(file, @schema)
      json_doc_importer.import!
      redirect_to '/advocates'
    else
      redirect_to '/advocates'
    end
  end

  private

  def set_schema
    template = JsonTemplate.generate
    @schema = JsonSchema.generate(template)
  end

end
