RSpec.shared_examples 'unused material fees tests for final claim' do
  describe '#unused_materials_applicable?' do
    subject { claim.unused_materials_applicable? }

    let(:claim) { described_class.new(defendants: defendants, case_type: case_type) }

    context 'when the claim is a trial' do
      let(:case_type) { build(:case_type, :trial) }

      context 'when the earliest representation date is on or after CLAR' do
        let(:defendants) { [build(:defendant, scheme: 'scheme 12')] }

        it { is_expected.to be_truthy }
      end

      context 'when the earliest representation date is before CLAR' do
        let(:defendants) { [build(:defendant, scheme: 'scheme 11')] }

        it { is_expected.to be_falsey }
      end
    end

    context 'when the claim is a cracked trial' do
      let(:case_type) { build(:case_type, :cracked_trial) }

      context 'when the earliest representation date is on or after CLAR' do
        let(:defendants) { [build(:defendant, scheme: 'scheme 12')] }

        it { is_expected.to be_truthy }
      end

      context 'when the earliest representation date is before CLAR' do
        let(:defendants) { [build(:defendant, scheme: 'scheme 11')] }

        it { is_expected.to be_falsey }
      end
    end

    context 'when the claim is not a trial or a cracked trial' do
      let(:case_type) { build(:case_type, :appeal_against_conviction) }
      let(:defendants) { [build(:defendant, scheme: 'scheme 12')] }

      it { is_expected.to be_falsey }
    end
  end
end

RSpec.shared_examples 'unused material fees tests for non-final claim' do
  describe '#unused_materials_applicable?' do
    subject { claim.unused_materials_applicable? }

    let(:claim) { described_class.new(defendants: defendants, case_type: case_type) }

    context 'when the claim is a trial' do
      let(:case_type) { build(:case_type, :trial) }

      context 'when the earliest representation date is on or after CLAR' do
        let(:defendants) { [build(:defendant, scheme: 'scheme 12')] }

        it { is_expected.to be_falsey }
      end
    end

    context 'when the claim is a cracked trial' do
      let(:case_type) { build(:case_type, :cracked_trial) }

      context 'when the earliest representation date is on or after CLAR' do
        let(:defendants) { [build(:defendant, scheme: 'scheme 12')] }

        it { is_expected.to be_falsey }
      end
    end

    context 'when the claim is not a trial or a cracked trial' do
      let(:case_type) { build(:case_type, :appeal_against_conviction) }
      let(:defendants) { [build(:defendant, scheme: 'scheme 12')] }

      it { is_expected.to be_falsey }
    end
  end
end
