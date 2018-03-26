require 'rails_helper'

RSpec.describe OffenceFeeScheme, type: :model do
  it { should belong_to(:offence) }
  it { should belong_to(:fee_scheme) }
end
