shared_examples "common advocate litigator validations" do |external_user_type|

  context 'external_user' do
    it 'should error if not present, regardless' do
      claim.external_user = nil
      should_error_with(claim, :external_user, "blank_#{external_user_type}")
    end

    it 'should error if does not belong to the same provider as the creator' do
      claim.creator = create(:external_user, external_user_type)
      claim.external_user = create(:external_user, external_user_type)
      should_error_with(claim, :external_user, "Creator and #{external_user_type} must belong to the same provider")
    end
  end

  context 'creator' do
    it 'should error if not present, regardless' do
      claim.creator = nil
      should_error_with(claim, :creator, "blank")
    end
  end

  context 'case_type' do
    it 'should error if not present' do
      claim.case_type = nil
      should_error_with(claim, :case_type, "blank")
    end
  end

  context 'court' do
    it 'should error if not present' do
      claim.court = nil
      should_error_with(claim, :court, 'blank')
    end
  end
end


shared_examples "common litigator validations" do

  let(:advocate)      { build(:external_user, :advocate) }
  let(:offence)       { build(:offence) }
  let(:offence_class) { build(:offence_class, class_letter: 'X', description: 'Offences of dishonesty in Class F where the value in is in excess of £100,000') }
  let(:misc_offence)  { create(:offence, description: 'Miscellaneous/other', offence_class: offence_class) }

  describe 'validate creator provider is in LGFS fee scheme' do
    it 'rejects creators whose provider is only agfs' do
      claim.creator = build(:external_user, provider: build(:provider, :agfs))
      expect(claim).not_to be_valid
      expect(claim.errors[:creator]).to eq(["must be from a provider with permission to submit LGFS claims"])
    end

    it 'accepts creators whose provider is only lgfs' do
      claim.creator = create(:external_user, :litigator, provider: build(:provider, :lgfs))
      claim.external_user = claim.creator
      claim.valid?
      expect(claim.errors.key?(:creator)).to be_falsey
      expect(claim.errors.key?(:external_user)).to be_falsey
    end

    it 'accepts creators whose provider is both agfs and lgfs' do
      claim.creator = create(:external_user, :litigator, provider: build(:provider, :agfs_lgfs))
      claim.external_user = claim.creator
      claim.valid?
      expect(claim.errors.key?(:creator)).to be_falsey
      expect(claim.errors.key?(:external_user)).to be_falsey
    end
  end

  context 'case concluded at date' do
    let(:claim) { build :litigator_claim }
    before(:each) { claim.force_validation = true }

    it 'is invalid when absent' do
      claim.case_concluded_at = nil
      claim.valid?
      expect(claim.errors[:case_concluded_at]).to eq(['blank'])
    end

    it 'is valid when present' do
      claim.case_concluded_at = 1.month.ago
      expect(claim).to be_valid
      expect(claim.errors.key?(:case_concluded_at)).to be false
    end
  end

  context 'external_user' do
    it 'should error when does not have advocate role' do
      claim.external_user = advocate
      should_error_with(claim, :external_user, "must have litigator role")
    end

    it 'should error if not present, regardless' do
      claim.external_user = nil
      should_error_with(claim, :external_user, "blank_litigator")
    end

    it 'should error if does not belong to the same provider as the creator' do
      claim.creator = create(:external_user, :litigator)
      claim.external_user = create(:external_user, :litigator)
      should_error_with(claim, :external_user, "Creator and litigator must belong to the same provider")
    end
  end

  context 'creator' do
    it 'should error when their provider does not have LGFS role' do
      claim.creator = create(:external_user, :advocate)
      should_error_with(claim, :creator, "must be from a provider with permission to submit LGFS claims")
    end
  end

  context 'supplier_number' do
    it 'should error when the supplier number is not valid for litigators' do
      claim.supplier_number = 'XP312'
      should_error_with(claim, :supplier_number, 'invalid')
    end

    it 'should error when the supplier number doesn\'t belong to the provider' do
      claim.supplier_number = '2A267M'
      should_error_with(claim, :supplier_number, 'unknown')
    end
  end

  context 'advocate_category' do
    it 'should be absent' do
      claim.advocate_category = 'QC'
      should_error_with(claim, :advocate_category, "invalid")
      claim.advocate_category = nil
      expect(claim).to be_valid
    end
  end

  context 'offence' do
    before { claim.offence = nil }

    it 'should error if NOT present for any case type' do
      claim.case_type.is_fixed_fee = false
      should_error_with(claim, :offence, 'blank_class')
      claim.case_type.is_fixed_fee = true
      should_error_with(claim, :offence, 'blank_class')
    end

    it 'should error if NOT a Miscellaneous/other offence' do
      claim.offence = offence
      should_error_with(claim, :offence, 'invalid_class')
    end

    it 'should NOT error if a Miscellaneous/other offence' do
      claim.offence = misc_offence
      expect(claim).to be_valid
    end
  end
end
