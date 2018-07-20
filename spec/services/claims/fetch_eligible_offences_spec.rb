require 'rails_helper'

RSpec.describe Claims::FetchEligibleOffences, type: :service do
  subject(:offences) { described_class.for(claim) }

  before { seed_fee_schemes }

  shared_examples_for 'a claim with default offences' do
    context 'and the claim has no associated offence' do
      before do
        claim.offence = nil
      end

      it 'returns a list of all available offences' do
        expect(offences).to match_array(Offence.in_scheme_nine)
      end
    end

    context 'and the claim has an associated offence' do
      let(:offence) { create(:offence) }

      before do
        claim.offence = offence
      end

      it 'returns a list containing only the associated offence' do
        expect(offences).to match_array([offence])
      end
    end
  end

  context 'when claim is for LGFS' do
    let(:claim) { create(:litigator_claim) }

    include_examples 'a claim with default offences'
  end

  context 'when claim is for AGFS' do
    context 'and fee scheme for the claim is not the AGFS reform scheme' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_9) }

      include_examples 'a claim with default offences'
    end

    context 'and fee scheme for the claim is the AGFS reform scheme' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

      it 'returns a list of all available offences for the associated fee scheme' do
        expect(offences).to match_array(Offence.in_scheme_ten)
      end
    end
  end
end
