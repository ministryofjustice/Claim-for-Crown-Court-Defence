# == Schema Information
#
# Table name: dates_attended
#
#  id         :integer          not null, primary key
#  date       :datetime
#  fee_id     :integer
#  created_at :datetime
#  updated_at :datetime
#  date_to    :datetime
#

require 'rails_helper'

RSpec.describe DateAttended, type: :model do
  it { should belong_to(:fee) }
  it { should validate_presence_of(:date) }
end
