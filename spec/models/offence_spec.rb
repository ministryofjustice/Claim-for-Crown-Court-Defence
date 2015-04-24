require 'rails_helper'

RSpec.describe Offence, type: :model do
  it { should have_many(:claims) }

  it { should validate_presence_of(:offence_class) }
  it { should validate_inclusion_of(:offence_class).in_array(('A'..'J').to_a) }
  it { should validate_presence_of(:description) }
  it { should validate_uniqueness_of(:description) }
end
