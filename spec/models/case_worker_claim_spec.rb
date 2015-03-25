require 'rails_helper'

RSpec.describe CaseWorkerClaim, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:case_worker) }
end
