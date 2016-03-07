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
#

class DocumentsController < ApplicationController
  respond_to :html
  before_action :set_document, only: [:show, :download, :destroy]

  def index
    return render json: [] if params[:form_id].blank?
    render json: Document.where(form_id: params[:form_id])
  end

  def show
    send_file Paperclip.io_adapters.for(@document.converted_preview_document).path, view_or_download_file(:view)
  end

  def download
    send_file Paperclip.io_adapters.for(@document.document).path, view_or_download_file(:download)
  end

  def create
    @document = Document.new(document_params.merge(creator_id: current_user.id))

    if @document.save
      render json: { document: @document.reload }, status: :created
    else
      render json: { error: @document.errors[:document].join(', ') }, status: 400
    end
  end

  def destroy
    if @document.destroy
      respond_to do |format|
        format.json { render json: { message: 'Document removed', document: @document } }
        format.js
      end
    else
      respond_to do |format|
        format.json { render json: { message: @document.errors.full_messages.join(', '), document: @document } }
        format.js
      end
    end
  end

  private

  def view_or_download_file(option)
    file_opts = {}

    case option
      when :view
        file_opts.merge!({
          type:        @document.converted_preview_document_content_type,
          filename:    @document.converted_preview_document_file_name,
          disposition: 'inline'
        })
      when :download
        file_opts.merge!({
          type:        @document.document_content_type,
          filename:    @document.document_file_name,
          x_sendfile:  true
        })
    end

    file_opts
  end

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(
      :document,
      :form_id,
      :creator_id
    )
  end
end
