require 'rails_helper'

RSpec.describe 'Disc evidence covertsheet', type: :request do
  let!(:advocate) { create(:external_user, :advocate) }
  let(:claim) { create(:claim, external_user: advocate) }

  before do
    seed_fee_schemes
    sign_in advocate.user
  end

  describe 'GET #new' do
    before { get new_external_users_claim_disc_evidence_coversheets_path(claim) }

    it 'displays form' do
      expect(response).to be_successful
    end

    context 'prefills basic form values' do
      subject(:body) { response.body }
      it { expect(body).to include(claim.case_number) }
      it { expect(body).to include(claim.court.name) }
      it { expect(body).to include(claim.defendants.first.name) }
      it { expect(body).to include(claim.earliest_representation_order.maat_reference) }
      it { expect(body).to include(claim.supplier_number) }

      # TODO: test date form field output (3 part gov uk date fields)
      # TODO: test fee scheme checkbox form field
    end
  end

  describe 'POST #create' do
    before { post external_users_claim_disc_evidence_coversheets_path(params) }
    let(:params) { { format: fmt, claim_id: claim.id, disc_evidence_coversheet: { fee_scheme: 'AGFS' } } }

    context 'pdf format' do
      let(:fmt) { 'pdf' }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'renders pdf template' do
        expect(response).to render_template('pdfs/templates/disc_evidence_coversheet.html.erb')
      end

      it 'returns the pdf mime type' do
        expect(response.media_type).to eql('application/pdf')
      end

      it 'renders a pdf' do
        expect(response.body[0,4]).to eq('%PDF')
      end

      it 'returns pdf inline' do
        expect(response['Content-disposition']).to include('inline')
      end

      it 'returns pdf filename including case number' do
        expect(response['Content-disposition']).to include("filename=\"disc_evidence_coversheet_#{claim.case_number}.pdf\"")
      end
    end

    context 'html format' do
      let(:fmt) { 'html' }

      it 'returns http success' do
        expect(response).to be_successful
      end

      it 'renders pdf template' do
        expect(response).to render_template('pdfs/templates/disc_evidence_coversheet.html.erb')
      end

      it 'returns the html mime type' do
        expect(response.media_type).to eql('text/html')
      end
    end
  end
end
