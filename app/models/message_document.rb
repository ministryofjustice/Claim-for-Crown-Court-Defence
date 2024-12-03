class MessageDocument < ApplicationRecord
  belongs_to :message, class_name: 'Message'

  has_one_attached :message_document
  # has_many_attached :attachments

  validates :message_document,
            size: { less_than: 20.megabytes },
            content_type: %w[
              application/pdf
              application/msword
              application/vnd.openxmlformats-officedocument.wordprocessingml.document
              application/vnd.oasis.opendocument.text
              application/vnd.ms-excel
              application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
              application/vnd.oasis.opendocument.spreadsheet
              text/rtf
              application/rtf
              image/jpeg
              image/png
              image/tiff
              image/x-bmp
              image/x-bitmap
            ]


end
