require 'rails_helper'

describe ExportedClaim do
  describe '#published?' do
    it 'returns false' do
      ec = build  :exported_claim, :enqueued
      expect(ec.published?).to be false
    end

    it 'returns true' do
      ec = build  :exported_claim, :published
      expect(ec.published?).to be true
    end
  end
end