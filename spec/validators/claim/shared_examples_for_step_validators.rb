# NOTE: Ideally should be matching exactly the fields to be validated
# The current way only asserts that the provided fields are validated,
# not that the other step fields aren't, so could lead to false positives.
RSpec.shared_examples 'common partial validations' do |steps|
  let(:validator) do
    claim.class.validators.find { |v| v.is_a?(described_class) }
  end

  context 'partial validation' do
    context 'from web' do
      before do
        claim.source = 'web'
        steps.each_value do |fields|
          fields.each do |field|
            (fields - [field]).each do |other_field|
              allow(validator).to receive(:validate_field).with(other_field)
            end
          end
        end
      end

      steps.each do |step_name, fields|
        fields.each do |field|
          it "validates #{field} just for the #{step_name} step" do
            claim.form_step = step_name
            expect(validator).to receive(:validate_field).with(field)
            claim.valid?
          end
        end
      end
    end

    context 'from API' do
      before do
        claim.source = 'api'
      end

      it 'validates all the attributes for all the steps' do
        steps.values.flatten.each do |attrib|
          expect(validator).to receive(:validate_field).with(attrib)
        end

        claim.valid?
      end
    end
  end
end

# NOTE: Ideally should be matching exactly the fields to be validated
# The current way only asserts that the provided associations are validated,
# not that the other step fields aren't, so could lead to false positives.
RSpec.shared_examples 'common partial association validations' do |steps|
  let(:validator) do
    claim.class.validators.find { |v| v.is_a?(described_class) }
  end

  context 'partial validation' do
    before do
      claim.force_validation = true
    end

    context 'from web' do
      before do
        claim.source = 'web'
        steps[:has_one].each_value do |associations|
          associations.each do |association_data|
            (associations - [association_data]).each do |other_association|
              allow(validator).to receive(:validate_association_for).with(claim, other_association[:name])
            end
          end
        end
      end

      steps[:has_one].each do |step_name, associations|
        associations.each do |association_data|
          association_name = association_data[:name]
          it "validates has_one association #{association_name} just for the #{step_name} step" do
            claim.form_step = step_name
            expect(validator).to receive(:validate_association_for).with(claim, association_name)

            if association_data[:options] && association_data[:options][:presence]
              expect(validator).to receive(:validate_presence).with(association_name, 'blank')
            end

            claim.valid?
          end
        end
      end

      steps[:has_many].each do |step_name, associations|
        associations.each do |association_data|
          association_name = association_data[:name]
          association_misc_fees = :misc_fees
          it "validates has_many association #{association_name} just for the #{step_name} step" do
            claim.form_step = step_name
            expect(validator).to receive(:validate_collection_for).with(claim, association_name)
            if association_data[:options] && association_data[:options][:presence]
              if association_name == association_misc_fees
                expect(validator).to receive(:validate_presence).with(association_name, :blank)
              else
                expect(validator).to receive(:validate_presence).with(association_name, 'blank')
              end
            end

            claim.valid?
          end
        end
      end
    end

    context 'from API' do
      before do
        claim.source = 'api'
      end

      it 'validates all the has_one associations for all the steps' do
        steps[:has_one].values.flatten.each do |association_data|
          expect(validator).to receive(:validate_association_for).with(claim, association_data[:name])
        end

        claim.valid?
      end

      it 'validates all the has_many associations for all the steps' do
        steps[:has_many].values.flatten.each do |association_data|
          expect(validator).to receive(:validate_collection_for).with(claim, association_data[:name])
        end

        claim.valid?
      end
    end
  end
end
