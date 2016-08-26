require 'rails_helper'

RSpec.describe NotifyMailer, type: :mailer do

  describe 'new_message_test_email' do
    let(:template) { '9661d08a-486d-4c67-865e-ad976f17871d' }

    let(:user) { instance_double(User, name: 'Test Name', email: 'test@example.com') }
    let(:external_user) { instance_double(ExternalUser, user: user) }
    let(:claim) { instance_double(Claim::BaseClaim, external_user: external_user) }

    let(:mail) { described_class.new_message_test_email(claim) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient' do
      expect(mail.to).to eq(['test@example.com'])
    end

    it 'sets the subject' do
      expect(mail.body).to match("This is a GOV.UK Notify email with template #{template}")
    end

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq(template)
    end

    it 'sets the personalisation' do
      expect(mail.govuk_notify_personalisation.keys.sort).to eq([:full_name, :messages_url])
    end
  end

end
