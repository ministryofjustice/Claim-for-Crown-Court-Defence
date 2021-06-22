shared_examples 'common litigator claim attributes' do |*flags|
  it { should delegate_method(:provider_id).to(:creator) }

  describe '#lgfs?' do
    it 'returns true' do
      expect(claim.lgfs?).to be true
    end
  end

  describe '#agfs?' do
    it 'returns false' do
      expect(claim.agfs?).to be false
    end
  end

  describe '#vat_registered?' do
    it 'returns the value from the provider' do
      expect(claim.provider).to receive(:vat_registered?)
      claim.vat_registered?
    end
  end

  describe '#requires_trial_dates?' do
    it 'always returns false' do
      skip('does not apply to this claim type') if ([:hardship_claim] & flags).any?
      expect(claim.requires_trial_dates?).to be false
    end
  end
end
