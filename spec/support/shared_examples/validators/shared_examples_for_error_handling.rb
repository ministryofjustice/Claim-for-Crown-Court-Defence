# frozen_string_literal: true

RSpec.shared_context 'with associated error handler setup' do
  let(:association_name) { 'foos' }
  let(:record_num) { 0 }
  let(:error) { instance_double(ActiveModel::Error) }

  before { allow(error).to receive(:attribute).and_return('bar') }
end

RSpec.shared_examples 'a govuk design system associated error handler' do
  describe '#associated_error_attribute' do
    subject { validator.associated_error_attribute(association_name, record_num, error) }

    include_context 'with associated error handler setup'

    it { is_expected.to eql('foos_attributes_0_bar') }
  end
end

RSpec.shared_examples 'a custom CCCD associated error handler' do
  describe '#associated_error_attribute' do
    subject { validator.associated_error_attribute(association_name, record_num, error) }

    include_context 'with associated error handler setup'

    it { is_expected.to eql('foo_1_bar') }
  end
end
