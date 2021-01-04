require 'rails_helper'

RSpec.describe DiscEvidenceCoversheet, type: :model do
  let(:instance) { described_class.new(params) }
  let(:claim) { create(:advocate_claim) }

  context '#claim' do
    subject { instance.claim }
    let(:params) { { claim_id: claim.id } }

    it 'set by claim_id' do
      is_expected.to eql claim
    end

    it 'not available for soft deleted claims' do
      claim.soft_delete
      is_expected.to be_nil
    end
  end

  context '#external_user' do
    subject { instance.external_user }
    let(:params) { { claim_id: claim.id } }

    it 'delegated to claim' do
      is_expected.to eql claim.external_user
    end
  end

  context '#current_date' do
    subject { instance.current_date }

    context 'when params do not specify current date' do
      let(:params) { { claim_id: claim.id } }

      it 'defaults to current date' do
        is_expected.to eql Date.current
      end
    end

    context 'when params do specify parts' do
      let(:params) { { claim_id: claim.id, current_date_dd: '01', current_date_mm: '01', current_date_yyyy: '2019' } }

      it 'sets current_date from parts' do
        is_expected.to eql Date.new(2019, 01, 01)
      end
    end

    context 'when params specify current_date' do
      let(:date) { Date.new(2017, 12, 01) }
      let(:params) { { claim_id: claim.id, current_date: date } }

      it 'sets parts from current_date param' do
        expect(instance.current_date_dd).to eql '01'
        expect(instance.current_date_mm).to eql '12'
        expect(instance.current_date_yyyy).to eql '2017'
      end

      it 'sets current_date from param' do
        is_expected.to eql Date.new(2017, 12, 01)
      end
    end
  end

  context '#fee_scheme' do
    subject { instance.fee_scheme }

    before do
      seed_fee_schemes
    end

    context 'when param does not specify fee scheme' do
      let(:params) { { claim_id: claim.id } }

      it 'defaults to claim fee scheme name' do
        is_expected.to eql 'AGFS'
      end
    end

    context 'when param does specify fee scheme' do
      let(:params) { { claim_id: claim.id, fee_scheme: 'LGFS' } }

      it 'uses param value' do
        is_expected.to eql 'LGFS'
      end
    end
  end

  context '#agfs?' do
    subject { instance.agfs? }

    context 'when fee scheme is AGFS' do
      let(:params) { { claim_id: claim.id, fee_scheme: 'AGFS' } }

      it 'returns true' do
        is_expected.to be_truthy
      end
    end

    context 'when fee scheme is LGFS' do
      let(:params) { { claim_id: claim.id, fee_scheme: 'LGFS' } }

      it 'returns false' do
        is_expected.to be_falsey
      end
    end
  end

  context '#lgfs?' do
    subject { instance.lgfs? }

    context 'when fee scheme is AGFS' do
      let(:params) { { claim_id: claim.id, fee_scheme: 'AGFS' } }

      it 'returns false' do
        is_expected.to be_falsey
      end
    end

    context 'when fee scheme is LGFS' do
      let(:params) { { claim_id: claim.id, fee_scheme: 'LGFS' } }

      it 'returns false' do
        is_expected.to be_truthy
      end
    end
  end

  context '#case_number' do
    subject { instance.case_number }

    context 'when param does not specify case_number' do
      let(:params) { { claim_id: claim.id } }

      it 'defaults to claim case_number' do
        is_expected.to eql claim.case_number
      end
    end

    context 'when param does specify case_number' do
      let(:params) { { claim_id: claim.id, case_number: 'ANYOLDCASENUMBER' } }

      it 'uses param value' do
        is_expected.to eql 'ANYOLDCASENUMBER'
      end
    end
  end

  context '#court_name' do
    subject { instance.court_name }

    context 'when param does not specify court_name' do
      let(:params) { { claim_id: claim.id } }

      it 'defaults to claim court\'s name' do
        is_expected.to eql claim.court.name
      end
    end

    context 'when param does specify court_name' do
      let(:params) { { claim_id: claim.id, court_name: 'ANYOLDCOURTNAME' } }

      it 'uses param value' do
        is_expected.to eql 'ANYOLDCOURTNAME'
      end
    end
  end

  context '#claim_submitted_at' do
    subject { instance.claim_submitted_at }

    context 'when params do not specify claim_submitted_at' do
      let(:params) { { claim_id: claim.id } }

      it 'defaults to current date' do
        is_expected.to be_nil
      end
    end

    context 'when params do specify parts' do
      let(:params) { { claim_id: claim.id, claim_submitted_at_dd: '01', claim_submitted_at_mm: '01', claim_submitted_at_yyyy: '2019' } }

      it 'sets current_date from parts' do
        is_expected.to eql Date.new(2019, 01, 01)
      end
    end

    context 'when params specify claim_submitted_at' do
      let(:date) { Date.new(2017, 12, 01) }
      let(:params) { { claim_id: claim.id, claim_submitted_at: date } }

      it 'sets parts from current_date param' do
        expect(instance.claim_submitted_at_dd).to eql '01'
        expect(instance.claim_submitted_at_mm).to eql '12'
        expect(instance.claim_submitted_at_yyyy).to eql '2017'
      end

      it 'sets claim_submitted_at from param' do
        is_expected.to eql Date.new(2017, 12, 01)
      end
    end
  end

  context '#defendant_name' do
    subject { instance.defendant_name }

    context 'when param does not specify defendant_name' do
      let(:params) { { claim_id: claim.id } }

      it 'defaults to claim\'s first defendants name' do
        is_expected.to eql claim.defendants.first.name
      end
    end

    context 'when param does specify defendant_name' do
      let(:params) { { claim_id: claim.id, defendant_name: 'ANYOLDDEFENDANTNAME' } }

      it 'uses param value' do
        is_expected.to eql 'ANYOLDDEFENDANTNAME'
      end
    end
  end

  context '#maat_reference' do
    subject { instance.maat_reference }

    context 'when param does not specify maat_reference' do
      let(:params) { { claim_id: claim.id } }

      it 'defaults to claim\'s earliest rep order maat_reference' do
        is_expected.to eql claim.earliest_representation_order.maat_reference
      end
    end

    context 'when param does specify maat_reference' do
      let(:params) { { claim_id: claim.id, maat_reference: 'ANYOLDMAATREF' } }

      it 'uses param value' do
        is_expected.to eql 'ANYOLDMAATREF'
      end
    end
  end

  context '#provider_account_no' do
    subject { instance.provider_account_no }

    context 'when param does not specify provider_account_no' do
      let(:params) { { claim_id: claim.id } }

      it 'defaults to claim\'s supplier_number' do
        is_expected.to eql claim.supplier_number
      end
    end

    context 'when param does specify provider_account_no' do
      let(:params) { { claim_id: claim.id, provider_account_no: 'ANYOLDSUPPLIERNO' } }

      it 'uses param value' do
        is_expected.to eql 'ANYOLDSUPPLIERNO'
      end
    end
  end

  context '#provider_address' do
    subject { instance.provider_address }

    context 'when param does not specify provider_address' do
      let(:params) { { claim_id: claim.id } }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when param does specify provider_address' do
      let(:params) { { claim_id: claim.id, provider_address: "\n\tANYOLDPROVIDERADDRESS\t\n" } }

      it 'uses stripped param value' do
        is_expected.to eql 'ANYOLDPROVIDERADDRESS'
      end
    end
  end

  context '#data_storage_type' do
    subject { instance.data_storage_type }

    context 'when param does not specify data_storage_type' do
      let(:params) { { claim_id: claim.id } }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when param does specify data_storage_type' do
      let(:params) { { claim_id: claim.id, data_storage_type: 'ANYOLDDATASTORAGETYPE' } }

      it 'uses param value' do
        is_expected.to eql 'ANYOLDDATASTORAGETYPE'
      end
    end
  end
end
