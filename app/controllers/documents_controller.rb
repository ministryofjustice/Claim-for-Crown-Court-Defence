class DocumentsController < ApplicationController
  load_and_authorize_resource
  respond_to :html
  before_action :set_document, only: [:show, :edit, :summary, :update, :destroy, :download]

  def new
    @document = Document.new(advocate_id: current_user.persona.id)
  end

  def create
    @document = Document.create(document_params)

    respond_with @document
  end

  def show
    send_file Paperclip.io_adapters.for(@document.document).path,
      type:        @document.document_content_type,
      filename:    @document.document_file_name,
      disposition: 'inline'
  end

  def download
    send_file Paperclip.io_adapters.for(@document.document).path,
      type:        @document.document_content_type,
      filename:    @document.document_file_name,
      x_sendfile:  true
  end

  def update
  end

  def destroy
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(
      :document,
      :notes,
      :document_type_id
    )
  end
end
