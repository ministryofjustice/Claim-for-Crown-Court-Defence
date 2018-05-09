require 'rails_helper'

RSpec.describe CCR::AdvocateCategoryAdapter, type: :adapter do
  describe '.code_for' do
    subject { described_class.code_for(advocate_category) }

    ADVOCATE_CATEGORY_MAPPINGS = {
      'QC': 'QC',
      'Led junior': 'LEDJR',
      'Leading junior': 'LEADJR',
      'Junior alone': 'JRALONE',
      'Junior': 'JUNIOR'
    }.stringify_keys.freeze

    context 'mappings' do
      ADVOCATE_CATEGORY_MAPPINGS.each do |description, code|
        context "maps #{description}" do
          let(:advocate_category) { description }

          it "returns #{code}" do
            is_expected.to eql code
          end
        end
      end
    end
  end
end
