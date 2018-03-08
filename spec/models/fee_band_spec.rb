require 'rails_helper'

RSpec.describe FeeBand, type: :model do
  it { should belong_to(:fee_category) }
end
