require 'rails_helper'

RSpec.describe Claims::FetchEligibleOffences, type: :service do
  subject(:offences) { described_class.for(claim) }

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
    let(:claim) { create(:advocate_claim) }

    context 'and AGFS fee reform feature is not active' do
      before do
        allow(FeatureFlag).to receive(:active?).with(:agfs_fee_reform).and_return(false)
      end

      include_examples 'a claim with default offences'
    end

    context 'and AGFS fee reform feature is active' do
      before do
        allow(FeatureFlag).to receive(:active?).with(:agfs_fee_reform).and_return(true)
      end

      context 'and fee scheme for the claim is not the AGFS reform scheme' do
        before do
          allow(claim).to receive(:fee_scheme).and_return('default')
        end

        include_examples 'a claim with default offences'
      end

      context 'and fee scheme for the claim is the AGFS reform scheme' do
        before do
          allow(claim).to receive(:fee_scheme).and_return('fee_reform')
        end

        it 'TODO: returns the eligible offences' do
          expect(offences).to match_array([:todo])
        end
      end
    end
  end
end
