# frozen_string_literal: true

RSpec.shared_examples 'fee_type_rules_creator' do
  it { is_expected.to respond_to(:sets) }

  before do
    create(:misc_fee_type, :miumu)
    create(:misc_fee_type, :miumo)
  end

  describe '.all' do
    subject { described_class.all }

    it { is_expected.to be_an Array }
    it { is_expected.to all(be_a(Rule::Set)) }
  end

  describe '.where' do
    subject { described_class.where(unique_code: unique_code) }

    context 'with unique code matching existing set' do
      let(:unique_code) { 'MIUMU' }

      it { is_expected.to all(be_a(Rule::Set)) }
    end

    context 'with unique code not matching existing set' do
      let(:unique_code) { 'NOTEXIST' }

      it { is_expected.to be_empty }
    end
  end
end
