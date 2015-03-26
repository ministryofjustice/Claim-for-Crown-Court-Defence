require 'rails_helper'

RSpec.describe Defendant, type: :model do
  it { should belong_to(:claim) }

  it { should validate_presence_of(:claim) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:date_of_birth) }
end
