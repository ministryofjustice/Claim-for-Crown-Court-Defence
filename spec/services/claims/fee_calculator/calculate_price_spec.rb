RSpec.describe Claims::FeeCalculator::CalculatePrice do
  subject { described_class.new(claim, params) }

  # IMPORTANT: use specific case type, offence class, fee types and reporder
  # date in order to reduce and afix VCR cassettes required (that have to match
  # on query values), prevent flickering specs (from random offence classes,
  # rep order dates) and to allow testing actual amounts "calculated".
  let(:claim) do
    create(:draft_claim,
      create_defendant_and_rep_order: false,
      create_defendant_and_rep_order_for_scheme_9: true,
      case_type: case_type, offence: offence
    )
  end
  let(:case_type) { create(:case_type, :appeal_against_conviction) }
  let(:offence_class) { create(:offence_class, class_letter: 'K') }
  let(:offence) { create(:offence, offence_class: offence_class) }
  let(:fee_type) { create(:fixed_fee_type, :fxacv) }
  let(:fee) { create(:fixed_fee, fee_type: fee_type, claim: claim, quantity: 1) }

  let(:params) do
    {
      format: :json,
      id: claim.id,
      advocate_category: 'Junior alone',
      fee_type_id: fee.fee_type.id,
      fees: {
        "0": { fee_type_id: fee.fee_type.id, quantity: fee.quantity }
      }
    }
  end

  it { is_expected.to respond_to(:call) }
  it { is_expected.to delegate_method(:earliest_representation_order_date).to(:claim) }
  it { is_expected.to delegate_method(:agfs?).to(:claim) }
  it { is_expected.to delegate_method(:lgfs?).to(:claim) }
  it { is_expected.to delegate_method(:agfs_reform?).to(:claim) }
  it { is_expected.to delegate_method(:case_type).to(:claim) }
  it { is_expected.to delegate_method(:offence).to(:claim) }
  it { is_expected.to delegate_method(:defendants).to(:claim) }

  it { is_expected.to respond_to(:claim) }
  it { is_expected.to respond_to(:options) }
  it { is_expected.to respond_to(:fee_type) }
  it { is_expected.to respond_to(:advocate_category) }
  it { is_expected.to respond_to(:quantity) }
  it { is_expected.to respond_to(:current_page_fees) }

  describe '#call' do
    subject(:response) { described_class.new(claim, params).call }

    it 'returns a response object' do
      is_expected.to be_a Claims::FeeCalculator::Response
    end

    it 'returns a response error message \'implement in subclass\'' do
      expect(response.errors).to include(a_kind_of(RuntimeError))
      expect(response.errors.map(&:message)).to include('implement in subclass')
    end
  end

  context 'Subclasses' do
    class SubclassPrice < described_class
      private

      def amount
        1001.00
      end
    end

    describe '#call' do
      subject(:response) { SubclassPrice.new(claim, params).call }

      it 'returns a response object' do
        is_expected.to be_a Claims::FeeCalculator::Response
      end

      context 'response object' do
        it { is_expected.to respond_to(:success?) }
        it { is_expected.to respond_to(:data) }
        it { is_expected.to respond_to(:errors) }
        it { is_expected.to respond_to(:message) }
      end

      context 'data object' do
        subject(:data) { response.data }

        it { is_expected.to respond_to(:amount) }
        it { is_expected.to respond_to(:unit) }
      end

      it 'populates data amount' do
        expect(response.data.amount).to eql 1001.00
      end

      it 'unit may be populated' do
        expect(response.data.unit).to be_nil
      end

      context 'when setup fails' do
        before { params.delete(:fee_type_id) }

        it 'returns a response error' do
          expect(response.errors).to include(a_kind_of(RuntimeError))
          expect(response.errors.map(&:message)).to include('incomplete')
        end
      end
    end
  end
end
