RSpec.describe Schedule::DocumentCleaner do
  subject(:generator) { described_class.new }

  describe '#perform' do
    subject(:perform) { generator.perform }

    let(:cleaner) { instance_double(DocumentCleaner) }

    before do
      allow(DocumentCleaner).to receive(:new).and_return(cleaner)
      allow(cleaner).to receive(:clean!)
    end

    it do
      perform
      expect(cleaner).to have_received(:clean!)
    end
  end
end
