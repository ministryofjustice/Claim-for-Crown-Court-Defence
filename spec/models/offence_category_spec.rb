require 'rails_helper'

RSpec.describe OffenceCategory, type: :model do
  it { should have_many(:offence_bands) }
end
