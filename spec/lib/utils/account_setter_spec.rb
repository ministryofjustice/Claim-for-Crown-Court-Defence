require 'rails_helper'

RSpec.describe Utils::AccountSetter do
  subject(:instance) { described_class.new(emails) }

  let(:emails) { [email] }
  let(:email) { 'test@example.com' }
  let(:user) { create(:user, id: 99, email: 'test@example.com', password: 'testing12345') }

  before { allow($stdout).to receive(:puts) }

  describe '#report' do
    subject(:report) { instance.report }

    let(:external_user) { create(:external_user, user:, provider: create(:provider, name: 'Test provider')) }

    before { create_list(:claim, 5, external_user:) }

    context 'with an existing user' do
      let(:expected_hash) do
        { email: 'test@example.com', found: true,
          id: 99, active: true, enabled: true,
          provider: 'Test provider', claims: 5 }
      end

      it { expect(report).to include(expected_hash) }
    end

    context 'with csv format' do
      subject(:report) { instance.report(format: 'csv') }

      it { expect(report).to include('email,found,id,active,enabled,provider,claims') }
      it { expect(report).to include('test@example.com,true,99,true,true,Test provider,5') }
    end

    context 'with a non-existant user' do
      let(:emails) { ['unknown@example.com'] }

      it { expect(report).to include({ email: 'unknown@example.com', found: false }) }
    end

    context 'with a deleted user' do
      before { user.persona.soft_delete }

      let(:expected_hash) do
        { email: 'test@example.com.deleted.99', found: true,
          id: 99, active: false, enabled: true,
          provider: 'Test provider', claims: 5 }
      end

      it { expect(report).to include(expected_hash) }
    end

    context 'with a disabled user' do
      before { user.disable }

      let(:expected_hash) do
        { email: 'test@example.com', found: true,
          id: 99, active: true, enabled: false,
          provider: 'Test provider', claims: 5 }
      end

      it { expect(report).to include(expected_hash) }
    end
  end

  describe '#soft_delete' do
    subject(:soft_delete) { instance.soft_delete }

    before { create(:external_user, user:) }

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
        .to(be_a(Time))
    end

    it 'marks the persona of the user as deleted' do
      expect { soft_delete }
        .to change { user.reload.persona.deleted_at }
        .from(nil)
        .to(be_a(Time))
    end

    context 'with an unknown user' do
      let(:emails) { ['unknown@example.com'] }

      it { expect { soft_delete }.to output(/User with email unknown@example\.com not found/).to_stdout }
    end
  end

  describe '#un_soft_delete' do
    subject(:un_soft_delete) { instance.un_soft_delete }

    before do
      external_user = create(:external_user, user:)
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
        .from(be_a(Time))
        .to(nil)
    end

    it 'removes the deleted at timestamp of the persona of the user' do
      expect { un_soft_delete }
        .to change { user.reload.persona.deleted_at }
        .from(be_a(Time))
        .to(nil)
    end

    context 'with an unknown user' do
      let(:emails) { ['unknown@example.com'] }

      it { expect { un_soft_delete }.to output(/User email "unknown@example\.com\.delete\.%" not found/).to_stdout }
    end
  end

  describe '#disable' do
    subject(:disable) { instance.disable }

    context 'with an enabled user' do
      let!(:user) { create(:user, email:, disabled_at: nil) }

      it 'marks the user as disabled' do
        expect { disable }.to change { user.reload.disabled_at }.from(nil).to(be_a(Time))
      end

      it { expect { disable }.to output(/User with email "test@example.com" disabled!/).to_stdout }
    end

    context 'with a disabled user' do
      let!(:user) { create(:user, email:, disabled_at: 1.minute.ago) }

      it { expect { disable }.not_to change { user.reload.disabled_at } }
      it { expect { disable }.to output(/Enabled user with email "test@example\.com" not found/).to_stdout }
    end

    context 'with an unknown user' do
      let(:emails) { ['unknown@example.com'] }

      it { expect { disable }.to output(/Enabled user with email "unknown@example\.com" not found/).to_stdout }
    end
  end

  describe '#enable' do
    subject(:enable) { instance.enable }

    context 'with a disabled user' do
      let!(:user) { create(:user, email:, disabled_at: 1.minute.ago) }

      it 'marks the user as enabled' do
        expect { enable }.to change { user.reload.disabled_at }.from(be_a(Time)).to(nil)
      end

      it { expect { enable }.to output(/User with email "test@example.com" enabled!/).to_stdout }
    end

    context 'with an enabled user' do
      let!(:user) { create(:user, email:, disabled_at: nil) }

      it { expect { enable }.not_to change { user.reload.disabled_at } }
      it { expect { enable }.to output(/Disabled user with email "test@example\.com" not found/).to_stdout }
    end

    context 'with an unknown user' do
      let(:emails) { ['unknown@example.com'] }

      it { expect { enable }.to output(/Disabled user with email "unknown@example\.com" not found/).to_stdout }
    end
  end

  describe '#change_password' do
    subject(:change_password) { instance.change_password }

    it 'changes the password of the user' do
      expect { change_password }.to change { user.reload.valid_password?('testing12345') }.from(true).to(false)
    end

    context 'with an unknown user' do
      let(:emails) { ['unknown@example.com'] }

      it { expect { change_password }.to output(/User with email unknown@example\.com not found/).to_stdout }
    end
  end
end
