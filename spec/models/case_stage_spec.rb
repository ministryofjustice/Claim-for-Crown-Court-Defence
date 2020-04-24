RSpec.describe CaseStage, type: :model do
  subject(:case_stage) { create(:case_stage) }

  it { is_expected.to belong_to(:case_type) }

  # should delegate stuff?! to case type
  # TODO: write custom matcher for delegate_missing_to rails helper or spec individually
  xit { is_expected.to delegate_method(:requires_trial_dates?).to(:case_type) }
  xit { is_expected.to delegate_method(:requires_retrial_dates?).to(:case_type) }
  xit { is_expected.to delegate_method(:requires_cracked_dates?).to(:case_type) }
  xit { is_expected.to delegate_method(:is_fixed_fee?).to(:case_type) }

  it_behaves_like 'roles', CaseStage, CaseStage::ROLES

  it { is_expected.to respond_to(:case_type_id, :case_type, :unique_code, :description, :position, :roles, :agfs?, :lgfs?) }

  describe '#unique_code' do
    it { is_expected.to validate_presence_of(:unique_code).with_message('Case stage unique_code must exist') }
    it { is_expected.to validate_uniqueness_of(:unique_code).with_message('Case stage unique_code must be unique') }
  end

  describe '#description' do
    it { is_expected.to validate_presence_of(:description).with_message('Case stage description must exist') }
  end

  describe '#case_type' do
    it { expect(case_stage.case_type).to be_a CaseType }
  end

  describe '#name' do
    subject { case_stage.name }
    it { is_expected.to eql case_stage.description }
  end

  describe '.chronological' do
    subject(:set) { described_class.chronological }

    before do
      create(:case_stage, position: 3)
      create(:case_stage, position: 7)
      create(:case_stage, position: 6)
    end

    it 'returns set ordered by position' do
      expect(set.map(&:position)).to eql([3, 6, 7])
    end
  end
end
