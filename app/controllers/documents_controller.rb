class DocumentsController < ApplicationController
  respond_to :html
  before_action :set_document, only: [:show, :edit, :summary, :update, :destroy, :download]

  def new
    @document = Document.new
  end

  def create
    @document = Document.create!(document_params)

    respond_with @document
  end

  def show
  end

  def download
    redirect_to @document.document.expiring_url(30)
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
      :document
    )
  end
end
