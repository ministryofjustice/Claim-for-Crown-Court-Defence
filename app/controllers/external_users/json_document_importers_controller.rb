class ExternalUsers::JsonDocumentImportersController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => :create
  skip_load_and_authorize_resource only: [:create]

  def create
    api_key = current_user.persona.provider.api_key
    schema_validator = ClaimJsonSchemaValidator

    @json_document_importer = JsonDocumentImporter.new(
      json_document_importer_params.merge(schema_validator: schema_validator, api_key: api_key)
    )

    # valid? will trigger the following validations:
    #
    #  file_parses_to_json:
    #     will ensure the uploaded file is a well formed json and can be parsed to a hash.
    #  file_conforms_to_basic_json_schema:
    #     will validate the parsed json against a basic schema to know if we should continue with the import.
    #
    if @json_document_importer.valid?
      @json_document_importer.import!
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js { render :format_error, locals: {errors: @json_document_importer.errors} }
      end
    end
  end

  private

  def json_document_importer_params
    params.require(:json_document_importer).permit(:json_file)
  end
end
