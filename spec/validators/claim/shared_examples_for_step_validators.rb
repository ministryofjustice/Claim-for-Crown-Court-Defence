# NOTE: Ideally should be matching exactly the fields to be validated
# The current way only asserts that the provided fields are validated,
# not that the other step fields aren't, so could lead to false positives.
RSpec.shared_examples 'common partial validations' do |steps|
  let(:validator) { claim.class.validators.find { |v| v.is_a?(described_class) } }

  context 'partial validation' do
    before { allow(validator).to receive(:validate_field).with(anything) }

    context 'from web' do
      before { claim.source = 'web' }

      steps.each do |step_name, fields|
        fields.each do |field|
          it "validates #{field} just for the #{step_name} step" do
            claim.form_step = step_name

            claim.valid?

            expect(validator).to have_received(:validate_field).with(field)
          end
        end
      end
    end

    context 'from API' do
      before { claim.source = 'api' }

      it 'validates all the attributes for all the steps' do
        claim.valid?

        steps.values.flatten.tally.each do |attrib, count|
          expect(validator).to have_received(:validate_field).with(attrib).exactly(count).times
        end
      end
    end
  end
end

# NOTE: Ideally should be matching exactly the fields to be validated
# The current way only asserts that the provided associations are validated,
# not that the other step fields aren't, so could lead to false positives.
RSpec.shared_examples 'common partial association validations' do |steps|
  let(:validator) { claim.class.validators.find { |v| v.is_a?(described_class) } }

  context 'partial validation' do
    before do
      allow(validator).to receive(:validate_association_for).with(claim, anything)
      allow(validator).to receive(:validate_collection_for).with(claim, anything)
      allow(validator).to receive(:validate_presence).with(anything, anything)

      claim.force_validation = true
    end

    context 'from web' do
      before { claim.source = 'web' }

      steps[:has_one].each do |step_name, associations|
        associations.each do |association_data|
          association_name = association_data[:name]
          it "validates has_one association #{association_name} just for the #{step_name} step" do
            claim.form_step = step_name

            claim.valid?

            expect(validator).to have_received(:validate_association_for).with(claim, association_name)

            if association_data[:options] && association_data[:options][:presence]
              expect(validator).to have_received(:validate_presence).with(association_name, 'blank')
            end
          end
        end
      end

      steps[:has_many].each do |step_name, associations|
        associations.each do |association_data|
          association_name = association_data[:name]
          association_misc_fees = :misc_fees
          it "validates has_many association #{association_name} just for the #{step_name} step" do
            claim.form_step = step_name

            claim.valid?

            expect(validator).to have_received(:validate_collection_for).with(claim, association_name)
            if association_data[:options] && association_data[:options][:presence]
              if association_name == association_misc_fees
                expect(validator).to have_received(:validate_presence).with(association_name, :blank)
              else
                expect(validator).to have_received(:validate_presence).with(association_name, 'blank')
              end
            end
          end
        end
      end
    end

    context 'from API' do
      before { claim.source = 'api' }

      it 'validates all the has_one associations for all the steps' do
        claim.valid?

        steps[:has_one].values.flatten.each do |association_data|
          expect(validator).to have_received(:validate_association_for).with(claim, association_data[:name])
        end
      end

      it 'validates all the has_many associations for all the steps' do
        claim.valid?

        steps[:has_many].values.flatten.each do |association_data|
          expect(validator).to have_received(:validate_collection_for).with(claim, association_data[:name])
        end
      end
    end
  end
end
