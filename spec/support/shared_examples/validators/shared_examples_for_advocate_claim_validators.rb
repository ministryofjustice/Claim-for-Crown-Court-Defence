RSpec.shared_examples 'advocate category validations' do |options|
  let(:claim) { create(options[:factory]) }

  before do
    claim.form_step = options[:form_step]
  end

  default_valid_categories = ['QC', 'Led junior', 'Leading junior', 'Junior alone']
  fee_reform_valid_categories = ['QC', 'Leading junior', 'Junior']
  fee_reform_invalid_categories = default_valid_categories - fee_reform_valid_categories
  all_valid_categories = (default_valid_categories + fee_reform_valid_categories).uniq

  it 'should error if not present' do
    claim.advocate_category = nil
    should_error_with(claim, :advocate_category, 'blank')
  end

  it 'should error if not in the available list' do
    claim.advocate_category = 'not-a-QC'
    should_error_with(claim, :advocate_category, "Advocate category must be one of those in the provided list")
  end

  context 'when on a pre fee reform scheme' do
    let(:claim) { create(options[:factory], :agfs_scheme_9) }

    default_valid_categories.each do |valid_entry|
      it "should not error if '#{valid_entry}' specified" do
        claim.advocate_category = valid_entry
        should_not_error(claim, :advocate_category)
      end
    end
  end

  context 'when on fee reform scheme' do
    let(:claim) { create(options[:factory], :agfs_scheme_10) }

    fee_reform_valid_categories.each do |category|
      it "should not error if '#{category}' specified" do
        claim.advocate_category = category
        should_not_error(claim, :advocate_category)
      end
    end

    fee_reform_invalid_categories.each do |category|
      it "should error if '#{category}' specified" do
        claim.advocate_category = category
        should_error_with(claim, :advocate_category, "Advocate category must be one of those in the provided list")
      end
    end
  end
end

RSpec.shared_examples 'advocate claim external user role' do
  let(:litigator) { create(:external_user, :litigator) }

  context 'external_user' do
    it 'should error when does not have advocate role' do
      claim.external_user = litigator
      should_error_with(claim, :external_user, "must have advocate role")
    end
  end
end

  RSpec.shared_examples 'advocate claim case concluded at' do
    context 'case concluded at date' do
      it 'is valid when absent' do
        expect(claim.case_concluded_at).to be_nil
        claim.valid?
        expect(claim.errors.key?(:case_concluded_at)).to be false
      end

      it 'is invalid when present' do
        claim.case_concluded_at = 1.month.ago
        expect(claim).not_to be_valid
        expect(claim.errors[:case_concluded_at]).to eq([ 'present' ])
      end
    end
  end

RSpec.shared_examples 'advocate claim creator role' do
  let(:litigator) { create(:external_user, :litigator) }

  context 'creator' do
    before { claim.creator = litigator }

    it 'should error when their provider does not have AGFS role' do
      should_error_with(claim, :creator, "must be from a provider with permission to submit AGFS claims")
    end

    context 'when validation has been overridden' do
      before { claim.disable_for_state_transition = :all }

      it { expect(claim.valid?).to be true }
    end
  end
end

RSpec.shared_examples 'advocate claim supplier number' do
  context 'supplier_number' do
      # NOTE: In reality supplier number is derived from external_user which in turn is validated in any event
      let(:advocate) { build(:external_user, :advocate, supplier_number: '9G606X') }

      it 'should error when the supplier number does not match pattern' do
        claim.external_user = advocate
        should_error_with(claim, :supplier_number, 'invalid')
      end
    end
  end
