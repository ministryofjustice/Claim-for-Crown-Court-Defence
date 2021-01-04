require 'rails_helper'
require 'data_migrator/offence_code_generator'

RSpec.describe OffenceCodeGenerator do
  subject(:code_generator) { described_class.new(offence) }

  let(:offence_category) { create :offence_category, description: 'Murder/Manslaughter' }
  let(:offence_band) { create :offence_band, description: '1.1', offence_category: offence_category }

  describe '.code' do
    subject { code_generator.code }

    context 'when the offence is in' do
      context 'scheme nine' do
        let(:offence) { create(:offence, :with_fee_scheme, description: 'Murder', offence_class: create(:offence_class)) }

        it { is_expected.to match(/^MURDER_[A-K]$/) }
      end

      context 'scheme ten' do
        let(:offence) { create(:offence, :with_fee_scheme_ten, description: 'Murder', offence_band: offence_band) }

        it { is_expected.to eql 'MURDER_1.1' }
      end

      context 'scheme eleven' do
        let(:offence) { create(:offence, :with_fee_scheme_eleven, description: 'Murder', offence_band: offence_band) }

        it { is_expected.to eql 'MURDER_1.1~11' }
      end
    end
  end
end
