# == Schema Information
#
# Table name: representation_orders
#
#  id                                      :integer          not null, primary key
#  defendant_id                            :integer
#  document_file_name                      :string(255)
#  document_content_type                   :string(255)
#  document_file_size                      :integer
#  document_updated_at                     :datetime
#  converted_preview_document_file_name    :string(255)
#  converted_preview_document_content_type :string(255)
#  converted_preview_document_file_size    :integer
#  converted_preview_document_updated_at   :datetime
#  created_at                              :datetime
#  updated_at                              :datetime
#

FactoryGirl.define do
  factory :representation_order do
    document { File.open(Rails.root + 'features/examples/longer_lorem.pdf') }
  end  
end
