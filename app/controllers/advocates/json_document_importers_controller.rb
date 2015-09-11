class Advocates::JsonDocumentImportersController < ApplicationController

  skip_load_and_authorize_resource only: [:create]
  before_action :set_schema

  def create
    @json_document_importer = JsonDocumentImporter.new(json_document_importer_params.merge(schema: @schema))
    if @json_document_importer.valid?
      @json_document_importer.import!
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

  def json_document_importer_params
    params.require(:json_document_importer).permit(:json_file)
  end

end
