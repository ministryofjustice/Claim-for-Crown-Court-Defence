require 'rails_helper'

RSpec.describe OffenceBand, type: :model do
  it { should belong_to(:offence_category) }
end
