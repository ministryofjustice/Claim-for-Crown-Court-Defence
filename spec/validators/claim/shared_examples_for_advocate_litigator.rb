RSpec.shared_examples 'common advocate litigator validations' do |external_user_type, options|
  context 'when validating external_user' do
    let(:expected_blank_message) do
      { advocate: 'Choose an advocate',
        litigator: 'Choose a litigator' }
    end

    it 'errors if not present, regardless' do
      claim.external_user = nil
      should_error_with(claim, :external_user_id, expected_blank_message[external_user_type])
    end

    it 'errors if does not belong to the same provider as the creator' do
      claim.creator = create(:external_user, external_user_type)
      claim.external_user = create(:external_user, external_user_type)
      should_error_with(claim, :external_user_id, "Creator and #{external_user_type} must belong to the same provider")
    end
  end

  context 'when validating creator' do
    it 'errors if not present, regardless' do
      claim.creator = nil
      should_error_with(claim, :creator, 'blank')
    end
  end

  unless options&.fetch(:case_type, nil) == false
    context 'case_type' do
      it 'errors if not present' do
        claim.case_type = nil
        should_error_with(claim, :case_type_id, 'Choose a case type')
      end
    end
  end

  context 'when validating court' do
    it 'errors if not present' do
      claim.court = nil
      should_error_with(claim, :court_id, 'Choose a court')
    end
  end

  context 'when validating transfer_court_id' do
    context 'with case_transferred_from_another_court not explictly set, but case number set' do
      before { claim.transfer_case_number = 'A20161234' }

      it 'errors if blank' do
        claim.transfer_court = nil
        should_error_with(claim, :transfer_court_id, 'Choose a transfer court')
      end

      it 'errors when the same as the original court' do
        claim.transfer_court = claim.court
        should_error_with(claim, :transfer_court_id, 'Choose a different transfer court')
      end
    end

    context 'with case transferred from another court set' do
      before do
        claim.case_transferred_from_another_court = true
      end

      it 'errors if blank' do
        claim.transfer_court = nil
        should_error_with(claim, :transfer_court_id, 'Choose a transfer court')
      end

      it 'errors when the same as the original court' do
        claim.transfer_court = claim.court
        should_error_with(claim, :transfer_court_id, 'Choose a different transfer court')
      end

      it 'valid when transfer court different to original court' do
        claim.transfer_court = build(:court)
        should_not_error(claim, :transfer_court_id)
      end
    end
  end

  context 'when validating transfer_case_number' do
    before { claim.transfer_court = FactoryBot.build(:court) }

    it 'does not error if blank' do
      claim.transfer_case_number = nil
      should_not_error(claim, :transfer_case_number)
    end

    it 'does not error if valid case_number' do
      claim.transfer_case_number = 'A20161234'
      should_not_error(claim, :transfer_case_number)
    end

    it 'does not error if valid URN' do
      claim.transfer_case_number = 'ABCDEFGHIJ1234567890'
      should_not_error(claim, :transfer_case_number)
    end

    it 'errors when format is similar to but invalid case number' do
      claim.transfer_case_number = 'A201612345'
      should_error_with(claim, :transfer_case_number, 'Invalid transfer case number')
    end

    it 'errors when format is invalid case number or urn' do
      claim.transfer_case_number = 'ABC_'
      should_error_with(claim, :transfer_case_number, 'Invalid transfer case number or urn')
    end

    context 'with case transferred from another court' do
      before do
        claim.case_transferred_from_another_court = true
      end

      context 'with transfer court not set' do
        before { claim.transfer_court = nil }

        context 'with transfer case number blank' do
          before { claim.transfer_case_number = '' }

          it 'does not contain errors on transfer case number' do
            should_not_error(claim, :transfer_case_number)
          end
        end

        context 'with transfer case number in invalid format' do
          before { claim.transfer_case_number = 'ABC_' }

          it 'contains an invalid error on transfer case number' do
            should_error_with(claim, :transfer_case_number, 'Invalid transfer case number or urn')
          end
        end
      end
    end
  end
end

RSpec.shared_examples 'common litigator validations' do |*flags|
  let(:advocate)      { build(:external_user, :advocate) }
  let(:offence)       { build(:offence) }
  let(:offence_class) { build(:offence_class, class_letter: 'X', description: 'Offences of dishonesty in Class F where the value in is in excess of £100,000') }
  let(:misc_offence)  { build(:offence, description: 'Miscellaneous/other', offence_class: offence_class) }

  context 'when validating creator and provider are in LGFS fee scheme' do
    it 'rejects creators whose provider is only agfs' do
      claim.creator = build(:external_user, provider: build(:provider, :agfs))
      expect(claim).not_to be_valid
      expect(claim.errors[:creator]).to eq(['must be from a provider with permission to submit LGFS claims'])
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

  unless ([:interim_claim, :hardship_claim] & flags).any?
    context 'when validating case_concluded_at date' do
      before { claim.force_validation = true }

      it 'is invalid when absent' do
        should_error_if_not_present(claim, :case_concluded_at, 'blank')
      end

      it 'is invalid when too far in past' do
        should_error_if_too_far_in_the_past(claim, :case_concluded_at, 'check_not_too_far_in_past')
      end

      it 'is invalid when in future' do
        should_error_if_in_future(claim, :case_concluded_at, 'check_not_in_future')
      end

      it 'is valid when present' do
        claim.case_concluded_at = 1.month.ago
        expect(claim).to be_valid
        expect(claim.errors.key?(:case_concluded_at)).to be false
      end
    end
  end

  context 'when validating external_user' do
    it 'errors when does not have advocate role' do
      claim.external_user = advocate
      should_error_with(claim, :external_user_id, 'must have litigator role')
    end

    it 'errors if not present, regardless' do
      claim.external_user = nil
      should_error_with(claim, :external_user_id, 'Choose a litigator')
    end

    it 'errors if does not belong to the same provider as the creator' do
      claim.creator = create(:external_user, :litigator)
      claim.external_user = create(:external_user, :litigator)
      should_error_with(claim, :external_user_id, 'Creator and litigator must belong to the same provider')
    end
  end

  context 'when validating creator' do
    it 'errors when their provider does not have LGFS role' do
      claim.creator = create(:external_user, :advocate)
      should_error_with(claim, :creator, 'must be from a provider with permission to submit LGFS claims')
    end
  end

  context 'when validating offence' do
    before do
      claim.form_step = :offence_details
      claim.offence = nil
    end

    unless ([:hardship_claim] & flags).any?
      it 'errors if NOT present for case type without fixed fees' do
        claim.case_type.is_fixed_fee = false
        should_error_with(claim, :offence, 'blank_class')
        claim.case_type.is_fixed_fee = true
        should_not_error(claim, :offence)
      end
    end

    it 'does not error if a Miscellaneous/other offence' do
      claim.offence = misc_offence
      expect(claim).to be_valid
    end
  end
end
