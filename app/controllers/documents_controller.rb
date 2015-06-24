class DocumentsController < ApplicationController
  load_and_authorize_resource
  respond_to :html
  before_action :set_document, only: [:show, :edit, :summary, :update, :destroy, :download]

  def show
    send_file Paperclip.io_adapters.for(@document.converted_preview_document).path, view_or_download_file(:view)
  end

  def download
    send_file Paperclip.io_adapters.for(@document.document).path, view_or_download_file(:download)
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
      :notes,
      :document_type_id
    )
  end

end
