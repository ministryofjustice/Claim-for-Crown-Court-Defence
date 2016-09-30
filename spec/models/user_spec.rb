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
#  settings               :text
#  deleted_at             :datetime
#  api_key                :uuid
#

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { should belong_to(:persona) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should have_many(:messages_sent).class_name('Message').with_foreign_key('sender_id') }
  it { should have_many(:user_message_statuses) }

  it { should delegate_method(:claims).to(:persona) }

  describe '#name' do
    it 'returns the first and last names' do
      expect(subject.name).to eq("#{subject.first_name} #{subject.last_name}")
    end
  end

  describe '#settings' do
    context 'without settings' do
      it 'returns an empty hash when there are no settings yet for the user' do
        expect(subject.settings).to eq({})
      end
    end

    context 'with settings' do
      subject { build(:user, :with_settings) }

      it 'returns a hash with the settings' do
        expect(subject.settings).to be_kind_of(Hash)
        expect(subject.settings.keys).not_to be_empty
      end
    end
  end

  describe '#setting?' do
    context 'without settings' do
      it 'returns nil if no default value provided' do
        expect(subject.setting?(:setting1)).to eq(nil)
      end

      it 'returns default value when provided' do
        expect(subject.setting?(:setting1, 'hello')).to eq('hello')
      end
    end

    context 'with settings' do
      subject { build(:user, :with_settings) }

      it 'returns the setting if found' do
        expect(subject.setting?(:setting1)).to eq('test1')
      end

      it 'returns nil if no default value provided and setting not found' do
        expect(subject.setting?(:setting123)).to eq(nil)
      end

      it 'returns default value when provided and setting not found' do
        expect(subject.setting?(:setting123, 'hello')).to eq('hello')
      end
    end
  end

  describe '#save_setting!' do
    it 'is an alias for save_settings!' do
      expect(subject.method(:save_setting!)).to eq(subject.method(:save_settings!))
    end
  end

  describe '#save_settings!' do
    context 'without previous settings' do
      before do
        expect(subject.settings).to eq({})
        subject.save_settings!(setting1: 'hello')
      end

      it 'save the setting' do
        expect(subject.settings).to eq({'setting1' => 'hello'})
      end
    end

    context 'with previous settings present' do
      subject { build(:user, :with_settings) }

      before do
        expect(subject.settings.keys).not_to be_empty
        subject.save_settings!(test123: 'blabla')
      end

      it 'creates and saves the setting if not already present' do
        expect(subject.settings.keys).to include('test123')
        expect(subject.settings[:test123]).to eq('blabla')
      end

      it 'updates and saves the setting if already present' do
        expect(subject.settings[:setting1]).to eq('test1')
        subject.save_settings!(setting1: 'blabla')
        expect(subject.settings[:setting1]).to eq('blabla')
      end

      it 'maintains the other settings' do
        expect(subject.settings.keys.sort).to eq(%w(setting1 setting2 test123))
      end
    end
  end

  context 'soft deletions' do
    before(:all) do
      @live_user_1 = create :user
      @live_user_2 = create :user
      @dead_user_1 = create :user, :softly_deleted
      @dead_user_2 = create :user, :softly_deleted
    end

    after(:all) { clean_database }

    describe 'active scope' do
      it 'should only return undeleted records' do
        expect(User.active.order(:id)).to eq([ @live_user_1, @live_user_2 ])
      end

      it 'should return ActiveRecord::RecordNotFound if find by id relates to a deleted record' do
        expect{
          User.active.find(@dead_user_1.id)
        }.to raise_error ActiveRecord::RecordNotFound, %Q{Couldn't find User with 'id'=#{@dead_user_1.id} [WHERE "users"."deleted_at" IS NULL]}
      end

      it 'returns an empty array if the selection criteria only reference deleted records' do
        expect(User.active.where(id: [@dead_user_1.id, @dead_user_2.id])).to be_empty
      end
    end

    describe 'deleted scope' do
      it 'should return only deleted records' do
        expect(User.softly_deleted.order(:id)).to eq([@dead_user_1, @dead_user_2])
      end

      it 'should return ActiveRecord::RecordNotFound if find by id relates to an undeleted record' do
        expect{
          User.softly_deleted.find(@live_user_1.id)
        }.to raise_error ActiveRecord::RecordNotFound, %Q{Couldn't find User with 'id'=#{@live_user_1.id} [WHERE "users"."deleted_at" IS NOT NULL]}
      end

      it 'returns an empty array if the selection criteria only reference live records' do
        expect(User.softly_deleted.where(id: [@live_user_1.id, @live_user_2.id])).to be_empty
      end
    end

    describe 'default scope' do
      it 'should return deleted and undeleted records' do
        expect(User.order(:id)).to eq([ @live_user_1, @live_user_2, @dead_user_1, @dead_user_2])
      end

      it 'should return the record if find by id relates to a deleted record' do
        expect(User.find(@dead_user_1.id)).to eq @dead_user_1
      end

      it 'returns the deleted records if the selection criteria reference only deleted records' do
        expect(User.where(id: [@dead_user_1.id, @dead_user_2.id]).order(:id)).to eq([@dead_user_1, @dead_user_2])
      end
    end
  end

  describe '#email_with_name' do
    it 'returns name and email' do
      user = build(:user, first_name: 'Winston', last_name: 'Churchill', email: 'winnie@pm.example.com')
      expect(user.email_with_name).to eq 'Winston Churchill <winnie@pm.example.com>'
    end
  end
end
