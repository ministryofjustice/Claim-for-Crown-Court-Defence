class ExternalUsers::JsonDocumentImportersController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => :create
  skip_load_and_authorize_resource only: [:create]
  before_action :set_schema, :get_api_key
  respond_to :js, :html

  def create
    @json_document_importer = JsonDocumentImporter.new(json_document_importer_params.merge(schema: @schema, api_key: @api_key))
    if @json_document_importer.valid?
      @json_document_importer.import!
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js { render :format_error, locals: { filename: json_document_importer_params[:json_file].original_filename } }
      end
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

  def get_api_key
    @api_key = current_user.persona.provider.api_key
  end

end
