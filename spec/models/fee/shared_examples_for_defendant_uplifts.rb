shared_examples '#defendant_uplift?' do
  describe '#defendant_uplift?' do
    before do
      allow(subject).to receive(:fee_type).and_return fee_type
    end

    it 'delegates to fee type' do
      expect(fee_type).to receive(:defendant_uplift?)
      subject.defendant_uplift?
    end
  end
end

shared_examples '.defendant_uplift_sums' do
  describe '.defendant_uplift_sums' do
    subject { described_class.defendant_uplift_sums }
    let(:claim) { create(:claim) }
    let(:miahu) { create(:misc_fee_type, :miahu) }

    before do
      create(:misc_fee, fee_type: miahu, claim: claim, quantity: 3, amount: 21.01)
    end

    it 'returns hash of sums grouped by fee\'s unique_code' do
      is_expected.to eql({ "MIAHU" => 3 })
    end
  end
end

shared_examples 'defendant upliftable' do
 describe '#defendant_uplift?' do
    subject { fee_type.defendant_uplift? }

    it 'returns true when fee_type is a defendant uplift' do
      fee_type.unique_code = 'MIAHU'
      is_expected.to be_truthy
    end

    it 'returns false when fee_type is not a defendant uplift' do
      fee_type.unique_code = 'MIUPL'
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
      is_expected.to include(*%w[BANDR FXNDR])
    end
  end

  describe '::DEFENDANT_UPLIFT_MAPPINGS' do
    subject { described_class::DEFENDANT_UPLIFT_MAPPINGS[code] }

    DEFENDANT_UPLIFT_MAPPINGS ||= {
        BASAF: 'MISAU', # Standard appearance fee uplift
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
        MIUAV2: 'MIUAV4', # Unsuccessful application to vacate a guilty plea (whole day uplift)
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
