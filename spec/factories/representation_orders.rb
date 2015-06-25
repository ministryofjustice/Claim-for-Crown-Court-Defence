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
#  granting_body                           :string(255)
#  maat_reference                          :string(255)
#  representation_order_date               :date
#

FactoryGirl.define do
  factory :representation_order do
    # document                            { File.open(Rails.root + 'features/examples/longer_lorem.pdf') }
    representation_order_date           { Time.now }
    maat_reference                      { Faker::Lorem.characters(10).upcase }
    granting_body                       { Settings.court_types[ randomly_0_or_1 ] }
  end
end



def randomly_0_or_1
  Time.now.to_i % 2
end
