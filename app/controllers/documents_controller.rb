class DocumentsController < ApplicationController
  include ActiveStorage::SetCurrent

  respond_to :html
  before_action :document, only: %i[show download destroy]

  def index
    return render json: [] if params[:form_id].blank?
    render json: Document.where(form_id: params[:form_id])
  end

  def show
    raise ActiveRecord::RecordNotFound, 'Preview not found' unless document.converted_preview_document.attached?

    redirect_to document.converted_preview_document.blob.url(disposition: :inline), allow_other_host: true
  end

  def download
    redirect_to document.document.blob.url(disposition: :attachment), allow_other_host: true
  end

  def create
    @document = Document.new(document_params.merge(creator_id: current_user.id))

    if @document.save_and_verify
      render json: { document: { id: @document.id, filename: @document.document.filename } }, status: :created
    else
      render json: { error: @document.errors[:document].join(', ') }, status: :unprocessable_entity
    end
  end

  def destroy
    if document.destroy
      respond_to do |format|
        format.json { render json: { message: 'Document removed', document: } }
        format.js
      end
    else
      respond_to do |format|
        format.json { render json: { message: document.errors.full_messages.join(', '), document: } }
        format.js
      end
    end
  end

  def upload
    @document = Document.new(creator_id: current_user.id, document: params[:documents])

    if @document.save_and_verify
      render_success_response
    else
      render_error_response
    end
  end

  def delete
    # TODO: This does not do any checking to see if the document is owned by the current user
    @document = Document.find(params[:delete])

    @document.destroy

    render json: { file: { filename: params[:delete] } }
  end

  def render_success_response
    render json: {
      file: {
        originalname: @document.document.filename,
        filename: @document.id
      },
      success: {
        messageHtml: "#{@document.document.filename} uploaded"
      }
    }, status: :created
  end

  def render_error_response
    render json: {
      error: {
        message: "#{@document.document.filename} #{@document.errors[:document].join(', ')}"
      }
    }, status: :accepted
  end

  private

  def document
    @document ||= Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(
      :document,
      :form_id,
      :creator_id
    )
  end
end
