# frozen_string_literal: true

RSpec.describe DefendantSubModelValidator, type: :validator do
  subject(:validator) { described_class.new }

  it_behaves_like 'a custom CCCD associated error handler'

  describe '#has_many_association_names' do
    subject { validator.has_many_association_names }

    it { is_expected.to contain_exactly(:representation_orders) }
  end
end
