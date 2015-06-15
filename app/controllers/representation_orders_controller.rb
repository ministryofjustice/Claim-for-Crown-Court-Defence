class RepresentationOrdersController < ApplicationController
  # load_and_authorize_resource
  respond_to :html
  before_action :set_rep_order, only: [:show, :download]

 
  def show
    send_file Paperclip.io_adapters.for(@rep_order.converted_preview_document).path,
      type:        @rep_order.converted_preview_document_content_type,
      filename:    @rep_order.converted_preview_document_file_name,
      disposition: 'inline'
  end

  def download
    send_file Paperclip.io_adapters.for(@rep_order.document).path,
      type:        @rep_order.document_content_type,
      filename:    @rep_order.document_file_name,
      x_sendfile:  true
  end

 
  private

  def set_rep_order
    @rep_order = RepresentationOrder.find(params[:id])
  end

  def document_params
    params.require(:document).permit(
      :document
    )
  end

end