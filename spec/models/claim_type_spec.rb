# frozen_string_literal: true

RSpec.describe ClaimType do
  let(:instance) { described_class.new(id:) }
  let(:id) { 'agfs' }
  let(:valid_ids) do
    %w[agfs
       agfs_interim
       agfs_supplementary
       agfs_hardship
       lgfs_final
       lgfs_interim
       lgfs_transfer
       lgfs_hardship]
  end

  describe '.valid_ids' do
    subject(:collection) { described_class.valid_ids }

    it { is_expected.to match_array(valid_ids) }
  end

  describe '#id' do
    it { expect(instance.id).to be_a(String) }
    it { is_expected.to validate_presence_of(:id).with_message('Choose a bill type') }
    it { is_expected.to validate_inclusion_of(:id).in_array(valid_ids).with_message('Choose a valid bill type') }
  end
end
