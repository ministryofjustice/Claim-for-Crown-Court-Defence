require 'rails_helper'

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
    before { get :index }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    context 'advocate' do
      before do
        create(:claim,            advocate: advocate)
        create(:submitted_claim,  advocate: advocate)
        create(:completed_claim,  advocate: advocate)
        create(:rejected_claim,   advocate: advocate)
      end

      it 'assigns @submitted_claims' do
        expect(assigns(:submitted_claims)).to eq(advocate.reload.claims.submitted.order(created_at: :desc))
      end

      it 'assigns @submitted_or_allocated_claims' do
        expect(assigns(:submitted_or_allocated_claims)).to eq(advocate.reload.claims.submitted_or_allocated.order(created_at: :desc))
      end

      it 'assigns @rejected_claims' do
        expect(assigns(:rejected_claims)).to eq(advocate.reload.claims.rejected.order(created_at: :desc))
      end

      it 'assigns @allocated_claims' do
        expect(assigns(:allocated_claims)).to eq(advocate.reload.claims.allocated.order(created_at: :desc))
      end

      it 'assigns @part_paid_claims' do
        expect(assigns(:part_paid_claims)).to eq(advocate.reload.claims.part_paid.order(created_at: :desc))
      end

      it 'assigns @completed_claims' do
        expect(assigns(:completed_claims)).to eq(advocate.reload.claims.completed.order(created_at: :desc))
      end

      it 'assigns @draft_claims' do
        expect(assigns(:draft_claims)).to eq(advocate.reload.claims.draft.order(created_at: :desc))
      end
    end

    context 'advocate admin' do
      let(:chamber) { create(:chamber) }
      let(:advocate_admin) { create(:advocate, :admin, chamber_id: chamber.id) }

      before do
        create(:claim, advocate: advocate)
        create(:submitted_claim, advocate: advocate)
        create(:completed_claim, advocate: advocate)

        advocate.update_column(:chamber_id, chamber.id)
        create(:claim, advocate: advocate.reload)

        sign_in advocate_admin.user
      end

      it 'assigns @submitted_claims' do
        expect(assigns(:submitted_claims)).to eq(advocate.reload.chamber.claims.submitted.order(created_at: :desc))
      end

      it 'assigns @rejected_claims' do
        expect(assigns(:rejected_claims)).to eq(advocate.reload.chamber.claims.rejected.order(created_at: :desc))
      end

      it 'assigns @allocated_claims' do
        expect(assigns(:allocated_claims)).to eq(advocate.reload.chamber.claims.allocated.order(created_at: :desc))
      end

      it 'assigns @part_paid_claims' do
        expect(assigns(:part_paid_claims)).to eq(advocate.reload.chamber.claims.part_paid.order(created_at: :desc))
      end

      it 'assigns @completed_claims' do
        expect(assigns(:completed_claims)).to eq(advocate.reload.chamber.claims.completed.order(created_at: :desc))
      end

      it 'assigns @draft_claims' do
        expect(assigns(:draft_claims)).to eq(advocate.reload.chamber.claims.draft.order(created_at: :desc))
      end
    end

    it 'renders the template' do
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
        let!(:basic_fee_type_1)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 1' }
        let!(:basic_fee_type_2)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 2' }
        let!(:basic_fee_type_3)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 3' }
        let!(:basic_fee_type_4)         { FactoryGirl.create :fee_type, :basic, description: 'Basic Fee Type 4' }
        let!(:misc_fee_type_1)          { FactoryGirl.create :fee_type, :misc, description: 'Miscellaneous Fee Type 1' }
        let!(:misc_fee_type_2)          { FactoryGirl.create :fee_type, :misc, description: 'Miscellaneous Fee Type 2' }
        let!(:fixed_fee_type_1)         { FactoryGirl.create :fee_type, :fixed, description: 'Fixed Fee Type 1' }

        let(:court)                     { create(:court) }
        let(:offence)                   { create(:offence) }
        let(:claim_params)              { full_valid_params }
        let(:invalid_claim_params)      { full_valid_params.reject{ |k,v| k == 'prosecuting_authority'} }

        context 'valid params' do
          it 'should create a claim with all basic fees and the specified non-basic fees' do
            post :create, claim: claim_params
            claim = assigns(:claim)
            puts ">>>>>>>>>>>>>>>> DEBUG message    #{__FILE__}::#{__LINE__} <<<<<<<<<<"
            ap claim, plain: true
            puts ">>>>>>>>>>>>>>>> DEBUG errors    #{__FILE__}::#{__LINE__} <<<<<<<<<<"
            ap claim.errors.full_messages


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
      expect(Claim.count).to eq(0)
    end

    it "sets the claim's state to 'archived_pending_delete'" do
      expect(subject.reload).to be_archived_pending_delete
    end

    it 'redirects to advocates root url' do
      expect(response).to redirect_to(advocates_claims_url)
    end
  end
end


def full_valid_params
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
           "document"=> mock_uploaded_file}
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
     "apply_vat" => "0"}
end

def mock_uploaded_file
  ActionDispatch::Http::UploadedFile.new(tempfile: Tempfile.new('abc.txt'), 
      filename: File.basename('/repo_order.pdf'), 
      original_filename: 'repo_order_2.pdf',
      type: "application/pdf",
      content_type: 'application/pdf',
      headers: "Content-Disposition: form-data; name=\"claim[defendants_attributes][0][representation_orders_attributes][0][document]\"; filename=\"repo_order_2.pdf\"\r\nContent-Type: application/pdf\r\n"
      )        
end



