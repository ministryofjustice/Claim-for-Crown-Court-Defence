class DocumentsController < ApplicationController
  respond_to :html
  before_action :set_document, only: [:show, :edit, :summary, :update, :destroy, :download]

  def new
    @document = Document.new
  end

  def create
    @document = Document.create(document_params)

    respond_with @document
  end

  def show
    send_file @document.path_to_pdf_duplicate, type: 'application/pdf', disposition: 'inline'
  end

  def download
    send_file @document.document.path, type: @document.document_content_type, x_sendfile: true
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
