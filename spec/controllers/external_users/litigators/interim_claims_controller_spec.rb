require 'rails_helper'

RSpec.describe ExternalUsers::Litigators::InterimClaimsController do
  before { sign_in litigator.user }

  let!(:litigator)    { create(:external_user, :litigator) }

  describe 'GET #new' do
    before { get :new }

    it 'returns http success' do
      expect(response).to be_successful
    end

    it 'assigns @claim' do
      expect(assigns(:claim)).to be_new_record
    end

    it 'assigns @claim to be a interim claim' do
      expect(assigns(:claim)).to be_instance_of Claim::InterimClaim
    end

    it 'routes to litigators interim new claim path' do
      expect(request.path).to eq('/litigators/interim_claims/new')
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'when litigator signed in' do
      context 'when the input is valid' do
        let(:court) { create(:court) }
        let(:offence) { create(:offence, :miscellaneous) }
        let(:case_type) { create(:case_type, :hsts, roles: %w[lgfs interim]) }
        let(:supplier_number) { litigator.provider.lgfs_supplier_numbers.first.supplier_number }
        let(:claim_params) do
          {
            external_user_id: litigator.id,
            additional_information: 'foo',
            supplier_number:,
            court_id: court,
            case_type_id: case_type.id,
            offence_id: offence,
            case_number: 'A20161234',
            defendants_attributes: [
              {
                first_name: 'John',
                last_name: 'Smith',
                date_of_birth_dd: '4',
                date_of_birth_mm: '10',
                date_of_birth_yyyy: '1980',
                representation_orders_attributes: [
                  {
                    representation_order_date_dd: Time.zone.now.day.to_s,
                    representation_order_date_mm: Time.zone.now.month.to_s,
                    representation_order_date_yyyy: Time.zone.now.year.to_s,
                    maat_reference: '4561237'
                  }
                ]
              }
            ]
          }
        end

        context 'when creating draft' do
          it 'creates a claim' do
            expect { post :create, params: { claim: claim_params } }.to change(Claim::InterimClaim, :count).by(1)
          end

          it 'redirects to claims list' do
            post :create, params: { claim: claim_params }
            expect(response).to redirect_to(external_users_claims_path)
          end

          it 'sets the claim\'s state to "draft"' do
            post :create, params: { claim: claim_params }
            expect(Claim::InterimClaim.active.first).to be_draft
          end
        end

        context 'when submitting to LAA' do
          subject(:create_claim) { post :create, params: { claim: claim_params, commit_submit_claim: 'Submit to LAA' } }

          it 'creates a claim' do
            expect { create_claim }.to change(Claim::InterimClaim, :count).by(1)
          end

          it 'redirects to claim summary if no validation errors present' do
            create_claim
            expect(response).to redirect_to(summary_external_users_claim_path(Claim::InterimClaim.active.first))
          end

          it 'leaves the claim\'s state in "draft"' do
            create_claim
            expect(Claim::InterimClaim.active.first).to be_draft
          end
        end

        context 'with multi-step form submit to LAA' do
          let(:case_number) { 'A20168888' }
          let(:interim_fee_type) { create(:interim_fee_type, :effective_pcmh) }

          let(:interim_fee_params) do
            {
              interim_fee_attributes: {
                fee_type_id: interim_fee_type.id,
                quantity: 2,
                amount: 10.0
              },
              effective_pcmh_date_dd: 5.days.ago.day.to_s,
              effective_pcmh_date_mm: 5.days.ago.month.to_s,
              effective_pcmh_date_yyyy: 5.days.ago.year.to_s
            }
          end

          let(:claim_params_step1) do
            {
              external_user_id: litigator.id,
              supplier_number:,
              court_id: court,
              case_type_id: case_type.id,
              offence_id: offence,
              case_number:,
              defendants_attributes: [
                {
                  first_name: 'John',
                  last_name: 'Smith',
                  'date_of_birth(3i)': '4',
                  'date_of_birth(2i)': '10',
                  'date_of_birth(1i)': '1980',
                  representation_orders_attributes: [
                    {
                      'representation_order_date(3i)': Time.zone.now.day.to_s,
                      'representation_order_date(2i)': Time.zone.now.month.to_s,
                      'representation_order_date(1i)': Time.zone.now.year.to_s,
                      maat_reference: '4561237'
                    }
                  ]
                }
              ]
            }
          end

          let(:subject_claim) { Claim::InterimClaim.where(case_number:).first }

          context 'with step 1 continue' do
            render_views
            before do
              post :create, params: { commit_continue: 'Continue', claim: claim_params_step1 }
            end

            it 'leaves claim in draft state' do
              expect(subject_claim.draft?).to be_truthy
            end

            it { expect(response).to redirect_to edit_litigators_interim_claim_path(subject_claim, step: :defendants) }
          end

          context 'with step 2 submit to LAA' do
            let(:claim_params_step2) do
              {
                form_step: 'defendants',
                additional_information: 'foo'
              }.merge(interim_fee_params)
            end

            before do
              post :create, params: { commit_continue: 'Continue', claim: claim_params_step1 }
              put(
                :update,
                params: { id: subject_claim, commit_submit_claim: 'Submit to LAA', claim: claim_params_step2 }
              )
            end

            it { expect(subject_claim.draft?).to be_truthy }
            it { expect(response).to redirect_to(summary_external_users_claim_path(subject_claim)) }
            it { expect(subject_claim.interim_fee).not_to be_nil }
            it { expect(subject_claim.interim_fee.quantity).to eq 2 }
            it { expect(subject_claim.interim_fee.amount).to eq 10.00 }
          end
        end
      end

      context 'when submitting to LAA with incomplete/invalid params' do
        let(:invalid_claim_params) { { advocate_category: 'QC' } }

        it 'does not create a claim' do
          expect do
            post :create, params: { claim: invalid_claim_params, commit_submit_claim: 'Submit to LAA' }
          end.not_to change(Claim::InterimClaim, :count)
        end

        it 'renders the new template' do
          post :create, params: { claim: invalid_claim_params, commit_submit_claim: 'Submit to LAA' }
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:edit_request) { -> { get :edit, params: { id: claim } } }

    before { edit_request.call }

    context 'with an editable claim' do
      let(:claim) { create(:interim_claim, creator: litigator) }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @claim' do
        expect(assigns(:claim)).to eq(claim)
      end

      it 'claim is in the first submission step by default' do
        expect(assigns(:claim).form_step).to eq(claim.submission_stages.first.to_sym)
      end

      context 'when a step is provided' do
        let(:edit_request) { -> { get :edit, params: { id: claim, step: :defendants } } }

        it 'claim is submitted submission step' do
          expect(assigns(:claim).form_step).to eq(:defendants)
        end
      end

      it 'routes to litigators edit path' do
        expect(request.path).to eq edit_litigators_interim_claim_path(claim)
      end

      it 'renders the template' do
        expect(response).to render_template(:edit)
      end
    end

    context 'with an uneditable claim' do
      let(:claim) { create(:interim_claim, :allocated, :interim_effective_pcmh_fee, creator: litigator) }

      it 'redirects to the claims index' do
        expect(response).to redirect_to(external_users_claims_path)
      end
    end
  end

  describe 'PUT #update' do
    subject(:update_claim) { put :update, params: }

    let(:claim) { create(:interim_claim, :interim_effective_pcmh_fee, creator: litigator) }

    context 'when valid' do
      context 'when deleting a rep order' do
        let(:params) do
          {
            id: claim,
            claim: {
              defendants_attributes: {
                '1' => {
                  id: claim.defendants.first,
                  representation_orders_attributes: {
                    '0' => { id: claim.defendants.first.representation_orders.first, _destroy: 1 }
                  }
                }
              }
            }
          }
        end

        before { update_claim }

        it 'reduces the number of associated rep orders by 1' do
          expect(claim.reload.defendants.first.representation_orders.count).to eq 1
        end
      end

      context 'when saving to draft' do
        let(:params) { { id: claim, claim: { additional_information: 'foo' } } }

        before { update_claim }

        it 'updates a claim' do
          expect(claim.reload.additional_information).to eq('foo')
        end

        it 'redirects to claims list path' do
          expect(response).to redirect_to(external_users_claims_path)
        end
      end

      context 'when submitted to LAA' do
        let(:params) do
          { id: claim, claim: { additional_information: 'foo' }, summary: true, commit_submit_claim: 'Submit to LAA' }
        end

        before do
          get :edit, params: { id: claim }
          update_claim
        end

        it 'redirects to the claim summary page' do
          expect(response).to redirect_to(summary_external_users_claim_path(claim))
        end
      end
    end

    context 'when submitted to LAA and invalid' do
      let(:params) do
        { id: claim, claim: { additional_information: 'foo', court_id: nil }, commit_submit_claim: 'Submit to LAA' }
      end

      before { update_claim }

      it { expect(claim.reload).not_to be_submitted }
      it { expect(response).to render_template(:edit) }
    end

    describe 'Date Parameter handling' do
      before do
        put :update, params: {
          id: claim,
          claim: date_params,
          commit_submit_claim: 'Submit to LAA'
        }
      end

      context 'when there are invalid dates' do
        let(:date_params) do
          {
            'first_day_of_trial(1i)' => '2014',
            'first_day_of_trial(2i)' => 'JAN',
            'first_day_of_trial(3i)' => '4'
          }
        end

        it { expect(assigns(:claim).first_day_of_trial).to be_nil }
      end

      context 'with numbered months' do
        let(:date_params) do
          {
            'first_day_of_trial(1i)' => '2014',
            'first_day_of_trial(2i)' => '11',
            'first_day_of_trial(3i)' => '4'
          }
        end

        it { expect(assigns(:claim).first_day_of_trial).to eq Date.new(2014, 11, 4) }
      end
    end
  end
end
