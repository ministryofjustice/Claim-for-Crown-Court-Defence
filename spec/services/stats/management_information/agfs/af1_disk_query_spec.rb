# frozen_string_literal: true

require_relative '../shared_examples_for_journey_queryable'
require_relative '../shared_examples_for_base_count_query'

RSpec.describe Stats::ManagementInformation::AGFS::Af1DiskQuery do
  it_behaves_like 'a base count query', 'AGFS'

  it_behaves_like 'an originally_submitted_at filterable query' do
    let(:claim) do
      create(:advocate_final_claim,
             :submitted,
             disk_evidence: true)
    end
  end

  it_behaves_like 'a completed_at filterable query' do
    let(:claim) do
      create(:advocate_final_claim,
             :refused,
             disk_evidence: true)
    end
  end
end
