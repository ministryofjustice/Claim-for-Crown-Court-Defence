require 'rails_helper'

RSpec.describe Claims::FetchEligibleOffences, type: :service do
  subject(:offences) { described_class.for(claim) }

  shared_examples_for 'a claim with default offences' do
    context 'when the claim has no associated offence' do
      before do
        claim.offence = nil
      end

      it 'returns a list of scheme 9 offences' do
        expect(offences).to match_array(Offence.in_scheme_nine)
      end
    end

    context 'when the claim has an associated offence' do
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
    context 'with claim fee scheme AGFS 9' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_9) }

      include_examples 'a claim with default offences'
    end

    context 'with claim fee scheme of AGFS reform (scheme 10)' do
      before { create(:offence, :with_fee_scheme_ten) }

      let(:claim) { create(:advocate_claim, :agfs_scheme_10) }

      it 'returns all AGFS 10 offences' do
        expect(offences).to match_array(Offence.in_scheme_ten)
      end
    end

    context 'with claim fee scheme of AGFS 11' do
      before { create(:offence, :with_fee_scheme_eleven) }

      let(:claim) { create(:advocate_claim, :agfs_scheme_11) }

      it 'returns all AGFS 11 offences' do
        expect(offences).to match_array(Offence.in_scheme_eleven)
      end
    end

    context 'with claim fee scheme of AGFS 12' do
      before { create(:offence, :with_fee_scheme_twelve) }

      let(:claim) { create(:advocate_claim, :agfs_scheme_12) }

      it 'returns all AGFS 12 offences' do
        expect(offences).to match_array(Offence.in_scheme_twelve)
      end
    end
  end
end
