# frozen_string_literal: true

require_relative '../../shared_examples_for_base_count_query'

RSpec.describe Stats::ManagementInformation::Queries::AGFS::AF1HighValueQuery do
  it_behaves_like 'a base count query', 'AGFS'

  it_behaves_like 'an originally_submitted_at filterable query' do
    let(:claim) do
      create(:advocate_final_claim, :submitted).tap do |claim|
        claim.update!(total: 20_000)
      end
    end
  end

  it_behaves_like 'a completed_at filterable query' do
    let(:claim) do
      create(:advocate_final_claim, :refused).tap do |claim|
        claim.update!(total: 20_000)
      end
    end
  end
end
