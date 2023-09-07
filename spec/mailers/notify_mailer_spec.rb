require 'rails_helper'

RSpec.describe NotifyMailer do
  describe 'message_added_email' do
    let(:template) { '4240bf0e-0000-444e-9c30-0d1bb64a2fb4' }
    let(:mail) { described_class.message_added_email(claim) }
    let(:provider) { create(:provider, :agfs) }
    let(:external_user) { create(:external_user, provider:) }
    let(:creator_external_user) { create(:external_user, provider:) }
    let(:claim) { create(:advocate_final_claim) }

    before do
      claim.external_user = external_user
      claim.creator = creator_external_user
      claim.save!
      allow(Settings.govuk_notify.templates).to receive(:message_added_email).and_return(template)
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    context 'when setting recipient' do
      it 'uses claim creator\'s external user email address' do
        expect(mail.to).to eq([creator_external_user.email])
      end

      it 'does not use the claim\'s external user email address' do
        expect(mail.to).to_not eq([external_user.email])
      end
    end

    it 'sets the body' do
      expect(mail.body).to match("This is a GOV.UK Notify email with template #{template}")
    end

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq(template)
    end

    context 'when setting personalisation' do
      subject(:personalisation) { mail.govuk_notify_personalisation }

      it 'adds relevant attributes' do
        expect(personalisation.keys).to match_array %i[claim_case_number claim_url edit_user_url user_name]
      end

      it 'adds creators name' do
        expect(personalisation[:user_name]).to eql(creator_external_user.user.name)
      end

      it 'adds claim case number' do
        expect(personalisation[:claim_case_number]).to eql(claim.case_number)
      end

      it 'adds link to claim messages' do
        expect(personalisation[:claim_url]).to match(%r{.*/external_users/claims/#{claim.id}\?messages=true})
      end

      it 'adds link to edit creators profile' do
        expect(personalisation[:edit_user_url]).to match(%r{.*/external_users/admin/external_users/#{creator_external_user.id}/edit})
      end
    end
  end
end
