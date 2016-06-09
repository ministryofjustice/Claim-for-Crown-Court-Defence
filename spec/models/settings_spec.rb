require 'rails_helper'

describe Settings do

  context 'litigator interim fees' do
    it 'should be OFF' do
      expect(Settings.allow_lgfs_interim_fees?).to be false
    end
  end

  context 'litigator transfer fees' do
    it 'should be OFF' do
      expect(Settings.allow_lgfs_transfer_fees?).to be false
    end
  end
end