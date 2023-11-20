# frozen_string_literal: true

require_relative '../../shared_examples_for_base_count_query'

RSpec.describe Stats::ManagementInformation::Queries::LGFS::LF2RedeterminationQuery do
  it_behaves_like 'a base count query', 'LGFS'

  it_behaves_like 'an originally_submitted_at filterable query' do
    # [submitted, allocated, refused] and [redetermination] today
    let(:claim) do
      create(:litigator_final_claim, :refused, disk_evidence: false).tap do |claim|
        claim.update!(total: 19_999)
        claim.redetermine!
      end
    end
  end

  it_behaves_like 'a completed_at filterable query' do
    # [submitted, allocated, refused] and [redetermination, allocated, refused] today
    let(:claim) do
      create(:litigator_final_claim, :refused, disk_evidence: false).tap do |claim|
        claim.update!(total: 19_999)
        claim.redetermine!
        claim.allocate!
        claim.refuse!
      end
    end
  end
end
