shared_examples "common litigator claim attributes" do

  it { should delegate_method(:provider_id).to(:creator) }

  describe '#vat_registered?' do
    it 'returns the value from the provider' do
      expect(claim.provider).to receive(:vat_registered?)
      claim.vat_registered?
    end
  end

  describe '#requires_cracked_dates?' do
    it 'should always return false' do
      expect(claim.requires_trial_dates?).to eql false
    end
  end
end