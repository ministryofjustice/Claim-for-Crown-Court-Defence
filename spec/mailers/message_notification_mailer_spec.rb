require "rails_helper"

RSpec.describe MessageNotificationMailer, type: :mailer do

  let(:claim) { create :claim, case_number: 'X76253311' }
  let(:mail) { described_class.notify_message(claim).deliver_now }

  describe '#notify_message' do

    it 'renders the subject' do
      expect(mail.subject).to eq 'You have messages on claim X76253311'
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([claim.creator.user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['noreply@digital.justice.gov.uk'])
    end

    it 'substitutes variables' do
      expect(mail.body.encoded).to match(claim.creator.user.name)
      expect(mail.body.encoded).to match(claim.case_number)
      expect(mail.body.encoded).to match(/http:\/\/localhost:3000\/external_users\/claims\/#{claim.id}\?messages=true/)
    end
  end
end
