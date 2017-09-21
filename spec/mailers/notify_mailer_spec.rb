require 'rails_helper'

RSpec.describe NotifyMailer, type: :mailer do

  describe 'message_added_email' do
    let(:template) { '4240bf0e-0000-444e-9c30-0d1bb64a2fb4' }

    let(:user) { instance_double(User, name: 'Test Name', email: 'test@example.com') }
    let(:external_user) { instance_double(ExternalUser, user: user) }
    let(:claim) { instance_double(Claim::BaseClaim, external_user: external_user, case_number: 'T201600001') }

    let(:mail) { described_class.message_added_email(claim) }

    before { allow(Settings.govuk_notify.templates).to receive(:message_added_email).and_return(template) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient' do
      expect(mail.to).to eq(['test@example.com'])
    end

    it 'sets the body' do
      expect(mail.body).to match("This is a GOV.UK Notify email with template #{template}")
    end

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq(template)
    end

    it 'sets the personalisation' do
      expect(mail.govuk_notify_personalisation.keys.sort).to eq([:claim_case_number, :claim_url, :edit_user_url, :user_name])
    end
  end
end
