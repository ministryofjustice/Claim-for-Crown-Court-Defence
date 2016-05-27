# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  persona_id             :integer
#  persona_type           :string
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string
#  last_name              :string
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#  unlock_token           :string
#

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should belong_to(:persona) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should have_many(:messages_sent).class_name('Message').with_foreign_key('sender_id') }
  it { should have_many(:user_message_statuses) }

  it { should delegate_method(:claims).to(:persona) }

  describe 'email "+" character validation' do
    subject { build(:user) }

    it 'is not valid with a "+" in the email address' do
      subject.email = 'user+1@example.com'
      subject.valid?
      expect(subject.errors.full_messages).to include('Email "+" not allowed in addresses')
    end
  end

  describe '#name' do
    subject { build(:user) }

    it 'returns the first and last names' do
      expect(subject.name).to eq("#{subject.first_name} #{subject.last_name}")
    end
  end
end
