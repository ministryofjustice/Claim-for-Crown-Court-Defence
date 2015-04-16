require 'rails_helper'

RSpec.describe Document, type: :model do
  it { should belong_to(:claim) }
  it { should have_attached_file(:document) }
  it { should validate_attachment_presence(:document) }

  it do
    should validate_attachment_content_type(:document).
      allowing('application/pdf',
               'application/msword',
               'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
               'application/vnd.oasis.opendocument.text',
               'text/rtf',
               'application/rtf').
      rejecting('text/plain',
                'text/html')
  end

  #it { should validate_presence_of(:claim) }
  #it { should validate_presence_of(:description) }
  #it { should validate_presence_of(:document) }
end
