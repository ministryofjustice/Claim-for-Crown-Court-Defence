shared_examples 'defendant uplift delegation' do
  it { is_expected.to respond_to(:defendant_uplift?) }
  it { is_expected.to respond_to(:orphan_defendant_uplift?) }
  it { is_expected.to delegate_method(:defendant_uplift?).to(:fee_type) }
  it { is_expected.to delegate_method(:orphan_defendant_uplift?).to(:fee_type) }
end

shared_examples '.defendant_uplift_sums' do
  context 'miscellaneous fees' do
    describe '.defendant_uplift_sums' do
      subject { described_class.defendant_uplift_sums }
      let(:claim) { create(:advocate_claim) }
      let(:miahu) { create(:misc_fee_type, :miahu) }

      before do
        create(:misc_fee, fee_type: miahu, claim: claim, quantity: 3, amount: 21.01)
      end

      it 'returns hash of sums grouped by fee\'s unique_code' do
        is_expected.to eql({ 'MIAHU' => 3 })
      end
    end
  end
end

shared_examples 'defendant upliftable' do
  it { is_expected.to respond_to(:defendant_uplift?) }
  it { is_expected.to respond_to(:orphan_defendant_uplift?) }
  it { is_expected.to respond_to(:case_uplift_parent_unique_code) }

  describe '#defendant_uplift?' do
    subject { fee_type.defendant_uplift? }

    it 'returns true when fee_type is a defendant uplift' do
      fee_type.unique_code = 'MIAHU'
      is_expected.to be_truthy
    end

    it 'returns false when fee_type is not a defendant uplift' do
      fee_type.unique_code = 'MIAPH'
      is_expected.to be_falsey
    end
  end

  describe '#orphan_defendant_uplift?' do
    subject { fee_type.defendant_uplift? }

    it 'returns true when fee_type is a defendant uplift' do
      fee_type.unique_code = 'FXNDR'
      is_expected.to be_truthy
    end

    it 'returns false when fee_type is not a defendant uplift' do
      fee_type.unique_code = 'FXACV'
      is_expected.to be_falsey
    end
  end

  describe '.defendant_uplifts' do
    it 'calls .defendant_uplift_unique_codes' do
      expect(described_class).to receive(:defendant_uplift_unique_codes)
      described_class.defendant_uplifts
    end
  end

  describe '.defendant_uplift_unique_codes' do
    subject { described_class.defendant_uplift_unique_codes }

    it 'includes orphan defendant uplift unique codes' do
      is_expected.to include(*%w[BANDR FXNDR MIUPL])
    end
  end

  describe '#defendant_uplift_parent_unique_code' do
    subject { fee_type.defendant_uplift_parent_unique_code }

    context 'for non-orphan defendant uplift fees types with one parent' do
      before { allow(fee_type).to receive(:unique_code).and_return 'MIAHU' }

      it 'returns parent fee type unique code' do
        is_expected.to eql 'MIAPH'
      end
    end

    context 'for non-orphan defendant uplift fees types with two parents' do
      before { allow(fee_type).to receive(:unique_code).and_return 'MISAU' }

      context 'when supplementary claim passed as an arg' do
        subject { fee_type.defendant_uplift_parent_unique_code(claim) }
        let(:claim) { instance_double(Claim::AdvocateSupplementaryClaim, supplementary?: true) }

        it 'returns parent miscellaneous fee type unique code' do
          is_expected.to eql 'MISAF'
        end
      end

      context 'when no claim passed as an arg' do
        it 'returns parent basic fee type unique code' do
          is_expected.to eql 'BASAF'
        end
      end
    end

    context 'for orphan defendant uplift fees types' do
      before { allow(fee_type).to receive(:unique_code).and_return 'MIUPL' }
      it { is_expected.to be_nil }
    end

    context 'for non-defendant uplift fees types' do
      before { allow(fee_type).to receive(:unique_code).and_return 'MIAPH' }
      it { is_expected.to be_nil }
    end
  end

  describe '::DEFENDANT_UPLIFT_MAPPINGS' do
    subject { described_class::DEFENDANT_UPLIFT_MAPPINGS[code] }

    DEFENDANT_UPLIFT_MAPPINGS ||= {
        MISAF: 'MISAU', # Standard appearance fee uplift (supplementary)
        MIAPH: 'MIAHU', # Abuse of process hearings (half day uplift)
        MIAPW: 'MIAWU', # Abuse of process hearings (whole day uplift)
        MIADC1: 'MIADC3', # Application to dismiss a charge (half day uplift)
        MIADC2: 'MIADC4', # Application to dismiss a charge (whole day uplift)
        MIDTH: 'MIDHU', # Confiscation hearings (half day uplift)
        MIDTW: 'MIDWU', # Confiscation hearings (whole day uplift)
        MIDSE: 'MIDSU', # Deferred sentence hearings uplift
        MIAEH: 'MIEHU', # Hearings relating to admissibility of evidence (half day uplift)
        MIAEW: 'MIEWU', # Hearings relating to admissibility of evidence (whole day uplift)
        MIHDH: 'MIHHU', # Hearings relating to disclosure (half day uplift)
        MIHDW: 'MIHWU', # Hearings relating to disclosure (whole day uplift)
        MIPPC: 'MIPCU', # Paper plea & case management uplift
        MIPCH: 'MICHU', # Proceeds of crime hearings (half day uplift)
        MIPCW: 'MICHW', # Proceeds of crime hearings (whole day uplift)
        MIPIH1: 'MIPIU3', # Public interest immunity hearings (half day uplift)
        MIPIH2: 'MIPIH4', # Public interest immunity hearings (whole day uplift)
        MISHR: 'MISHU', # Sentence hearings uplift
        MITNP: 'MITNU', # Trial not proceed uplift
        MIUAV1: 'MIUAV3', # Unsuccessful application to vacate a guilty plea (half day uplift)
        MIUAV2: 'MIUAV4' # Unsuccessful application to vacate a guilty plea (whole day uplift)
    }.freeze

    context 'mappings' do
      DEFENDANT_UPLIFT_MAPPINGS.each do |code, uplift_code|
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
