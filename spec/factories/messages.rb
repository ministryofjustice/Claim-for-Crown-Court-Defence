# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  subject                 :string
#  body                    :text
#  claim_id                :integer
#  sender_id               :integer
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#

FactoryGirl.define do
  factory :message do
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    claim

    after(:build) do |message|
      message.sender_id = create(:user, email: Faker::Internet.email, password: 'password', password_confirmation: 'password').id
    end
  end

  factory :unpersisted_message, class: Message do
    subject         { Faker::Lorem.sentence }
    body            { Faker::Lorem.paragraph }
    claim           { FactoryGirl.build :unpersisted_claim }
    sender          { FactoryGirl.build :user }
  end

  trait :with_attachment do
    attachment { File.open(Rails.root + 'features/examples/shorter_lorem.docx')}
    attachment_content_type { 'application/msword' }
  end
end
