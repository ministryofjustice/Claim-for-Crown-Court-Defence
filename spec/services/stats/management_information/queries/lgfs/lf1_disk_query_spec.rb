# frozen_string_literal: true

require_relative '../../shared_examples_for_base_count_query'

RSpec.describe Stats::ManagementInformation::Queries::LGFS::LF1DiskQuery do
  it_behaves_like 'a base count query', 'LGFS'

  it_behaves_like 'an originally_submitted_at filterable query' do
    let(:claim) { create(:litigator_final_claim, :submitted, disk_evidence: true) }
  end

  it_behaves_like 'a completed_at filterable query' do
    let(:claim) { create(:litigator_final_claim, :refused, disk_evidence: true) }
  end
end
