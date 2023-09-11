RSpec.shared_examples 'delegates missing methods to case type' do |*delegated_methods|
  context 'when methods missing' do
    delegated_methods.each do |delegated_method|
      before do
        allow(case_stage.case_type).to receive(delegated_method.to_sym).and_return 'received'
      end

      it "delegates #{delegated_method} to case_type" do
        expect(case_stage.send(delegated_method.to_sym)).to eql('received')
      end
    end
  end
end

RSpec.describe CaseStage do
  subject(:case_stage) { create(:case_stage) }

  it { is_expected.to belong_to(:case_type) }

  include_examples 'delegates missing methods to case type',
                   :requires_trial_dates?,
                   :requires_retrial_dates?,
                   :requires_cracked_dates?,
                   :is_fixed_fee?

  it_behaves_like 'roles', CaseStage, CaseStage::ROLES

  it { is_expected.to respond_to(:case_type_id, :case_type, :unique_code, :description, :position, :roles, :agfs?, :lgfs?) }

  describe '#unique_code' do
    it { is_expected.to validate_presence_of(:unique_code).with_message('Case stage unique_code must exist') }
    it { is_expected.to validate_uniqueness_of(:unique_code).ignoring_case_sensitivity.with_message('Case stage unique_code must be unique') }
  end

  describe '#description' do
    it { is_expected.to validate_presence_of(:description).with_message('Case stage description must exist') }
  end

  describe '#case_type' do
    it { expect(case_stage.case_type).to be_a CaseType }
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
