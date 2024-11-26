RSpec.describe 'Caseworker summary page' do
  describe 'GET /case_workers/claims/12' do
    describe 'display offence band' do

    context 'when a litigator is submitting a claim - fee scheme 9' do
      subject(:claim) { create(:litigator_claim, :lgfs_scheme_9) }

      it 'displays the offence band ' do
        expect(claim.offence.display_offence_band_or_offence_class).to eq('ABC')
      end

      it 'does not display class' do
        expect(claim.offence.display_offence_band_or_offence_class).to eq('ABC')
      end
    end
    end

    RSpec.describe 'Caseworker summary page', type: :request do
      describe 'GET /case_workers/claims/:id' do
        let(:claim) { create(:litigator_claim, :lgfs_scheme_9) }

        context 'when a litigator is submitting a claim - fee scheme 9' do
          before do
            get "/case_workers/claims/#{claim.id}"
          end

          it 'displays the offence band' do
            expect(response.body).to include('ABC')
          end

          it 'does not display the offence class' do
            expect(response.body).not_to include('Offence Class')
          end
        end
      end
    end



  #
  #   context 'Advocate is submitting a claim fee scheme 9' do
  #     let(:offence) {
  #       create(
  #         :offence, with_fee_scheme_nine,
  #         :offence_class, :with_lgfs_offence
  #       )
  #     }
  #   subject(:claim) { create(:advocate_claim, :offence) }
  #
  #   end
  #
  #   context ' FROM Fee scheme 10 onwards then their will be a band' do
  #
  #   end
  #
  #   context 'No band has been provided' do
  #
  #   end
  #
  #   context 'Not offence class has been provided '
  # end
  #
  # describe 'display offence class' do
  #   # the reverse
  #   # lgfs and agfs 9 will have a class
  #   # agfs onwards wont
  # end
end
