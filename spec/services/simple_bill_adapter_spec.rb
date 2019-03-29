RSpec.describe SimpleBillAdapter do
  it { expect(described_class).to respond_to :acts_as_simple_bill }

  context 'Subclasses' do
    class MockSimpleBillAdapter < described_class
      acts_as_simple_bill bill_type: 'MY_BILL_TYPE', bill_subtype: 'MY_BILL_SUBTYPE'
    end

    describe MockSimpleBillAdapter do
      let(:instance) { MockSimpleBillAdapter.new(nil) }

      describe '.bill_type' do
        subject { described_class.bill_type }
        it { is_expected.to eql 'MY_BILL_TYPE' }
      end

      describe '.bill_subtype' do
        subject { described_class.bill_subtype }
        it { is_expected.to eql 'MY_BILL_SUBTYPE' }
      end

      describe '#bill_type' do
        subject { instance.bill_type }
        it { is_expected.to eql 'MY_BILL_TYPE' }
      end

      describe '#bill_subtype' do
        subject { instance.bill_subtype }
        it { is_expected.to eql 'MY_BILL_SUBTYPE' }
      end
    end
  end
end
