RSpec.shared_context 'when set up for #unused_materials_applicable? tests' do |case_type_name|
  subject { claim.unused_materials_applicable? }

  let(:case_type) { build :case_type, name: (case_type_name || 'Trial') }
  let(:claim) { described_class.new(defendants: [defendant], case_type: case_type) }
end

RSpec.shared_examples 'a claim eligible for unused materials fee' do |case_type_name|
  describe '#unused_materials_applicable?' do
    include_context 'when set up for #unused_materials_applicable? tests', case_type_name

    context 'when the earliest representation date is on or after 17th September 2020 (scheme 12/CLAR)' do
      let(:defendant) { build :defendant, scheme: 'scheme 12' }

      it { is_expected.to be_truthy }
    end

    context 'when the earliest representation date is before 17th September 2020' do
      let(:defendant) { build :defendant, scheme: 'scheme 11' }

      it { is_expected.to be_falsey }
    end
  end
end

RSpec.shared_examples 'a claim not eligible for unused materials fee' do |case_type_name|
  describe '#unused_materials_applicable?' do
    include_context 'when set up for #unused_materials_applicable? tests', case_type_name

    context 'when the earliest representation date is on or after 17th September 2020 (scheme 12/CLAR)' do
      let(:defendant) { build :defendant, scheme: 'scheme 12' }

      it { is_expected.to be_falsey }
    end
  end
end
