require 'rails_helper'

RSpec.describe ExternalUsers::Advocates::ClaimsController, type: :controller do
  let!(:advocate) { create(:external_user, :advocate) }
  before { sign_in advocate.user }

  describe 'GET #new' do
    context 'AGFS or LGFS provider members only' do
      before { get :new }
      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'assigns @claim' do
        expect(assigns(:claim)).to be_new_record
      end

      it 'assigns @claim to be an advocate claim' do
        expect(assigns(:claim)).to be_instance_of Claim::AdvocateClaim
      end

      it 'routes to advocates new claim path' do
        expect(request.path).to eq new_advocates_claim_path
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
      amount: 1125.00,
      date_dd: expense_date.day,
      date_mm: expense_date.month,
      date_yyyy: expense_date.year
    }
  end

  describe 'POST #create' do
    context 'when advocate signed in' do
      context 'and the input is valid' do
        let(:court)         { create(:court) }
        let(:offence)       { create(:offence) }
        let(:case_type)     { create(:case_type) }
        let(:expense_type)  { create(:expense_type, :train) }
        let(:expense_date)  { 10.days.ago }
        let(:claim_params) do
          {
            additional_information: 'foo',
            court_id: court,
            case_type_id: case_type.id,
            offence_id: offence,
            case_number: 'A20161234',
            advocate_category: 'QC',
            expenses_attributes: [expense_params],
            defendants_attributes: [
              {
                first_name: 'John',
                last_name: 'Smith',
                date_of_birth_dd: '4',
                date_of_birth_mm: '10',
                date_of_birth_yyyy: '1980',
                representation_orders_attributes: [
                  {
                    representation_order_date_dd: Time.now.day.to_s,
                    representation_order_date_mm: Time.now.month.to_s,
                    representation_order_date_yyyy: Time.now.year.to_s,
                    maat_reference: '4561237895'
                  }
                ]
              }
            ]
          }
        end

        context 'create draft' do
          before do
            expect(Claim::AdvocateClaim.active.count).to eq(0)
            post :create, params: { commit_save_draft: 'Save to drafts', claim: claim_params }
          end

          it 'creates the claim and sets the state to "draft"' do
            expect(Claim::AdvocateClaim.active.first).to be_draft
          end

          it 'redirects to claims list' do
            expect(response).to redirect_to(external_users_claims_path)
          end

          it 'sets the created claim\'s external_user/"owner" to the signed in advocate' do
            expect(Claim::AdvocateClaim.active.first.external_user).to eq(advocate)
            expect(Claim::AdvocateClaim.active.first.creator).to eq(advocate)
          end
        end

        context 'submit to LAA' do
          it 'creates a claim' do
            expect {
              post :create, params: { commit_submit_claim: 'Submit to LAA', claim: claim_params }
            }.to change(Claim::AdvocateClaim, :count).by(1)
          end

          it 'redirects to claim summary if no validation errors present' do
            post :create, params: { claim: claim_params, commit_submit_claim: 'Submit to LAA' }
            expect(response).to redirect_to(summary_external_users_claim_path(Claim::AdvocateClaim.active.first))
          end

          it 'sets the created claim\'s external_user/owner to the signed in advocate' do
            post :create, params: { claim: claim_params, commit_submit_claim: 'Submit to LAA' }
            expect(Claim::AdvocateClaim.active.first.external_user).to eq(advocate)
            expect(Claim::AdvocateClaim.active.first.creator).to eq(advocate)
          end

          it 'leaves the claim\'s state in "draft"' do
            post :create, params: { claim: claim_params, commit_submit_claim: 'Submit to LAA' }
            expect(response).to have_http_status(:redirect)
            expect(Claim::AdvocateClaim.active.first).to be_draft
          end

          context 'blank expenses' do
            let(:expense_params) do
              {
                expense_type_id: '',
                location: '',
                distance: '',
                date_dd: '',
                date_mm: '',
                date_yyyy: '',
                reason_id: '',
                reason_text: '',
                amount: '0.00',
                vat_amount: '0.00',
                _destroy: false
              }
            end

            it 'rejects the blank expense when all blank or zero, not failing validations, and creates the claim' do
              expect {
                post :create, params: { commit_submit_claim: 'Submit to LAA', claim: claim_params }
              }.not_to change(Expense, :count)
              expect(response).to have_http_status(:redirect)
            end
          end
        end

        context 'multi-step form submit to LAA' do
          let(:case_number) { 'A20168888' }

          let(:claim_params_step1) do
            {
              claim_class: 'Claim::AdvocateClaim',
              court_id: court,
              case_type_id: case_type.id,
              offence_id: offence,
              case_number: case_number,
              advocate_category: 'QC',
              defendants_attributes: [
                {
                  first_name: 'John',
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

          let(:claim_params_step2) do
            {
              form_step: 'defendants',
              additional_information: 'foo',
              expenses_attributes:
              [
                expense_params
              ]
            }
          end

          let(:subject_claim) { Claim::AdvocateClaim.active.where(case_number: case_number).first }

          it 'validates step fields and move to next steps' do
            post :create, params: { commit_continue: 'Continue', claim: claim_params_step1 }
            expect(subject_claim.draft?).to be_truthy
            expect(subject_claim.valid?).to be_truthy
            expect(response).to redirect_to(edit_advocates_claim_path(subject_claim, step: :defendants))

            put :update, params: { id: subject_claim, commit_submit_claim: 'Submit to LAA', claim: claim_params_step2 }
            expect(subject_claim.draft?).to be_truthy
            expect(subject_claim.valid?).to be_truthy
            expect(response).to redirect_to(summary_external_users_claim_path(subject_claim))
          end
        end
      end

      context 'submit to LAA with incomplete/invalid params' do
        let(:invalid_claim_params) { { claim_class: 'Claim::AdvocateClaim' } }
        it 'does not create a claim' do
          expect {
            post :create, params: { claim: invalid_claim_params, commit_submit_claim: 'Submit to LAA' }
          }.to_not change(Claim::AdvocateClaim, :count)
        end

        it 'renders the new template' do
          post :create, params: { claim: invalid_claim_params, commit_submit_claim: 'Submit to LAA' }
          expect(response).to render_template(:new)
        end
      end

      context 'basic and non-basic fees' do
        before do
          seed_case_types
          seed_fee_types
        end

        let!(:basic_fee_type_1)         { Fee::BasicFeeType.find_by(unique_code: 'BABAF') }
        let!(:basic_fee_type_2)         { Fee::BasicFeeType.find_by(unique_code: 'BADAF') }
        let!(:basic_fee_type_3)         { Fee::BasicFeeType.find_by(unique_code: 'BANPW') }
        let!(:basic_fee_type_4)         { Fee::BasicFeeType.find_by(unique_code: 'BAPCM') }
        let!(:misc_fee_type_1)          { Fee::MiscFeeType.find_by(unique_code: 'MISPF') }
        let!(:misc_fee_type_2)          { Fee::MiscFeeType.find_by(unique_code: 'MIAPH') }
        let!(:fixed_fee_type_1)         { Fee::FixedFeeType.find_by(unique_code: 'FXASE') }

        let(:court)                     { create(:court) }
        let(:offence)                   { create(:offence) }
        let(:claim_params)              { valid_claim_fee_params }
        let(:invalid_claim_params)      { valid_claim_fee_params.reject { |k, _v| k == 'advocate_category' } }

        context 'non fixed fee case types' do
          context 'valid params' do
            it 'creates a claim with all basic fees and specified miscellaneous but NOT the fixed fees' do
              post :create, params: { claim: claim_params }
              claim = assigns(:claim)
              # one record for every basic fee regardless of whether blank or not
              expect(claim.basic_fees.size).to eq 11
              expect(claim.basic_fees.detect { |f| f.fee_type_id == basic_fee_type_1.id }.amount.to_f).to eq 1000
              expect(claim.basic_fees.detect { |f| f.fee_type_id == basic_fee_type_3.id }.amount.to_f).to eq 9000.45
              expect(claim.basic_fees.detect { |f| f.fee_type_id == basic_fee_type_4.id }.amount.to_f).to eq 125.0
              expect(claim.basic_fees.detect { |f| f.fee_type_id == basic_fee_type_2.id }).to be_blank

              # fixed fees are deleted implicitly by claim model for non-fixed-fee case types
              expect(claim.fixed_fees.size).to eq 0

              expect(claim.misc_fees.size).to eq 1
              expect(claim.misc_fees.detect { |f| f.fee_type_id == misc_fee_type_2.id }.amount.to_f).to eq 250.0

              expect(claim.reload.fees_total).to eq 10_375.45
            end
          end

          context 'invalid params' do
            render_views
            it 'redisplays the page with error messages and all the entered data in basic, miscellaneous and fixed fees' do
              post :create, params: { claim: invalid_claim_params, commit_submit_claim: 'Submit to LAA' }
              expect(response.status).to eq 200
              expect(response).to render_template(:new)
              expect(response.body).to have_content('Case details')
              claim = assigns(:claim)
              expect(claim.basic_fees.size).to eq 11
              expect(claim.fixed_fees.size).to eq 0
              expect(claim.misc_fees.size).to eq 1

              bf1 = claim.basic_fees.detect { |f| f.description == basic_fee_type_1.description }
              expect(bf1.quantity).to eq 10
              expect(bf1.amount).to eq 1000

              bf2 = claim.basic_fees.detect { |f| f.description == basic_fee_type_2.description }
              expect(bf2.quantity).to eq 0
              expect(bf2.amount).to eq 0

              bf3 = claim.basic_fees.detect { |f| f.description == basic_fee_type_3.description }
              expect(bf3.quantity).to eq 1
              expect(bf3.amount.to_f).to eq 9000.45

              bf4 = claim.basic_fees.detect { |f| f.description == basic_fee_type_4.description }
              expect(bf4.quantity).to eq 5
              expect(bf4.amount).to eq 125
            end
          end
        end

        context 'fixed fee case types' do
          context 'valid params' do
            it 'creates a claim with fixed fees ONLY' do
              ct = create :case_type, :fixed_fee
              claim_params['case_type_id'] = ct.id
              post :create, params: { claim: claim_params }
              claim = assigns(:claim)

              # basic fees are cleared, but not destroyed, implicitly for fixed-fee case types
              expect(claim.basic_fees.size).to eq 4
              expect(claim.basic_fees.map(&:amount).compact.sum.to_f).to eq 0.00

              # miscellaneous fees are NOT destroyed implicitly by claim model for fixed-fee case types
              expect(claim.misc_fees.size).to eq 1
              expect(claim.misc_fees.map(&:amount).sum.to_f).to eq 250.00
              expect(claim.fixed_fees.size).to eq 1
              expect(claim.fixed_fees.map(&:amount).sum.to_f).to eq 250.00

              expect(claim.reload.fees_total).to eq 500.00
            end
          end
        end
      end

      context 'document checklist' do
        let(:court)             { create(:court) }
        let(:offence)           { create(:offence) }
        let(:case_type)         { create(:case_type) }
        let(:claim_params) do
          {
            additional_information: 'foo',
            court_id: court,
            case_type_id: case_type.id,
            offence_id: offence,
            case_number: '12345',
            advocate_category: 'QC',
            evidence_checklist_ids: ['2', '3', '']
          }
        end

        it 'creates a claim with document checklist items' do
          post :create, params: { claim: claim_params }
          claim = assigns(:claim)
          expect(claim.evidence_checklist_ids).to eql([2, 3])
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:edit_request) { -> { get :edit, params: { id: claim } } }

    before { edit_request.call }

    context 'editable claim' do
      let(:claim) { create(:advocate_claim, external_user: advocate) }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'updates the last_edited_at field' do
        expect(assigns(:claim).last_edited_at).to_not be_nil
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

      it 'renders the template' do
        expect(response).to render_template(:edit)
      end

      context 'when the claim has fixed fees' do
        let(:claim) { create(:advocate_claim, :with_fixed_fee_case, external_user: advocate) }

        before do
          seed_case_types
          seed_fee_types

          edit_request.call
        end

        it 'builds eligible fixed fees' do
          claim = assigns(:claim)
          expect(claim.fixed_fees.map(&:fee_type_id)).to match_array(claim.eligible_fixed_fee_types.map(&:id))
        end
      end
    end

    context 'uneditable claim' do
      let(:claim) { create(:allocated_claim, external_user: advocate) }

      it 'does not update the last_edited_at field' do
        expect(assigns(:claim).last_edited_at).to be_nil
      end

      it 'redirects to advocates claims index' do
        expect(response).to redirect_to(external_users_claims_url)
      end
    end
  end

  describe 'PUT #update' do
    subject { create(:claim, external_user: advocate) }

    context 'when valid' do
      context 'and deleting a rep order' do
        before {
          put :update, params: { id: subject, claim: { defendants_attributes: { '1' => { id: subject.defendants.first, representation_orders_attributes: { '0' => { id: subject.defendants.first.representation_orders.first, _destroy: 1 } } } } }, commit_save_draft: 'Save to drafts' }
        }
        it 'reduces the number of associated rep order by 1' do
          expect(subject.reload.defendants.first.representation_orders.count).to eq 1
        end
      end

      context 'and editing an API created claim' do
        before do
          subject.update(source: 'api')
        end

        context 'and saving to draft' do
          before { put :update, params: { id: subject, claim: { additional_information: 'foo' }, commit_save_draft: 'Save to drafts' } }
          it 'sets API created claims source to indicate it is from API but has been edited in web' do
            expect(subject.reload.source).to eql 'api_web_edited'
          end
        end

        context 'and submitted to LAA' do
          before { put :update, params: { id: subject, claim: { additional_information: 'foo' }, summary: true, commit_submit_claim: 'Submit to LAA' } }
          it 'sets API created claims source to indicate it is from API but has been edited in web' do
            expect(subject.reload.source).to eql 'api_web_edited'
          end
        end
      end

      context 'and editing a JSON imported claim' do
        before do
          subject.update(source: 'json_import')
        end

        context 'and saving to draft' do
          before { put :update, params: { id: subject, claim: { additional_information: 'foo' }, commit_save_draft: 'Save to drafts' } }

          it 'updates the source to indicate it was originally from JSON import but has been edited via web' do
            expect(subject.reload.source).to eql 'json_import_web_edited'
          end
        end

        context 'and submitted to LAA' do
          before { put :update, params: { id: subject, claim: { additional_information: 'foo' }, summary: true, commit_submit_claim: 'Submit to LAA' } }

          it 'updates the source to indicate it was originally from JSON import but has been edited via web' do
            expect(subject.reload.source).to eql 'json_import_web_edited'
          end
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
      it 'transforms dates with named months into dates' do
        put :update, params: {
          id: subject,
          claim: {
            'first_day_of_trial_yyyy' => '2015',
            'first_day_of_trial_mm' => 'jan',
            'first_day_of_trial_dd' => '4'
          },
          commit_submit_claim: 'Submit to LAA'
        }
        expect(assigns(:claim).first_day_of_trial).to eq Date.new(2015, 1, 4)
      end

      it 'transforms dates with numbered months into dates' do
        put :update, params: {
          id: subject,
          claim: {
            'first_day_of_trial_yyyy' => '2015',
            'first_day_of_trial_mm' => '11',
            'first_day_of_trial_dd' => '4'
          },
          commit_submit_claim: 'Submit to LAA'
        }
        expect(assigns(:claim).first_day_of_trial).to eq Date.new(2015, 11, 4)
      end
    end
  end

  def valid_claim_fee_params
    case_type = CaseType.find_by(name: 'Guilty plea') || create(:case_type)

    {
      'source' => 'web',
      'case_type_id' => case_type.id.to_s,
      'court_id' => court.id.to_s,
      'case_number' => 'CASE98989-',
      'advocate_category' => 'QC',
      'offence_class_id' => '2',
      'offence_id' => offence.id.to_s,
      'first_day_of_trial_dd' => '13',
      'first_day_of_trial_mm' => '5',
      'first_day_of_trial_yyyy' => '2015',
      'estimated_trial_length' => '2',
      'actual_trial_length' => '2',
      'trial_concluded_at_dd' => '15',
      'trial_concluded_at_mm' => '05',
      'trial_concluded_at_yyyy' => '2015',
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
      'basic_fees_attributes' => {
        '0' => { 'quantity' => '10', 'rate' => '100', 'fee_type_id' => basic_fee_type_1.id.to_s },
        '1' => { 'quantity' => '0', 'amount' => '0.00', 'fee_type_id' => basic_fee_type_2.id.to_s },
        '2' => { 'quantity' => '1', 'amount' => '9000.45', 'fee_type_id' => basic_fee_type_3.id.to_s },
        '3' => { 'quantity' => '5', 'rate' => '25', 'fee_type_id' => basic_fee_type_4.id.to_s }
      },
      'fixed_fees_attributes' => {
        '0' => { 'fee_type_id' => fixed_fee_type_1.id.to_s, 'quantity' => '25', 'rate' => '10', '_destroy' => 'false' }
      },
      'misc_fees_attributes' => {
        '1' => { 'fee_type_id' => misc_fee_type_2.id.to_s, 'quantity' => '2', 'rate' => '125', '_destroy' => 'false' }
      },
      'expenses_attributes' => {
        '0' => { 'expense_type_id' => '', 'location' => '', 'quantity' => '', 'rate' => '', 'amount' => '', '_destroy' => 'false' }
      },
      'apply_vat' => '0'
    }.with_indifferent_access
  end
end
