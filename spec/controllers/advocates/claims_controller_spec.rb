require 'rails_helper'
require 'custom_matchers'

RSpec.describe Advocates::ClaimsController, type: :controller, focus: true do
  let!(:advocate) { create(:advocate) }

  before { sign_in advocate.user }

  describe 'GET #landing' do
    before { get :landing }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'renders the template' do
      expect(response).to render_template(:landing)
    end
  end

  describe 'GET #index' do
    before(:each) do
      @allocated_claim                = build_claim_in_state(:allocated)
      @appealed_claim                 = build_claim_in_state(:appealed)
      @archived_pending_delete_claim  = build_claim_in_state(:archived_pending_delete)
      @awaiting_further_info_claim    = build_claim_in_state(:awaiting_further_info)
      @awaiting_info_from_court_claim = build_claim_in_state(:awaiting_info_from_court)
      @completed_claim                = build_claim_in_state(:completed)
      @draft_claim                    = build_claim_in_state(:draft)
      @part_paid_claim                = build_claim_in_state(:part_paid)
      @parts_rejected_claim           = build_claim_in_state(:parts_rejected)
      @refused_claim                  = build_claim_in_state(:refused)
      @rejected_claim                 = build_claim_in_state(:rejected)
      @submitted_claim                = build_claim_in_state(:submitted)

      allow_any_instance_of(Claim).to receive(:id).and_return(777)
      allow_any_instance_of(Claims::FinancialSummary).to receive(:total_authorised_claim_value).and_return( 45454.45 )
      allow_any_instance_of(Claims::FinancialSummary).to receive(:total_outstanding_claim_value).and_return( 1323.44 )
    end

    let(:full_collection)  { [  @allocated_claim, @appealed_claim, @archived_pending_delete_claim,
                                @awaiting_further_info_claim, @awaiting_info_from_court_claim, @completed_claim,
                                @draft_claim, @part_paid_claim, @parts_rejected_claim, @refused_claim,
                                @rejected_claim, @submitted_claim ] }

    context 'advocate' do
      it 'should categorise the claims for the advocate' do
        query_result = double 'QueryResult'
        expect(controller.current_user).to receive(:claims).and_return(query_result)
        allow(query_result).to receive(:order).and_return(full_collection)
        allow(query_result).to receive(:unscope).and_return(full_collection)

        get :index

        expect(response).to have_http_status(:success)
        expect(assigns(:draft_claims)).to contain_claims( @draft_claim )
        expect(assigns(:rejected_claims)).to contain_claims( @rejected_claim )
        expect(assigns(:submitted_claims)).to contain_claims( @allocated_claim,
                                                              @submitted_claim,
                                                              @awaiting_info_from_court_claim,
                                                              @awaiting_further_info_claim)
        expect(assigns(:part_paid_claims)).to contain_claims( @part_paid_claim,
                                                              @appealed_claim,
                                                              @parts_rejected_claim)
        expect(assigns(:completed_claims)).to contain_claims( @completed_claim, @refused_claim )
      end
    end

    context 'advocate admin' do

      let(:advocate_admin)                  { create(:advocate, :admin, chamber_id: advocate.chamber.id) }

      it 'should categorise claims for the chamber' do
        sign_in advocate_admin.user
        query_result = double 'QueryResult'
        expect(controller.current_user.persona.chamber).to receive(:claims).and_return(query_result)
        allow(query_result).to receive(:order).and_return(full_collection)
        allow(query_result).to receive(:unscope).and_return(full_collection)

        get :index

        expect(response).to have_http_status(:success)
        expect(assigns(:draft_claims)).to contain_claims( @draft_claim )
        expect(assigns(:rejected_claims)).to contain_claims( @rejected_claim )
        expect(assigns(:submitted_claims)).to contain_claims( @allocated_claim,
                                                              @submitted_claim,
                                                              @awaiting_info_from_court_claim,
                                                              @awaiting_further_info_claim)
        expect(assigns(:part_paid_claims)).to contain_claims( @part_paid_claim,
                                                              @appealed_claim,
                                                              @parts_rejected_claim)
        expect(assigns(:completed_claims)).to contain_claims( @completed_claim, @refused_claim )
      end
    end

    it 'renders the template' do
      get :index
      expect(response).to render_template(:index)
    end

    render_views

    it 'renders breadcrumbs' do
      get :index
      expect(response.body).to match(/Dashboard/)
    end
  end

  describe "GET #show" do
    subject { create(:claim, advocate: advocate) }

    before { get :show, id: subject }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @claim' do
      expect(assigns(:claim)).to eq(subject)
    end

    it 'renders the template' do
      expect(response).to render_template(:show)
    end

    render_views

    it 'renders breadcrumbs' do
      expect(response.body).to match(%Q{Dashboard.*Claim: #{Regexp.escape(CGI.escapeHTML(subject.case_number))}})
    end

    it 'does not display claim notes' do
      expect(response.body).to_not include('Add note')
    end
  end

  describe "GET #new" do
    before { get :new }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @claim' do
      expect(assigns(:claim)).to be_new_record
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end

    render_views

    it 'renders breadcrumbs' do
      expect(response.body).to match(/Dashboard.*New claim/)
    end
  end

  describe "GET #edit" do
    before { get :edit, id: subject }

    context 'editable claim' do
      subject { create(:claim, advocate: advocate) }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @claim' do
        expect(assigns(:claim)).to eq(subject)
      end

      it 'renders the template' do
        expect(response).to render_template(:edit)
      end

      render_views

      it 'renders breadcrumbs' do
        expect(response.body).to match(%Q{Dashboard.*Claim: #{Regexp.escape(CGI.escapeHTML(subject.case_number))}.*Edit})
      end
    end

    context 'uneditable claim' do
      subject { create(:allocated_claim, advocate: advocate) }

      it 'redirects to advocates claims index' do
        expect(response).to redirect_to(advocates_claims_url)
      end
    end
  end

  describe "POST #create" do
    context 'when advocate signed in' do
      context 'and the input is valid' do
        let(:court) { create(:court) }
        let(:offence) { create(:offence) }
        let(:scheme) { create(:scheme) }
        let(:claim_params) do
          {
            additional_information: 'foo',
            court_id: court,
            case_type: 'trial',
            offence_id: offence,
            case_number: '12345',
            advocate_category: 'QC',
            prosecuting_authority: 'cps',
            defendants_attributes: [
              { first_name: 'John',
                last_name: 'Smith',
                date_of_birth: '1980-10-04',
                representation_orders_attributes: [
                  {
                    representation_order_date: scheme.start_date,
                    granting_body: 'Crown Court',
                    maat_reference: '111AAA222BB'
                  }
                ]
              }
            ]
          }
        end

        context 'submit to LAA' do
          it 'creates a claim' do
            expect {
              post :create, commit: 'Submit to LAA', claim: claim_params
            }.to change(Claim, :count).by(1)
          end

          it 'redirects to claim confirmation' do
            post :create, claim: claim_params, commit: 'Submit to LAA'
            expect(response).to redirect_to(confirmation_advocates_claim_path(Claim.first))
          end

          it 'sets the created claim\'s advocate to the signed in advocate' do
            post :create, claim: claim_params, commit: 'Submit to LAA'
            expect(Claim.first.advocate).to eq(advocate)
          end

          it 'sets the claim\'s state to "submitted"' do
            post :create, claim: claim_params, commit: 'Submit to LAA'
            expect(response).to have_http_status(:redirect)
            expect(Claim.first).to be_submitted
          end
        end

        context 'create draft' do
          it 'creates a claim' do
            expect {
              post :create, commit: 'Save to drafts', claim: claim_params
            }.to change(Claim, :count).by(1)
          end

          it 'redirects to claims list' do
            post :create, claim: claim_params, commit: 'Save to drafts'
            expect(response).to redirect_to(advocates_claims_path)
          end

          it 'sets the created claim\'s advocate to the signed in advocate' do
            post :create, claim: claim_params, commit: 'Save to drafts'
            expect(Claim.first.advocate).to eq(advocate)
          end

          it 'sets the claim\'s state to "draft"' do
            post :create, claim: claim_params, commit: 'Save to drafts'
            expect(Claim.first).to be_draft
          end
        end
      end

      context 'submit to LAA with incomplete/invalid params' do
        it 'does not create a claim' do
          expect {
            post :create, claim: { additional_information: 'foo' }, commit: 'Submit to LAA'
          }.to_not change(Claim, :count)
        end

        it 'renders the new template' do
          post :create, claim: { additional_information: 'foo' }, commit: 'Submit to LAA'
          expect(response).to render_template(:new)
        end
      end

      context 'basic and non-basic fees' do

        before(:each) do
          @file = fixture_file_upload('files/repo_order_1.pdf', 'application/pdf')
        end

        let!(:basic_fee_type_1)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 1', quantity_modifier: 0 }
        let!(:basic_fee_type_2)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 2', quantity_modifier: 0 }
        let!(:basic_fee_type_3)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 3', quantity_modifier: 0 }
        let!(:basic_fee_type_4)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 4', quantity_modifier: 0 }
        let!(:misc_fee_type_1)          { FactoryGirl.create :fee_type, :misc, description: 'Miscellaneous Fee Type 1' }
        let!(:misc_fee_type_2)          { FactoryGirl.create :fee_type, :misc, description: 'Miscellaneous Fee Type 2' }
        let!(:fixed_fee_type_1)         { FactoryGirl.create :fee_type, :fixed, description: 'Fixed Fee Type 1' }

        let(:court)                     { create(:court) }
        let(:offence)                   { create(:offence) }
        let(:claim_params)              { valid_claim_fee_params }
        let(:invalid_claim_params)      { valid_claim_fee_params.reject{ |k,v| k == 'prosecuting_authority'} }

        context 'valid params' do
          it 'should create a claim with all basic fees and the specified non-basic fees' do
            post :create, claim: claim_params
            claim = assigns(:claim)

            # one record for every basic fee regardless of whether blank or not
            expect(claim.basic_fees.size).to eq 4
            expect(claim.basic_fees.detect{ |f| f.fee_type_id == basic_fee_type_1.id }.amount.to_f ).to eq 1000
            expect(claim.basic_fees.detect{ |f| f.fee_type_id == basic_fee_type_3.id }.amount.to_f ).to eq 9000.45
            expect(claim.basic_fees.detect{ |f| f.fee_type_id == basic_fee_type_4.id }.amount.to_f ).to eq 125.0
            expect(claim.basic_fees.detect{ |f| f.fee_type_id == basic_fee_type_2.id }).to be_blank

            # expect(claim.non_basic_fees.size).to eq 2
            # expect(claim.non_basic_fees.detect{ |f| f.fee_type_id == misc_fee_type_2.id }.amount.to_f ).to eq 250.0
            # expect(claim.non_basic_fees.detect{ |f| f.fee_type_id == fixed_fee_type_1.id }.amount.to_f ).to eq 2500.0

            expect(claim.fixed_fees.size).to eq 1
            expect(claim.fixed_fees.detect{ |f| f.fee_type_id == fixed_fee_type_1.id }.amount.to_f ).to eq 2500.0

            expect(claim.misc_fees.size).to eq 1
            expect(claim.misc_fees.detect{ |f| f.fee_type_id == misc_fee_type_2.id }.amount.to_f ).to eq 250.0

            expect(claim.reload.fees_total).to eq 12_875.45
          end
        end

        context 'invalid params' do
          render_views
          it 'should redisplay the page with error messages and all the entered data in basic and non basic fees' do
            post :create, claim: invalid_claim_params, commit: 'Submit to LAA'
            expect(response.status).to eq 200
            expect(response).to render_template(:new)
            expect(response.body).to have_content("Prosecuting authority can't be blank")
            claim = assigns(:claim)
            expect(claim.basic_fees.size).to eq 4
            # expect(claim.non_basic_fees.size).to eq 2
            expect(claim.fixed_fees.size).to eq 1
            expect(claim.misc_fees.size).to eq 1

            bf1 = claim.basic_fees.detect{ |f| f.description == 'Basic Fee Type 1' }
            expect(bf1.quantity).to eq 10
            expect(bf1.rate).to eq 100
            expect(bf1.amount).to eq 1000

            bf2 = claim.basic_fees.detect{ |f| f.description == 'Basic Fee Type 2' }
            expect(bf2.quantity).to eq 0
            expect(bf2.rate).to eq 0
            expect(bf2.amount).to eq 0

            bf3 = claim.basic_fees.detect{ |f| f.description == 'Basic Fee Type 3' }
            expect(bf3.quantity).to eq 1
            expect(bf3.rate.to_f).to eq 9000.45
            expect(bf3.amount.to_f).to eq 9000.45

            bf4 = claim.basic_fees.detect{ |f| f.description == 'Basic Fee Type 4' }
            expect(bf4.quantity).to eq 5
            expect(bf4.rate).to eq 25
            expect(bf4.amount).to eq 125
          end
        end
      end

      context 'document checklist' do
        let(:court) { create(:court) }
        let(:offence) { create(:offence) }
        let(:claim_params) do
          {
             additional_information: 'foo',
             court_id: court,
             case_type: 'trial',
             offence_id: offence,
             case_number: '12345',
             advocate_category: 'QC',
             prosecuting_authority: 'cps',
             evidence_checklist_ids:  ['2', '3', '']
          }
        end

        it 'should create a claim with document checklist items' do
          post :create, claim: claim_params
          claim = assigns(:claim)
          expect(claim.evidence_checklist_ids).to eql( [ 2, 3 ] )
        end
      end

    end
  end

  describe "PUT #update" do
    subject { create(:claim, advocate: advocate) }

    context 'when valid' do
      context 'and saving to draft' do
        it 'updates a claim' do
          put :update, id: subject, claim: { additional_information: 'foo' }, commit: 'Save to drafts'
          subject.reload
          expect(subject.additional_information).to eq('foo')
        end

        it 'redirects to claims list path' do
          put :update, id: subject, claim: { additional_information: 'foo' }
          expect(response).to redirect_to(advocates_claims_path)
        end
      end

      context 'and submitted to LAA' do
        before do
          get :edit, id: subject
          put :update, id: subject, claim: { additional_information: 'foo' }, summary: true, commit: 'Submit to LAA'
        end

        it 'redirects to the claim confirmation path' do
          expect(response).to redirect_to(confirmation_advocates_claim_path(subject))
        end

        it 'sets the claim to submitted' do
          subject.reload
          expect(subject).to be_submitted
        end

        it 'sets the claim submitted_at' do
          subject.reload
          expect(subject.submitted_at).to_not be_nil
        end
      end
    end

    context 'when submitted to LAA and invalid ' do
      it 'does not set claim to submitted' do
        put :update, id: subject, claim: { court_id: nil }, commit: 'Submit to LAA'
        subject.reload
        expect(subject).to_not be_submitted
      end

      it 'renders edit template' do
        put :update, id: subject, claim: { additional_information: 'foo', court_id: nil }, commit: 'Submit to LAA'
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    before { delete :destroy, id: subject }

    subject { create(:claim, advocate: advocate) }

    it 'deletes the claim' do
      expect(Claim.count).to eq(1)
      claim = Claim.first
      expect(claim.state).to eq 'archived_pending_delete'
    end

    it "sets the claim's state to 'archived_pending_delete'" do
      expect(subject.reload).to be_archived_pending_delete
    end

    it 'redirects to advocates root url' do
      expect(response).to redirect_to(advocates_claims_url)
    end
  end
end


def valid_claim_fee_params
    {"advocate_id" => "4",
     "scheme_id" => "2",
     "case_type" => "appeal_against_sentence",
     "prosecuting_authority" => "cps",
     "court_id" => court.id.to_s,
     "case_number" => "CASE98989",
     "advocate_category" => "QC",
     "offence_class_id" => "2",
     "offence_id" => offence.id.to_s,
     "first_day_of_trial" => "2015-05-13",
     "estimated_trial_length" => "2",
     "actual_trial_length" => "2",
     "trial_concluded_at" => "2015-05-15",
     "evidence_checklist_ids" => ["1", "5", ""],
     "defendants_attributes"=>
      {"0"=>
        {"first_name" => "Stephen",
         "middle_name" => "",
         "last_name" => "Richards",
         "date_of_birth" => "1966-08-13",
         "representation_order_date" => "2015-05-13",
         "_destroy" => "false",
         "representation_orders_attributes"=>{
           "0"=>{
             "representation_order_date" => "2015-05-13",
             "maat_reference" => "MAAT2015",
             "granting_body" => "Crown Court"}
          }
        }
      },
     "additional_information" => "",
     "basic_fees_attributes"=>
      {
        "0"=>{"quantity" => "10", "rate" => "100", "fee_type_id" => basic_fee_type_1.id.to_s},
        "1"=>{"quantity" => "0", "rate" => "0.00", "fee_type_id" => basic_fee_type_2.id.to_s},
        "2"=>{"quantity" => "1", "rate" => "9000.45", "fee_type_id" => basic_fee_type_3.id.to_s},
        "3"=>{"quantity" => "5", "rate" => "25", "fee_type_id" => basic_fee_type_4.id.to_s}
        },
     # "non_basic_fees_attributes"=>
     #  {
     #    "0"=>{"fee_type_id" => misc_fee_type_2.id.to_s, "quantity" => "2", "rate" => "125", "_destroy" => "false"},
     #    "1"=>{"fee_type_id" => fixed_fee_type_1.id.to_s, "quantity" => "250", "rate" => "10", "_destroy" => "false"}
     #  },
      "fixed_fees_attributes"=>
      {
        "0"=>{"fee_type_id" => fixed_fee_type_1.id.to_s, "quantity" => "250", "rate" => "10", "_destroy" => "false"}
      },
      "misc_fees_attributes"=>
      {
        "1"=>{"fee_type_id" => misc_fee_type_2.id.to_s, "quantity" => "2", "rate" => "125", "_destroy" => "false"},
      },
     "expenses_attributes"=>
     {
      "0"=>{"expense_type_id" => "", "location" => "", "quantity" => "", "rate" => "", "amount" => "", "_destroy" => "false"}
     },
     "apply_vat" => "0"
   }
end



def build_claim_in_state(state)
  claim = FactoryGirl.build :unpersisted_claim
  allow(claim).to receive(:state).and_return(state.to_s)
  claim
end



