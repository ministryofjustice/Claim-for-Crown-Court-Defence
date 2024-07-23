class DocumentsController < ApplicationController
  include ActiveStorage::SetCurrent

  respond_to :html
  before_action :document, only: %i[show destroy]

  def index
    return render json: [] if params[:form_id].blank?
    render json: Document.where(form_id: params[:form_id])
  end

  def show
    raise ActiveRecord::RecordNotFound, 'Preview not found' unless document.converted_preview_document.attached?

    redirect_to document.converted_preview_document.rails_blob_path(message.attachment, disposition: 'attachment'),
                allow_other_host: true
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
