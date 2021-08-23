RSpec.shared_examples 'a slack notifier formatter' do
  describe '#ready_to_send' do
    subject { formatter.ready_to_send }

    context 'when #build has not been called' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#build' do
    subject(:build) { formatter.build(**valid_build_parameters) }

    it { expect { build }.to change(formatter, :ready_to_send).to true }
  end
end
