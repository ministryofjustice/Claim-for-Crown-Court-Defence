require 'rails_helper'

RSpec.describe DeviseMailer, type: :mailer do
  describe 'reset_password_instructions' do
    subject(:mail) { described_class.reset_password_instructions(external_user.user, 'fake_token', inviting_user.name) }

    before do
      allow(Settings.govuk_notify.templates).to receive(:new_user).and_return('ed2faf1c-0000-0000-0000-9c837f64a687')
      allow(Settings.govuk_notify.templates).to receive(:new_external_advocate_admin).and_return('ed2faf1c-0000-0000-0000-9c837f64a687')
      allow(Settings.govuk_notify.templates).to receive(:new_external_litigator_admin).and_return('e55cda8b-0000-0000-0000-08967a4edcb4')
      allow(Settings.govuk_notify.templates).to receive(:password_reset).and_return('b405712b-0000-0000-0000-77814eb62394')
      allow(Settings.govuk_notify.templates).to receive(:unlock_instructions).and_return('20878b17-0000-0000-0000-387523c6dffe')
    end

    let(:external_user) { create(:external_user, supplier_number: 'XX878', user: create(:user, last_name: 'Smith', first_name: 'John', email:'test@example.com')) }
    let(:inviting_user) { create(:external_user) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient' do
      expect(mail.to).to eq(['test@example.com'])
    end

    it 'sets the personalisation' do
      expect(mail.govuk_notify_personalisation.keys.sort).to eq([:edit_password_url, :invited_by_full_name, :password_reset_url, :token_expiry_days, :user_full_name])
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

    context 'when user is a new advocate admin ' do
      let(:external_user) { create(:external_user, :advocate_and_admin) }

      it 'sets the template' do
        expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.templates.new_external_advocate_admin)
      end
    end

    context 'when user is a new litigator admin ' do
      let(:external_user) { create(:external_user, :litigator_and_admin) }

      it 'sets the template' do
        expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.templates.new_external_litigator_admin)
      end
    end
  end
end
