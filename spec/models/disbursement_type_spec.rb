# == Schema Information
#
# Table name: disbursement_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe DisbursementType, type: :model do
  it { should have_many(:disbursements) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
