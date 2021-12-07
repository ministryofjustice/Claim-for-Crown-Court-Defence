# frozen_string_literal: true

require_relative '../shared_examples_for_base_count_query'

RSpec.describe Stats::ManagementInformation::Agfs::IntakeFixedFeeQuery do
  it_behaves_like 'a base count query'

  it_behaves_like 'an originally_submitted_at filterable query' do
    let(:claim) do
      create(:advocate_final_claim,
             :submitted,
             case_type: build(:case_type, :appeal_against_conviction))
    end
  end

  it_behaves_like 'a completed_at filterable query' do
    let(:claim) do
      create(:advocate_final_claim,
             :refused,
             case_type: build(:case_type, :appeal_against_conviction))
    end
  end
end
