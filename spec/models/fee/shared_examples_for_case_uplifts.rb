shared_examples 'case upliftable' do
  it { is_expected.to respond_to :case_uplift? }

  describe '#case_uplift?' do
    subject { fee_type.case_uplift? }

    context 'for fees that require additional case numbers' do
      %w[BANOC FXNOC FXACU FXASU FXCBU FXCSU FXCDU FXENU].each do |unique_code|
        before { allow(fee_type).to receive(:unique_code).and_return unique_code }

        it "#{unique_code} should return true" do
          is_expected.to be_truthy
        end
      end
    end
  end

  describe '::CASE_UPLIFT_MAPPINGS' do
    subject { described_class::CASE_UPLIFT_MAPPINGS[code] }

    CASE_UPLIFT_MAPPINGS = {
      FXACV: 'FXACU',
      FXASE: 'FXASU',
      FXCBR: 'FXCBU',
      FXCSE: 'FXCSU',
      FXENP: 'FXENU'
    }.with_indifferent_access.freeze

    context 'mappings' do
      CASE_UPLIFT_MAPPINGS.each do |code, uplift_code|
        context "code #{code}" do
          let(:code) { code }

          it "returns #{uplift_code}" do
            is_expected.to eql uplift_code
          end
        end
      end
    end
  end
end