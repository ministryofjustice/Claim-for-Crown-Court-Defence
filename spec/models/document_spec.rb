require 'rails_helper'

RSpec.describe Document, type: :model do
  subject { build(:document) }
  it { should belong_to(:claim) }


  #it { should validate_presence_of(:claim) }
  #it { should validate_presence_of(:description) }
  #it { should validate_presence_of(:document) }
end
