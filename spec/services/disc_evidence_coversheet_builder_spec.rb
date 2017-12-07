require 'rails_helper'

RSpec.describe DiscEvidenceCoversheetBuilder do
  subject(:disc_evidence_coversheet) { described_class.new(claim) }
  let(:claim) { create :submitted_claim }

  describe '#export' do
    subject(:export) { disc_evidence_coversheet.export }
    it { is_expected.to be_a Tempfile }
  end
end
