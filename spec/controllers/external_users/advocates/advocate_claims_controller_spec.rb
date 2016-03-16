require 'rails_helper'
require 'custom_matchers'

RSpec.describe ExternalUsers::Advocates::ClaimsController, type: :controller, focus: true do

  let!(:advocate)       { create(:external_user, :advocate) }
  before { sign_in advocate.user }

  describe "GET #new" do

    context 'AGFS or LGFS provider members only' do
      before { get :new }
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @claim' do
        expect(assigns(:claim)).to be_new_record
      end

      it 'assigns @claim to be an advocate claim' do
        expect(assigns(:claim).class).to eql Claim::AdvocateClaim
      end

      it 'renders the template' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe "POST #create" do
    context 'when advocate signed in' do
      context 'and the input is valid' do
        let(:court)         { create(:court) }
        let(:offence)       { create(:offence) }
        let(:case_type)     { create(:case_type) }
        let(:expense_type)  { create(:expense_type) }
        let(:claim_params) do
          {
            additional_information: 'foo',
            court_id: court,
            case_type_id: case_type.id,
            offence_id: offence,
            case_number: 'A12345678',
            advocate_category: 'QC',
            expenses_attributes:
              [
                {
                  expense_type_id: expense_type.id,
                  location: "London",
                  quantity: 1,
                  rate: 40
                }
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
                    maat_reference: '4561237895'
                  }
                ]
              }
            ]
          }
        end
      end
    end
  end

end
