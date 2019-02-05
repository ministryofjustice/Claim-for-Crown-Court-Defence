RSpec.shared_examples 'a claim presenter' do

  describe '#requires_interim_claim_info?' do
    specify { expect(presenter.requires_interim_claim_info?).to be_falsey }
  end
end
