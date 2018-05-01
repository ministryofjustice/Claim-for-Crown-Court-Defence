RSpec.shared_examples 'common partial validations' do |steps|

  context 'partial validation' do
    context 'from web' do
      before do
        claim.source = 'web'
      end

      it 'validates fields just for the current step' do
        # NOTE: not very happy with what this is validating
        # Ideally should be matching exactly the fields to be validated
        # The current way only asserts that the provided fields are validated,
        # not that the other step fields aren't, so could leas to false positives.
        steps.each do |step_name, fields|
          claim.form_step = step_name
          fields.each do |field|
            expect_any_instance_of(described_class).to receive(:validate_field).with(field)
          end
          claim.valid?
        end
      end
    end

    context 'from API' do
      before do
        claim.source = 'api'
      end

      it 'validates all the attributes for all the steps' do
        steps.values.flatten.each do |attrib|
          expect_any_instance_of(described_class).to receive(:validate_field).with(attrib)
        end

        claim.valid?
      end
    end
  end
end

RSpec.shared_examples 'common partial association validations' do |steps|

  context 'partial validation' do
    before(:each) do
      claim.force_validation = true
    end

    context 'from web' do
      before do
        claim.source = 'web'
      end

      it 'validates has_one associations just for the current step' do
        # NOTE: not very happy with what this is validating
        # Ideally should be matching exactly the fields to be validated
        # The current way only asserts that the provided fields are validated,
        # not that the other step fields aren't, so could leas to false positives.
        steps[:has_one].each do |step_name, associations|
          claim.form_step = step_name
          associations.each do |association|
            expect_any_instance_of(described_class).to receive(:validate_association_for).with(claim, association)
          end
          claim.valid?
        end
      end

      it 'validates has_many associations just for the current step' do
        # NOTE: not very happy with what this is validating
        # Ideally should be matching exactly the fields to be validated
        # The current way only asserts that the provided fields are validated,
        # not that the other step fields aren't, so could leas to false positives.
        steps[:has_many].each do |step_name, associations|
          claim.form_step = step_name
          associations.each do |association|
            expect_any_instance_of(described_class).to receive(:validate_collection_for).with(claim, association)
          end
          claim.valid?
        end
      end
    end

    context 'from API' do
      before do
        claim.source = 'api'
      end

      it 'validates all the has_one associations for all the steps' do
        steps[:has_one].values.flatten.each do |association|
          expect_any_instance_of(described_class).to receive(:validate_association_for).with(claim, association)
        end

        claim.valid?
      end

      it 'validates all the has_many associations for all the steps' do
        steps[:has_many].values.flatten.each do |association|
          expect_any_instance_of(described_class).to receive(:validate_collection_for).with(claim, association)
        end

        claim.valid?
      end
    end
  end
end
