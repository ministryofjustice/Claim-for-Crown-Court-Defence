# frozen_string_literal: true

module ActiveStorage::SetBlob # :nodoc:
  extend ActiveSupport::Concern

  included do
    before_action :set_blob
  end

  private
    def set_blob
      File.open(File.expand_path('tmp/junk.txt', Rails.root), 'w') do |file|
        file.puts "Signed id from param:   #{params[:signed_id]}"
        file.puts "Signed id of last blob: #{ActiveStorage::Blob.last.signed_id}"
      end
      @blob = blob_scope.find_signed!(params[:signed_blob_id] || params[:signed_id])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      head :not_found
    end

    def blob_scope
      ActiveStorage::Blob
    end
end