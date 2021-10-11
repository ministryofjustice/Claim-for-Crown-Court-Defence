require 'rails_helper'

RSpec.describe FeedbackForm do
  subject(:form) { described_class.new }

  describe '#name' do
    subject { form.name }

    it { is_expected.to eq :feedback }
  end

  describe '#id' do
    subject { form.id }

    it { is_expected.to eq 25_473_840 }
  end

  describe '#template' do
    subject(:template) { form.template }

    it { is_expected.to be_a Hash }
    it { expect(template.values).to all(be_instance_of(Hash)) }
  end
end
