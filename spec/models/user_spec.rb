# frozen_string_literal: true

RSpec.describe User do
  subject(:user) { create(:user) }

  it { is_expected.to validate_presence_of(:first_name).with_message('Enter a first name') }
  it { is_expected.to validate_presence_of(:last_name).with_message('Enter a last name') }
  it { is_expected.to validate_length_of(:first_name).is_at_most(40).with_message('First name must be 40 characters or less') }
  it { is_expected.to validate_length_of(:last_name).is_at_most(40).with_message('Last name must be 40 characters or less') }
  it { is_expected.to validate_length_of(:email).is_at_most(80).with_message('Email must be 80 characters or less') }
  it { is_expected.to allow_value('email@addresse.foo').for(:email) }
  it { is_expected.not_to allow_value('foo').for(:email) }
  it { is_expected.to validate_length_of(:password).is_at_least(8).with_message('Password must be at least 8 characters') }

  context 'with terms_and_conditions_required: false' do
    before { user.terms_and_conditions_required = false }

    it { is_expected.not_to validate_acceptance_of(:terms_and_conditions) }
  end

  context 'with terms_and_conditions_required: true' do
    before { user.terms_and_conditions_required = true }

    context 'when creating' do
      it do
        expect(user).to validate_acceptance_of(:terms_and_conditions)
          .on(:create)
          .with_message('You must accept the terms and conditions')
      end
    end

    context 'when updating' do
      it do
        expect(user).not_to validate_acceptance_of(:terms_and_conditions)
          .on(:update)
      end
    end
  end

  it { should belong_to(:persona) }
  it { should have_many(:messages_sent).class_name('Message').with_foreign_key('sender_id') }
  it { should have_many(:user_message_statuses) }

  it { should delegate_method(:claims).to(:persona) }

  it_behaves_like 'a disablable object'

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
        expect(subject.settings).to be_a(Hash)
        expect(subject.settings.keys).not_to be_empty
      end
    end
  end

  describe '#setting?' do
    context 'without settings' do
      it 'returns nil if no default value provided' do
        expect(subject.setting?(:setting1)).to be_nil
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
        expect(subject.setting?(:setting123)).to be_nil
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
        expect(subject.settings).to eq({ 'setting1' => 'hello' })
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

  describe '#case_worker?' do
    let(:user) { build(:user, persona_type:) }

    subject { user.case_worker? }

    context 'when the persona is NOT a case worker' do
      let(:persona_type) { 'ExternalUser' }

      it { is_expected.to be_falsey }
    end

    context 'when the persona is a case worker' do
      let(:persona_type) { 'CaseWorker' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#external_user?' do
    let(:user) { build(:user, persona_type:) }

    subject { user.external_user? }

    context 'when the persona is NOT an external user' do
      let(:persona_type) { 'CaseWorker' }

      it { is_expected.to be_falsey }
    end

    context 'when the persona is an external user' do
      let(:persona_type) { 'ExternalUser' }

      it { is_expected.to be_falsey }
    end
  end

  it_behaves_like 'user model with default, active and softly deleted scopes' do
    let(:live_users) { create_list(:user, 2) }
    let(:dead_users) { create_list(:user, 2, :softly_deleted) }
  end

  describe '#soft_delete' do
    subject(:soft_delete) { user.soft_delete }

    let(:user) { create(:user, id: 999, email: 'john.smith@example.com') }

    it { expect { soft_delete }.to change(user, :email).from('john.smith@example.com').to('john.smith@example.com.deleted.999') }
  end

  describe '#email_with_name' do
    it 'returns name and email' do
      user = build(:user, first_name: 'Winston', last_name: 'Churchill', email: 'winnie@pm.example.com')
      expect(user.email_with_name).to eq 'Winston Churchill <winnie@pm.example.com>'
    end
  end

  context 'devise messages' do
    let(:active_user) { build(:user) }
    let(:inactive_user) { build(:user, :softly_deleted) }
    let(:disabled_user) { build(:user, :disabled) }

    describe '#inactive_message' do
      it 'returns :inactive for active user' do
        expect(active_user.inactive_message).to eq :inactive
      end

      it 'returns specialised message for softly deleted users' do
        expect(inactive_user.inactive_message).to eq 'Invalid Email or password.'
      end

      it 'returns specialised message for disabled users' do
        expect(disabled_user.inactive_message).to eq 'Invalid Email or password.'
      end
    end

    describe 'unauthenticated_message' do
      it 'calls override paranoid setting' do
        expect(active_user).to receive(:override_paranoid_setting).with(false)
        active_user.unauthenticated_message
      end
    end
  end

  describe '#active_for_authentication?' do
    subject { user.active_for_authentication? }

    context 'with an active enabled user' do
      let(:user) { build(:user, deleted_at: nil, disabled_at: nil) }

      it { is_expected.to be_truthy }
    end

    context 'with an active disabled user' do
      let(:user) { build(:user, deleted_at: nil, disabled_at: Time.zone.now) }

      it { is_expected.to be_falsey }
    end

    context 'with an inactive enabled user' do
      let(:user) { build(:user, deleted_at: Time.zone.now, disabled_at: nil) }

      it { is_expected.to be_falsey }
    end

    context 'with an inactive disabled user' do
      let(:user) { build(:user, deleted_at: Time.zone.now, disabled_at: Time.zone.now) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#inactive_message' do
    subject { user.inactive_message }

    context 'with active enabled user' do
      let(:user) { build(:user, deleted_at: nil, disabled_at: nil) }

      it { is_expected.to eq :inactive }
    end

    context 'with active disabled user' do
      let(:user) { build(:user, deleted_at: nil, disabled_at: Time.zone.now) }

      it { is_expected.to eq 'Invalid Email or password.' }
    end

    context 'with inactive enabled user' do
      let(:user) { build(:user, deleted_at: Time.zone.now, disabled_at: nil) }

      it { is_expected.to eq 'Invalid Email or password.' }
    end

    context 'with an inactive disabled user' do
      let(:user) { build(:user, deleted_at: Time.zone.now, disabled_at: Time.zone.now) }

      it { is_expected.to eq 'Invalid Email or password.' }
    end
  end

  describe '#send_devise_notification' do
    include ActiveJob::TestHelper

    subject(:send) { user.send_devise_notification(:unlock_instructions, :an_arg) }

    it { expect { send }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1) }
    it { expect { send }.to have_enqueued_job(ActionMailer::MailDeliveryJob) }
  end
end
