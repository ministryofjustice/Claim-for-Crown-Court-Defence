RSpec.shared_context 'when set up for #unused_materials_applicable? tests' do |options|
  subject { claim.unused_materials_applicable? }

  let(:case_type) { build :case_type, (options[:case_type_name] || :trial) }
  let(:claim) do
    described_class.new(
      defendants: [defendant],
      case_type: case_type,
      allocation_type: options[:allocation_type]
    )
  end
end

RSpec.shared_examples 'a claim eligible for unused materials fee' do |options|
  describe '#unused_materials_applicable?' do
    include_context 'when set up for #unused_materials_applicable? tests', options.to_h

    context 'when the earliest representation date is on or after CLAR' do
      let(:defendant) { build :defendant, scheme: 'scheme 12' }

      it { is_expected.to be_truthy }
    end

    context 'when the earliest representation date is before CLAR' do
      let(:defendant) { build :defendant, scheme: 'scheme 11' }

      it { is_expected.to be_falsey }
    end
  end
end

RSpec.shared_examples 'a claim not eligible for unused materials fee' do |options|
  describe '#unused_materials_applicable?' do
    include_context 'when set up for #unused_materials_applicable? tests', options.to_h

    context 'when the earliest representation date is on or after CLAR' do
      let(:defendant) { build :defendant, scheme: 'scheme 12' }

      it { is_expected.to be_falsey }
    end
  end
end
