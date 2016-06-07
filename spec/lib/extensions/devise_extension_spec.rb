require 'rails_helper'

describe DeviseExtension do
  let(:example_class) { Class.new { extend DeviseExtension } }

  context '#override_paranoid_setting (original value being true)' do
    before { Devise.paranoid = true }

    it 'should override the setting and call the passed block' do
      expect(Devise.paranoid).to be_truthy

      expect(
        example_class.override_paranoid_setting(false) { Devise.paranoid }
      ).to be_falsey

      expect(Devise.paranoid).to be_truthy
    end
  end

  context '#override_paranoid_setting (original value being false)' do
    before { Devise.paranoid = false }

    it 'should override the setting and call the passed block' do
      expect(Devise.paranoid).to be_falsey

      expect(
        example_class.override_paranoid_setting(true) { Devise.paranoid }
      ).to be_truthy

      expect(Devise.paranoid).to be_falsey
    end
  end
end
