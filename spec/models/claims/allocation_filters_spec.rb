require 'rails_helper'

module Claims
  describe AllocationFilters do
    include DatabaseHousekeeping

    context 'fixed and graduated scopes' do
      before(:all) do
        fft = create :fixed_fee_type, unique_code: 'FXACV'
        gft = create :graduated_fee_type, unique_code: 'GRTRL'
        ctf1 = create :case_type, :fixed_fee, fee_type_code: fft.unique_code
        ctg1 = create :case_type, :graduated_fee, fee_type_code: gft.unique_code

        @claim_fixed_1 = create :claim, case_type: ctf1
        @claim_fixed_2 = create :claim, case_type: ctf1
        @claim_grad_1 = create :claim, case_type: ctg1
        @claim_grad_2 = create :claim, case_type: ctg1
      end

      after(:all) do
        clean_database
      end

      describe 'all_fixed_fee' do
        it 'returns all claims with fixed fee case types' do
          expect(Claim::BaseClaim.all_fixed_fee).to match_array([@claim_fixed_1, @claim_fixed_2])
        end
      end

      describe 'all_graduated_fees' do
        it 'returns all claims with graduated fee case types' do
          expect(Claim::BaseClaim.all_graduated_fees).to match_array([@claim_grad_1, @claim_grad_2])
        end
      end
    end
  end
end
