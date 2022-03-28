# frozen_string_literal: true

require_relative '../shared_examples_for_base_count_query'

RSpec.describe Stats::ManagementInformation::AGFS::WrittenReasonsQuery do
  it_behaves_like 'a base count query', 'AGFS'

  it_behaves_like 'an originally_submitted_at filterable query' do
    # [submitted, allocated, refused] and [awaiting_written_reasons] today
    let(:claim) do
      create(:advocate_final_claim, :refused).tap(&:await_written_reasons!)
    end
  end

  it_behaves_like 'a completed_at filterable query' do
    # [submitted, allocated, refused] and [awaiting_written_reasons allocated, refused] today
    let(:claim) do
      create(:advocate_final_claim, :refused).tap do |claim|
        claim.await_written_reasons!
        claim.allocate!
        claim.refuse!
      end
    end
  end
end
