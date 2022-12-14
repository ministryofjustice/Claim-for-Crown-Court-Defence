# == Schema Information
#
# Table name: case_worker_claims
#
#  id             :integer          not null, primary key
#  case_worker_id :integer
#  claim_id       :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe CaseWorkerClaim do
  it { should belong_to(:claim) }
  it { should belong_to(:case_worker) }
end
