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
      should_error_with(claim, :court, 'blank' )
    end
  end

end
