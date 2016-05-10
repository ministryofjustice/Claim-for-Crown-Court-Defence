require 'rails_helper'
require 'custom_matchers'

RSpec.describe ExternalUsers::Litigators::TransferClaimsController, type: :controller, focus: true do

  let!(:litigator)      { create(:external_user, :litigator) }
  before { sign_in litigator.user }

  let(:court)         { create(:court) }
  let(:offence)       { create(:offence, :miscellaneous) }
  let(:case_type)     { create(:case_type, :hsts) }
  let(:expense_type)  { create(:expense_type, :car_travel, :lgfs) }
  let(:external_user) { create(:external_user, :litigator, provider: litigator.provider)}
  let(:supplier_number) { litigator.provider.supplier_numbers.first.supplier_number }

  describe 'GET #new' do
    before { get :new }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @claim' do
      expect(assigns(:claim)).to be_new_record
    end

    it 'assigns @claim to be a transfer claim' do
      expect(assigns(:claim)).to be_instance_of Claim::TransferClaim
    end

    it 'routes to litigators transfer new claim path' do
      expect(request.path).to eq('/litigators/transfer_claims/new')
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'when litigator signed in' do
      context 'and the input is valid' do

        let(:claim_params) do
          {
            external_user_id: litigator.id,
            additional_information: 'foo',
            court_id: court,
            case_type_id: case_type.id,
            offence_id: offence,
            case_number: 'A12345678',
            supplier_number: supplier_number,
            case_concluded_at_dd: 5.days.ago.day.to_s,
            case_concluded_at_mm: 5.days.ago.month.to_s,
            case_concluded_at_yyyy: 5.days.ago.year.to_s,
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
                    maat_reference: '4561237895'
                  }
                ]
              }
            ]
          }
        end

        context 'create draft' do
          it 'creates a claim' do
            expect {
              post :create, commit_save_draft: 'Save to drafts', claim: claim_params
            }.to change(Claim::TransferClaim, :count).by(1)
          end

          it 'redirects to claims list' do
            post :create, claim: claim_params, commit_save_draft: 'Save to drafts'
            expect(response).to redirect_to(external_users_claims_path)
          end

          it 'sets the claim\'s state to "draft"' do
            post :create, claim: claim_params, commit_save_draft: 'Save to drafts'
            expect(Claim::TransferClaim.first).to be_draft
          end
        end

        context 'submit to LAA' do
          it 'creates a claim' do
            expect {
              post :create, commit_submit_claim: 'Submit to LAA', claim: claim_params
            }.to change(Claim::TransferClaim, :count).by(1)
          end

          it 'redirects to claim summary if no validation errors present' do
            post :create, claim: claim_params, commit_submit_claim: 'Submit to LAA'
            expect(response).to redirect_to(summary_external_users_claim_path(Claim::TransferClaim.first))
          end

          it 'leaves the claim\'s state in "draft"' do
            post :create, claim: claim_params, commit_submit_claim: 'Submit to LAA'
            expect(response).to have_http_status(:redirect)
            expect(Claim::TransferClaim.first).to be_draft
          end
        end

        context 'multi-step form submit to LAA' do
          let!(:transfer_fee_type)  { create(:transfer_fee_type) }
          let(:case_number) { 'A88888888' }
          let(:transfer_detail_params) {
            {
              litigator_type: 'original',
              elected_case: false,
              transfer_stage_id: 10,
              transfer_date_dd:   5.days.ago.day.to_s,
              transfer_date_mm:   5.days.ago.month.to_s,
              transfer_date_yyyy: 5.days.ago.year.to_s,
              case_conclusion_id: 10
            }
          }
          let(:transfer_fee_params) {
            {
                transfer_fee_attributes: {
                  fee_type_id: transfer_fee_type.id,
                  amount: 10.0
                }
            }
          }

          let(:claim_params_step1) do
            {
                external_user_id: litigator.id,
                supplier_number: supplier_number,
                court_id: court,
                case_type_id: case_type.id,
                offence_id: offence,
                case_number: case_number,
                case_concluded_at_dd: 5.days.ago.day.to_s,
                case_concluded_at_mm: 5.days.ago.month.to_s,
                case_concluded_at_yyyy: 5.days.ago.year.to_s,
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
                              maat_reference: '4561237895'
                          }
                      ]
                    }
                ]
            }
          end

          let(:claim_params_step2) do
            {
                form_step: 2,
                additional_information: 'foo'
            }.
            merge(transfer_detail_params).
            merge(transfer_fee_params)
          end

          let(:claim) { Claim::TransferClaim.where(case_number: case_number).first }

          context 'step 1 Continue' do
            render_views
            before { post :create, commit_continue: 'Continue', claim: claim_params_step1 }

            it 'should leave claim in draft state'  do expect(claim.draft?).to be_truthy end
            it 'should assign current_step to 2'    do expect(assigns(:claim).current_step).to eq(2) end
            it { expect(response).to render_template('external_users/litigators/transfer_claims/new') }
            it { expect(response).to render_template(partial: 'external_users/claims/disbursements/_fields') }

          end

          context 'step 2 Submit to LAA' do
            before do
              post :create, commit_continue: 'Continue', claim: claim_params_step1
              put :update, id: claim, commit_submit_claim: 'Submit to LAA', claim: claim_params_step2
            end

            it 'updates the claim transfer details and transfer fee, still draft, and moves to summary page' do
              expect(claim.draft?).to be_truthy

              # note: transfer detail attributes are delegated to claim
              expect(claim.litigator_type).to eql 'original'
              expect(claim.elected_case).to eql false
              expect(claim.transfer_stage_id).to eql 10
              expect(claim.case_conclusion_id).to eql 10
              expect(claim.transfer_date.to_s).to eql 5.days.ago.strftime('%d/%m/%Y 00:00')

              expect(claim.transfer_fee).to_not be_nil
              expect(claim.transfer_fee.amount).to eql 10.00

              expect(response).to redirect_to(summary_external_users_claim_path(claim))
            end
          end
        end
      end

      context 'submit to LAA with incomplete/invalid params' do
        let(:invalid_claim_params)      { { advocate_category: 'QC' } }
        it 'does not create a claim' do
          expect {
            post :create, claim: invalid_claim_params, commit_submit_claim: 'Submit to LAA'
          }.to_not change(Claim::TransferClaim, :count)
        end

        it 'renders the new template' do
          post :create, claim: invalid_claim_params, commit_submit_claim: 'Submit to LAA'
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET #edit' do
    before { get :edit, id: subject }

    context 'editable claim' do
      subject { create(:transfer_claim, creator: litigator) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @claim' do
        expect(assigns(:claim)).to eq(subject)
      end

      it 'routes to litigators edit path' do
        expect(request.path).to eq edit_litigators_transfer_claim_path(subject)
      end

      it 'renders the template' do
        expect(response).to render_template(:edit)
      end
    end

    context 'uneditable claim' do
      subject do
        claim = create(:transfer_claim, creator: litigator)
        create(:transfer_detail, claim: claim)
        claim.submit!
        claim.allocate!
        claim
      end

      it 'redirects to the claims index' do
        expect(response).to redirect_to(external_users_claims_path)
      end
    end
  end

  describe 'PUT #update' do
    subject { create(:transfer_claim, creator: litigator) }

    context 'when valid' do

      context 'and deleting a rep order' do
        before {
          put :update, id: subject, claim: { defendants_attributes: { '1' => { id: subject.defendants.first, representation_orders_attributes: {'0' => {id: subject.defendants.first.representation_orders.first, _destroy: 1}}}}}, commit_save_draft: 'Save to drafts'
        }
        it 'reduces the number of associated rep orders by 1' do
          expect(subject.reload.defendants.first.representation_orders.count).to eq 1
        end
      end

      # context 'and editing an API created claim' do
      #   pending 'TODO: reimplement once/if transfer claim creation opened up to API'
      #
      #   before(:each) do
      #     subject.update(source: 'api')
      #   end
      #
      #   context 'and saving to draft' do
      #     before { put :update, id: subject, claim: { additional_information: 'foo' }, commit_save_draft: 'Save to drafts' }
      #     it 'sets API created claims source to indicate it is from API but has been edited in web' do
      #       expect(subject.reload.source).to eql 'api_web_edited'
      #     end
      #   end
      #
      #   context 'and submitted to LAA' do
      #     before { put :update, id: subject, claim: { additional_information: 'foo' }, summary: true, commit_submit_claim: 'Submit to LAA' }
      #     it 'sets API created claims source to indicate it is from API but has been edited in web' do
      #       expect(subject.reload.source).to eql 'api_web_edited'
      #     end
      #   end
      # end

      context 'and saving to draft' do
        it 'updates a claim' do
          put :update, id: subject, claim: { additional_information: 'foo' }, commit_save_draft: 'Save to drafts'
          subject.reload
          expect(subject.additional_information).to eq('foo')
        end

        it 'redirects to claims list path' do
          put :update, id: subject, claim: { additional_information: 'foo' }
          expect(response).to redirect_to(external_users_claims_path)
        end
      end

      context 'and submitted to LAA' do
        before do
          get :edit, id: subject
          put :update, id: subject, claim: { additional_information: 'foo' }, summary: true, commit_submit_claim: 'Submit to LAA'
        end

        it 'redirects to the claim summary page' do
          expect(response).to redirect_to(summary_external_users_claim_path(subject))
        end
      end
    end

    context 'when submitted to LAA and invalid ' do
      it 'does not set claim to submitted' do
        put :update, id: subject, claim: { court_id: nil }, commit_submit_claim: 'Submit to LAA'
        subject.reload
        expect(subject).to_not be_submitted
      end

      it 'renders edit template' do
        put :update, id: subject, claim: { additional_information: 'foo', court_id: nil }, commit_submit_claim: 'Submit to LAA'
        expect(response).to render_template(:edit)
      end
    end

    context 'Date Parameter handling' do
      it 'should transform dates with named months into dates' do
        put :update, id: subject, claim: {
          'first_day_of_trial_yyyy' => '2015',
          'first_day_of_trial_mm' => 'jan',
          'first_day_of_trial_dd' => '4' }, commit_submit_claim: 'Submit to LAA'
        expect(assigns(:claim).first_day_of_trial).to eq Date.new(2015, 1, 4)
      end

      it 'should transform dates with numbered months into dates' do
        put :update, id: subject, claim: {
          'first_day_of_trial_yyyy' => '2015',
          'first_day_of_trial_mm' => '11',
          'first_day_of_trial_dd' => '4' }, commit_submit_claim: 'Submit to LAA'
        expect(assigns(:claim).first_day_of_trial).to eq Date.new(2015, 11, 4)
      end
    end
  end

  # local helpers
  # -------------------------

  def valid_claim_fee_params
    case_type = FactoryGirl.create :case_type

    HashWithIndifferentAccess.new(
      {
       "source" => 'web',
       "supplier_number" => supplier_number,
       "case_type_id" => case_type.id.to_s,
       "court_id" => court.id.to_s,
       "case_number" => "CASE98989",
       "offence_class_id" => "2",
       "offence_id" => offence.id.to_s,
       "external_user_id" => external_user.id.to_s,
       "first_day_of_trial_dd" => '13',
       "first_day_of_trial_mm" => '5',
       "first_day_of_trial_yyyy" => '2015',
       "estimated_trial_length" => "2",
       "actual_trial_length" => "2",
       "trial_concluded_at_dd" => "15",
       "trial_concluded_at_mm" => "05",
       "trial_concluded_at_yyyy" => "2015",
       "evidence_checklist_ids" => ["1", "5", ""],
       "defendants_attributes"=>
        {"0"=>
          {"first_name" => "Stephen",
           "last_name" => "Richards",
           "date_of_birth_dd" => "13",
           "date_of_birth_mm" => "08",
           "date_of_birth_yyyy" => "1966",
           "_destroy" => "false",
           "representation_orders_attributes"=>{
             "0"=>{
               "representation_order_date_dd" => "13",
               "representation_order_date_mm" => "05",
               "representation_order_date_yyyy" => "2015",
               "maat_reference" => "1594851269",
             }
            }
          }
        },
       "additional_information" => "",
       "apply_vat" => "0"
     }
    )
  end
end