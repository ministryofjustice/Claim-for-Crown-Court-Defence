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

  describe "GET #index" do
    before(:each) do
      @allocated_claim                = FactoryGirl.create :allocated_claim, advocate: advocate
      @appealed_claim                 = FactoryGirl.create :appealed_claim, advocate: advocate
      @archived_pending_delete_claim  = FactoryGirl.create :archived_pending_delete_claim, advocate: advocate
      @awaiting_further_info_claim    = FactoryGirl.create :awaiting_further_info_claim, advocate: advocate
      @awaiting_info_from_court_claim = FactoryGirl.create :awaiting_info_from_court_claim, advocate: advocate
      @completed_claim                = FactoryGirl.create :completed_claim, advocate: advocate
      @draft_claim                    = FactoryGirl.create :draft_claim, advocate: advocate
      @part_paid_claim                = FactoryGirl.create :part_paid_claim, advocate: advocate
      @parts_rejected_claim           = FactoryGirl.create :parts_rejected_claim, advocate: advocate
      @refused_claim                  = FactoryGirl.create :refused_claim, advocate: advocate
      @rejected_claim                 = FactoryGirl.create :rejected_claim, advocate: advocate
      @submitted_claim                = FactoryGirl.create :submitted_claim, advocate: advocate
    end

    context 'advocate' do
      it 'should categorise the claims' do
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
      let(:other_chamber)                   { create(:chamber) }
      let(:advocate_admin)                  { create(:advocate, :admin, chamber_id: advocate.chamber.id) }
      let(:advocate_in_same_chamber)        { create(:advocate, chamber_id: advocate.chamber.id) }
      let(:advocate_in_different_chamber)   { create(:advocate, :admin, chamber_id: other_chamber.id) }

      before(:each) do
        @allocated_claim_2                = FactoryGirl.create :allocated_claim, advocate: advocate_in_same_chamber
        @appealed_claim_2                 = FactoryGirl.create :appealed_claim, advocate: advocate_in_same_chamber
        @archived_pending_delete_claim_2  = FactoryGirl.create :archived_pending_delete_claim, advocate: advocate_in_same_chamber
        @awaiting_further_info_claim_2    = FactoryGirl.create :awaiting_further_info_claim, advocate: advocate_in_same_chamber
        @awaiting_info_from_court_claim_2 = FactoryGirl.create :awaiting_info_from_court_claim, advocate: advocate_in_same_chamber
        @completed_claim_2                = FactoryGirl.create :completed_claim, advocate: advocate_in_same_chamber
        @draft_claim_2                    = FactoryGirl.create :draft_claim, advocate: advocate_in_same_chamber
        @part_paid_claim_2                = FactoryGirl.create :part_paid_claim, advocate: advocate_in_same_chamber
        @parts_rejected_claim_2           = FactoryGirl.create :parts_rejected_claim, advocate: advocate_in_same_chamber
        @refused_claim_2                  = FactoryGirl.create :refused_claim, advocate: advocate_in_same_chamber
        @rejected_claim_2                 = FactoryGirl.create :rejected_claim, advocate: advocate_in_same_chamber
        @submitted_claim_2                = FactoryGirl.create :submitted_claim, advocate: advocate_in_same_chamber

        @allocated_claim_3                = FactoryGirl.create :allocated_claim, advocate: advocate_in_different_chamber
        @appealed_claim_3                 = FactoryGirl.create :appealed_claim, advocate: advocate_in_different_chamber
        @archived_pending_delete_claim_3  = FactoryGirl.create :archived_pending_delete_claim, advocate: advocate_in_different_chamber
        @awaiting_further_info_claim_3    = FactoryGirl.create :awaiting_further_info_claim, advocate: advocate_in_different_chamber
        @awaiting_info_from_court_claim_3 = FactoryGirl.create :awaiting_info_from_court_claim, advocate: advocate_in_different_chamber
        @completed_claim_3                = FactoryGirl.create :completed_claim, advocate: advocate_in_different_chamber
        @draft_claim_3                    = FactoryGirl.create :draft_claim, advocate: advocate_in_different_chamber
        @part_paid_claim_3                = FactoryGirl.create :part_paid_claim, advocate: advocate_in_different_chamber
        @parts_rejected_claim_3           = FactoryGirl.create :parts_rejected_claim, advocate: advocate_in_different_chamber
        @refused_claim_3                  = FactoryGirl.create :refused_claim, advocate: advocate_in_different_chamber
        @rejected_claim_3                 = FactoryGirl.create :rejected_claim, advocate: advocate_in_different_chamber
        @submitted_claim_3                = FactoryGirl.create :submitted_claim, advocate: advocate_in_different_chamber

        sign_in advocate_admin.user
      end

      it 'should categorise claims from the same chamber and exclude those from another chamber' do
        get :index

        expect(response).to have_http_status(:success)

        expect(assigns(:draft_claims)).to contain_claims( @draft_claim, @draft_claim_2 )
        expect(assigns(:rejected_claims)).to contain_claims( @rejected_claim, @rejected_claim_2 )
        expect(assigns(:submitted_claims)).to contain_claims( @allocated_claim, @allocated_claim_2,
                                                              @submitted_claim, @submitted_claim_2,
                                                              @awaiting_info_from_court_claim, @awaiting_info_from_court_claim_2,
                                                              @awaiting_further_info_claim, @awaiting_further_info_claim_2)
        expect(assigns(:part_paid_claims)).to contain_claims( @part_paid_claim, @part_paid_claim_2,
                                                              @appealed_claim, @appealed_claim_2,
                                                              @parts_rejected_claim, @parts_rejected_claim_2) 
        expect(assigns(:completed_claims)).to contain_claims( @completed_claim, @completed_claim_2, @refused_claim, @refused_claim_2 )
      end
    end

    it 'renders the template' do
      get :index
      expect(response).to render_template(:index)
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
        let(:claim_params) do
          {
             additional_information: 'foo',
             court_id: court,
             case_type: 'trial',
             offence_id: offence,
             case_number: '12345',
             advocate_category: 'QC',
             prosecuting_authority: 'cps',
          }
        end

        it 'creates a claim' do
          expect {
            post :create, claim: claim_params
          }.to change(Claim, :count).by(1)
        end

        it 'redirects to claim summary' do
          post :create, claim: claim_params
          expect(response).to redirect_to(summary_advocates_claim_path(Claim.first))
        end

        it 'sets the created claim\'s advocate to the signed in advocate' do
          post :create, claim: claim_params
          expect(Claim.first.advocate).to eq(advocate)
        end
      end

      context 'and the input is invalid' do
        it 'does not create a claim' do
          expect {
            post :create, claim: { additional_information: 'foo' }
          }.to_not change(Claim, :count)
        end

        it 'render new template' do
          post :create, claim: { additional_information: 'foo' }
          expect(response).to render_template(:new)
        end
      end

      context 'basic and non-basic fees' do

        before(:each) do
          @file = fixture_file_upload('files/repo_order_1.pdf', 'application/pdf')
        end

        let!(:basic_fee_type_1)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 1' }
        let!(:basic_fee_type_2)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 2' }
        let!(:basic_fee_type_3)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 3' }
        let!(:basic_fee_type_4)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 4' }
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

            expect(claim.basic_fees.size).to eq 4             # one record for every basic fee regardless of whether blank or not
            expect(claim.basic_fees.detect{ |f| f.fee_type_id == basic_fee_type_1.id }.amount.to_f ).to eq 1000.0
            expect(claim.basic_fees.detect{ |f| f.fee_type_id == basic_fee_type_3.id }.amount.to_f ).to eq 9000.45
            expect(claim.basic_fees.detect{ |f| f.fee_type_id == basic_fee_type_4.id }.amount.to_f ).to eq 125.0
            expect(claim.basic_fees.detect{ |f| f.fee_type_id == basic_fee_type_2.id }).to be_blank

            expect(claim.non_basic_fees.size).to eq 2
            expect(claim.non_basic_fees.detect{ |f| f.fee_type_id == misc_fee_type_2.id }.amount.to_f ).to eq 250.0
            expect(claim.non_basic_fees.detect{ |f| f.fee_type_id == fixed_fee_type_1.id }.amount.to_f ).to eq 2500.0

            expect(claim.reload.fees_total).to eq 12_875.45
          end
        end

        context 'invalid params' do
          render_views
          it 'should redisplay the page with error messages and all the entered data in basic and non basic fees' do
            post :create, claim: invalid_claim_params
            expect(response.status).to eq 200
            expect(response).to render_template(:new)
            expect(response.body).to have_content("Prosecuting authority can't be blank")
            claim = assigns(:claim)
            expect(claim.basic_fees.size).to eq 4
            expect(claim.non_basic_fees.size).to eq 2

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

      context 'evidence checklist' do
        let(:court) { create(:court) }
        let(:offence) { create(:offence) }
        let(:evidence_list_item) { create(:evidence_list_item) }
        let(:claim_params) do
          {
             additional_information: 'foo',
             court_id: court,
             case_type: 'trial',
             offence_id: offence,
             case_number: '12345',
             advocate_category: 'QC',
             prosecuting_authority: 'cps',
             evidence_list_item_ids: [evidence_list_item.id.to_s]
          }
        end

        it 'should create a claim with evidence list items' do
          post :create, claim: claim_params
          claim = assigns(:claim)
          expect(claim.evidence_list_items.count).to eql(1)
        end
      end

    end
  end

  describe "PUT #update" do
    subject { create(:claim, advocate: advocate) }

    context 'when valid' do
      context 'and draft' do
        it 'updates a claim' do
          put :update, id: subject, claim: { additional_information: 'foo' }
          subject.reload
          expect(subject.additional_information).to eq('foo')
        end

        it 'redirects to claim summary path' do
          put :update, id: subject, claim: { additional_information: 'foo' }
          expect(response).to redirect_to(summary_advocates_claim_path(subject))
        end
      end

      context 'and submitted' do
        before do
          get :summary, id: subject
          put :update, id: subject, claim: { additional_information: 'foo' }, summary: true
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

    context 'when invalid' do
      it 'does not update claim' do
        put :update, id: subject, claim: { additional_information: 'foo', court_id: nil }
        subject.reload
        expect(subject.additional_information).to be_nil
      end

      it 'renders edit template' do
        put :update, id: subject, claim: { additional_information: 'foo', court_id: nil }
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
     "defendants_attributes"=>
      {"0"=>
        {"first_name" => "Stephen",
         "middle_name" => "",
         "last_name" => "Richards",
         "date_of_birth" => "1966-08-13",
         "representation_order_date" => "2015-05-13",
         "order_for_judicial_apportionment" => "0",
         "maat_reference" => "MAAT2015",
         "_destroy" => "false",
         "representation_orders_attributes"=>{
           "0"=>{
           "document"=> @file}
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
     "non_basic_fees_attributes"=>
      {
        "0"=>{"fee_type_id" => misc_fee_type_2.id.to_s, "quantity" => "2", "rate" => "125", "_destroy" => "false"},
        "1"=>{"fee_type_id" => fixed_fee_type_1.id.to_s, "quantity" => "250", "rate" => "10", "_destroy" => "false"}
      },
     "expenses_attributes"=>
     {
      "0"=>{"expense_type_id" => "", "location" => "", "quantity" => "", "rate" => "", "amount" => "", "_destroy" => "false"}
     },
     "apply_vat" => "0"
   }
end


