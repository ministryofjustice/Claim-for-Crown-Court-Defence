RSpec.describe 'Caseworker summary page', type: :request do
  describe 'GET /case_workers/claims/12' do
    describe 'Offence details segment' do
      before do
        @case_worker = create(:case_worker)
        sign_in @case_worker.user
        get case_workers_claim_url(claim.id)
      end

      let(:offence_class_numbers) { /^[0-9.]*$/ }
      let(:offence_band_letters) {/^[A-Z]+$/}

      context 'when a litigator has submitted a claim with fee scheme 9' do
        let(:claim) { create(:litigator_claim, :lgfs_scheme_9) }

        it 'displays the offence class' do
          binding.pry
          expect(response.body).to include(offence_class_numbers)
        end

        it 'does not display offence band' do
          expect(response.body).not_to include(offence_band_letters)
        end
      end

      context 'when a litigator has submitted a claim with fee scheme 10' do
        subject(:claim) { create(:litigator_claim, :lgfs_scheme_10) }

        it 'displays the offence class' do
          expect(response.body).to include(offence_class_numbers)
        end

        it 'does not display offence band' do
          expect(response.body).not_to include(offence_band_letters)
        end
      end

      context 'when an advocate has submitted a claim with fee scheme 9' do
        subject(:claim) { create(:advocate_claim, :agfs_scheme_9) }

        it 'displays the offence class' do
          expect(response.body).to include(offence_class_numbers)
        end

        it 'does not display offence band' do
          expect(response.body).not_to include(offence_band_letters)
        end
      end

      context 'when an advocate has submitted a claim with fee scheme 10' do
        subject(:claim) { create(:advocate_claim, :agfs_scheme_10) }

        it 'displays the offence band ' do
          expect(response.body).to include(offence_band_letters)
        end

        it 'does not display class' do
          expect(response.body).not_to include(offence_class_numbers)
        end
      end

      # context 'when no band or class has been provided' do
      # end
    end
  end
end
