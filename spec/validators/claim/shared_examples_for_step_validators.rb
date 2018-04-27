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
    let(:step1_has_one) { steps[:has_one][0] }
    let(:step2_has_one) { steps[:has_one][1] }
    let(:step3_has_one) { steps[:has_one][2] || [] }

    let(:step1_has_many) { steps[:has_many][0] }
    let(:step2_has_many) { steps[:has_many][1] }
    let(:step3_has_many) { steps[:has_many][2] || [] }

    before(:each) do
      claim.force_validation = true
    end

    context 'from web' do
      before do
        claim.source = 'web'
      end

      context 'first step' do
        before do
          claim.form_step = claim.submission_stages.first
        end

        it 'should validate has_one associations for this step' do
          step1_has_one.each do |association|
            expect_any_instance_of(described_class).to receive(:validate_association_for).with(claim, association)
          end

          step2_has_one.each do |association|
            expect_any_instance_of(described_class).not_to receive(:validate_association_for).with(claim, association)
          end

          claim.valid?
        end

        it 'should validate has_many associations for this step' do
          step1_has_many.each do |association|
            expect_any_instance_of(described_class).to receive(:validate_collection_for).with(claim, association)
          end

          step2_has_many.each do |association|
            expect_any_instance_of(described_class).not_to receive(:validate_collection_for).with(claim, association)
          end

          claim.valid?
        end
      end

      context 'second step' do
        before do
          claim.form_step = claim.submission_stages.second
        end

        it 'should validate has_one associations for this step and previous steps' do
          (step1_has_one + step2_has_one).each do |association|
            expect_any_instance_of(described_class).to receive(:validate_association_for).with(claim, association)
          end

          claim.valid?
        end

        it 'should validate has_many associations for this step and previous steps' do
          (step1_has_many + step2_has_many).each do |association|
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

      it 'should validate all the has_one associations for all the steps' do
        (step1_has_one + step2_has_one).each do |association|
          expect_any_instance_of(described_class).to receive(:validate_association_for).with(claim, association)
        end

        claim.valid?
      end

      it 'should validate all the has_many associations for all the steps' do
        steps[:has_many].flatten.each do |association|
          expect_any_instance_of(described_class).to receive(:validate_collection_for).with(claim, association)
        end

        claim.valid?
      end
    end
  end
end
