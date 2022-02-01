require 'rails_helper'

RSpec.describe AccountSetter do
  subject(:instance) { described_class.new(emails) }

  let(:emails) { [email] }
  let(:email) { 'test@example.com' }
  let(:user) { create(:user, id: 99, email: 'test@example.com', password: 'testing123') }

  before { allow($stdout).to receive(:puts) }

  describe '#report' do
    subject(:report) { instance.report }

    let(:external_user) { create(:external_user, user: user, provider: create(:provider, name: 'Test provider')) }

    before { create_list(:claim, 5, external_user: external_user) }

    it 'reports on the user' do
      expect { report }.to output(
        /User test@example\.com with id 99 have 5 claims for their provider, "Test provider"/
      ).to_stdout
    end

    it { expect { report }.to output(/No deleted users found for email "test@example\.com\.deleted\..*"/).to_stdout }

    context 'with an unknown user' do
      let(:emails) { ['unknown@example.com'] }

      it { expect { report }.to output(/No users found for email unknown@example\.com/).to_stdout }
    end

    context 'with a deleted user' do
      before { user.persona.soft_delete }

      it 'reports on the deleted user' do
        expect { report }.to output(
          /User test@example\.com\.deleted\..* with id 99 have 5 claims for their provider, "Test provider"/
        ).to_stdout
      end

      it { expect { report }.to output(/No users found for email test@example\.com/).to_stdout }
    end
  end

  describe '#soft_delete' do
    subject(:soft_delete) { instance.soft_delete }

    before { create(:external_user, user: user) }

    it 'appends deleted to the email of the user' do
      expect { soft_delete }
        .to change { user.reload.email }
        .from('test@example.com')
        .to(/test@example\.com\.deleted\.\d*/)
    end

    it 'marks the user as deleted' do
      expect { soft_delete }
        .to change { user.reload.deleted_at }
        .from(nil)
        .to(an_instance_of(ActiveSupport::TimeWithZone))
    end

    it 'marks the persona of the user as deleted' do
      expect { soft_delete }
        .to change { user.reload.persona.deleted_at }
        .from(nil)
        .to(an_instance_of(ActiveSupport::TimeWithZone))
    end

    context 'with an unknown user' do
      let(:emails) { ['unknown@example.com'] }

      it { expect { soft_delete }.to output(/User with email unknown@example\.com not found/).to_stdout }
    end
  end

  describe '#un_soft_delete' do
    subject(:un_soft_delete) { instance.un_soft_delete }

    before do
      external_user = create(:external_user, user: user)
      external_user.soft_delete
    end

    it 'removes deleted from the email of the user' do
      expect { un_soft_delete }
        .to change { user.reload.email }
        .from(/test@example\.com\.deleted\.\d*/)
        .to('test@example.com')
    end

    it 'removes the deleted at timestamp of the user' do
      expect { un_soft_delete }
        .to change { user.reload.deleted_at }
        .from(an_instance_of(ActiveSupport::TimeWithZone))
        .to(nil)
    end

    it 'removes the deleted at timestamp of the persona of the user' do
      expect { un_soft_delete }
        .to change { user.reload.persona.deleted_at }
        .from(an_instance_of(ActiveSupport::TimeWithZone))
        .to(nil)
    end

    context 'with an unknown user' do
      let(:emails) { ['unknown@example.com'] }

      it { expect { un_soft_delete }.to output(/User email "unknown@example\.com\.delete\.%" not found/).to_stdout }
    end
  end

  describe '#change_password' do
    subject(:change_password) { instance.change_password }

    it 'changes the password of the user' do
      expect { change_password }.to change { user.reload.valid_password?('testing123') }.from(true).to(false)
    end

    context 'with an unknown user' do
      let(:emails) { ['unknown@example.com'] }

      it { expect { change_password }.to output(/User with email unknown@example\.com not found/).to_stdout }
    end
  end
end
