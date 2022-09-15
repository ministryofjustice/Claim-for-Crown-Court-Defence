RSpec.shared_examples 'case upliftable' do
  it { is_expected.to respond_to :case_uplift? }
  it { is_expected.to respond_to :orphan_case_uplift? }
  it { is_expected.to respond_to :case_uplift_parent }
  it { is_expected.to respond_to :case_uplift_parent_unique_code }

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

  describe '#orphan_case_uplift?' do
    subject { fee_type.orphan_case_uplift? }

    context 'for orphan case uplift fees types' do
      %w[BANOC FXNOC].each do |unique_code|
        before { allow(fee_type).to receive(:unique_code).and_return unique_code }

        it "#{unique_code} should return true" do
          is_expected.to be_truthy
        end
      end
    end

    context 'for non-orphan case uplift fees types' do
      %w[FXACU FXASU FXCBU FXCSU FXCDU FXENU].each do |unique_code|
        before { allow(fee_type).to receive(:unique_code).and_return unique_code }

        it "#{unique_code} should return false" do
          is_expected.to be_falsy
        end
      end
    end
  end

  describe '#case_uplift_parent' do
    subject { fee_type.case_uplift_parent }

    before { create(:fixed_fee_type, :fxacv) }

    context 'for non-orphan case uplift fees types' do
      before do
        allow(fee_type).to receive(:unique_code).and_return 'FXACU'
      end

      it 'returns a fee type' do
        is_expected.to be_a Fee::BaseFeeType
      end

      it 'returns parent fee type' do
        is_expected.to have_attributes(unique_code: 'FXACV')
      end
    end

    context 'for orphan case uplift fees types' do
      before { allow(fee_type).to receive(:unique_code).and_return 'FXNOC' }

      it { is_expected.to be_nil }
    end

    context 'for non-case uplift fees types' do
      before { allow(fee_type).to receive(:unique_code).and_return 'FXNDR' }

      it { is_expected.to be_nil }
    end
  end

  describe '#case_uplift_parent_unique_code' do
    subject { fee_type.case_uplift_parent_unique_code }

    context 'for non-orphan case uplift fees types' do
      before { allow(fee_type).to receive(:unique_code).and_return 'FXACU' }

      it 'returns parent fee type unique code' do
        is_expected.to eql 'FXACV'
      end
    end

    context 'for orphan case uplift fees types' do
      before { allow(fee_type).to receive(:unique_code).and_return 'FXNOC' }

      it { is_expected.to be_nil }
    end

    context 'for non-case uplift fees types' do
      before { allow(fee_type).to receive(:unique_code).and_return 'FXNDR' }

      it { is_expected.to be_nil }
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
