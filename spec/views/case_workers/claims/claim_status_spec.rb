RSpec.describe 'case_workers/claims/_claim_status.html.haml' do
  subject { rendered }

  let(:case_worker) { create(:case_worker) }

  before do
    initialize_view_helpers(view)
    sign_in(case_worker.user, scope: :user)
    allow(view).to receive(:current_user_persona_is?).and_return(false)
  end

  context 'with reject/refuse reasons' do
    let(:claim) { create(:allocated_claim) }

    context 'when the claim was created before messaging feature released' do
      let(:reason_code) { %w[no_amend_rep_order] }

      before do |example|
        travel_to(Settings.reject_refuse_messaging_released_at - 1) do
          claim.reject!(reason_code:, reason_text: 'rejecting because...')
        end

        if example.metadata[:legacy]
          allow_any_instance_of(ClaimStateTransition).to receive(:reason_code).and_return('wrong_case_no')
        end

        assign(:message, claim.messages.build)
        assign(:claim, claim)
        render
      end

      it { is_expected.to have_content('Reason provided:') }
      it { is_expected.to have_css('li', text: 'No amending representation order') }

      context 'with multiple reasons' do
        let(:reason_code) { %w[no_amend_rep_order case_still_live other] }

        it { is_expected.to have_content('Reasons provided:') }
        it { is_expected.to have_css('li', text: 'No amending representation order') }
        it { is_expected.to have_css('li', text: 'Case still live') }
        it { is_expected.to have_css('li', text: 'Other (rejecting because...)') }
      end

      context 'with legacy cases with non-array reason codes', :legacy do
        it { is_expected.to have_css('li', text: 'Incorrect case number') }
      end
    end
  end
end
