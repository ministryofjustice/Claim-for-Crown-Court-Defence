class MessageDocumentsController < ApplicationController

  def create
    binding.pry
    @document = MessageDocument.new(document_params.merge(creator_id: current_user.id))

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

end
