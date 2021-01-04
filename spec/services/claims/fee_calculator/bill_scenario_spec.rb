RSpec.shared_examples 'expected bill scenario' do |options|
  it 'returns a string' do
    is_expected.to be_a String
  end

  if options[:scenario]
    it "returns code #{options[:scenario]}" do
      is_expected.to eql options[:scenario]
    end
  end
end

RSpec.describe Claims::FeeCalculator::BillScenario do
  subject { described_class.new(claim, fee_type) }

  let(:claim) { build(:draft_claim) }
  let(:fee_type) { build(:graduated_fee_type) }

  it { is_expected.to respond_to(:call) }
  it { is_expected.to respond_to(:claim) }
  it { is_expected.to respond_to(:fee_type) }
  it { is_expected.to respond_to(:namespace) }

  context 'AGFS' do
    subject(:bill_scenario) { described_class.new(claim, fee_type).call }

    context 'advocate claim - based on case type' do
      let(:claim) { build(:advocate_claim) }

      before do
        expect(claim).to receive(:case_type).and_return instance_double(CaseType, fee_type_code: 'GRGLT')
      end

      it_returns 'expected bill scenario', scenario: 'AS000002'
    end

    context 'advocate supplementary claim - defaults to trial case type' do
      let(:claim) { build(:advocate_supplementary_claim, case_type: nil) }

      it_returns 'expected bill scenario', scenario: 'AS000004'
    end
  end

  context 'LGFS' do
    subject(:bill_scenario) { described_class.new(claim, fee_type).call }
    let(:claim) { build(:litigator_claim) }

    context 'final graduated fee' do
      before do
        expect(claim).to receive(:lgfs?).and_return(true)
        expect(claim).to receive(:case_type).and_return instance_double(CaseType, fee_type_code: 'GRTRL')
      end

      it_returns 'expected bill scenario', scenario: 'ST1TS0T4'
    end

    context 'final fixed fee' do
      before do
        expect(claim).to receive(:lgfs?).and_return(true)
        expect(claim).to receive(:case_type).and_return instance_double(CaseType, fee_type_code: 'FXCON')
      end

      it_returns 'expected bill scenario', scenario: 'ST1TS0T8'
    end

    context 'interim fee' do
      let(:claim) { build(:interim_claim) }

      before do
        expect(claim).to receive(:lgfs?).and_return(true)
        expect(claim).to receive(:interim?).and_return(true)
        expect(fee_type).to receive(:unique_code).and_return 'INPCM' # Interim Claim - Effective PCMH - Trial only
      end

      it_returns 'expected bill scenario', scenario: 'ST1TS0T0'
    end

    context 'transfer fee' do
      let(:claim) { build(:transfer_claim) }

      before do
        expect(claim).to receive(:lgfs?).and_return(true)
        expect(claim).to receive(:transfer?).and_return(true)
        expect(claim).to receive(:transfer_detail).and_return instance_double(Claim::TransferDetail, bill_scenario: 'MYTRANSFERCODE')
      end

      it_returns 'expected bill scenario', scenario: 'MYTRANSFERCODE'
    end

    context 'hardship fee' do
      let(:claim) { build(:litigator_hardship_claim) }

      it_returns 'expected bill scenario', scenario: 'ST2TS1T0'
    end
  end
end
