require 'rails_helper'

module Stats
  describe MIData do
    subject { described_class.new }

    it { is_expected.to be_a Stats::MIData }

    it { expect(subject.attributes.size).to eq 53 }

    it { expect(subject).to_not respond_to :import }

    describe '.import' do
      subject(:import) { described_class.import(claim) }

      let(:claim) { create :archived_pending_delete_claim }
      it { is_expected.to be true }
      it { expect { import }.to change { Stats::MIData.count }.by 1 }
    end
  end
end
