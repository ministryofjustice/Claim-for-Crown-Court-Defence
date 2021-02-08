# == Schema Information
#
# Table name: documents
#
#  id                                      :integer          not null, primary key
#  claim_id                                :integer
#  created_at                              :datetime
#  updated_at                              :datetime
#  document_file_name                      :string
#  document_content_type                   :string
#  document_file_size                      :integer
#  document_updated_at                     :datetime
#  external_user_id                        :integer
#  converted_preview_document_file_name    :string
#  converted_preview_document_content_type :string
#  converted_preview_document_file_size    :integer
#  converted_preview_document_updated_at   :datetime
#  uuid                                    :uuid
#  form_id                                 :string
#  creator_id                              :integer
#  verified_file_size                      :integer
#  file_path                               :string
#  verified                                :boolean          default(FALSE)
#

class DocumentsController < ApplicationController
  respond_to :html
  before_action :document, only: %i[show download destroy]

  def index
    return render json: [] if params[:form_id].blank?
    render json: Document.where(form_id: params[:form_id])
  end

  def show
    redirect_to document.converted_preview_document.blob.service_url(disposition: 'inline')
  end

  def download
    redirect_to document.document.blob.service_url(disposition: 'attachment')
  end

  def create
    Rails.logger.info 'paperclip: Saving Document'

    @document = Document.new(document_params.merge(creator_id: current_user.id))

    if @document.save_and_verify
      render json: { document: { id: @document.id, document_file_name: @document.document.filename } }, status: :created
    else
      render json: { error: @document.errors[:document].join(', ') }, status: :unprocessable_entity
    end
  end

  def destroy
    if document.destroy
      respond_to do |format|
        format.json { render json: { message: 'Document removed', document: document } }
        format.js
      end
    else
      respond_to do |format|
        format.json { render json: { message: document.errors.full_messages.join(', '), document: document } }
        format.js
      end
    end
  end

  private

  def document
    @document ||= Document.find(params[:id])
  end

  def view_file_options
    {
      type: @document.converted_preview_document_content_type,
      filename: @document.converted_preview_document_file_name,
      disposition: 'inline'
    }
  end

  def download_file_options
    {
      type: @document.document_content_type,
      filename: @document.document_file_name,
      x_sendfile: true
    }
  end

  def document_params
    params.require(:document).permit(
      :document,
      :form_id,
      :creator_id
    )
  end
end
