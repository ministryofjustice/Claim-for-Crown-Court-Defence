RSpec.shared_examples 'user model with default, active and softly deleted scopes' do
  context 'with the active scope' do
    subject(:records) { described_class.active }

    it { is_expected.to match_array(live_users) }
    it { expect { records.find(dead_users.first.id) }.to raise_error ActiveRecord::RecordNotFound }
    it { expect(records.where(id: dead_users.map(&:id))).to be_empty }
  end

  context 'with the softly deleted scope' do
    subject(:records) { described_class.softly_deleted }

    it { is_expected.to match_array(dead_users) }
    it { expect { records.find(live_users.first.id) }.to raise_error ActiveRecord::RecordNotFound }
    it { expect(records.where(id: live_users.map(&:id))).to be_empty }
  end

  context 'with the default scope' do
    subject(:records) { described_class.all }

    it { is_expected.to match_array(live_users + dead_users) }
    it { expect(records.find(dead_users.first.id)).to eq dead_users.first }
    it { expect(records.where(id: dead_users.map(&:id))).to match_array(dead_users) }
  end
end
