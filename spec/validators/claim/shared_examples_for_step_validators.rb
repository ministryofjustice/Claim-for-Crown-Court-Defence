shared_examples 'common partial validations' do |steps|

  context 'partial validation' do
    let(:step1_attributes) { steps[0] }
    let(:step2_attributes) { steps[1] }
    let(:step3_attributes) { steps[2] || [] }

    context 'from web' do
      before do
        claim.source = 'web'
      end

      context 'step 1' do
        before do
          claim.form_step = 1
        end

        it 'should validate only attributes for this step' do
          step1_attributes.each do |attrib|
            expect_any_instance_of(described_class).to receive(:validate_field).with(attrib)
          end

          step2_attributes.each do |attrib|
            expect_any_instance_of(described_class).not_to receive(:validate_field).with(attrib)
          end

          claim.valid?
        end
      end

      context 'step 2' do
        before do
          claim.form_step = 2
        end

        it 'should validate attributes for this step and previous steps' do
          (step1_attributes + step2_attributes).each do |attrib|
            expect_any_instance_of(described_class).to receive(:validate_field).with(attrib)
          end

          claim.valid?
        end
      end
    end

    context 'from API' do
      before do
        claim.source = 'api'
      end

      it 'should validate all the attributes for all the steps' do
        steps.flatten.each do |attrib|
          expect_any_instance_of(described_class).to receive(:validate_field).with(attrib)
        end

        claim.valid?
      end
    end
  end
end

shared_examples 'common partial association validations' do |steps|

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

      context 'step 1' do
        before do
          claim.form_step = 1
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

      context 'step 2' do
        before do
          claim.form_step = 2
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
        (step1_has_many + step2_has_many + step3_has_many).each do |association|
          expect_any_instance_of(described_class).to receive(:validate_collection_for).with(claim, association)
        end

        claim.valid?
      end
    end
  end
end
