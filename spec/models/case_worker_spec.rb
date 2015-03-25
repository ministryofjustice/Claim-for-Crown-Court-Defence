require 'rails_helper'

RSpec.describe CaseWorker, type: :model do
  it { should have_many(:case_worker_claims) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
end
