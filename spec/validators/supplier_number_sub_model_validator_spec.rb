# frozen_string_literal: true

RSpec.describe SupplierNumberSubModelValidator, type: :validator do
  subject(:validator) { described_class.new }

  it_behaves_like 'a govuk design system associated error handler'

  describe '#has_many_association_names' do
    subject { validator.has_many_association_names }

    it { is_expected.to contain_exactly(:lgfs_supplier_numbers) }
  end

  describe '#validate' do
    subject(:validate) { validator.validate(record) }

    let(:record) { build(:provider, :lgfs) }

    context 'with an LGFS supplier number' do
      before { record.lgfs_supplier_numbers << build(:supplier_number) }

      specify { expect { validate }.not_to change(record.errors, :count) }
    end

    context 'without an LGFS supplier number' do
      specify { expect { validate }.to change(record.errors, :count).by(1) }

      specify do
        validate
        expect(record.errors.details).to eql({ base: [{ error: :blank_supplier_numbers }] })
      end

      specify do
        validate
        expect(record.errors.messages_for(:base)).to include('blank_supplier_numbers')
      end
    end
  end
end
