require 'rails_helper'

RSpec.describe ExternalUsers::Litigators::ClaimsController, type: :controller do
  before { sign_in litigator.user }

  let!(:litigator)    { create(:external_user, :litigator) }
  let(:court)         { create(:court) }
  let(:offence)       { create(:offence, :miscellaneous) }
  let(:case_type)     { create(:case_type, :hsts) }
  let(:expense_type)  { create(:expense_type, :car_travel, :lgfs) }
  let(:external_user) { create(:external_user, :litigator, provider: litigator.provider) }
  let(:supplier_number) { litigator.provider.lgfs_supplier_numbers.first.supplier_number }

  describe 'GET #new' do
    context 'LGFS provider members only' do
      before { get :new }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @claim' do
        expect(assigns(:claim)).to be_new_record
      end

      it 'assigns @claim to be a litigator claim' do
        expect(assigns(:claim)).to be_instance_of Claim::LitigatorClaim
      end

      it 'routes to litigators new claim path' do
        expect(request.path).to eq new_litigators_claim_path
      end

      it 'renders the template' do
        expect(response).to render_template(:new)
      end
    end
  end

  def expense_params
    {
      expense_type_id: expense_type.id,
      location: 'London',
      quantity: 1,
      rate: 40,
      reason_id: 1,
      distance: nil,
      amount: 1125.00,
      date_dd: expense_date.day,
      date_mm: expense_date.month,
      date_yyyy: expense_date.year
    }
  end

  describe 'POST #create' do
    context 'when litigator signed in' do
      context 'and the input is valid' do
        let(:expense_type) { create(:expense_type, :train) }
        let(:expense_date) { 10.days.ago }
        let(:claim_params) do
          {
            external_user_id: litigator.id,
            additional_information: 'foo',
            court_id: court,
            case_type_id: case_type.id,
            offence_id: offence,
            case_number: 'A20161234',
            supplier_number: supplier_number,
            case_concluded_at_dd: 5.days.ago.day.to_s,
            case_concluded_at_mm: 5.days.ago.month.to_s,
            case_concluded_at_yyyy: 5.days.ago.year.to_s,
            expenses_attributes: [
              expense_params
            ],
            defendants_attributes: [
              { first_name: 'John',
                last_name: 'Smith',
                date_of_birth_dd: '4',
                date_of_birth_mm: '10',
                date_of_birth_yyyy: '1980',
                representation_orders_attributes: [
                  {
                    representation_order_date_dd: Time.now.day.to_s,
                    representation_order_date_mm: Time.now.month.to_s,
                    representation_order_date_yyyy: Time.now.year.to_s,
                    maat_reference: '4561237'
                  }
                ]
              }
            ]
          }
        end

        context 'create draft' do
          it 'creates a claim' do
            expect {
              post :create, params: { commit_save_draft: 'Save to drafts', claim: claim_params }
            }.to change(Claim::LitigatorClaim, :count).by(1)
          end

          it 'redirects to claims list' do
            post :create, params: { claim: claim_params, commit_save_draft: 'Save to drafts' }
            expect(response).to redirect_to(external_users_claims_path)
          end

          it 'sets the created claim\'s creator/"owner" to the signed in litigator' do
            post :create, params: { claim: claim_params, commit_save_draft: 'Save to drafts' }
            expect(Claim::LitigatorClaim.active.first.creator).to eq(litigator)
          end

          it 'sets the claim\'s state to "draft"' do
            post :create, params: { claim: claim_params, commit_save_draft: 'Save to drafts' }
            expect(Claim::LitigatorClaim.active.first).to be_draft
          end
        end

        context 'submit to LAA' do
          it 'creates a claim' do
            expect {
              post :create, params: { commit_submit_claim: 'Submit to LAA', claim: claim_params }
            }.to change(Claim::LitigatorClaim, :count).by(1)
          end

          it 'redirects to claim summary if no validation errors present' do
            post :create, params: { claim: claim_params, commit_submit_claim: 'Submit to LAA' }
            expect(response).to redirect_to(summary_external_users_claim_path(Claim::LitigatorClaim.active.first))
          end

          it 'leaves the claim\'s state in "draft"' do
            post :create, params: { claim: claim_params, commit_submit_claim: 'Submit to LAA' }
            expect(response).to have_http_status(:redirect)
            expect(Claim::LitigatorClaim.active.first).to be_draft
          end
        end

        context 'multi-step form submit to LAA' do
          let(:case_number) { 'A20168888' }
          let(:case_concluded_at) { 5.days.ago }
          let(:representation_order_date) { case_concluded_at }

          let(:claim_params_step1) do
            {
              external_user_id: litigator.id,
              supplier_number: supplier_number,
              court_id: court,
              case_type_id: case_type.id,
              case_number: case_number,
              case_concluded_at_dd: case_concluded_at.day.to_s,
              case_concluded_at_mm: case_concluded_at.month.to_s,
              case_concluded_at_yyyy: case_concluded_at.year.to_s
            }
          end

          let(:claim_params_step2) do
            {
              form_step: :defendants,
              defendants_attributes: [
                {
                  first_name: 'John',
                  last_name: 'Smith',
                  date_of_birth_dd: '4',
                  date_of_birth_mm: '10',
                  date_of_birth_yyyy: '1980',
                  representation_orders_attributes: [
                    {
                        representation_order_date_dd: representation_order_date.day.to_s,
                        representation_order_date_mm: representation_order_date.month.to_s,
                        representation_order_date_yyyy: representation_order_date.year.to_s,
                        maat_reference: '4561237'
                    }
                  ]
                }
              ]
            }
          end

          let(:subject_claim) { Claim::LitigatorClaim.where(case_number: case_number).first }

          it 'validates step fields and move to next steps' do
            post :create, params: { commit_continue: 'Continue', claim: claim_params_step1 }
            expect(subject_claim.draft?).to be_truthy
            expect(subject_claim.valid?).to be_truthy
            expect(response).to redirect_to edit_litigators_claim_path(subject_claim, step: :defendants)

            put :update, params: { id: subject_claim, commit_submit_claim: 'Submit to LAA', claim: claim_params_step2 }
            expect(subject_claim.draft?).to be_truthy
            expect(subject_claim.valid?).to be_truthy
            expect(response).to redirect_to(summary_external_users_claim_path(subject_claim))
          end
        end
      end

      context 'submit to LAA with incomplete/invalid params' do
        let(:invalid_claim_params) { { advocate_category: 'QC' } }
        it 'does not create a claim' do
          expect {
            post :create, params: { claim: invalid_claim_params, commit_submit_claim: 'Submit to LAA' }
          }.to_not change(Claim::LitigatorClaim, :count)
        end

        it 'renders the new template' do
          post :create, params: { claim: invalid_claim_params, commit_submit_claim: 'Submit to LAA' }
          expect(response).to render_template(:new)
        end
      end

      context 'conditional fee logic' do
        let!(:misc_fee_type_1)          { FactoryBot.create :misc_fee_type, description: 'Miscellaneous Fee Type 1' }
        let!(:misc_fee_type_2)          { FactoryBot.create :misc_fee_type, description: 'Miscellaneous Fee Type 2' }
        let!(:fixed_fee_type_1)         { FactoryBot.create :fixed_fee_type, description: 'Fixed Fee Type 1' }
        let!(:graduated_fee_type_1)     { FactoryBot.create :graduated_fee_type, description: 'Graduated Fee Type 1' }

        let(:claim_params)              { valid_claim_fee_params }
        let(:invalid_claim_params)      { valid_claim_fee_params.reject { |k,v| k == 'case_number' } }

        context 'graduated fee case types' do
          context 'valid params' do
            before do
              post :create, params: { claim: claim_params, commit_submit_claim: 'Submit to LAA' }
            end

            it 'should be a redirect' do
              expect(response.status).to eq 302
              # expect(response).to redirect_to summary_external_users_claim_url(assigns(:claim))
            end

            it 'should be a valid claim' do
              expect(assigns(:claim)).to be_valid
            end

            it 'should create the graduated fee' do
              expect(assigns(:claim).graduated_fee).to be_valid
              expect(assigns(:claim).graduated_fee.amount).to eq 2000
            end

            it 'should create the miscellaneous fees' do
              expect(assigns(:claim).misc_fees.size).to eq 2
              expect(assigns(:claim).misc_fees.map(&:amount).sum).to eq 375
            end

            it 'should update claim total to sum of graduated and miscellaneous fees' do
              expect(assigns(:claim).fees_total).to eq 2375.00
            end
          end

          context 'invalid params' do
            render_views

            before do
              post :create, params: { claim: invalid_claim_params, commit_submit_claim: 'Submit to LAA' }
            end

            it 'should redisplay the page' do
              expect(response.status).to eq 200
              expect(response).to render_template(:new)
            end

            it 'should display error messages ' do
              expect(response.body).to have_content('Enter a case number')
            end

            it 'should not persist any of the data' do
              claim = assigns(:claim)
              expect(claim.graduated_fee).to have_attributes(fee_type_id: graduated_fee_type_1.id, quantity: 12, amount: 2000)
              expect(claim.misc_fees.count).to eq 0
            end
          end
        end

        context 'fixed fee case types' do
          context 'valid params' do
            let(:fixed_fee_claim_params) do
              params = claim_params.dup
              params['case_type_id'] = FactoryBot.create(:case_type, :fixed_fee).id.to_s
              params.delete(:graduated_fee_attributes)
              params.merge!(fixed_fee_attributes)
            end

            before do
              post :create, params: { claim: fixed_fee_claim_params, commit_submit_claim: 'Submit to LAA' }
            end

            it 'should be a redirect' do
              expect(response.status).to eq 302
            end

            it 'should create the fixed fee' do
              expect(assigns(:claim).fixed_fee).to be_valid
              expect(assigns(:claim).fixed_fee.amount).to eq 388.30
            end

            it 'should create the miscellaneous fees' do
              expect(assigns(:claim).misc_fees.size).to eq 2
              expect(assigns(:claim).misc_fees.map(&:amount).sum).to eq 375
            end

            it 'should NOT create the graduated fee' do
              expect(assigns(:claim).graduated_fee).to be_nil
            end

            it 'should update claim total to sum of fixed and miscellaneous fees' do
              expect(assigns(:claim).fees_total).to eq 763.30
            end
          end
        end
      end

      context 'document checklist' do
        let(:claim_params) do
          {
             additional_information: 'foo',
             court_id: court,
             case_type_id: case_type.id,
             offence_id: offence,
             case_number: 'A20161234',
             evidence_checklist_ids: ['2', '3', '']
          }
        end

        it 'should create a claim with document checklist items' do
          post :create, params: { claim: claim_params }
          expect(assigns(:claim).evidence_checklist_ids).to eql([2, 3])
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:edit_request) { -> { get :edit, params: { id: claim } } }

    before { edit_request.call }

    context 'editable claim' do
      let(:claim) { create(:litigator_claim, creator: litigator) }

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
        let(:step) { :defendants }
        let(:edit_request) { -> { get :edit, params: { id: claim, step: step } } }

        it 'claim is submitted submission step' do
          expect(assigns(:claim).form_step).to eq(:defendants)
        end
      end

      it 'routes to litigators edit path' do
        expect(request.path).to eq edit_litigators_claim_path(claim)
      end

      it 'renders the template' do
        expect(response).to render_template(:edit)
      end
    end

    context 'uneditable claim' do
      let(:claim) { create(:litigator_claim, :allocated, creator: litigator) }

      it 'redirects to the claims index' do
        expect(response).to redirect_to(external_users_claims_path)
      end
    end
  end

  describe 'PUT #update' do
    subject { create(:litigator_claim, creator: litigator) }

    context 'when valid' do
      context 'and deleting a rep order' do
        before {
          put :update, params: { id: subject, claim: { defendants_attributes: { '1' => { id: subject.defendants.first, representation_orders_attributes: { '0' => { id: subject.defendants.first.representation_orders.first, _destroy: 1 } } } } }, commit_save_draft: 'Save to drafts' }
        }
        it 'reduces the number of associated rep orders by 1' do
          expect(subject.reload.defendants.first.representation_orders.count).to eq 1
        end
      end

      context 'and saving to draft' do
        it 'updates a claim' do
          put :update, params: { id: subject, claim: { additional_information: 'foo' }, commit_save_draft: 'Save to drafts' }
          subject.reload
          expect(subject.additional_information).to eq('foo')
        end

        it 'redirects to claims list path' do
          put :update, params: { id: subject, claim: { additional_information: 'foo' } }
          expect(response).to redirect_to(external_users_claims_path)
        end
      end

      context 'and submitted to LAA' do
        before do
          get :edit, params: { id: subject }
          put :update, params: { id: subject, claim: { additional_information: 'foo' }, summary: true, commit_submit_claim: 'Submit to LAA' }
        end

        it 'redirects to the claim summary page' do
          expect(response).to redirect_to(summary_external_users_claim_path(subject))
        end
      end
    end

    context 'when submitted to LAA and invalid ' do
      it 'does not set claim to submitted' do
        put :update, params: { id: subject, claim: { court_id: nil }, commit_submit_claim: 'Submit to LAA' }
        subject.reload
        expect(subject).to_not be_submitted
      end

      it 'renders edit template' do
        put :update, params: { id: subject, claim: { additional_information: 'foo', court_id: nil }, commit_submit_claim: 'Submit to LAA' }
        expect(response).to render_template(:edit)
      end
    end

    context 'Date Parameter handling' do
      it 'should transform dates with named months into dates' do
        put :update, params: { id: subject, claim: {
          'first_day_of_trial_yyyy' => '2015',
          'first_day_of_trial_mm' => 'jan',
          'first_day_of_trial_dd' => '4' }, commit_submit_claim: 'Submit to LAA' }
        expect(assigns(:claim).first_day_of_trial).to eq Date.new(2015, 1, 4)
      end

      it 'should transform dates with numbered months into dates' do
        put :update, params: { id: subject, claim: {
          'first_day_of_trial_yyyy' => '2015',
          'first_day_of_trial_mm' => '11',
          'first_day_of_trial_dd' => '4' }, commit_submit_claim: 'Submit to LAA' }
        expect(assigns(:claim).first_day_of_trial).to eq Date.new(2015, 11, 4)
      end
    end
  end

  # local helpers
  # -------------------------

  def valid_claim_fee_params
    case_type = FactoryBot.create :case_type

    {
      'source' => 'web',
      'supplier_number' => supplier_number,
      'case_type_id' => case_type.id.to_s,
      'court_id' => court.id.to_s,
      'case_number' => 'A20161234',
      'offence_class_id' => offence.offence_class.id.to_s,
      'offence_id' => offence.id.to_s,
      'first_day_of_trial_dd' => '13',
      'first_day_of_trial_mm' => '5',
      'first_day_of_trial_yyyy' => '2015',
      'estimated_trial_length' => '2',
      'actual_trial_length' => '2',
      'trial_concluded_at_dd' => '15',
      'trial_concluded_at_mm' => '05',
      'trial_concluded_at_yyyy' => '2015',
      'case_concluded_at_dd' => '15',
      'case_concluded_at_mm' => '05',
      'case_concluded_at_yyyy' => '2015',
      'evidence_checklist_ids' => ['1', '5', ''],
      'defendants_attributes' => {
        '0' => {
          'first_name' => 'Stephen',
          'last_name' => 'Richards',
          'date_of_birth_dd' => '13',
          'date_of_birth_mm' => '08',
          'date_of_birth_yyyy' => '1966',
          '_destroy' => 'false',
          'representation_orders_attributes' => {
            '0' => {
              'representation_order_date_dd' => '13',
              'representation_order_date_mm' => '05',
              'representation_order_date_yyyy' => '2015',
              'maat_reference' => '1594851269'
            }
          }
        }
      },
      'additional_information' => '',
      'graduated_fee_attributes' => {
        'fee_type_id' => graduated_fee_type_1.id.to_s, 'quantity' => '12', 'amount' => '2000', 'date_dd' => '15', 'date_mm' => '05', 'date_yyyy' => '2015', '_destroy' => 'false'
      },
      'misc_fees_attributes' => {
        '0' => { 'fee_type_id' => misc_fee_type_1.id.to_s, 'amount' => '125', '_destroy' => 'false' },
        '1' => { 'fee_type_id' => misc_fee_type_2.id.to_s, 'amount' => '250', '_destroy' => 'false' }
      },
      'expenses_attributes' => {
        '0' => { 'expense_type_id' => '', 'location' => '', 'quantity' => '', 'rate' => '', 'amount' => '', '_destroy' => 'false' }
      },
      'apply_vat' => '0'
    }.with_indifferent_access
  end

  def fixed_fee_attributes
    {
      fixed_fee_attributes: {
        fee_type_id: fixed_fee_type_1.id.to_s, quantity: 5, rate: 77.66, amount: nil, date_dd: '15', date_mm: '05', date_yyyy: '2015', _destroy: 'false'
      }
    }.with_indifferent_access
  end
end
