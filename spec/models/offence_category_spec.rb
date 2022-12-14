require 'rails_helper'

RSpec.describe OffenceCategory do
  it { should have_many(:offence_bands) }
end
