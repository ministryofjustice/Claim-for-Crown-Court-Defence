require 'rails_helper'

RSpec.describe DeviseMailer do
  before do
    allow(Settings.govuk_notify.templates).to receive_messages(
      new_user: '11111111-0000-0000-0000-111111111111',
      new_external_admin: '22222222-0000-0000-0000-222222222222',
      new_external_advocate_admin: '33333333-0000-0000-0000-333333333333',
      new_external_litigator_admin: '44444444-0000-0000-0000-444444444444',
      password_reset: '55555555-0000-0000-0000-555555555555',
      unlock_instructions: '66666666-0000-0000-0000-666666666666'
    )
  end

  describe 'reset_password_instructions' do
    subject(:mail) { described_class.reset_password_instructions(external_user.user, 'fake_token', inviting_user.name) }

    let(:external_user) do
      create(
        :external_user,
        supplier_number: 'XX878',
        user: create(:user, last_name: 'Smith', first_name: 'John', email: 'test@example.com')
      )
    end
    let(:inviting_user) { create(:external_user) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient' do
      expect(mail.to).to eq(['test@example.com'])
    end

    it 'sets the personalisation' do
      expect(mail.govuk_notify_personalisation.keys.sort).to eq(%i[edit_password_url invited_by_full_name password_reset_url token_expiry_days user_full_name])
    end

    context 'when user is not new' do
      let(:external_user) { create(:external_user, user: create(:user, sign_in_count: 1)) }

      it 'sets the template' do
        expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.templates.password_reset)
      end
    end

    context 'when user is new' do
      let(:external_user) { create(:external_user) }

      it 'sets the template' do
        expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.templates.new_user)
      end
    end

    context 'when user is only an admin' do
      let(:external_user) { create(:external_user, :admin) }

      it 'sets the template' do
        expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.templates.new_external_admin)
      end
    end

    context 'when user is a new advocate admin' do
      let(:external_user) { create(:external_user, :advocate_and_admin) }

      it 'sets the template' do
        expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.templates.new_external_advocate_admin)
      end
    end

    context 'when user is a new litigator admin' do
      let(:external_user) { create(:external_user, :litigator_and_admin) }

      it 'sets the template' do
        expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.templates.new_external_litigator_admin)
      end
    end
  end

  describe 'unlock_instructions' do
    subject(:mail) { described_class.unlock_instructions(external_user.user, 'fake_token') }

    let(:external_user) { create(:external_user, supplier_number: 'XX878', user: create(:user, last_name: 'Smith', first_name: 'John', email: 'test@example.com')) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient' do
      expect(mail.to).to eq(['test@example.com'])
    end

    it 'sets the personalisation' do
      expect(mail.govuk_notify_personalisation.keys.sort).to eq(%i[unlock_url user_full_name])
    end
  end
end
