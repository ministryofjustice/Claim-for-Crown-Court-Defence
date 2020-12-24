# frozen_string_literal: true

RSpec.describe Rule::Struct, type: :rule do
  subject(:instance) { described_class.new(:myattribute, :equal, 1, options) }
  let(:options) { {} }

  it {
    is_expected.to respond_to(:attribute,
                              :rule_method,
                              :bound,
                              :options)
  }

  describe '#message' do
    subject(:message) { described_class.new(:myattribute, :equal, 1, options).message }

    context 'with message option provided' do
      let(:options) { { message: 'my custom message' } }

      it { is_expected.to eq 'my custom message' }
    end

    context 'with no message option provided' do
      it { is_expected.to eq 'myattribute is invalid' }
    end
  end
end
