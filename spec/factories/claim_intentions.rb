# == Schema Information
#
# Table name: claim_intentions
#
#  id         :integer          not null, primary key
#  form_id    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

FactoryBot.define do
  factory :claim_intention do
    form_id SecureRandom.uuid
  end
end
